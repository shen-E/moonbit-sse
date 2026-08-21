///|
test "crc32 checksum verification" {
  let msg = string_to_bytes("123456789")
  let checksum = crc32(msg)
  assert_eq(checksum, 0xcbf43926U)
}
