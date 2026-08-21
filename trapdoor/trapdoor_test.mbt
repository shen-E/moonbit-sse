///|
test "trapdoor generator and token derivation" {
  let master_key = @crypto.hex_to_bytes(
    "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  )
  let gen = TrapdoorGenerator::new(master_key)

  let st1 = gen.generate_search_token("security", 1U)
  let st2 = gen.generate_search_token("security", 1U)
  let st_other = gen.generate_search_token("privacy", 1U)

  assert_true(@crypto.bytes_equal_const_time(st1.get_token(), st2.get_token()))
  assert_false(
    @crypto.bytes_equal_const_time(st1.get_token(), st_other.get_token()),
  )

  let up = gen.generate_update_token("security", 42, 1, 0, 1U)
  assert_eq(up.get_addr().length(), 32)
}

///|
test "conjunctive derivator" {
  let master_key = @crypto.hex_to_bytes(
    "1111222233334444555566667777888811112222333344445555666677778888",
  )
  let gen = TrapdoorGenerator::new(master_key)
  let conj = ConjunctiveDerivator::new(gen)

  let aux : Array[String] = ["database", "encryption"]
  let c_token = conj.generate_conjunctive_token("cloud", aux, 1U)
  assert_eq(c_token.get_cross_tags().length(), 2)
}

///|
test "expiring trapdoors" {
  let master_key = @crypto.hex_to_bytes(
    "9999888877776666555544443333222299998888777766665555444433332222",
  )
  let gen = TrapdoorGenerator::new(master_key)
  let manager = ExpiringTrapdoorManager::new(gen)

  let exp_token = manager.generate_time_bound_token("confidential", 1U, 10U)
  assert_true(manager.verify_token(exp_token, 5U))
  assert_false(manager.verify_token(exp_token, 11U))
}

///|
test "blinded token roundtrip" {
  let master_key = @crypto.hex_to_bytes(
    "aaaabbbbccccddddeeeeffff00001111aaaabbbbccccddddeeeeffff00001111",
  )
  let gen = TrapdoorGenerator::new(master_key)
  let token = gen.generate_search_token("query", 1U)

  let blinding_factor = @crypto.hex_to_bytes(
    "0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f",
  )
  let blinded = blind_search_token(token, blinding_factor)

  assert_false(
    @crypto.bytes_equal_const_time(blinded.blinded_token, token.get_token()),
  )
  let unblinded = unblind_search_token(blinded, token.get_label(), 1U)
  assert_true(
    @crypto.bytes_equal_const_time(unblinded.get_token(), token.get_token()),
  )
}
