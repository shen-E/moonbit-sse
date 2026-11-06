///|
/// Cryptographic Pseudo-Random Generator based on HMAC-SHA256
pub struct Prg {
  seed : Bytes
  mut counter : UInt64
}

///|
/// Create a new PRG initialized with a cryptographically strong seed
pub fn Prg::new(seed : Bytes) -> Prg {
  { seed, counter: 0UL, }
}

///|
/// Generate pseudorandom bytes of specified length
pub fn Prg::next_bytes(self : Prg, len : Int32) -> Bytes {
  let out : FixedArray[Byte] = FixedArray::make(len, b'\x00')
  let mut generated = 0
  while generated < len {
    let ctr_bytes = uint64_to_be_bytes(self.counter)
    self.counter = self.counter + 1UL
    let block = hmac_sha256(self.seed, ctr_bytes)
    let copy_len = if len - generated < 32 { len - generated } else { 32 }
    for i in 0..<copy_len {
      out[generated + i] = block[i]
    }
    generated = generated + copy_len
  }
  Bytes::from_array(out)
}

///|
/// Generate a 32-bit pseudorandom unsigned integer
pub fn Prg::next_uint(self : Prg) -> UInt32 {
  let b = self.next_bytes(4)
  uint32_from_be_bytes(b, 0)
}

///|
/// Generate a pseudorandom integer in range [min, max)
pub fn Prg::next_int_range(self : Prg, min : Int32, max : Int32) -> Int32 {
  if min >= max {
    return min
  }
  let range = max - min
  let u = self.next_uint().reinterpret_as_int() & 0x7FFFFFFF
  min + u % range
}

///|
/// Deterministic Key Derivation Function (HKDF-style expand)
pub fn derive_key(master_key : Bytes, info : String, out_len : Int32) -> Bytes {
  let prg = Prg::new(hmac_sha256(master_key, string_to_bytes(info)))
  prg.next_bytes(out_len)
}
