///|
/// Single posting entry representing a document reference
#derive(Debug)
pub struct Posting {
  doc_id : Int32
  score : Int32
  op : Int32
}

///|
/// Create a new Posting
pub fn Posting::new(doc_id : Int32, score : Int32, op : Int32) -> Posting {
  { doc_id, score, op, }
}

///|
/// Encrypted inverted index entry stored on untrusted server
#derive(Debug)
pub struct EncryptedEntry {
  addr : Bytes
  val : Bytes
  proof : Bytes
}

///|
/// Create a new EncryptedEntry
pub fn EncryptedEntry::new(
  addr : Bytes,
  val : Bytes,
  proof : Bytes,
) -> EncryptedEntry {
  { addr, val, proof, }
}

///|
/// Search query result summary
#derive(Debug)
pub struct SearchResult {
  doc_ids : Array[Int32]
  scores : Array[Int32]
  num_matches : Int32
}

///|
/// Create a new SearchResult
pub fn SearchResult::new(
  doc_ids : Array[Int32],
  scores : Array[Int32],
) -> SearchResult {
  let num_matches = doc_ids.length()
  { doc_ids, scores, num_matches, }
}

///|
/// Index statistics
#derive(Debug)
pub struct IndexStats {
  total_keywords : Int32
  total_entries : Int32
  num_inserts : Int32
  num_deletes : Int32
}

///|
/// Create a new IndexStats
pub fn IndexStats::new(
  total_keywords : Int32,
  total_entries : Int32,
  num_inserts : Int32,
  num_deletes : Int32,
) -> IndexStats {
  { total_keywords, total_entries, num_inserts, num_deletes, }
}

///|
pub extend EncryptedEntry with @debug.Debug::{to_repr}

///|
pub extend IndexStats with @debug.Debug::{to_repr}

///|
pub extend Posting with @debug.Debug::{to_repr}

///|
pub extend SearchResult with @debug.Debug::{to_repr}
