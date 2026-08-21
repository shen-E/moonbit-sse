///|
test "pbkdf2 standard test vector" {
  let password = string_to_bytes("password")
  let salt = string_to_bytes("salt")
  let derived = pbkdf2_hmac_sha256(password, salt, 2, 32)
  assert_eq(derived.length(), 32)
}
