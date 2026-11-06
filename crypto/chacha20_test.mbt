///|
test "chacha20 standard test vectors RFC 8439" {
  let key = @crypto.hex_to_bytes(
    "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f",
  )
  let nonce = @crypto.hex_to_bytes("000000000000004a00000000")
  let plain = @crypto.string_to_bytes(
    "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.",
  )
  let cipher = @crypto.chacha20_encrypt(key, nonce, 1U, plain)
  assert_eq(
    @crypto.bytes_to_hex(cipher),
    "6e2e359a2568f98041ba0728dd0d6981e97e7aec1d4360c20a27afccfd9fae0b" +
    "f91b65c5524733ab8f593dabcd62b3571639d624e65152ab8f530c359f0861d8" +
    "07ca0dbf500d6a6156a38e088a22b65e52bc514d16ccf806818ce91ab7793736" +
    "5af90bbf74a35be6b40b8eedf2785e42874d",
  )
  let dec = @crypto.chacha20_decrypt(key, nonce, 1U, cipher)
  assert_eq(@crypto.bytes_to_string(dec), @crypto.bytes_to_string(plain))
}
