///|
/// Single ORAM Block
#derive(Debug)
pub struct Block {
  id : Int32
  data : Bytes
  is_dummy : Bool
}

///|
/// Create a real data block
pub fn Block::real(id : Int32, data : Bytes) -> Block {
  { id, data, is_dummy: false, }
}

///|
/// Create a dummy block
pub fn Block::dummy(data_len : Int32) -> Block {
  let buf : FixedArray[Byte] = FixedArray::make(data_len, b'\x00')
  { id: -1, data: Bytes::from_array(buf), is_dummy: true, }
}

///|
/// ORAM Bucket holding Z blocks
#derive(Debug)
pub struct Bucket {
  blocks : Array[Block]
}

///|
/// Create new empty Bucket with capacity Z
pub fn Bucket::new(capacity_z : Int32, data_len : Int32) -> Bucket {
  let blocks : Array[Block] = []
  for _ in 0..<capacity_z {
    blocks.push(Block::dummy(data_len))
  }
  { blocks, }
}

///|
/// Access operation type
#derive(Debug)
pub(all) enum AccessOp {
  Read
  Write(Bytes)
}

///|
/// Result of an oblivious memory access
#derive(Debug)
pub struct AccessResult {
  data : Bytes
  path_length : Int32
  stash_size_after : Int32
}

///|
/// Create new AccessResult
pub fn AccessResult::new(
  data : Bytes,
  path_length : Int32,
  stash_size_after : Int32,
) -> AccessResult {
  { data, path_length, stash_size_after, }
}

///|
pub extend AccessOp with @debug.Debug::{to_repr}

///|
pub extend AccessResult with @debug.Debug::{to_repr}

///|
pub extend Block with @debug.Debug::{to_repr}

///|
pub extend Bucket with @debug.Debug::{to_repr}
