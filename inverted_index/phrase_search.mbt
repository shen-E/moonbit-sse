///|
/// Positional Posting for Exact Phrase Searching
#derive(Debug)
pub struct PositionalPosting {
  doc_id : Int32
  position : Int32
}

///|
/// Create new PositionalPosting
pub fn PositionalPosting::new(
  doc_id : Int32,
  position : Int32,
) -> PositionalPosting {
  { doc_id, position, }
}

///|
/// Positional Inverted Index for Encrypted Phrase Matching
pub struct PhraseIndexEngine {
  client : ForwardSecureClient
  server : ForwardSecureServer
}

///|
/// Create new PhraseIndexEngine
pub fn PhraseIndexEngine::new(master_key : Bytes) -> PhraseIndexEngine {
  let client = ForwardSecureClient::new(master_key)
  let server = ForwardSecureServer::new()
  { client, server, }
}

///|
/// Index word occurrence at specific position in doc
pub fn PhraseIndexEngine::index_position(
  self : PhraseIndexEngine,
  word : String,
  doc_id : Int32,
  position : Int32,
) -> Unit {
  let token_kw = word + "@pos:" + position.to_string()
  self.client.insert(self.server, token_kw, doc_id)
}

///|
/// Search consecutive two-word phrase (w1 at pos, w2 at pos+1)
pub fn PhraseIndexEngine::search_phrase(
  self : PhraseIndexEngine,
  word1 : String,
  word2 : String,
  max_positions : Int32,
) -> SearchResult {
  let matching_docs : Map[Int32, Bool] = Map([])

  for pos = 0; pos < max_positions; pos = pos + 1 {
    let kw1 = word1 + "@pos:" + pos.to_string()
    let kw2 = word2 + "@pos:" + (pos + 1).to_string()
    let conj = search_conjunctive(self.client, self.server, [kw1, kw2])
    for i in 0..<conj.doc_ids.length() {
      matching_docs[conj.doc_ids[i]] = true
    }
  }

  let out_docs : Array[Int32] = []
  let out_scores : Array[Int32] = []
  for doc, _ in matching_docs {
    out_docs.push(doc)
    out_scores.push(200)
  }
  SearchResult::new(out_docs, out_scores)
}

///|
pub extend PositionalPosting with @debug.Debug::{to_repr}
