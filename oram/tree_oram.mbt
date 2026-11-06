///|
/// Deterministic Tree ORAM Node Eviction Strategy
pub struct TreeOramEngine {
  path_oram : PathOram
}

///|
/// Create new TreeOramEngine
pub fn TreeOramEngine::new(
  height_l : Int32,
  block_size : Int32,
  key : Bytes,
) -> TreeOramEngine {
  let path_oram = PathOram::new(height_l, 4, block_size, key)
  { path_oram, }
}

///|
/// Write block into oblivious storage
pub fn TreeOramEngine::write(
  self : TreeOramEngine,
  id : Int32,
  data : Bytes,
) -> AccessResult {
  self.path_oram.access(AccessOp::Write(data), id)
}

///|
/// Read block from oblivious storage
pub fn TreeOramEngine::read(self : TreeOramEngine, id : Int32) -> AccessResult {
  self.path_oram.access(AccessOp::Read, id)
}
