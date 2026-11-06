///|
/// Boolean Query Expression AST
#derive(Debug)
pub(all) enum BoolQuery {
  Term(String)
  And(BoolQuery, BoolQuery)
  Or(BoolQuery, BoolQuery)
  Not(BoolQuery)
}

///|
/// Evaluate encrypted boolean expression over forward secure index
pub fn evaluate_bool_query(
  client : ForwardSecureClient,
  server : ForwardSecureServer,
  all_docs_universe : Array[Int32],
  query : BoolQuery,
) -> SearchResult {
  match query {
    Term(kw) => client.search(server, kw)
    And(q1, q2) => {
      let r1 = evaluate_bool_query(client, server, all_docs_universe, q1)
      let r2 = evaluate_bool_query(client, server, all_docs_universe, q2)
      let m2 : Map[Int32, Bool] = Map([])
      for i in 0..<r2.doc_ids.length() {
        m2[r2.doc_ids[i]] = true
      }
      let out_docs : Array[Int32] = []
      let out_scores : Array[Int32] = []
      for i in 0..<r1.doc_ids.length() {
        let doc = r1.doc_ids[i]
        match m2.get(doc) {
          Some(_) => {
            out_docs.push(doc)
            out_scores.push(r1.scores[i] + 50)
          }
          None => ()
        }
      }
      SearchResult::new(out_docs, out_scores)
    }
    Or(q1, q2) => {
      let r1 = evaluate_bool_query(client, server, all_docs_universe, q1)
      let r2 = evaluate_bool_query(client, server, all_docs_universe, q2)
      let score_map : Map[Int32, Int32] = Map([])
      for i in 0..<r1.doc_ids.length() {
        score_map[r1.doc_ids[i]] = r1.scores[i]
      }
      for i in 0..<r2.doc_ids.length() {
        let doc = r2.doc_ids[i]
        match score_map.get(doc) {
          Some(s) => score_map[doc] = s + r2.scores[i]
          None => score_map[doc] = r2.scores[i]
        }
      }
      let out_docs : Array[Int32] = []
      let out_scores : Array[Int32] = []
      for doc, score in score_map {
        out_docs.push(doc)
        out_scores.push(score)
      }
      SearchResult::new(out_docs, out_scores)
    }
    Not(q) => {
      let r = evaluate_bool_query(client, server, all_docs_universe, q)
      let match_map : Map[Int32, Bool] = Map([])
      for i in 0..<r.doc_ids.length() {
        match_map[r.doc_ids[i]] = true
      }
      let out_docs : Array[Int32] = []
      let out_scores : Array[Int32] = []
      for i in 0..<all_docs_universe.length() {
        let doc = all_docs_universe[i]
        match match_map.get(doc) {
          Some(_) => ()
          None => {
            out_docs.push(doc)
            out_scores.push(50)
          }
        }
      }
      SearchResult::new(out_docs, out_scores)
    }
  }
}

///|
pub extend BoolQuery with @debug.Debug::{to_repr}
