///|
test "circuit oram compact access" {
  let key = @crypto.hex_to_bytes(
    "88889999aaaa0000111122223333444488889999aaaa00001111222233334444",
  )
  let cir = CircuitOramManager::new(2, 16, key)
  let d = @crypto.string_to_bytes("circuit_oram_blk")
  let _ = cir.compact_access(AccessOp::Write(d), 3)
  let res = cir.compact_access(AccessOp::Read, 3)
  assert_eq(@crypto.bytes_to_string(res.data), "circuit_oram_blk")
}
