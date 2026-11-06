///|
test "hierarchical scoped trapdoors" {
  let master_key = @crypto.hex_to_bytes(
    "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
  )
  let gen = @trapdoor.TrapdoorGenerator::new(master_key)
  let hier = @trapdoor.HierarchicalTrapdoor::new(gen, "enterprise")

  let t1 = hier.derive_scoped_token(["finance", "audit"], "q3_report", 1U)
  let t2 = hier.derive_scoped_token(["finance", "tax"], "q3_report", 1U)

  assert_false(@crypto.bytes_equal_const_time(t1.get_token(), t2.get_token()))
}
