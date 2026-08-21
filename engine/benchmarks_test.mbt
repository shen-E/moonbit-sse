///|
test "sse benchmark suite" {
  let master_key = @crypto.hex_to_bytes(
    "aaaa0000111122223333444455556666aaaa0000111122223333444455556666",
  )
  let suite = SseBenchmarkSuite::new(master_key)
  let rep1 = suite.bench_sha256(10)
  assert_eq(rep1.operation_name, "SHA-256")
  let rep2 = suite.bench_aes_ctr(10)
  assert_eq(rep2.operation_name, "AES-128-CTR")
}
