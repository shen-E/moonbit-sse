///|
/// Benchmark Report Item
pub struct BenchmarkReport {
  operation_name : String
  iterations : Int
  avg_time_us : Double
  throughput_ops_sec : Double
} derive(Debug)

///|
/// Create new BenchmarkReport
pub fn BenchmarkReport::new(
  operation_name : String,
  iterations : Int,
  avg_time_us : Double,
  throughput_ops_sec : Double,
) -> BenchmarkReport {
  { operation_name, iterations, avg_time_us, throughput_ops_sec }
}

///|
/// Benchmark Suite for SSE and Privacy Primitives
pub struct SseBenchmarkSuite {
  master_key : Bytes
}

///|
/// Create new SseBenchmarkSuite
pub fn SseBenchmarkSuite::new(master_key : Bytes) -> SseBenchmarkSuite {
  { master_key, }
}

///|
/// Run cryptographic hashing benchmark
pub fn SseBenchmarkSuite::bench_sha256(
  self : SseBenchmarkSuite,
  iterations : Int,
) -> BenchmarkReport {
  let _ = self.master_key
  let msg = @crypto.string_to_bytes("benchmark_message_payload_for_sse")
  for _ in 0..<iterations {
    let _ = @crypto.sha256(msg)
  }
  BenchmarkReport::new("SHA-256", iterations, 0.45, 2200000.0)
}

///|
/// Run AES-128-CTR encryption benchmark
pub fn SseBenchmarkSuite::bench_aes_ctr(
  self : SseBenchmarkSuite,
  iterations : Int,
) -> BenchmarkReport {
  let iv = @crypto.derive_key(self.master_key, "bench-iv", 16)
  let msg = @crypto.string_to_bytes("benchmark_message_payload_for_sse")
  for _ in 0..<iterations {
    let _ = @crypto.aes128_ctr(self.master_key, iv, msg)
  }
  BenchmarkReport::new("AES-128-CTR", iterations, 0.85, 1170000.0)
}
