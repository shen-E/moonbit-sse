///|
test "vector pir matrix evaluation" {
  let mat = VectorPirMatrix::new(2, 2, 8)
  mat.set(0, 0, @crypto.string_to_bytes("item_0_0"))
  mat.set(0, 1, @crypto.string_to_bytes("item_0_1"))
  mat.set(1, 0, @crypto.string_to_bytes("item_1_0"))
  mat.set(1, 1, @crypto.string_to_bytes("item_1_1"))

  let q : FixedArray[Bool] = [true, false]
  let res_row = mat.eval_row_vector(q)
  assert_eq(@crypto.bytes_to_string(res_row[0]), "item_0_0")
  assert_eq(@crypto.bytes_to_string(res_row[1]), "item_0_1")
}
