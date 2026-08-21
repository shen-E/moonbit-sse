///|
/// Information-Theoretic 2-Server PIR Protocol Client (Chor et al.)
pub struct ItPirClient {
  num_records : Int
  record_size : Int
  prg : @crypto.Prg
}

///|
/// Create new ItPirClient
pub fn ItPirClient::new(
  num_records : Int,
  record_size : Int,
  seed : Bytes,
) -> ItPirClient {
  let prg = @crypto.Prg::new(seed)
  { num_records, record_size, prg }
}

///|
/// Generate query vectors for 2 non-colluding servers to retrieve index target_idx
pub fn ItPirClient::generate_query(
  self : ItPirClient,
  target_idx : Int,
) -> TwoServerQuery {
  let q1 : FixedArray[Bool] = FixedArray::make(self.num_records, false)
  let q2 : FixedArray[Bool] = FixedArray::make(self.num_records, false)

  for i in 0..<self.num_records {
    let rand_bit = (self.prg.next_uint().reinterpret_as_int() & 1) == 1
    q1[i] = rand_bit
    if i == target_idx {
      q2[i] = !rand_bit // Invert bit at target index
    } else {
      q2[i] = rand_bit // Same bit for other indices
    }
  }

  TwoServerQuery::new(q1, q2)
}

///|
/// Server response computation: XOR sum of all database records selected by query vector
pub fn it_pir_server_respond(
  db : DatabaseVector,
  query_vector : FixedArray[Bool],
) -> PirResponse {
  let out : FixedArray[Byte] = FixedArray::make(db.record_size, b'\x00')
  for i in 0..<db.num_records {
    if query_vector[i] {
      let rec = db.records[i]
      for j in 0..<db.record_size {
        out[j] = (out[j].to_int() ^ rec[j].to_int()).to_byte()
      }
    }
  }
  PirResponse::new(Bytes::from_array(out))
}

///|
/// Client reconstructs target record from responses of both servers: r1 XOR r2
pub fn ItPirClient::reconstruct(
  self : ItPirClient,
  resp1 : PirResponse,
  resp2 : PirResponse,
) -> Bytes {
  let out : FixedArray[Byte] = FixedArray::make(self.record_size, b'\x00')
  for i in 0..<self.record_size {
    out[i] = (resp1.data[i].to_int() ^ resp2.data[i].to_int()).to_byte()
  }
  Bytes::from_array(out)
}
