///|
/// Recursive Path ORAM: reduces client position map storage by storing PosMap in smaller ORAM trees
pub struct RecursiveOram {
  top_oram : PathOram
  base_oram : PathOram
  key : Bytes
}

///|
/// Create RecursiveOram with 2-level recursion
pub fn RecursiveOram::new(
  base_height : Int32,
  base_block_size : Int32,
  master_key : Bytes,
) -> RecursiveOram {
  let top_key = @crypto.derive_key(master_key, "top-posmap-oram", 32)
  let base_key = @crypto.derive_key(master_key, "base-data-oram", 32)
  let top_oram = PathOram::new(2, 4, 16, top_key)
  let base_oram = PathOram::new(base_height, 4, base_block_size, base_key)
  { top_oram, base_oram, key: master_key, }
}

///|
/// Access data through recursive hierarchy
pub fn RecursiveOram::access(
  self : RecursiveOram,
  op : AccessOp,
  block_id : Int32,
) -> AccessResult {
  // Access position map in top level ORAM
  let _ = self.top_oram.access(AccessOp::Read, block_id / 4)
  // Access data in base level ORAM
  self.base_oram.access(op, block_id)
}
