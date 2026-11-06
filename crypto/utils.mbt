///|
/// Constant-time equality comparison between two byte sequences
pub fn bytes_equal_const_time(a : Bytes, b : Bytes) -> Bool {
  if a.length() != b.length() {
    return false
  }
  let mut diff = 0
  for i in 0..<a.length() {
    diff = diff | (a[i].to_int() ^ b[i].to_int())
  }
  diff == 0
}

///|
/// XOR two byte sequences of equal length
pub fn xor_bytes(a : Bytes, b : Bytes) -> Bytes {
  let len = if a.length() < b.length() { a.length() } else { b.length() }
  let out : FixedArray[Byte] = FixedArray::make(len, b'\x00')
  for i in 0..<len {
    out[i] = (a[i].to_int() ^ b[i].to_int()).to_byte()
  }
  Bytes::from_array(out)
}

///|
/// Helper to convert a 0-15 nibble to hex character
fn hex_digit(v : Int32) -> Char {
  if v < 10 {
    ('0'.to_int() + v).unsafe_to_char()
  } else {
    ('a'.to_int() + (v - 10)).unsafe_to_char()
  }
}

///|
/// Convert bytes to lowercase hexadecimal string
pub fn bytes_to_hex(b : Bytes) -> String {
  let buf = StringBuilder()
  for i in 0..<b.length() {
    let byte_val = b[i].to_int()
    let hi = (byte_val >> 4) & 0x0F
    let lo = byte_val & 0x0F
    buf.write_char(hex_digit(hi))
    buf.write_char(hex_digit(lo))
  }
  buf.to_string()
}

///|
/// Convert a character code to hex nibble
fn hex_code_to_nibble(code : Int32) -> Int32? {
  if code >= '0'.to_int() && code <= '9'.to_int() {
    Some(code - '0'.to_int())
  } else if code >= 'a'.to_int() && code <= 'f'.to_int() {
    Some(code - 'a'.to_int() + 10)
  } else if code >= 'A'.to_int() && code <= 'F'.to_int() {
    Some(code - 'A'.to_int() + 10)
  } else {
    None
  }
}

///|
/// Decode hexadecimal, rejecting odd lengths and invalid digits.
pub fn hex_to_bytes(s : String) -> Bytes raise CryptoInputError {
  let s_len = s.length()
  guard s_len % 2 == 0 else { raise OddHexLength(s_len) }
  let out_len = s_len / 2
  let out : FixedArray[Byte] = FixedArray::make(out_len, b'\x00')
  for i in 0..<out_len {
    let hi_code = s[i * 2].to_int()
    let lo_code = s[i * 2 + 1].to_int()
    let hi = match hex_code_to_nibble(hi_code) {
      Some(v) => v
      None => raise InvalidHexDigit(i * 2)
    }
    let lo = match hex_code_to_nibble(lo_code) {
      Some(v) => v
      None => raise InvalidHexDigit(i * 2 + 1)
    }
    out[i] = ((hi << 4) | lo).to_byte()
  }
  Bytes::from_array(out)
}

///|
/// Encode a string as UTF-8 without a byte order mark.
pub fn string_to_bytes(s : String) -> Bytes {
  @utf8.encode(s)
}

///|
/// Decode UTF-8 strictly, preserving a leading byte order mark.
pub fn bytes_to_string(b : Bytes) -> String raise CryptoInputError {
  @utf8.decode(b) catch {
    _ => raise InvalidUtf8
  }
}

///|
/// Convert 32-bit unsigned integer to 4-byte big-endian Bytes
pub fn uint32_to_be_bytes(v : UInt32) -> Bytes {
  let out : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let v_int = v.reinterpret_as_int()
  out[0] = ((v_int >> 24) & 0xFF).to_byte()
  out[1] = ((v_int >> 16) & 0xFF).to_byte()
  out[2] = ((v_int >> 8) & 0xFF).to_byte()
  out[3] = (v_int & 0xFF).to_byte()
  Bytes::from_array(out)
}

///|
/// Parse 32-bit unsigned integer from 4-byte big-endian Bytes
pub fn uint32_from_be_bytes(b : Bytes, offset : Int32) -> UInt32 {
  let b0 = b[offset].to_int()
  let b1 = b[offset + 1].to_int()
  let b2 = b[offset + 2].to_int()
  let b3 = b[offset + 3].to_int()
  let val = (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
  val.reinterpret_as_uint()
}

///|
/// Convert 64-bit unsigned integer to 8-byte big-endian Bytes
pub fn uint64_to_be_bytes(v : UInt64) -> Bytes {
  let out : FixedArray[Byte] = FixedArray::make(8, b'\x00')
  let hi = (v >> 32).to_uint().reinterpret_as_int()
  let lo = (v & 0xFFFFFFFFUL).to_uint().reinterpret_as_int()
  out[0] = ((hi >> 24) & 0xFF).to_byte()
  out[1] = ((hi >> 16) & 0xFF).to_byte()
  out[2] = ((hi >> 8) & 0xFF).to_byte()
  out[3] = (hi & 0xFF).to_byte()
  out[4] = ((lo >> 24) & 0xFF).to_byte()
  out[5] = ((lo >> 16) & 0xFF).to_byte()
  out[6] = ((lo >> 8) & 0xFF).to_byte()
  out[7] = (lo & 0xFF).to_byte()
  Bytes::from_array(out)
}

///|
/// Parse 64-bit unsigned integer from 8-byte big-endian Bytes
pub fn uint64_from_be_bytes(b : Bytes, offset : Int32) -> UInt64 {
  let hi = uint32_from_be_bytes(b, offset).to_uint64()
  let lo = uint32_from_be_bytes(b, offset + 4).to_uint64()
  (hi << 32) | lo
}

///|
/// Convert 8 bytes from little-endian representation to UInt64.
fn uint64_from_le_bytes(b : Bytes, offset : Int32) -> UInt64 {
  let mut value = 0UL
  for i in 0..<8 {
    value = value | (b[offset + i].to_uint64() << (8 * i))
  }
  value
}

///|
/// Convert UInt64 to an 8-byte little-endian representation.
fn uint64_to_le_bytes(v : UInt64) -> Bytes {
  let out : FixedArray[Byte] = FixedArray::make(8, b'\x00')
  for i in 0..<8 {
    out[i] = ((v >> (8 * i)) & 0xFFUL).to_uint().reinterpret_as_int().to_byte()
  }
  Bytes::from_array(out)
}

///|
/// PKCS7 Padding
pub fn pad_pkcs7(data : Bytes, block_size : Int32) -> Bytes {
  let pad_len = block_size - data.length() % block_size
  let total_len = data.length() + pad_len
  let out : FixedArray[Byte] = FixedArray::make(total_len, pad_len.to_byte())
  for i in 0..<data.length() {
    out[i] = data[i]
  }
  Bytes::from_array(out)
}

///|
/// PKCS7 Unpadding
pub fn unpad_pkcs7(data : Bytes) -> Bytes? {
  if data.length() == 0 {
    return None
  }
  let pad_val = data[data.length() - 1].to_int()
  if pad_val == 0 || pad_val > data.length() {
    return None
  }
  for i in (data.length() - pad_val)..<data.length() {
    if data[i].to_int() != pad_val {
      return None
    }
  }
  let out_len = data.length() - pad_val
  let out : FixedArray[Byte] = FixedArray::make(out_len, b'\x00')
  for i in 0..<out_len {
    out[i] = data[i]
  }
  Some(Bytes::from_array(out))
}
