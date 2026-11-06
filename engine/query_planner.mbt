///|
/// Privacy Query Execution Strategy
#derive(Debug)
pub(all) enum QueryStrategy {
  SSE_InvertedIndex
  ORAM_Oblivious
  PIR_DirectVector
}

///|
/// Heuristic query execution plan.
#derive(Debug)
pub struct QueryPlan {
  strategy : QueryStrategy
  target_terms : Array[String]
  estimated_cost_ms : Int32
  privacy_level : String
}

///|
/// Create new QueryPlan
pub fn QueryPlan::new(
  strategy : QueryStrategy,
  target_terms : Array[String],
  estimated_cost_ms : Int32,
  privacy_level : String,
) -> QueryPlan {
  { strategy, target_terms, estimated_cost_ms, privacy_level, }
}

///|
/// Query optimizer exposing a simple strategy trade-off for the demo.
pub struct QueryOptimizer {
  high_security_mode : Bool
}

///|
/// Create new QueryOptimizer
pub fn QueryOptimizer::new(high_security_mode : Bool) -> QueryOptimizer {
  { high_security_mode, }
}

///|
/// Plan optimal execution strategy for input search terms
pub fn QueryOptimizer::plan(
  self : QueryOptimizer,
  terms : Array[String],
) -> QueryPlan {
  if self.high_security_mode {
    QueryPlan::new(
      QueryStrategy::ORAM_Oblivious,
      terms,
      15,
      "ORAM-trace-reference",
    )
  } else if terms.length() == 1 {
    QueryPlan::new(
      QueryStrategy::SSE_InvertedIndex,
      terms,
      2,
      "Dynamic-SSE-reference",
    )
  } else {
    QueryPlan::new(
      QueryStrategy::SSE_InvertedIndex,
      terms,
      4,
      "Conjunctive-Cross-Tag",
    )
  }
}

///|
pub extend QueryPlan with @debug.Debug::{to_repr}

///|
pub extend QueryStrategy with @debug.Debug::{to_repr}
