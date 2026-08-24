///|
test "pbkdf2 standard test vector" {
  let password = string_to_bytes("password")
  let salt = string_to_bytes("salt")
  let derived = pbkdf2_hmac_sha256(password, salt, 2, 32)
  assert_eq(
    bytes_to_hex(derived),
    "ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43",
  )
}
