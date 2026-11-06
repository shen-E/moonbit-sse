///|
/// Path ORAM Implementation (Stefanov et al.)
pub struct PathOram {
  height_l : Int32
  num_leaves : Int32
  capacity_z : Int32
  block_size : Int32
  key : Bytes
  pos_map : Map[Int32, Int32]
  mut stash : Array[(Block, Int32)] // (block, assigned_leaf)
  tree : Array[Bucket] // Binary tree of buckets of size 2^(L+1) - 1
  prg : @crypto.Prg
}

///|
/// Initialize Path ORAM with height L, bucket size Z, and block size
pub fn PathOram::new(
  height_l : Int32,
  capacity_z : Int32,
  block_size : Int32,
  master_key : Bytes,
) -> PathOram {
  let mut num_leaves = 1
  for _ in 0..<height_l {
    num_leaves = num_leaves * 2
  }
  let total_buckets = num_leaves * 2 - 1
  let tree : Array[Bucket] = []
  for _ in 0..<total_buckets {
    tree.push(Bucket::new(capacity_z, block_size))
  }
  let prg = @crypto.Prg::new(master_key)
  {
    height_l,
    num_leaves,
    capacity_z,
    block_size,
    key: master_key,
    pos_map: Map([]),
    stash: [],
    tree,
    prg,
  }
}

///|
/// Get bucket indices along the path from root (0) to leaf
fn get_path_indices(height_l : Int32, leaf : Int32) -> Array[Int32] {
  let path : Array[Int32] = []
  let cur_leaf = leaf
  let num_leaves = 1 << height_l
  let mut node = num_leaves - 1 + cur_leaf
  for _ in 0..<=height_l {
    path.push(node)
    if node == 0 {
      break
    }
    node = (node - 1) / 2
  }
  // Reverse to get root-to-leaf order
  let reversed : Array[Int32] = []
  for i = path.length() - 1; i >= 0; i = i - 1 {
    reversed.push(path[i])
  }
  reversed
}

///|
/// Check if a node is an ancestor of a given leaf
fn is_node_on_path(height_l : Int32, node : Int32, leaf : Int32) -> Bool {
  let path = get_path_indices(height_l, leaf)
  for i in 0..<path.length() {
    if path[i] == node {
      return true
    }
  }
  false
}

///|
/// Perform oblivious access: Read or Write
pub fn PathOram::access(
  self : PathOram,
  op : AccessOp,
  block_id : Int32,
) -> AccessResult {
  let leaf = match self.pos_map.get(block_id) {
    Some(l) => l
    None => self.prg.next_int_range(0, self.num_leaves)
  }
  let new_leaf = self.prg.next_int_range(0, self.num_leaves)
  self.pos_map[block_id] = new_leaf

  // 1. Read entire path from root to leaf into stash
  let path_nodes = get_path_indices(self.height_l, leaf)
  for p in 0..<path_nodes.length() {
    let node_idx = path_nodes[p]
    let bucket = self.tree[node_idx]
    for b in 0..<bucket.blocks.length() {
      let blk = bucket.blocks[b]
      if !blk.is_dummy {
        let blk_leaf = match self.pos_map.get(blk.id) {
          Some(l) => l
          None => new_leaf
        }
        self.stash.push((blk, blk_leaf))
      }
    }
    // Clear bucket on server
    self.tree[node_idx] = Bucket::new(self.capacity_z, self.block_size)
  }

  // 2. Process requested operation
  let mut return_data = Bytes::from_array(
    FixedArray::make(self.block_size, b'\x00'),
  )
  let mut found_in_stash = false

  for i in 0..<self.stash.length() {
    let (blk, _) = self.stash[i]
    if blk.id == block_id {
      found_in_stash = true
      return_data = blk.data
      match op {
        Read => ()
        Write(new_data) => {
          self.stash[i] = (Block::real(block_id, new_data), new_leaf)
          return_data = new_data
        }
      }
      break
    }
  }

  if !found_in_stash {
    match op {
      Read => ()
      Write(new_data) => {
        self.stash.push((Block::real(block_id, new_data), new_leaf))
        return_data = new_data
      }
    }
  }

  // 3. Evict blocks from stash back to tree (greedy deepest first)
  for p = path_nodes.length() - 1; p >= 0; p = p - 1 {
    let node_idx = path_nodes[p]
    let new_bucket = Bucket::new(self.capacity_z, self.block_size)
    let mut placed_count = 0

    let remaining_stash : Array[(Block, Int32)] = []
    for s in 0..<self.stash.length() {
      let (blk, blk_leaf) = self.stash[s]
      if placed_count < self.capacity_z &&
        is_node_on_path(self.height_l, node_idx, blk_leaf) {
        new_bucket.blocks[placed_count] = blk
        placed_count = placed_count + 1
      } else {
        remaining_stash.push((blk, blk_leaf))
      }
    }
    self.stash = remaining_stash
    self.tree[node_idx] = new_bucket
  }

  AccessResult::new(return_data, path_nodes.length(), self.stash.length())
}
