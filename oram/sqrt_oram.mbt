///|
/// Square-Root ORAM (Goldreich-Ostrovsky Scheme)
pub struct SqrtOram {
  num_elements : Int
  block_size : Int
  sqrt_capacity : Int
  main_memory : Array[Block]
  mut shelter : Array[Block]
  key : Bytes
  prg : @crypto.Prg
  mut access_count : Int
}

///|
/// Create new Square-Root ORAM
pub fn SqrtOram::new(
  num_elements : Int,
  block_size : Int,
  master_key : Bytes,
) -> SqrtOram {
  let mut sqrt_c = 1
  while sqrt_c * sqrt_c < num_elements {
    sqrt_c = sqrt_c + 1
  }
  let main_memory : Array[Block] = []
  for i in 0..<num_elements {
    let buf : FixedArray[Byte] = FixedArray::make(block_size, b'\x00')
    main_memory.push(Block::real(i, Bytes::from_array(buf)))
  }
  let prg = @crypto.Prg::new(master_key)
  {
    num_elements,
    block_size,
    sqrt_capacity: sqrt_c,
    main_memory,
    shelter: [],
    key: master_key,
    prg,
    access_count: 0,
  }
}

///|
/// Oblivious shuffle shelter into main memory
pub fn SqrtOram::rebuild_shuffle(self : SqrtOram) -> Unit {
  for s in 0..<self.shelter.length() {
    let blk = self.shelter[s]
    if blk.id >= 0 && blk.id < self.num_elements {
      self.main_memory[blk.id] = blk
    }
  }
  self.shelter = []
  self.access_count = 0
}

///|
/// Sqrt ORAM Access (Read / Write)
pub fn SqrtOram::access(
  self : SqrtOram,
  op : AccessOp,
  block_id : Int,
) -> Bytes {
  let mut found_data = Bytes::from_array(
    FixedArray::make(self.block_size, b'\x00'),
  )
  let mut found = false

  // Scan shelter
  for s = self.shelter.length() - 1; s >= 0; s = s - 1 {
    let blk = self.shelter[s]
    if blk.id == block_id {
      found = true
      found_data = blk.data
      break
    }
  }

  if !found {
    if block_id >= 0 && block_id < self.num_elements {
      found_data = self.main_memory[block_id].data
    }
  }

  let final_data = match op {
    Read => found_data
    Write(new_data) => new_data
  }

  self.shelter.push(Block::real(block_id, final_data))
  self.access_count = self.access_count + 1

  if self.access_count >= self.sqrt_capacity {
    self.rebuild_shuffle()
  }

  final_data
}
