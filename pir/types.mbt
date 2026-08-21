///|
/// Database partitioned into N records of uniform block_size
pub struct DatabaseVector {
  records : Array[Bytes]
  num_records : Int
  record_size : Int
} derive(Debug)

///|
/// Create a new DatabaseVector
pub fn DatabaseVector::new(
  records : Array[Bytes],
  record_size : Int,
) -> DatabaseVector {
  let num_records = records.length()
  { records, num_records, record_size }
}

///|
/// 2-Server PIR Query containing two query bitmasks
pub struct TwoServerQuery {
  q1 : FixedArray[Bool]
  q2 : FixedArray[Bool]
} derive(Debug)

///|
/// Create new TwoServerQuery
pub fn TwoServerQuery::new(
  q1 : FixedArray[Bool],
  q2 : FixedArray[Bool],
) -> TwoServerQuery {
  { q1, q2 }
}

///|
/// Single server PIR response block
pub struct PirResponse {
  data : Bytes
} derive(Debug)

///|
/// Create new PirResponse
pub fn PirResponse::new(data : Bytes) -> PirResponse {
  { data, }
}

///|
/// PIR Evaluation Metrics
pub struct PirMetrics {
  database_size_bytes : Int
  query_size_bytes : Int
  response_size_bytes : Int
  communication_overhead_ratio : Double
} derive(Debug)

///|
/// Create new PirMetrics
pub fn PirMetrics::new(
  database_size_bytes : Int,
  query_size_bytes : Int,
  response_size_bytes : Int,
  communication_overhead_ratio : Double,
) -> PirMetrics {
  {
    database_size_bytes,
    query_size_bytes,
    response_size_bytes,
    communication_overhead_ratio,
  }
}
