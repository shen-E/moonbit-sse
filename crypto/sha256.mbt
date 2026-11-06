///|
/// Initial hash values (H0..H7) for SHA-256
let sha256_init_h : FixedArray[UInt32] = [
  0x6a09e667U, 0xbb67ae85U, 0x3c6ef372U, 0xa54ff53aU, 0x510e527fU, 0x9b05688cU, 0x1f83d9abU,
  0x5be0cd19U,
]

///|
/// Round constants K for SHA-256
let sha256_k : FixedArray[UInt32] = [
  0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U, 0x3956c25bU, 0x59f111f1U, 0x923f82a4U,
  0xab1c5ed5U, 0xd807aa98U, 0x12835b01U, 0x243185beU, 0x550c7dc3U, 0x72be5d74U, 0x80deb1feU,
  0x9bdc06a7U, 0xc19bf174U, 0xe49b69c1U, 0xefbe4786U, 0x0fc19dc6U, 0x240ca1ccU, 0x2de92c6fU,
  0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU, 0x983e5152U, 0xa831c66dU, 0xb00327c8U, 0xbf597fc7U,
  0xc6e00bf3U, 0xd5a79147U, 0x06ca6351U, 0x14292967U, 0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU,
  0x53380d13U, 0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U, 0xa2bfe8a1U, 0xa81a664bU,
  0xc24b8b70U, 0xc76c51a3U, 0xd192e819U, 0xd6990624U, 0xf40e3585U, 0x106aa070U, 0x19a4c116U,
  0x1e376c08U, 0x2748774cU, 0x34b0bcb5U, 0x391c0cb3U, 0x4ed8aa4aU, 0x5b9cca4fU, 0x682e6ff3U,
  0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U, 0x90befffaU, 0xa4506cebU, 0xbef9a3f7U,
  0xc67178f2U,
]

///|
/// Bitwise right rotation for UInt
fn rotr(x : UInt32, n : Int32) -> UInt32 {
  (x >> n) | (x << (32 - n))
}

///|
/// SHA-256 helper functions
fn ch(x : UInt32, y : UInt32, z : UInt32) -> UInt32 {
  (x & y) ^ ((x ^ 0xFFFFFFFFU) & z)
}

///|
fn maj(x : UInt32, y : UInt32, z : UInt32) -> UInt32 {
  (x & y) ^ (x & z) ^ (y & z)
}

///|
fn sigma0(x : UInt32) -> UInt32 {
  rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22)
}

///|
fn sigma1(x : UInt32) -> UInt32 {
  rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25)
}

///|
fn gamma0(x : UInt32) -> UInt32 {
  rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3)
}

///|
fn gamma1(x : UInt32) -> UInt32 {
  rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10)
}

///|
/// Process a 64-byte block in SHA-256
fn sha256_process_block(
  state : FixedArray[UInt32],
  block : Bytes,
  offset : Int32,
) -> Unit {
  let w : FixedArray[UInt32] = FixedArray::make(64, 0U)
  for i in 0..<16 {
    w[i] = uint32_from_be_bytes(block, offset + i * 4)
  }
  for i in 16..<64 {
    w[i] = gamma1(w[i - 2]) + w[i - 7] + gamma0(w[i - 15]) + w[i - 16]
  }

  let mut a = state[0]
  let mut b = state[1]
  let mut c = state[2]
  let mut d = state[3]
  let mut e = state[4]
  let mut f = state[5]
  let mut g = state[6]
  let mut h = state[7]

  for i in 0..<64 {
    let t1 = h + sigma1(e) + ch(e, f, g) + sha256_k[i] + w[i]
    let t2 = sigma0(a) + maj(a, b, c)
    h = g
    g = f
    f = e
    e = d + t1
    d = c
    c = b
    b = a
    a = t1 + t2
  }

  state[0] = state[0] + a
  state[1] = state[1] + b
  state[2] = state[2] + c
  state[3] = state[3] + d
  state[4] = state[4] + e
  state[5] = state[5] + f
  state[6] = state[6] + g
  state[7] = state[7] + h
}

///|
/// Compute SHA-256 hash of arbitrary bytes
pub fn sha256(data : Bytes) -> Bytes {
  let state : FixedArray[UInt32] = FixedArray::make(8, 0U)
  for i in 0..<8 {
    state[i] = sha256_init_h[i]
  }

  let len = data.length()
  let bit_len = (len.to_int64() * 8L).reinterpret_as_uint64()
  let pad_len = if len % 64 < 56 { 56 - len % 64 } else { 120 - len % 64 }
  let total_len = len + pad_len + 8
  let padded : FixedArray[Byte] = FixedArray::make(total_len, b'\x00')

  for i in 0..<len {
    padded[i] = data[i]
  }
  padded[len] = b'\x80'

  let len_bytes = uint64_to_be_bytes(bit_len)
  for i in 0..<8 {
    padded[len + pad_len + i] = len_bytes[i]
  }

  let padded_bytes = Bytes::from_array(padded)
  let num_blocks = total_len / 64
  for b = 0; b < num_blocks; b = b + 1 {
    sha256_process_block(state, padded_bytes, b * 64)
  }

  let out : FixedArray[Byte] = FixedArray::make(32, b'\x00')
  for i in 0..<8 {
    let word_bytes = uint32_to_be_bytes(state[i])
    for j in 0..<4 {
      out[i * 4 + j] = word_bytes[j]
    }
  }
  Bytes::from_array(out)
}

///|
/// Compute SHA-256 hash and return hex string
pub fn sha256_hex(data : Bytes) -> String {
  bytes_to_hex(sha256(data))
}

///|
/// Compute SHA-256 hash of a string
pub fn sha256_str(s : String) -> Bytes {
  sha256(string_to_bytes(s))
}
