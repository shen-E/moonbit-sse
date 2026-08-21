///|
/// ChaCha20 Quarter Round
fn chacha_quarter_round(
  x : FixedArray[UInt],
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> Unit {
  x[a] = x[a] + x[b]
  x[d] = rotr(x[d] ^ x[a], 16)
  x[c] = x[c] + x[d]
  x[b] = rotr(x[b] ^ x[c], 20)
  x[a] = x[a] + x[b]
  x[d] = rotr(x[d] ^ x[a], 24)
  x[c] = x[c] + x[d]
  x[b] = rotr(x[b] ^ x[c], 25)
}

///|
/// ChaCha20 block function (RFC 8439)
fn chacha20_block(key : Bytes, nonce : Bytes, counter : UInt) -> Bytes {
  let state : FixedArray[UInt] = [
    0x61707865U, 0x3320646eU, 0x79622d32U, 0x6b206574U, 0U, 0U, 0U, 0U, 0U, 0U, 0U,
    0U, 0U, 0U, 0U, 0U,
  ]

  // Key (8 words)
  for i in 0..<8 {
    let b0 = key[i * 4].to_int()
    let b1 = key[i * 4 + 1].to_int()
    let b2 = key[i * 4 + 2].to_int()
    let b3 = key[i * 4 + 3].to_int()
    state[4 + i] = ((b3 << 24) | (b2 << 16) | (b1 << 8) | b0).reinterpret_as_uint()
  }

  // Counter
  state[12] = counter

  // Nonce (3 words = 96-bit nonce)
  for i in 0..<3 {
    let b0 = nonce[i * 4].to_int()
    let b1 = nonce[i * 4 + 1].to_int()
    let b2 = nonce[i * 4 + 2].to_int()
    let b3 = nonce[i * 4 + 3].to_int()
    state[13 + i] = ((b3 << 24) | (b2 << 16) | (b1 << 8) | b0).reinterpret_as_uint()
  }

  let working : FixedArray[UInt] = FixedArray::make(16, 0U)
  for i in 0..<16 {
    working[i] = state[i]
  }

  for _ in 0..<10 {
    // Column rounds
    chacha_quarter_round(working, 0, 4, 8, 12)
    chacha_quarter_round(working, 1, 5, 9, 13)
    chacha_quarter_round(working, 2, 6, 10, 14)
    chacha_quarter_round(working, 3, 7, 11, 15)
    // Diagonal rounds
    chacha_quarter_round(working, 0, 5, 10, 15)
    chacha_quarter_round(working, 1, 6, 11, 12)
    chacha_quarter_round(working, 2, 7, 8, 13)
    chacha_quarter_round(working, 3, 4, 9, 14)
  }

  let out : FixedArray[Byte] = FixedArray::make(64, b'\x00')
  for i in 0..<16 {
    let word = (working[i] + state[i]).reinterpret_as_int()
    out[i * 4] = (word & 0xFF).to_byte()
    out[i * 4 + 1] = ((word >> 8) & 0xFF).to_byte()
    out[i * 4 + 2] = ((word >> 16) & 0xFF).to_byte()
    out[i * 4 + 3] = ((word >> 24) & 0xFF).to_byte()
  }
  Bytes::from_array(out)
}

///|
/// ChaCha20 stream encryption/decryption
pub fn chacha20_encrypt(
  key : Bytes,
  nonce : Bytes,
  counter : UInt,
  data : Bytes,
) -> Bytes {
  let out : FixedArray[Byte] = FixedArray::make(data.length(), b'\x00')
  let num_blocks = (data.length() + 63) / 64
  for b = 0; b < num_blocks; b = b + 1 {
    let cur_counter = counter + b.reinterpret_as_uint()
    let keyblock = chacha20_block(key, nonce, cur_counter)
    let start = b * 64
    let end = if start + 64 < data.length() {
      start + 64
    } else {
      data.length()
    }
    for i in start..<end {
      out[i] = (data[i].to_int() ^ keyblock[i - start].to_int()).to_byte()
    }
  }
  Bytes::from_array(out)
}

///|
/// ChaCha20 stream decryption (symmetric to encrypt)
pub fn chacha20_decrypt(
  key : Bytes,
  nonce : Bytes,
  counter : UInt,
  data : Bytes,
) -> Bytes {
  chacha20_encrypt(key, nonce, counter, data)
}
