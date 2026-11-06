///|
/// AES S-Box table
let aes_sbox : FixedArray[Byte] = [
  0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7,
  0xab, 0x76, 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf,
  0x9c, 0xa4, 0x72, 0xc0, 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5,
  0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15, 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a,
  0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75, 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e,
  0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84, 0x53, 0xd1, 0x00, 0xed,
  0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf, 0xd0, 0xef,
  0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
  0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff,
  0xf3, 0xd2, 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d,
  0x64, 0x5d, 0x19, 0x73, 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee,
  0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb, 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c,
  0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79, 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5,
  0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08, 0xba, 0x78, 0x25, 0x2e,
  0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a, 0x70, 0x3e,
  0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
  0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55,
  0x28, 0xdf, 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f,
  0xb0, 0x54, 0xbb, 0x16,
]

///|
/// AES Inverse S-Box table
let aes_inv_sbox : FixedArray[Byte] = [
  0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3,
  0xd7, 0xfb, 0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44,
  0xc4, 0xde, 0xe9, 0xcb, 0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c,
  0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e, 0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2,
  0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25, 0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68,
  0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92, 0x6c, 0x70, 0x48, 0x50,
  0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84, 0x90, 0xd8,
  0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
  0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13,
  0x8a, 0x6b, 0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce,
  0xf0, 0xb4, 0xe6, 0x73, 0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9,
  0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e, 0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89,
  0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b, 0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2,
  0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4, 0x1f, 0xdd, 0xa8, 0x33,
  0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f, 0x60, 0x51,
  0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
  0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53,
  0x99, 0x61, 0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63,
  0x55, 0x21, 0x0c, 0x7d,
]

///|
/// Rcon constants
let aes_rcon : FixedArray[UInt32] = [
  0x00U, 0x01U, 0x02U, 0x04U, 0x08U, 0x10U, 0x20U, 0x40U, 0x80U, 0x1bU, 0x36U,
]

///|
/// SubWord for AES key expansion
fn aes_sub_word(w : UInt32) -> UInt32 {
  let b0 = aes_sbox[(w.reinterpret_as_int() >> 24) & 0xFF].to_int()
  let b1 = aes_sbox[(w.reinterpret_as_int() >> 16) & 0xFF].to_int()
  let b2 = aes_sbox[(w.reinterpret_as_int() >> 8) & 0xFF].to_int()
  let b3 = aes_sbox[w.reinterpret_as_int() & 0xFF].to_int()
  let res = (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
  res.reinterpret_as_uint()
}

///|
/// RotWord for AES key expansion
fn aes_rot_word(w : UInt32) -> UInt32 {
  (w << 8) | (w >> 24)
}

///|
/// AES-128 Key Expansion
fn aes128_key_expansion(key : Bytes) -> FixedArray[UInt32] {
  let w : FixedArray[UInt32] = FixedArray::make(44, 0U)
  for i in 0..<4 {
    w[i] = uint32_from_be_bytes(key, i * 4)
  }
  for i in 4..<44 {
    let mut temp = w[i - 1]
    if i % 4 == 0 {
      let rcon_val = aes_rcon[i / 4] << 24
      temp = aes_sub_word(aes_rot_word(temp)) ^ rcon_val
    }
    w[i] = w[i - 4] ^ temp
  }
  w
}

///|
/// AES-256 Key Expansion
fn aes256_key_expansion(key : Bytes) -> FixedArray[UInt32] {
  let w : FixedArray[UInt32] = FixedArray::make(60, 0U)
  for i in 0..<8 {
    w[i] = uint32_from_be_bytes(key, i * 4)
  }
  for i in 8..<60 {
    let mut temp = w[i - 1]
    if i % 8 == 0 {
      let rcon_val = aes_rcon[i / 8] << 24
      temp = aes_sub_word(aes_rot_word(temp)) ^ rcon_val
    } else if i % 8 == 4 {
      temp = aes_sub_word(temp)
    }
    w[i] = w[i - 8] ^ temp
  }
  w
}

///|
/// GF(2^8) multiplication by 2
fn xtime(b : Int32) -> Int32 {
  if (b & 0x80) != 0 {
    ((b << 1) ^ 0x1b) & 0xFF
  } else {
    (b << 1) & 0xFF
  }
}

///|
/// GF(2^8) general multiplication
fn gf_mul(a : Int32, b : Int32) -> Int32 {
  let mut cur_a = a
  let mut cur_b = b
  let mut p = 0
  for _ in 0..<8 {
    if (cur_b & 1) != 0 {
      p = p ^ cur_a
    }
    let hi = cur_a & 0x80
    cur_a = (cur_a << 1) & 0xFF
    if hi != 0 {
      cur_a = cur_a ^ 0x1b
    }
    cur_b = cur_b >> 1
  }
  p
}

///|
/// Encrypt single 16-byte block with expanded key and num_rounds
fn aes_cipher_block(
  w : FixedArray[UInt32],
  num_rounds : Int32,
  block : Bytes,
) -> Bytes {
  let state : FixedArray[Byte] = FixedArray::make(16, b'\x00')
  for i in 0..<16 {
    state[i] = block[i]
  }

  // AddRoundKey round 0
  for col in 0..<4 {
    let rk = uint32_to_be_bytes(w[col])
    for row in 0..<4 {
      state[row + col * 4] = (state[row + col * 4].to_int() ^ rk[row].to_int()).to_byte()
    }
  }

  for round in 1..<num_rounds {
    // SubBytes
    for i in 0..<16 {
      state[i] = aes_sbox[state[i].to_int()]
    }

    // ShiftRows
    let temp = state[1]
    state[1] = state[5]
    state[5] = state[9]
    state[9] = state[13]
    state[13] = temp

    let temp0 = state[2]
    let temp1 = state[6]
    state[2] = state[10]
    state[6] = state[14]
    state[10] = temp0
    state[14] = temp1

    let temp3 = state[15]
    state[15] = state[11]
    state[11] = state[7]
    state[7] = state[3]
    state[3] = temp3

    // MixColumns
    for col in 0..<4 {
      let idx = col * 4
      let a0 = state[idx].to_int()
      let a1 = state[idx + 1].to_int()
      let a2 = state[idx + 2].to_int()
      let a3 = state[idx + 3].to_int()

      state[idx] = (xtime(a0) ^ (xtime(a1) ^ a1) ^ a2 ^ a3).to_byte()
      state[idx + 1] = (a0 ^ xtime(a1) ^ (xtime(a2) ^ a2) ^ a3).to_byte()
      state[idx + 2] = (a0 ^ a1 ^ xtime(a2) ^ (xtime(a3) ^ a3)).to_byte()
      state[idx + 3] = (xtime(a0) ^ a0 ^ a1 ^ a2 ^ xtime(a3)).to_byte()
    }

    // AddRoundKey
    for col in 0..<4 {
      let rk = uint32_to_be_bytes(w[round * 4 + col])
      for row in 0..<4 {
        state[row + col * 4] = (state[row + col * 4].to_int() ^ rk[row].to_int()).to_byte()
      }
    }
  }

  // Final Round
  // SubBytes
  for i in 0..<16 {
    state[i] = aes_sbox[state[i].to_int()]
  }

  // ShiftRows
  let temp = state[1]
  state[1] = state[5]
  state[5] = state[9]
  state[9] = state[13]
  state[13] = temp

  let temp0 = state[2]
  let temp1 = state[6]
  state[2] = state[10]
  state[6] = state[14]
  state[10] = temp0
  state[14] = temp1

  let temp3 = state[15]
  state[15] = state[11]
  state[11] = state[7]
  state[7] = state[3]
  state[3] = temp3

  // AddRoundKey final
  for col in 0..<4 {
    let rk = uint32_to_be_bytes(w[num_rounds * 4 + col])
    for row in 0..<4 {
      state[row + col * 4] = (state[row + col * 4].to_int() ^ rk[row].to_int()).to_byte()
    }
  }

  Bytes::from_array(state)
}

///|
/// Decrypt single 16-byte block with expanded key and num_rounds
fn aes_inv_cipher_block(
  w : FixedArray[UInt32],
  num_rounds : Int32,
  block : Bytes,
) -> Bytes {
  let state : FixedArray[Byte] = FixedArray::make(16, b'\x00')
  for i in 0..<16 {
    state[i] = block[i]
  }

  // AddRoundKey initial (round = num_rounds)
  for col in 0..<4 {
    let rk = uint32_to_be_bytes(w[num_rounds * 4 + col])
    for row in 0..<4 {
      state[row + col * 4] = (state[row + col * 4].to_int() ^ rk[row].to_int()).to_byte()
    }
  }

  for round = num_rounds - 1; round > 0; round = round - 1 {
    // InvShiftRows
    let temp = state[13]
    state[13] = state[9]
    state[9] = state[5]
    state[5] = state[1]
    state[1] = temp

    let temp0 = state[10]
    let temp1 = state[14]
    state[10] = state[2]
    state[14] = state[6]
    state[2] = temp0
    state[6] = temp1

    let temp3 = state[3]
    state[3] = state[7]
    state[7] = state[11]
    state[11] = state[15]
    state[15] = temp3

    // InvSubBytes
    for i in 0..<16 {
      state[i] = aes_inv_sbox[state[i].to_int()]
    }

    // AddRoundKey
    for col in 0..<4 {
      let rk = uint32_to_be_bytes(w[round * 4 + col])
      for row in 0..<4 {
        state[row + col * 4] = (state[row + col * 4].to_int() ^ rk[row].to_int()).to_byte()
      }
    }

    // InvMixColumns
    for col in 0..<4 {
      let idx = col * 4
      let s0 = state[idx].to_int()
      let s1 = state[idx + 1].to_int()
      let s2 = state[idx + 2].to_int()
      let s3 = state[idx + 3].to_int()

      state[idx] = (gf_mul(0x0e, s0) ^
      gf_mul(0x0b, s1) ^
      gf_mul(0x0d, s2) ^
      gf_mul(0x09, s3)).to_byte()
      state[idx + 1] = (gf_mul(0x09, s0) ^
      gf_mul(0x0e, s1) ^
      gf_mul(0x0b, s2) ^
      gf_mul(0x0d, s3)).to_byte()
      state[idx + 2] = (gf_mul(0x0d, s0) ^
      gf_mul(0x09, s1) ^
      gf_mul(0x0e, s2) ^
      gf_mul(0x0b, s3)).to_byte()
      state[idx + 3] = (gf_mul(0x0b, s0) ^
      gf_mul(0x0d, s1) ^
      gf_mul(0x09, s2) ^
      gf_mul(0x0e, s3)).to_byte()
    }
  }

  // Final Round
  // InvShiftRows
  let temp = state[13]
  state[13] = state[9]
  state[9] = state[5]
  state[5] = state[1]
  state[1] = temp

  let temp0 = state[10]
  let temp1 = state[14]
  state[10] = state[2]
  state[14] = state[6]
  state[2] = temp0
  state[6] = temp1

  let temp3 = state[3]
  state[3] = state[7]
  state[7] = state[11]
  state[11] = state[15]
  state[15] = temp3

  // InvSubBytes
  for i in 0..<16 {
    state[i] = aes_inv_sbox[state[i].to_int()]
  }

  // AddRoundKey round 0
  for col in 0..<4 {
    let rk = uint32_to_be_bytes(w[col])
    for row in 0..<4 {
      state[row + col * 4] = (state[row + col * 4].to_int() ^ rk[row].to_int()).to_byte()
    }
  }

  Bytes::from_array(state)
}

///|
/// Encrypt single 16-byte block with AES-128
pub fn aes128_encrypt_block(key : Bytes, block : Bytes) -> Bytes {
  let w = aes128_key_expansion(key)
  aes_cipher_block(w, 10, block)
}

///|
/// Decrypt single 16-byte block with AES-128
pub fn aes128_decrypt_block(key : Bytes, block : Bytes) -> Bytes {
  let w = aes128_key_expansion(key)
  aes_inv_cipher_block(w, 10, block)
}

///|
/// Encrypt single 16-byte block with AES-256
pub fn aes256_encrypt_block(key : Bytes, block : Bytes) -> Bytes {
  let w = aes256_key_expansion(key)
  aes_cipher_block(w, 14, block)
}

///|
/// Decrypt single 16-byte block with AES-256
pub fn aes256_decrypt_block(key : Bytes, block : Bytes) -> Bytes {
  let w = aes256_key_expansion(key)
  aes_inv_cipher_block(w, 14, block)
}

///|
/// AES CTR mode streaming encryption/decryption (128-bit key, 16-byte IV)
pub fn aes128_ctr(key : Bytes, iv : Bytes, data : Bytes) -> Bytes {
  let w = aes128_key_expansion(key)
  let out : FixedArray[Byte] = FixedArray::make(data.length(), b'\x00')
  let ctr_block : FixedArray[Byte] = FixedArray::make(16, b'\x00')
  for i in 0..<16 {
    ctr_block[i] = iv[i]
  }

  let num_blocks = (data.length() + 15) / 16
  for b = 0; b < num_blocks; b = b + 1 {
    let keystream = aes_cipher_block(w, 10, Bytes::from_array(ctr_block))
    let start = b * 16
    let end = if start + 16 < data.length() {
      start + 16
    } else {
      data.length()
    }
    for i in start..<end {
      out[i] = (data[i].to_int() ^ keystream[i - start].to_int()).to_byte()
    }
    // Increment 128-bit counter
    for i = 15; i >= 0; i = i - 1 {
      let val = ctr_block[i].to_int() + 1
      ctr_block[i] = (val & 0xFF).to_byte()
      if (val & 0x100) == 0 {
        break
      }
    }
  }
  Bytes::from_array(out)
}

///|
/// AES-128 CBC mode encryption with PKCS7 padding
pub fn aes128_cbc_encrypt(key : Bytes, iv : Bytes, data : Bytes) -> Bytes {
  let padded = pad_pkcs7(data, 16)
  let w = aes128_key_expansion(key)
  let out : FixedArray[Byte] = FixedArray::make(padded.length(), b'\x00')
  let mut prev_block = iv

  let num_blocks = padded.length() / 16
  for b = 0; b < num_blocks; b = b + 1 {
    let blk : FixedArray[Byte] = FixedArray::make(16, b'\x00')
    for i in 0..<16 {
      blk[i] = (padded[b * 16 + i].to_int() ^ prev_block[i].to_int()).to_byte()
    }
    let enc = aes_cipher_block(w, 10, Bytes::from_array(blk))
    for i in 0..<16 {
      out[b * 16 + i] = enc[i]
    }
    prev_block = enc
  }
  Bytes::from_array(out)
}

///|
/// AES-128 CBC mode decryption with PKCS7 unpadding
pub fn aes128_cbc_decrypt(
  key : Bytes,
  iv : Bytes,
  ciphertext : Bytes,
) -> Bytes? {
  if ciphertext.length() == 0 || ciphertext.length() % 16 != 0 {
    return None
  }
  let w = aes128_key_expansion(key)
  let out : FixedArray[Byte] = FixedArray::make(ciphertext.length(), b'\x00')
  let mut prev_block = iv

  let num_blocks = ciphertext.length() / 16
  for b = 0; b < num_blocks; b = b + 1 {
    let cur_blk : FixedArray[Byte] = FixedArray::make(16, b'\x00')
    for i in 0..<16 {
      cur_blk[i] = ciphertext[b * 16 + i]
    }
    let dec = aes_inv_cipher_block(w, 10, Bytes::from_array(cur_blk))
    for i in 0..<16 {
      out[b * 16 + i] = (dec[i].to_int() ^ prev_block[i].to_int()).to_byte()
    }
    prev_block = Bytes::from_array(cur_blk)
  }
  unpad_pkcs7(Bytes::from_array(out))
}
