///|
test "prg generator and key derivation" {
  let seed = @crypto.hex_to_bytes(
    "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  )
  let prg1 = @crypto.Prg::new(seed)
  let bytes1 = prg1.next_bytes(32)
  let bytes2 = prg1.next_bytes(16)
  assert_eq(bytes1.length(), 32)
  assert_eq(bytes2.length(), 16)

  let prg2 = @crypto.Prg::new(seed)
  let bytes1_replay = prg2.next_bytes(32)
  assert_true(@crypto.bytes_equal_const_time(bytes1, bytes1_replay))

  let derived = @crypto.derive_key(seed, "sse-trapdoor-key", 32)
  assert_eq(derived.length(), 32)
}
