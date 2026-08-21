///|
test "comprehensive benchmark runner execution" {
  let master_key = @crypto.hex_to_bytes(
    "efefefef01010101efefefef01010101efefefef01010101efefefef01010101",
  )
  let runner = ComprehensiveBenchRunner::new(master_key, 5)

  let r1 = runner.bench_document_ingestion()
  assert_eq(r1.iterations, 5)

  let r2 = runner.bench_search_latency()
  assert_eq(r2.iterations, 5)

  let r3 = runner.bench_oram_access()
  assert_eq(r3.iterations, 10)

  let r4 = runner.bench_pir_retrieval()
  assert_eq(r4.iterations, 5)
}
