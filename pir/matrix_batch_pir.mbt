///|
/// Multi-Server Block Matrix PIR Query Packet
pub struct MatrixPirPacket {
  server_id : Int
  row_masks : Array[FixedArray[Bool]]
} derive(Debug)

///|
/// Create new MatrixPirPacket
pub fn MatrixPirPacket::new(
  server_id : Int,
  row_masks : Array[FixedArray[Bool]],
) -> MatrixPirPacket {
  { server_id, row_masks }
}

///|
/// Matrix Batch PIR Client for 2 servers
pub struct MatrixBatchPirClient {
  matrix : VectorPirMatrix
  seed : Bytes
}

///|
/// Create new MatrixBatchPirClient
pub fn MatrixBatchPirClient::new(
  rows : Int,
  cols : Int,
  record_size : Int,
  seed : Bytes,
) -> MatrixBatchPirClient {
  let matrix = VectorPirMatrix::new(rows, cols, record_size)
  { matrix, seed }
}

///|
/// Generate multi-server query packets for a batch of target rows
pub fn MatrixBatchPirClient::generate_batch_query(
  self : MatrixBatchPirClient,
  target_rows : Array[Int],
) -> (MatrixPirPacket, MatrixPirPacket) {
  let prg = @crypto.Prg::new(self.seed)
  let s1_masks : Array[FixedArray[Bool]] = []
  let s2_masks : Array[FixedArray[Bool]] = []

  for t = 0; t < target_rows.length(); t = t + 1 {
    let target = target_rows[t]
    let q1 : FixedArray[Bool] = FixedArray::make(self.matrix.rows, false)
    let q2 : FixedArray[Bool] = FixedArray::make(self.matrix.rows, false)

    for r = 0; r < self.matrix.rows; r = r + 1 {
      let b = (prg.next_uint().reinterpret_as_int() & 1) == 1
      q1[r] = b
      q2[r] = if r == target { !b } else { b }
    }
    s1_masks.push(q1)
    s2_masks.push(q2)
  }

  (MatrixPirPacket::new(1, s1_masks), MatrixPirPacket::new(2, s2_masks))
}
