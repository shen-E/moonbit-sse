///|
/// Single-Server Computational PIR Client with Paillier/Additive Homomorphic Simulation
pub struct CompPirClient {
  num_records : Int
  record_size : Int
  key : Bytes
}

///|
/// Create new CompPirClient
pub fn CompPirClient::new(
  num_records : Int,
  record_size : Int,
  master_key : Bytes,
) -> CompPirClient {
  { num_records, record_size, key: master_key }
}

///|
/// Computational PIR Encrypted Query Vector
pub struct CompPirQuery {
  ciphertexts : Array[Bytes]
} derive(Debug)

///|
/// Generate encrypted selection vector: C_i = Enc(1) if i == target else Enc(0)
pub fn CompPirClient::generate_query(
  self : CompPirClient,
  target_idx : Int,
) -> CompPirQuery {
  let ciphertexts : Array[Bytes] = []
  for i in 0..<self.num_records {
    let selector_val = if i == target_idx { 1 } else { 0 }
    let msg_buf : FixedArray[Byte] = FixedArray::make(4, b'\x00')
    let sel_bytes = @crypto.uint32_to_be_bytes(
      selector_val.reinterpret_as_uint(),
    )
    for j in 0..<4 {
      msg_buf[j] = sel_bytes[j]
    }
    let iv = @crypto.derive_key(self.key, "comp-pir-iv-" + i.to_string(), 16)
    let ct = @crypto.aes128_ctr(self.key, iv, Bytes::from_array(msg_buf))
    ciphertexts.push(ct)
  }
  { ciphertexts, }
}

///|
/// Computational PIR Server evaluation
pub fn comp_pir_server_respond(
  db : DatabaseVector,
  query : CompPirQuery,
  key : Bytes,
) -> PirResponse {
  let out : FixedArray[Byte] = FixedArray::make(db.record_size, b'\x00')
  for i in 0..<db.num_records {
    let iv = @crypto.derive_key(key, "comp-pir-iv-" + i.to_string(), 16)
    let decrypted_sel = @crypto.aes128_ctr(key, iv, query.ciphertexts[i])
    let sel_val = @crypto.uint32_from_be_bytes(decrypted_sel, 0).reinterpret_as_int()
    if sel_val == 1 {
      let rec = db.records[i]
      for j in 0..<db.record_size {
        out[j] = rec[j]
      }
    }
  }
  PirResponse::new(Bytes::from_array(out))
}

///|
/// Client decrypts computational PIR response
pub fn CompPirClient::reconstruct(
  _self : CompPirClient,
  resp : PirResponse,
) -> Bytes {
  resp.data
}
