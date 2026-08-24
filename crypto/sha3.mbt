///|
/// Keccak-f[1600] Round Constants
let keccak_rc : FixedArray[UInt64] = [
  0x0000000000000001UL, 0x0000000000008082UL, 0x800000000000808aUL, 0x8000000080008000UL,
  0x000000000000808bUL, 0x0000000080000001UL, 0x8000000080008081UL, 0x8000000000008009UL,
  0x000000000000008aUL, 0x0000000000000088UL, 0x0000000080008009UL, 0x000000008000000aUL,
  0x000000008000808bUL, 0x800000000000008bUL, 0x8000000000008089UL, 0x8000000000008003UL,
  0x8000000000008002UL, 0x8000000000000080UL, 0x000000000000800aUL, 0x800000008000000aUL,
  0x8000000080008081UL, 0x8000000000008080UL, 0x0000000080000001UL, 0x8000000080008008UL,
]

///|
/// 64-bit Left Rotation
fn rotl64(x : UInt64, n : Int) -> UInt64 {
  (x << n) | (x >> (64 - n))
}

///|
/// Keccak-f[1600] permutation on 25 64-bit lanes (5x5 state)
pub fn keccak_f1600(state : FixedArray[UInt64]) -> Unit {
  let c : FixedArray[UInt64] = FixedArray::make(5, 0UL)
  let d : FixedArray[UInt64] = FixedArray::make(5, 0UL)

  for round in 0..<24 {
    // Theta step
    for x in 0..<5 {
      c[x] = state[x] ^
        state[x + 5] ^
        state[x + 10] ^
        state[x + 15] ^
        state[x + 20]
    }
    for x in 0..<5 {
      d[x] = c[(x + 4) % 5] ^ rotl64(c[(x + 1) % 5], 1)
    }
    for i in 0..<25 {
      state[i] = state[i] ^ d[i % 5]
    }

    // Rho and Pi steps
    let mut cur = state[1]
    let mut x = 1
    let mut y = 0
    for t in 0..<24 {
      let shift = (t + 1) * (t + 2) / 2 % 64
      let n_x = y
      let n_y = (2 * x + 3 * y) % 5
      let next_lane = state[n_x + n_y * 5]
      state[n_x + n_y * 5] = rotl64(cur, shift)
      cur = next_lane
      x = n_x
      y = n_y
    }

    // Chi step
    for y_idx in 0..<5 {
      let b0 = state[0 + y_idx * 5]
      let b1 = state[1 + y_idx * 5]
      let b2 = state[2 + y_idx * 5]
      let b3 = state[3 + y_idx * 5]
      let b4 = state[4 + y_idx * 5]
      state[0 + y_idx * 5] = b0 ^ ((b1 ^ 0xFFFFFFFFFFFFFFFFUL) & b2)
      state[1 + y_idx * 5] = b1 ^ ((b2 ^ 0xFFFFFFFFFFFFFFFFUL) & b3)
      state[2 + y_idx * 5] = b2 ^ ((b3 ^ 0xFFFFFFFFFFFFFFFFUL) & b4)
      state[3 + y_idx * 5] = b3 ^ ((b4 ^ 0xFFFFFFFFFFFFFFFFUL) & b0)
      state[4 + y_idx * 5] = b4 ^ ((b0 ^ 0xFFFFFFFFFFFFFFFFUL) & b1)
    }

    // Iota step
    state[0] = state[0] ^ keccak_rc[round]
  }
}

///|
/// SHA3-256 Hash Function (FIPS 202)
pub fn sha3_256(data : Bytes) -> Bytes {
  let rate_bytes = 136 // 1088 bits / 8
  let state : FixedArray[UInt64] = FixedArray::make(25, 0UL)

  let len = data.length()
  let pad_len = rate_bytes - len % rate_bytes
  let total_len = len + pad_len
  let padded : FixedArray[Byte] = FixedArray::make(total_len, b'\x00')
  for i in 0..<len {
    padded[i] = data[i]
  }

  if pad_len == 1 {
    padded[len] = (0x86).to_byte()
  } else {
    padded[len] = (0x06).to_byte()
    padded[total_len - 1] = (0x80).to_byte()
  }

  let num_blocks = total_len / rate_bytes
  for b = 0; b < num_blocks; b = b + 1 {
    let offset = b * rate_bytes
    for i in 0..<17 { // 17 64-bit words in 136 bytes
      let w_bytes : FixedArray[Byte] = FixedArray::make(8, b'\x00')
      for j in 0..<8 {
        w_bytes[j] = padded[offset + i * 8 + j]
      }
      let lane = uint64_from_le_bytes(Bytes::from_array(w_bytes), 0)
      state[i] = state[i] ^ lane
    }
    keccak_f1600(state)
  }

  let out : FixedArray[Byte] = FixedArray::make(32, b'\x00')
  for i in 0..<4 {
    let lane_b = uint64_to_le_bytes(state[i])
    for j in 0..<8 {
      out[i * 8 + j] = lane_b[j]
    }
  }
  Bytes::from_array(out)
}
