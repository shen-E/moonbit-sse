///|
test "keyword pir oblivious lookup" {
  let seed = @crypto.hex_to_bytes(
    "9999aaaa0000111122223333444455559999aaaa000011112222333344445555",
  )
  let engine = KeywordPirEngine::new(4, 12, seed)

  engine.put("secret_key_1", @crypto.string_to_bytes("private_val1"))
  engine.put("secret_key_2", @crypto.string_to_bytes("private_val2"))

  let res = engine.get("secret_key_2")
  match res {
    Some(b) => assert_eq(@crypto.bytes_to_string(b), "private_val2")
    None => assert_true(false)
  }
}
