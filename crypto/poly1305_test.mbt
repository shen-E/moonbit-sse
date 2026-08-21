///|
test "poly1305 authenticator" {
  let key = hex_to_bytes(
    "85d6be7857556d337f4452fe42d506a80103808afb0db2fd4abff6af4149f51b",
  )
  let msg = string_to_bytes("Cryptographic Authentication for SSE")
  let tag = poly1305_auth(key, msg)
  assert_eq(tag.length(), 16)
}
