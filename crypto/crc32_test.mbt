///|
test "crc32 checksum verification" {
  let msg = @crypto.string_to_bytes("123456789")
  let checksum = @crypto.crc32(msg)
  assert_eq(checksum, 0xcbf43926U)
}
