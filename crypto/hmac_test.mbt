///|
test "hmac_sha256 test vectors" {
  // RFC 4231 Test Case 1
  let key1 = @crypto.hex_to_bytes("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b")
  let data1 = @crypto.string_to_bytes("Hi There")
  let mac1 = @crypto.hmac_sha256(key1, data1)
  assert_eq(
    @crypto.bytes_to_hex(mac1),
    "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7",
  )

  // RFC 4231 Test Case 2
  let key2 = @crypto.string_to_bytes("Jefe")
  let data2 = @crypto.string_to_bytes("what do ya want for nothing?")
  let mac2 = @crypto.hmac_sha256(key2, data2)
  assert_eq(
    @crypto.bytes_to_hex(mac2),
    "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
  )
}
