///|
test "recursive oram hierarchy" {
  let master_key = @crypto.hex_to_bytes(
    "777788889999aaaa0000111122223333777788889999aaaa0000111122223333",
  )
  let r_oram = @oram.RecursiveOram::new(3, 16, master_key)

  let d = @crypto.string_to_bytes("recursive_payload")
  let _ = r_oram.access(@oram.AccessOp::Write(d), 5)
  let res = r_oram.access(@oram.AccessOp::Read, 5)
  assert_eq(@crypto.bytes_to_string(res.data), "recursive_payload")
}
