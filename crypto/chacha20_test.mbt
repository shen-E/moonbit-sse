///|
test "chacha20 standard test vectors RFC 8439" {
  let key = hex_to_bytes(
    "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f",
  )
  let nonce = hex_to_bytes("000000090000004a00000000")
  let plain = string_to_bytes(
    "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.",
  )
  let cipher = chacha20_encrypt(key, nonce, 1U, plain)
  let dec = chacha20_decrypt(key, nonce, 1U, cipher)
  assert_eq(bytes_to_string(dec), bytes_to_string(plain))
}
