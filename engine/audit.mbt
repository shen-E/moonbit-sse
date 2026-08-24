///|
/// Observed query-pattern summary.
pub struct LeakageProfile {
  observed_query_count : Int
  distinct_query_count : Int
  repeated_query_count : Int
} derive(Debug)

///|
/// Create a query-pattern summary.
pub fn LeakageProfile::new(
  observed_query_count : Int,
  distinct_query_count : Int,
  repeated_query_count : Int,
) -> LeakageProfile {
  { observed_query_count, distinct_query_count, repeated_query_count }
}

///|
/// Leakage Profile Auditor
pub struct LeakageAuditor {
  queries_observed : Map[String, Int]
}

///|
/// Create new LeakageAuditor
pub fn LeakageAuditor::new() -> LeakageAuditor {
  { queries_observed: Map([]) }
}

///|
/// Log observed search query token
pub fn LeakageAuditor::observe_query(
  self : LeakageAuditor,
  token_hex : String,
) -> Unit {
  let count = match self.queries_observed.get(token_hex) {
    Some(c) => c
    None => 0
  }
  self.queries_observed[token_hex] = count + 1
}

///|
/// Compute descriptive statistics from the observed query log.
///
/// These counters describe the local trace only; they are not a security
/// proof or an estimate of leakage against an adversary.
pub fn LeakageAuditor::evaluate_leakage(
  self : LeakageAuditor,
) -> LeakageProfile {
  let distinct = self.queries_observed.length()
  let mut observed = 0
  for _, count in self.queries_observed {
    observed += count
  }
  let repeated = if observed > distinct { observed - distinct } else { 0 }
  LeakageProfile::new(observed, distinct, repeated)
}
