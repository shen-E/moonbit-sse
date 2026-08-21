///|
/// Conjunctive multi-keyword intersection search
pub fn search_conjunctive(
  client : ForwardSecureClient,
  server : ForwardSecureServer,
  keywords : Array[String],
) -> SearchResult {
  if keywords.length() == 0 {
    return SearchResult::new([], [])
  }

  let first_res = client.search(server, keywords[0])
  if first_res.doc_ids.length() == 0 {
    return first_res
  }

  let mut current_set : Map[Int, Int] = Map([])
  for i in 0..<first_res.doc_ids.length() {
    current_set[first_res.doc_ids[i]] = first_res.scores[i]
  }

  for k = 1; k < keywords.length(); k = k + 1 {
    let next_res = client.search(server, keywords[k])
    let next_map : Map[Int, Int] = Map([])
    for i in 0..<next_res.doc_ids.length() {
      let doc = next_res.doc_ids[i]
      match current_set.get(doc) {
        Some(old_score) => next_map[doc] = old_score + next_res.scores[i]
        None => ()
      }
    }
    current_set = next_map
  }

  let final_docs : Array[Int] = []
  let final_scores : Array[Int] = []
  for doc, score in current_set {
    final_docs.push(doc)
    final_scores.push(score)
  }
  SearchResult::new(final_docs, final_scores)
}

///|
/// Disjunctive multi-keyword union search (OR query)
pub fn search_disjunctive(
  client : ForwardSecureClient,
  server : ForwardSecureServer,
  keywords : Array[String],
) -> SearchResult {
  let doc_scores : Map[Int, Int] = Map([])

  for k in 0..<keywords.length() {
    let res = client.search(server, keywords[k])
    for i in 0..<res.doc_ids.length() {
      let doc = res.doc_ids[i]
      let score = res.scores[i]
      match doc_scores.get(doc) {
        Some(s) => doc_scores[doc] = s + score
        None => doc_scores[doc] = score
      }
    }
  }

  let final_docs : Array[Int] = []
  let final_scores : Array[Int] = []
  for doc, score in doc_scores {
    final_docs.push(doc)
    final_scores.push(score)
  }
  SearchResult::new(final_docs, final_scores)
}
