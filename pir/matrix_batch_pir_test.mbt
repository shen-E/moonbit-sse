///|
test "matrix batch pir packets" {
  let seed = @crypto.hex_to_bytes(
    "1111000011110000111100001111000011110000111100001111000011110000",
  )
  let client = MatrixBatchPirClient::new(4, 4, 8, seed)
  let (p1, p2) = client.generate_batch_query([1, 3])

  assert_eq(p1.row_masks.length(), 2)
  assert_eq(p2.row_masks.length(), 2)
}
