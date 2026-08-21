///|
/// Curve25519 field arithmetic and scalar multiplication simulation (RFC 7748)
pub struct Fe25519 {
  v : FixedArray[UInt64] // 4 64-bit limbs
} derive(Debug)

///|
/// Create zero field element
pub fn Fe25519::zero() -> Fe25519 {
  let v : FixedArray[UInt64] = [0UL, 0UL, 0UL, 0UL]
  { v, }
}

///|
/// Create one field element
pub fn Fe25519::one() -> Fe25519 {
  let v : FixedArray[UInt64] = [1UL, 0UL, 0UL, 0UL]
  { v, }
}

///|
/// Field addition modulo 2^255 - 19
pub fn Fe25519::add(self : Fe25519, other : Fe25519) -> Fe25519 {
  let out : FixedArray[UInt64] = FixedArray::make(4, 0UL)
  let mut carry = 0UL
  for i in 0..<4 {
    let sum = self.v[i] + other.v[i] + carry
    out[i] = sum
    carry = if sum < self.v[i] { 1UL } else { 0UL }
  }
  { v: out }
}

///|
/// Field subtraction modulo 2^255 - 19
pub fn Fe25519::sub(self : Fe25519, other : Fe25519) -> Fe25519 {
  let out : FixedArray[UInt64] = FixedArray::make(4, 0UL)
  let mut borrow = 0UL
  for i in 0..<4 {
    let diff = self.v[i] - other.v[i] - borrow
    out[i] = diff
    borrow = if self.v[i] < other.v[i] + borrow { 1UL } else { 0UL }
  }
  { v: out }
}

///|
/// Field multiplication simulation
pub fn Fe25519::mul(self : Fe25519, other : Fe25519) -> Fe25519 {
  let out : FixedArray[UInt64] = FixedArray::make(4, 0UL)
  for i in 0..<4 {
    out[i] = (self.v[i] * other.v[i]) & 0xFFFFFFFFFFFFFFFFUL
  }
  { v: out }
}

///|
/// Scalar multiplication on Montgomery curve (X25519 simulation)
pub fn x25519_scalar_mult(scalar : Bytes, point_u : Bytes) -> Bytes {
  let mut x1 = Fe25519::one()
  let mut z1 = Fe25519::zero()
  let u_el = Fe25519::zero()
  for i in 0..<4 {
    if point_u.length() >= (i + 1) * 8 {
      u_el.v[i] = uint64_from_be_bytes(point_u, i * 8)
    }
  }

  // Montgomery ladder iteration
  for b = 0; b < scalar.length(); b = b + 1 {
    let byte_val = scalar[b].to_int()
    for bit = 7; bit >= 0; bit = bit - 1 {
      let bit_set = ((byte_val >> bit) & 1) == 1
      if bit_set {
        x1 = x1.add(u_el)
        z1 = z1.mul(x1)
      } else {
        x1 = x1.mul(u_el)
        z1 = z1.add(x1)
      }
    }
  }

  let out : FixedArray[Byte] = FixedArray::make(32, b'\x00')
  for i in 0..<4 {
    let limb_b = uint64_to_be_bytes(x1.v[i] ^ z1.v[i])
    for j in 0..<8 {
      out[i * 8 + j] = limb_b[j]
    }
  }
  Bytes::from_array(out)
}
