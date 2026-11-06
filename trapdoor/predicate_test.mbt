///|
test "predicate trapdoor generation" {
  let master_key = @crypto.hex_to_bytes(
    "bbbbccccddddeeee0000111122223333bbbbccccddddeeee0000111122223333",
  )
  let gen = @trapdoor.TrapdoorGenerator::new(master_key)
  let pred_gen = @trapdoor.PredicateGenerator::new(gen)

  let attrs : Array[String] = [
    "role:admin", "clearance:top_secret", "dept:crypto",
  ]
  let weights : Array[Int32] = [10, 20, 5]
  let p_tok = pred_gen.generate_predicate_token(attrs, weights, 25, 1U)

  assert_eq(p_tok.weight_vectors.length(), 3)
  assert_eq(p_tok.threshold, 25)
}
