///|
/// Encrypted Range Index using Hierarchical Prefix Encoding
pub struct RangeIndex {
  client : ForwardSecureClient
  server : ForwardSecureServer
  field_name : String
  max_value : Int
}

///|
/// Create new RangeIndex
pub fn RangeIndex::new(
  master_key : Bytes,
  field_name : String,
  max_value : Int,
) -> RangeIndex {
  let client = ForwardSecureClient::new(master_key)
  let server = ForwardSecureServer::new()
  { client, server, field_name, max_value }
}

///|
/// Generate hierarchical prefix tokens for integer value
fn generate_prefixes(val : Int, max_val : Int) -> Array[String] {
  let prefixes : Array[String] = []
  let mut cur_val = val
  let mut cur_max = max_val
  let mut level = 0
  while cur_max > 0 {
    prefixes.push("pfx_" + level.to_string() + "_" + cur_val.to_string())
    cur_val = cur_val / 2
    cur_max = cur_max / 2
    level = level + 1
  }
  prefixes
}

///|
/// Insert a numerical record with hierarchical prefix indices
pub fn RangeIndex::insert(self : RangeIndex, doc_id : Int, value : Int) -> Unit {
  let prefixes = generate_prefixes(value, self.max_value)
  for i in 0..<prefixes.length() {
    let kw = self.field_name + ":" + prefixes[i]
    self.client.insert(self.server, kw, doc_id)
  }
}

///|
/// Range query [min_val, max_val] by expanding prefix terms
pub fn RangeIndex::search_range(
  self : RangeIndex,
  min_val : Int,
  max_val : Int,
) -> SearchResult {
  let matching_docs : Map[Int, Bool] = Map([])
  for v = min_val; v <= max_val; v = v + 1 {
    let exact_kw = self.field_name + ":pfx_0_" + v.to_string()
    let res = self.client.search(self.server, exact_kw)
    for i in 0..<res.doc_ids.length() {
      matching_docs[res.doc_ids[i]] = true
    }
  }

  let final_docs : Array[Int] = []
  let final_scores : Array[Int] = []
  for doc, _ in matching_docs {
    final_docs.push(doc)
    final_scores.push(100)
  }
  SearchResult::new(final_docs, final_scores)
}
