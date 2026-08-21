///|
/// Privacy Query Execution Strategy
pub(all) enum QueryStrategy {
  SSE_InvertedIndex
  ORAM_Oblivious
  PIR_DirectVector
} derive(Debug)

///|
/// Optimized Query Execution Plan
pub struct QueryPlan {
  strategy : QueryStrategy
  target_terms : Array[String]
  estimated_cost_ms : Int
  privacy_level : String
} derive(Debug)

///|
/// Create new QueryPlan
pub fn QueryPlan::new(
  strategy : QueryStrategy,
  target_terms : Array[String],
  estimated_cost_ms : Int,
  privacy_level : String,
) -> QueryPlan {
  { strategy, target_terms, estimated_cost_ms, privacy_level }
}

///|
/// Query Optimizer determining optimal trade-off between speed and access pattern leakage
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
      "Full-Oblivious-Zero-Leakage",
    )
  } else if terms.length() == 1 {
    QueryPlan::new(
      QueryStrategy::SSE_InvertedIndex,
      terms,
      2,
      "Forward-Backward-Secure",
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
