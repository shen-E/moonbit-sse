///|
test "sha3_256 hash function" {
  let msg = string_to_bytes("MoonBit SHA3 Cryptographic Hash")
  let h = sha3_256(msg)
  assert_eq(h.length(), 32)
}
