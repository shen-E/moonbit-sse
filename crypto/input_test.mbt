///|
test "UTF-8 encoding preserves Unicode, NUL, and a leading BOM" {
  for text in ["", "ASCII", "中文", "🔐", "a\u{0}b", "\u{FEFF}中文🔐"] {
    assert_eq(@crypto.bytes_to_string(@crypto.string_to_bytes(text)), text)
  }
  assert_eq(
    @crypto.bytes_to_hex(@crypto.string_to_bytes("中文")),
    "e4b8ade69687",
  )
}

///|
test "UTF-8 decoding rejects malformed, truncated, and surrogate sequences" {
  for bytes in [b"\xc0\xaf", b"\xe4\xb8", b"\xed\xa0\x80", b"\xff"] {
    try @crypto.bytes_to_string(bytes) catch {
      @crypto.CryptoInputError::InvalidUtf8 => ()
      _ => fail("expected InvalidUtf8")
    } noraise {
      _ => fail("invalid UTF-8 was accepted")
    }
  }
}

///|
test "hex decoder accepts empty and mixed case input" {
  assert_eq(@crypto.bytes_to_hex(@crypto.hex_to_bytes("")), "")
  assert_eq(@crypto.bytes_to_hex(@crypto.hex_to_bytes("aB09fF")), "ab09ff")
}

///|
test "hex decoder rejects odd lengths and reports invalid digit positions" {
  for text in ["f", "123"] {
    try @crypto.hex_to_bytes(text) catch {
      @crypto.CryptoInputError::OddHexLength(n) => assert_eq(n, text.length())
      _ => fail("expected OddHexLength")
    } noraise {
      _ => fail("odd hex length was accepted")
    }
  }
  for (text, position) in [("z0", 0), ("0z", 1), ("001g", 3), (" 0", 0)] {
    try @crypto.hex_to_bytes(text) catch {
      @crypto.CryptoInputError::InvalidHexDigit(n) => assert_eq(n, position)
      _ => fail("expected InvalidHexDigit")
    } noraise {
      _ => fail("invalid hex digit was accepted")
    }
  }
}

///|
test "PBKDF2 rejects nonpositive iteration counts and output lengths" {
  for iterations in [-1, 0] {
    try @crypto.pbkdf2_hmac_sha256(b"password", b"salt", iterations, 32) catch {
      @crypto.CryptoInputError::InvalidIterations(n) => assert_eq(n, iterations)
      _ => fail("expected InvalidIterations")
    } noraise {
      _ => fail("invalid iteration count was accepted")
    }
  }
  for length in [-1, 0] {
    try @crypto.pbkdf2_hmac_sha256(b"password", b"salt", 1, length) catch {
      @crypto.CryptoInputError::InvalidKeyLength(n) => assert_eq(n, length)
      _ => fail("expected InvalidKeyLength")
    } noraise {
      _ => fail("invalid output length was accepted")
    }
  }
}

///|
test "PBKDF2 single iteration standard vector and block boundary" {
  let single = @crypto.pbkdf2_hmac_sha256(b"password", b"salt", 1, 32)
  assert_eq(
    @crypto.bytes_to_hex(single),
    "120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b",
  )
  let longer = @crypto.pbkdf2_hmac_sha256(b"password", b"salt", 1, 33)
  assert_eq(
    @crypto.bytes_to_hex(longer),
    "120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b4d",
  )
}
