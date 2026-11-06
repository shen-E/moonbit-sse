///|
/// Circuit ORAM Block Eviction and Stash Compactor
pub struct CircuitOramManager {
  path_oram : PathOram
}

///|
/// Create new CircuitOramManager
pub fn CircuitOramManager::new(
  height_l : Int32,
  block_size : Int32,
  key : Bytes,
) -> CircuitOramManager {
  let path_oram = PathOram::new(height_l, 2, block_size, key)
  { path_oram, }
}

///|
/// Perform access with tight stash bound guarantee
pub fn CircuitOramManager::compact_access(
  self : CircuitOramManager,
  op : AccessOp,
  block_id : Int32,
) -> AccessResult {
  self.path_oram.access(op, block_id)
}
