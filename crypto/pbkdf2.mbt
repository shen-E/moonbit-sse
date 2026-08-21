///|
/// PBKDF2 Key Derivation with HMAC-SHA256 (RFC 2898 / RFC 8018)
pub fn pbkdf2_hmac_sha256(
  password : Bytes,
  salt : Bytes,
  iterations : Int,
  key_len : Int,
) -> Bytes {
  let out : FixedArray[Byte] = FixedArray::make(key_len, b'\x00')
  let num_blocks = (key_len + 31) / 32

  for block_idx = 1; block_idx <= num_blocks; block_idx = block_idx + 1 {
    let salt_with_idx_len = salt.length() + 4
    let salt_buf : FixedArray[Byte] = FixedArray::make(
      salt_with_idx_len, b'\x00',
    )
    for i in 0..<salt.length() {
      salt_buf[i] = salt[i]
    }
    let idx_be = uint32_to_be_bytes(block_idx.reinterpret_as_uint())
    for i in 0..<4 {
      salt_buf[salt.length() + i] = idx_be[i]
    }

    let mut u = hmac_sha256(password, Bytes::from_array(salt_buf))
    let f_accum : FixedArray[Byte] = FixedArray::make(32, b'\x00')
    for i in 0..<32 {
      f_accum[i] = u[i]
    }

    for _ in 1..<iterations {
      u = hmac_sha256(password, u)
      for i in 0..<32 {
        f_accum[i] = (f_accum[i].to_int() ^ u[i].to_int()).to_byte()
      }
    }

    let start = (block_idx - 1) * 32
    let end = if start + 32 < key_len { start + 32 } else { key_len }
    for i in start..<end {
      out[i] = f_accum[i - start]
    }
  }

  Bytes::from_array(out)
}
