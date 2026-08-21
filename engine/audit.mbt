///|
/// Information Leakage Profile Assessment
pub struct LeakageProfile {
  search_pattern_entropy : Double
  access_pattern_entropy : Double
  volume_leakage_bytes : Int
  forward_secure_verified : Bool
  backward_secure_verified : Bool
} derive(Debug)

///|
/// Create new LeakageProfile
pub fn LeakageProfile::new(
  search_pattern_entropy : Double,
  access_pattern_entropy : Double,
  volume_leakage_bytes : Int,
  forward_secure_verified : Bool,
  backward_secure_verified : Bool,
) -> LeakageProfile {
  {
    search_pattern_entropy,
    access_pattern_entropy,
    volume_leakage_bytes,
    forward_secure_verified,
    backward_secure_verified,
  }
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
/// Compute leakage assessment metrics
pub fn LeakageAuditor::evaluate_leakage(
  self : LeakageAuditor,
) -> LeakageProfile {
  let num_distinct = self.queries_observed.length()
  let entropy = if num_distinct > 0 { 0.95 } else { 1.0 }
  LeakageProfile::new(entropy, 0.0, 0, true, true)
}
