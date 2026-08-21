///|
/// Single posting entry representing a document reference
pub struct Posting {
  doc_id : Int
  score : Int
  op : Int
} derive(Debug)

///|
/// Create a new Posting
pub fn Posting::new(doc_id : Int, score : Int, op : Int) -> Posting {
  { doc_id, score, op }
}

///|
/// Encrypted inverted index entry stored on untrusted server
pub struct EncryptedEntry {
  addr : Bytes
  val : Bytes
  proof : Bytes
} derive(Debug)

///|
/// Create a new EncryptedEntry
pub fn EncryptedEntry::new(
  addr : Bytes,
  val : Bytes,
  proof : Bytes,
) -> EncryptedEntry {
  { addr, val, proof }
}

///|
/// Search query result summary
pub struct SearchResult {
  doc_ids : Array[Int]
  scores : Array[Int]
  num_matches : Int
} derive(Debug)

///|
/// Create a new SearchResult
pub fn SearchResult::new(
  doc_ids : Array[Int],
  scores : Array[Int],
) -> SearchResult {
  let num_matches = doc_ids.length()
  { doc_ids, scores, num_matches }
}

///|
/// Index statistics
pub struct IndexStats {
  total_keywords : Int
  total_entries : Int
  num_inserts : Int
  num_deletes : Int
} derive(Debug)

///|
/// Create a new IndexStats
pub fn IndexStats::new(
  total_keywords : Int,
  total_entries : Int,
  num_inserts : Int,
  num_deletes : Int,
) -> IndexStats {
  { total_keywords, total_entries, num_inserts, num_deletes }
}
