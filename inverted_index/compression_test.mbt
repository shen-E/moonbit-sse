///|
test "posting list delta and vbyte compression" {
  let doc_ids : Array[Int] = [100, 105, 120, 250, 1000]
  let deltas = delta_encode(doc_ids)
  let compressed = compress_vbyte(deltas)
  assert_true(compressed.length() < doc_ids.length() * 4)

  let decompressed_deltas = decompress_vbyte(compressed)
  let recovered_ids = delta_decode(decompressed_deltas)
  assert_eq(recovered_ids.length(), 5)
  assert_eq(recovered_ids[0], 100)
  assert_eq(recovered_ids[4], 1000)
}
