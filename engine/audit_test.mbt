///|
test "leakage auditor" {
  let auditor = LeakageAuditor::new()
  auditor.observe_query("token_01")
  auditor.observe_query("token_02")
  auditor.observe_query("token_01")
  let profile = auditor.evaluate_leakage()
  assert_eq(profile.observed_query_count, 3)
  assert_eq(profile.distinct_query_count, 2)
  assert_eq(profile.repeated_query_count, 1)
}
