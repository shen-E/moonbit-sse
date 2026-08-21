///|
test "encrypted bloom filter" {
  let key = @crypto.hex_to_bytes(
    "ccccdddd000011112222333344445555ccccdddd000011112222333344445555",
  )
  let bf = BloomFilter::new(256, 3, key)

  bf.add("cryptography")
  bf.add("searchable")

  assert_true(bf.contains("cryptography"))
  assert_true(bf.contains("searchable"))
  assert_false(bf.contains("unrelated_keyword"))
}
