///|
/// Compute HMAC-SHA256 for a given key and message
pub fn hmac_sha256(key : Bytes, message : Bytes) -> Bytes {
  let block_size = 64
  let mut actual_key = key
  if actual_key.length() > block_size {
    actual_key = sha256(actual_key)
  }

  let k_pad_len = block_size
  let ipad : FixedArray[Byte] = FixedArray::make(k_pad_len, (0x36).to_byte())
  let opad : FixedArray[Byte] = FixedArray::make(k_pad_len, (0x5c).to_byte())

  for i in 0..<actual_key.length() {
    ipad[i] = (actual_key[i].to_int() ^ 0x36).to_byte()
    opad[i] = (actual_key[i].to_int() ^ 0x5c).to_byte()
  }

  let inner_len = block_size + message.length()
  let inner_buf : FixedArray[Byte] = FixedArray::make(inner_len, b'\x00')
  for i in 0..<block_size {
    inner_buf[i] = ipad[i]
  }
  for i in 0..<message.length() {
    inner_buf[block_size + i] = message[i]
  }
  let inner_hash = sha256(Bytes::from_array(inner_buf))

  let outer_len = block_size + 32
  let outer_buf : FixedArray[Byte] = FixedArray::make(outer_len, b'\x00')
  for i in 0..<block_size {
    outer_buf[i] = opad[i]
  }
  for i in 0..<32 {
    outer_buf[block_size + i] = inner_hash[i]
  }
  sha256(Bytes::from_array(outer_buf))
}

///|
/// Compute HMAC-SHA256 and return hex string
pub fn hmac_sha256_hex(key : Bytes, message : Bytes) -> String {
  bytes_to_hex(hmac_sha256(key, message))
}
