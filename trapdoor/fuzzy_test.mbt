///|
test "fuzzy ngram trapdoor generation" {
  let master_key = @crypto.hex_to_bytes(
    "3333444455556666777788889999000033334444555566667777888899990000",
  )
  let gen = TrapdoorGenerator::new(master_key)
  let fuzzy = FuzzyTrapdoorGenerator::new(gen, 3)

  let tokens = fuzzy.generate_fuzzy_tokens("privacy", 1U)
  assert_eq(tokens.length(), 5) // "pri", "riv", "iva", "vac", "acy"
}
