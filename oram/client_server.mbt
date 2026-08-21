///|
/// Oblivious storage access trace record for security audit
pub struct AccessTrace {
  op_type : String
  path_nodes : Array[Int]
} derive(Debug)

///|
/// Client-Server Oblivious Storage Protocol Simulator
pub struct ObliviousProtocolSimulator {
  engine : TreeOramEngine
  traces : Array[AccessTrace]
}

///|
/// Create new simulator
pub fn ObliviousProtocolSimulator::new(
  height_l : Int,
  block_size : Int,
  key : Bytes,
) -> ObliviousProtocolSimulator {
  let engine = TreeOramEngine::new(height_l, block_size, key)
  { engine, traces: [] }
}

///|
/// Perform traced access and record server-side observable pattern
pub fn ObliviousProtocolSimulator::traced_access(
  self : ObliviousProtocolSimulator,
  op_type : String,
  block_id : Int,
  data : Bytes?,
) -> AccessResult {
  let res = match data {
    Some(d) => self.engine.write(block_id, d)
    None => self.engine.read(block_id)
  }
  let path_nodes = get_path_indices(
    self.engine.path_oram.height_l,
    self.engine.path_oram.pos_map.get(block_id).unwrap(),
  )
  self.traces.push({ op_type, path_nodes })
  res
}

///|
/// Audit access trace to verify indistinguishability (every access accesses equal height paths)
pub fn ObliviousProtocolSimulator::audit_trace_security(
  self : ObliviousProtocolSimulator,
) -> Bool {
  if self.traces.length() == 0 {
    return true
  }
  let expected_len = self.engine.path_oram.height_l + 1
  for i in 0..<self.traces.length() {
    if self.traces[i].path_nodes.length() != expected_len {
      return false
    }
  }
  true
}
