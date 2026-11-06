///|
/// Database partitioned into N records of uniform block_size
#derive(Debug)
pub struct DatabaseVector {
  records : Array[Bytes]
  num_records : Int32
  record_size : Int32
}

///|
/// Create a new DatabaseVector
pub fn DatabaseVector::new(
  records : Array[Bytes],
  record_size : Int32,
) -> DatabaseVector {
  let num_records = records.length()
  { records, num_records, record_size, }
}

///|
/// 2-Server PIR Query containing two query bitmasks
#derive(Debug)
pub struct TwoServerQuery {
  q1 : FixedArray[Bool]
  q2 : FixedArray[Bool]
}

///|
/// Create new TwoServerQuery
pub fn TwoServerQuery::new(
  q1 : FixedArray[Bool],
  q2 : FixedArray[Bool],
) -> TwoServerQuery {
  { q1, q2, }
}

///|
/// Single server PIR response block
#derive(Debug)
pub struct PirResponse {
  data : Bytes
}

///|
/// Create new PirResponse
pub fn PirResponse::new(data : Bytes) -> PirResponse {
  { data, }
}

///|
/// PIR Evaluation Metrics
#derive(Debug)
pub struct PirMetrics {
  database_size_bytes : Int32
  query_size_bytes : Int32
  response_size_bytes : Int32
  communication_overhead_ratio : Double
}

///|
/// Create new PirMetrics
pub fn PirMetrics::new(
  database_size_bytes : Int32,
  query_size_bytes : Int32,
  response_size_bytes : Int32,
  communication_overhead_ratio : Double,
) -> PirMetrics {
  {
    database_size_bytes,
    query_size_bytes,
    response_size_bytes,
    communication_overhead_ratio,
  }
}

///|
pub extend DatabaseVector with @debug.Debug::{to_repr}

///|
pub extend PirMetrics with @debug.Debug::{to_repr}

///|
pub extend PirResponse with @debug.Debug::{to_repr}

///|
pub extend TwoServerQuery with @debug.Debug::{to_repr}
