///|
test "aes128 standard block test vector" {
  // NIST FIPS 197 Appendix B Test Vector
  let key = hex_to_bytes("2b7e151628aed2a6abf7158809cf4f3c")
  let plaintext = hex_to_bytes("6bc1bee22e409f96e93d7e117393172a")
  let ciphertext = aes128_encrypt_block(key, plaintext)
  assert_eq(bytes_to_hex(ciphertext), "3ad77bb40d7a3660a89ecaf32466ef97")
  let decrypted = aes128_decrypt_block(key, ciphertext)
  assert_eq(bytes_to_hex(decrypted), bytes_to_hex(plaintext))
}

///|
test "aes128 ctr and cbc mode" {
  let key = hex_to_bytes("000102030405060708090a0b0c0d0e0f")
  let iv = hex_to_bytes("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff")
  let msg = string_to_bytes("Searchable Symmetric Encryption in MoonBit!")

  // CTR mode
  let ct = aes128_ctr(key, iv, msg)
  let pt = aes128_ctr(key, iv, ct)
  assert_eq(bytes_to_string(pt), "Searchable Symmetric Encryption in MoonBit!")

  // CBC mode
  let cbc_ct = aes128_cbc_encrypt(key, iv, msg)
  let cbc_pt = aes128_cbc_decrypt(key, iv, cbc_ct)
  match cbc_pt {
    Some(res) =>
      assert_eq(
        bytes_to_string(res),
        "Searchable Symmetric Encryption in MoonBit!",
      )
    None => assert_true(false)
  }
}
