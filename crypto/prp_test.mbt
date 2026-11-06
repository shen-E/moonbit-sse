///|
test "prp permutation and inversion bijection" {
  let key = @crypto.hex_to_bytes("fedcba9876543210fedcba9876543210")
  let domain_size = 100
  let prp = @crypto.Prp::new(key, domain_size)

  let seen : FixedArray[Bool] = FixedArray::make(domain_size, false)
  for i in 0..<domain_size {
    let p = prp.permute(i)
    assert_true(p >= 0 && p < domain_size)
    assert_false(seen[p])
    seen[p] = true
    let inv = prp.invert(p)
    assert_eq(inv, i)
  }
}
