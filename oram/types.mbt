///|
/// Single ORAM Block
pub struct Block {
  id : Int
  data : Bytes
  is_dummy : Bool
} derive(Debug)

///|
/// Create a real data block
pub fn Block::real(id : Int, data : Bytes) -> Block {
  { id, data, is_dummy: false }
}

///|
/// Create a dummy block
pub fn Block::dummy(data_len : Int) -> Block {
  let buf : FixedArray[Byte] = FixedArray::make(data_len, b'\x00')
  { id: -1, data: Bytes::from_array(buf), is_dummy: true }
}

///|
/// ORAM Bucket holding Z blocks
pub struct Bucket {
  blocks : Array[Block]
} derive(Debug)

///|
/// Create new empty Bucket with capacity Z
pub fn Bucket::new(capacity_z : Int, data_len : Int) -> Bucket {
  let blocks : Array[Block] = []
  for _ in 0..<capacity_z {
    blocks.push(Block::dummy(data_len))
  }
  { blocks, }
}

///|
/// Access operation type
pub(all) enum AccessOp {
  Read
  Write(Bytes)
} derive(Debug)

///|
/// Result of an oblivious memory access
pub struct AccessResult {
  data : Bytes
  path_length : Int
  stash_size_after : Int
} derive(Debug)

///|
/// Create new AccessResult
pub fn AccessResult::new(
  data : Bytes,
  path_length : Int,
  stash_size_after : Int,
) -> AccessResult {
  { data, path_length, stash_size_after }
}
