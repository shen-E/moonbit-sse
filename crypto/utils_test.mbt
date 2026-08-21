///|
/// Test constant time equality and hex conversion
test "utils bytes conversion and const time eq" {
  let a = hex_to_bytes("0123456789abcdef")
  let hex_str = bytes_to_hex(a)
  assert_eq(hex_str, "0123456789abcdef")
  assert_true(bytes_equal_const_time(a, hex_to_bytes("0123456789abcdef")))
  assert_false(bytes_equal_const_time(a, hex_to_bytes("0123456789abcdee")))
}

///|
/// Test XOR
test "utils xor_bytes" {
  let a = hex_to_bytes("ff00aa55")
  let b = hex_to_bytes("00ff55aa")
  let c = xor_bytes(a, b)
  assert_eq(bytes_to_hex(c), "ffffffff")
}

///|
/// Test uint32/uint64 be bytes conversion
test "utils uint conversions" {
  let u = 0x12345678U
  let b = uint32_to_be_bytes(u)
  assert_eq(bytes_to_hex(b), "12345678")
  let parsed = uint32_from_be_bytes(b, 0)
  assert_eq(parsed, u)
}

///|
/// Test pkcs7 padding and unpadding
test "utils pkcs7 padding" {
  let msg = string_to_bytes("hello world")
  let padded = pad_pkcs7(msg, 16)
  assert_eq(padded.length(), 16)
  let unpadded = unpad_pkcs7(padded)
  match unpadded {
    Some(res) => assert_eq(bytes_to_string(res), "hello world")
    None => assert_true(false)
  }
}
