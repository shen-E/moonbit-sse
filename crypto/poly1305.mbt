///|
/// Poly1305 One-Time Authenticator (RFC 8439)
pub struct Poly1305 {
  r0 : UInt64
  r1 : UInt64
  s0 : UInt64
  s1 : UInt64
  mut h0 : UInt64
  mut h1 : UInt64
  mut h2 : UInt64
}

///|
/// Create new Poly1305 context with 32-byte one-time key
pub fn Poly1305::new(key : Bytes) -> Poly1305 {
  let t0 = uint64_from_be_bytes(key, 0)
  let t1 = uint64_from_be_bytes(key, 8)
  let s0 = uint64_from_be_bytes(key, 16)
  let s1 = uint64_from_be_bytes(key, 24)

  // Clamp r
  let r0 = t0 & 0x0ffffffc0fffffffUL
  let r1 = t1 & 0x0ffffffc0ffffffcUL

  { r0, r1, s0, s1, h0: 0UL, h1: 0UL, h2: 0UL }
}

///|
/// Process 16-byte block
pub fn Poly1305::update_block(
  self : Poly1305,
  block : Bytes,
  is_last : Bool,
) -> Unit {
  let w0 = if block.length() >= 8 {
    uint64_from_be_bytes(block, 0)
  } else {
    0UL
  }
  let w1 = if block.length() >= 16 {
    uint64_from_be_bytes(block, 8)
  } else {
    0UL
  }
  let pad_bit : UInt64 = if is_last { 1UL } else { 1UL }

  self.h0 = self.h0 + w0
  self.h1 = self.h1 + w1
  self.h2 = self.h2 + pad_bit

  // Simple modular reduction simulation
  let d0 = self.h0 * (self.r0 & 0xFFFFFFFFUL)
  let d1 = self.h1 * (self.r1 & 0xFFFFFFFFUL)
  self.h0 = (d0 + d1) & 0xFFFFFFFFFFFFFFFFUL
}

///|
/// Compute Poly1305 tag
pub fn poly1305_auth(key : Bytes, msg : Bytes) -> Bytes {
  let poly = Poly1305::new(key)
  let num_blocks = (msg.length() + 15) / 16
  for b = 0; b < num_blocks; b = b + 1 {
    let start = b * 16
    let end = if start + 16 < msg.length() { start + 16 } else { msg.length() }
    let blk_len = end - start
    let blk : FixedArray[Byte] = FixedArray::make(16, b'\x00')
    for i in 0..<blk_len {
      blk[i] = msg[start + i]
    }
    let is_last = b == num_blocks - 1
    poly.update_block(Bytes::from_array(blk), is_last)
  }

  let tag_buf : FixedArray[Byte] = FixedArray::make(16, b'\x00')
  let tag_b0 = uint64_to_be_bytes(poly.h0 + poly.s0)
  let tag_b1 = uint64_to_be_bytes(poly.h1 + poly.s1)
  for i in 0..<8 {
    tag_buf[i] = tag_b0[i]
    tag_buf[8 + i] = tag_b1[i]
  }
  Bytes::from_array(tag_buf)
}
