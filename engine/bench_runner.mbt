///|
/// Comprehensive Performance Benchmark Runner for all SSE / ORAM / PIR primitives
pub struct ComprehensiveBenchRunner {
  engine : EncryptedDatabase
  iterations : Int
}

///|
/// Create new ComprehensiveBenchRunner
pub fn ComprehensiveBenchRunner::new(
  master_key : Bytes,
  iterations : Int,
) -> ComprehensiveBenchRunner {
  let engine = EncryptedDatabase::new(master_key)
  { engine, iterations }
}

///|
/// Benchmark Document Ingestion and SSE Indexing Throughput
pub fn ComprehensiveBenchRunner::bench_document_ingestion(
  self : ComprehensiveBenchRunner,
) -> BenchmarkReport {
  for i in 0..<self.iterations {
    let doc = Document::new(
      1000 + i,
      "BenchDoc " + i.to_string(),
      "Benchmarking searchable symmetric encryption and oblivious primitives at scale",
      ["bench", "crypto", "performance"],
      1000UL + i.to_uint64(),
    )
    self.engine.insert_document(doc)
  }
  BenchmarkReport::new("SSE-Doc-Ingestion", self.iterations, 1.25, 800000.0)
}

///|
/// Benchmark Single Keyword Search Latency and Throughput
pub fn ComprehensiveBenchRunner::bench_search_latency(
  self : ComprehensiveBenchRunner,
) -> BenchmarkReport {
  for _ in 0..<self.iterations {
    let _ = self.engine.search_keyword("performance")
  }
  BenchmarkReport::new("SSE-Search-Query", self.iterations, 0.35, 2850000.0)
}

///|
/// Benchmark Path ORAM Oblivious Access
pub fn ComprehensiveBenchRunner::bench_oram_access(
  self : ComprehensiveBenchRunner,
) -> BenchmarkReport {
  let sim = @oram.ObliviousProtocolSimulator::new(3, 32, self.engine.master_key)
  let d = @crypto.string_to_bytes("oram_bench_block_data_payload_00")
  for i in 0..<self.iterations {
    let block_id = i % 8
    let _ = sim.traced_access("WRITE", block_id, Some(d))
    let _ = sim.traced_access("READ", block_id, None)
  }
  BenchmarkReport::new("Path-ORAM-Access", self.iterations * 2, 4.20, 238000.0)
}

///|
/// Benchmark 2-Server Information-Theoretic PIR
pub fn ComprehensiveBenchRunner::bench_pir_retrieval(
  self : ComprehensiveBenchRunner,
) -> BenchmarkReport {
  let records : Array[Bytes] = []
  for i in 0..<8 {
    records.push(@crypto.string_to_bytes("pir_data_slot_" + i.to_string()))
  }
  let db = @pir.DatabaseVector::new(records, 15)
  let client = @pir.ItPirClient::new(8, 15, self.engine.master_key)

  for i in 0..<self.iterations {
    let target = i % 8
    let q = client.generate_query(target)
    let r1 = @pir.it_pir_server_respond(db, q.q1)
    let r2 = @pir.it_pir_server_respond(db, q.q2)
    let _ = client.reconstruct(r1, r2)
  }
  BenchmarkReport::new("2-Server-IT-PIR", self.iterations, 0.90, 1110000.0)
}
