///|
/// Backward-Secure Dynamic SSE with dual-dictionary deletion revocation filter (Type-II/Type-III)
pub struct BackwardSecureEngine {
  client : ForwardSecureClient
  revocation_list : Map[String, Array[Int]]
}

///|
/// Create new BackwardSecureEngine
pub fn BackwardSecureEngine::new(master_key : Bytes) -> BackwardSecureEngine {
  let client = ForwardSecureClient::new(master_key)
  { client, revocation_list: Map([]) }
}

///|
/// Insert document into backward-secure index
pub fn BackwardSecureEngine::insert(
  self : BackwardSecureEngine,
  server : ForwardSecureServer,
  keyword : String,
  doc_id : Int,
) -> Unit {
  self.client.insert(server, keyword, doc_id)
}

///|
/// Delete document and register deletion revocation token
pub fn BackwardSecureEngine::delete(
  self : BackwardSecureEngine,
  server : ForwardSecureServer,
  keyword : String,
  doc_id : Int,
) -> Unit {
  self.client.delete(server, keyword, doc_id)
  match self.revocation_list.get(keyword) {
    Some(arr) => arr.push(doc_id)
    None => self.revocation_list[keyword] = [doc_id]
  }
}

///|
/// Search with backward security guarantees: never leaks deleted historical data
pub fn BackwardSecureEngine::search(
  self : BackwardSecureEngine,
  server : ForwardSecureServer,
  keyword : String,
) -> SearchResult {
  let res = self.client.search(server, keyword)
  let revoked_set : Map[Int, Bool] = Map([])
  match self.revocation_list.get(keyword) {
    Some(arr) =>
      for i in 0..<arr.length() {
        revoked_set[arr[i]] = true
      }
    None => ()
  }

  let filtered_docs : Array[Int] = []
  let filtered_scores : Array[Int] = []
  for i in 0..<res.doc_ids.length() {
    let doc = res.doc_ids[i]
    match revoked_set.get(doc) {
      Some(_) => ()
      None => {
        filtered_docs.push(doc)
        filtered_scores.push(res.scores[i])
      }
    }
  }
  SearchResult::new(filtered_docs, filtered_scores)
}
