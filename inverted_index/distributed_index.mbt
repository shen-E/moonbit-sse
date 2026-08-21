///|
/// Distributed Partition Shard
pub struct IndexShard {
  shard_id : Int
  server : ForwardSecureServer
}

///|
/// Multi-Partition Distributed SSE Coordinator
pub struct DistributedIndexCoordinator {
  shards : Array[IndexShard]
  client : ForwardSecureClient
  num_shards : Int
}

///|
/// Create new DistributedIndexCoordinator
pub fn DistributedIndexCoordinator::new(
  master_key : Bytes,
  num_shards : Int,
) -> DistributedIndexCoordinator {
  let client = ForwardSecureClient::new(master_key)
  let shards : Array[IndexShard] = []
  for i in 0..<num_shards {
    shards.push({ shard_id: i, server: ForwardSecureServer::new() })
  }
  { shards, client, num_shards }
}

///|
/// Determine shard for document id
fn get_shard_id(num_shards : Int, doc_id : Int) -> Int {
  let mut s = doc_id % num_shards
  if s < 0 {
    s = s + num_shards
  }
  s
}

///|
/// Insert record into target partition
pub fn DistributedIndexCoordinator::insert(
  self : DistributedIndexCoordinator,
  keyword : String,
  doc_id : Int,
) -> Unit {
  let s_id = get_shard_id(self.num_shards, doc_id)
  self.client.insert(self.shards[s_id].server, keyword, doc_id)
}

///|
/// Query all partitions in parallel and aggregate results
pub fn DistributedIndexCoordinator::search_distributed(
  self : DistributedIndexCoordinator,
  keyword : String,
) -> SearchResult {
  let aggregated_docs : Array[Int] = []
  let aggregated_scores : Array[Int] = []

  for s = 0; s < self.num_shards; s = s + 1 {
    let res = self.client.search(self.shards[s].server, keyword)
    for i in 0..<res.doc_ids.length() {
      aggregated_docs.push(res.doc_ids[i])
      aggregated_scores.push(res.scores[i])
    }
  }

  SearchResult::new(aggregated_docs, aggregated_scores)
}
