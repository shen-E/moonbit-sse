///|
test "sha3_256 hash function" {
  let msg = @crypto.string_to_bytes("MoonBit SHA3 Cryptographic Hash")
  let h = @crypto.sha3_256(msg)
  assert_eq(
    @crypto.bytes_to_hex(h),
    "b687943a4e00980aca1f9d35cff1392fb22ddb683b97c2824044b8e73f10a12e",
  )
}
