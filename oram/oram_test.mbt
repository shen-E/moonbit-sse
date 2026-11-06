///|
test "path oram read and write correctness" {
  let key = @crypto.hex_to_bytes(
    "1234123412341234123412341234123412341234123412341234123412341234",
  )
  let oram = @oram.PathOram::new(3, 4, 16, key)

  let data42 = @crypto.string_to_bytes("secret_block_42_")
  let data99 = @crypto.string_to_bytes("secret_block_99_")

  // Write block 42 and 99
  let _ = oram.access(@oram.AccessOp::Write(data42), 42)
  let _ = oram.access(@oram.AccessOp::Write(data99), 99)

  // Read block 42
  let res42 = oram.access(@oram.AccessOp::Read, 42)
  assert_eq(@crypto.bytes_to_string(res42.data), "secret_block_42_")

  // Read block 99
  let res99 = oram.access(@oram.AccessOp::Read, 99)
  assert_eq(@crypto.bytes_to_string(res99.data), "secret_block_99_")
}

///|
test "sqrt oram read, write, and periodic rebuild" {
  let key = @crypto.hex_to_bytes(
    "abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
  )
  let sqrt_oram = @oram.SqrtOram::new(16, 8, key)

  let d1 = @crypto.string_to_bytes("data_001")
  let d2 = @crypto.string_to_bytes("data_002")

  let _ = sqrt_oram.access(@oram.AccessOp::Write(d1), 5)
  let _ = sqrt_oram.access(@oram.AccessOp::Write(d2), 10)

  let r1 = sqrt_oram.access(@oram.AccessOp::Read, 5)
  assert_eq(@crypto.bytes_to_string(r1), "data_001")

  let r2 = sqrt_oram.access(@oram.AccessOp::Read, 10)
  assert_eq(@crypto.bytes_to_string(r2), "data_002")
}

///|
test "oblivious simulator and trace audit" {
  let key = @crypto.hex_to_bytes(
    "9876543210987654321098765432109876543210987654321098765432109876",
  )
  let sim = @oram.ObliviousProtocolSimulator::new(3, 16, key)

  let d = @crypto.string_to_bytes("block_payload_01")
  let _ = sim.traced_access("WRITE", 1, Some(d))
  let _ = sim.traced_access("READ", 1, None)
  let _ = sim.traced_access("READ", 2, None)

  assert_true(sim.audit_trace_security())
  assert_eq(sim.traces.length(), 3)
}
