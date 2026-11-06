///|
/// Pseudo-Random Permutation over domain [0, domain_size - 1]
pub struct Prp {
  key : Bytes
  domain_size : Int32
  radix : Int32
  num_rounds : Int32
}

///|
/// Compute integer square root rounded up
fn int_sqrt_ceil(n : Int32) -> Int32 {
  let mut r = 1
  while r * r < n {
    r = r + 1
  }
  r
}

///|
/// Create a new PRP over domain [0, domain_size - 1]
pub fn Prp::new(key : Bytes, domain_size : Int32) -> Prp {
  let radix = int_sqrt_ceil(domain_size)
  { key, domain_size, radix, num_rounds: 4, }
}

///|
/// Round function for Feistel network
fn prp_round_fn(key : Bytes, round : Int32, r : Int32) -> Int32 {
  let buf : FixedArray[Byte] = FixedArray::make(8, b'\x00')
  let r_u = r.reinterpret_as_uint()
  let r_b = uint32_to_be_bytes(r_u)
  buf[0] = round.to_byte()
  buf[1] = b'\x00'
  buf[2] = b'\x00'
  buf[3] = b'\x00'
  buf[4] = r_b[0]
  buf[5] = r_b[1]
  buf[6] = r_b[2]
  buf[7] = r_b[3]
  let mac = hmac_sha256(key, Bytes::from_array(buf))
  let w = uint32_from_be_bytes(mac, 0)
  w.reinterpret_as_int() & 0x7FFFFFFF
}

///|
/// Forward permutation with cycle-walking
pub fn Prp::permute(self : Prp, x : Int32) -> Int32 {
  if self.domain_size <= 1 {
    return x
  }
  let radix = self.radix
  let mut cur = x
  for ;; {
    let mut l = cur / radix
    let mut r = cur % radix
    for round in 0..<self.num_rounds {
      let f = prp_round_fn(self.key, round, r) % radix
      let new_r = (l + f) % radix
      l = r
      r = new_r
    }
    let mapped = l * radix + r
    if mapped < self.domain_size {
      return mapped
    }
    cur = mapped
  }
}

///|
/// Invert permutation with cycle-walking
pub fn Prp::invert(self : Prp, y : Int32) -> Int32 {
  if self.domain_size <= 1 {
    return y
  }
  let radix = self.radix
  let mut cur = y
  for ;; {
    let mut l = cur / radix
    let mut r = cur % radix
    for round = self.num_rounds - 1; round >= 0; round = round - 1 {
      let f = prp_round_fn(self.key, round, l) % radix
      let mut orig_l = (r - f) % radix
      if orig_l < 0 {
        orig_l = orig_l + radix
      }
      r = l
      l = orig_l
    }
    let mapped = l * radix + r
    if mapped < self.domain_size {
      return mapped
    }
    cur = mapped
  }
}
