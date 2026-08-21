///|
test "leakage auditor" {
  let auditor = LeakageAuditor::new()
  auditor.observe_query("token_01")
  auditor.observe_query("token_02")
  let profile = auditor.evaluate_leakage()
  assert_true(profile.forward_secure_verified)
  assert_true(profile.backward_secure_verified)
}
