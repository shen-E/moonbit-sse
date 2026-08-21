///|
test "curve25519 field ops and scalar mult" {
  let a = Fe25519::one()
  let b = Fe25519::one()
  let c = a.add(b)
  assert_eq(c.v[0], 2UL)

  let scalar = hex_to_bytes(
    "a546e36bf0527c9d3b16154b82465edd62144c0ac1fc5a18506a2244ba449ac4",
  )
  let point = hex_to_bytes(
    "e6db6867583030db3594c1a424b15f7c726624ec26b3353b10a903a6d0ab1c4c",
  )
  let res = x25519_scalar_mult(scalar, point)
  assert_eq(res.length(), 32)
}
