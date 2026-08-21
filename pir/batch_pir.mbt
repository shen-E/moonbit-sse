///|
/// Batched Multi-Query PIR Coordinator
pub struct BatchPirCoordinator {
  it_client : ItPirClient
}

///|
/// Create new BatchPirCoordinator
pub fn BatchPirCoordinator::new(
  num_records : Int,
  record_size : Int,
  seed : Bytes,
) -> BatchPirCoordinator {
  let it_client = ItPirClient::new(num_records, record_size, seed)
  { it_client, }
}

///|
/// Batch retrieve multiple record indices in private parallel batches
pub fn BatchPirCoordinator::batch_retrieve(
  self : BatchPirCoordinator,
  db : DatabaseVector,
  target_indices : Array[Int],
) -> Array[Bytes] {
  let results : Array[Bytes] = []
  for i in 0..<target_indices.length() {
    let idx = target_indices[i]
    let query = self.it_client.generate_query(idx)
    let resp1 = it_pir_server_respond(db, query.q1)
    let resp2 = it_pir_server_respond(db, query.q2)
    let rec = self.it_client.reconstruct(resp1, resp2)
    results.push(rec)
  }
  results
}
