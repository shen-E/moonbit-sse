///|
test "sha256 standard test vectors" {
  // Hash of empty string
  let empty_hash = sha256(string_to_bytes(""))
  assert_eq(
    bytes_to_hex(empty_hash),
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )

  // Hash of "abc"
  let abc_hash = sha256(string_to_bytes("abc"))
  assert_eq(
    bytes_to_hex(abc_hash),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )

  // Hash of "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  let long_hash = sha256(
    string_to_bytes("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
  )
  assert_eq(
    bytes_to_hex(long_hash),
    "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1",
  )
}
