///|
/// PIR by Keyword: retrieves content mapped to string keys without revealing key
pub struct KeywordPirEngine {
  it_client : ItPirClient
  key_slots : Map[String, Int32]
  db : DatabaseVector
}

///|
/// Create new KeywordPirEngine
pub fn KeywordPirEngine::new(
  num_slots : Int32,
  record_size : Int32,
  seed : Bytes,
) -> KeywordPirEngine {
  let it_client = ItPirClient::new(num_slots, record_size, seed)
  let records : Array[Bytes] = []
  for _ in 0..<num_slots {
    let buf : FixedArray[Byte] = FixedArray::make(record_size, b'\x00')
    records.push(Bytes::from_array(buf))
  }
  let db = DatabaseVector::new(records, record_size)
  { it_client, key_slots: Map([]), db, }
}

///|
/// Insert key-value into PIR slot
pub fn KeywordPirEngine::put(
  self : KeywordPirEngine,
  key : String,
  val : Bytes,
) -> Unit {
  let slot = self.key_slots.length()
  if slot < self.db.num_records {
    self.db.records[slot] = val
    self.key_slots[key] = slot
  }
}

///|
/// Query value by keyword with Information-Theoretic PIR
pub fn KeywordPirEngine::get(self : KeywordPirEngine, key : String) -> Bytes? {
  match self.key_slots.get(key) {
    Some(slot) => {
      let query = self.it_client.generate_query(slot)
      let resp1 = it_pir_server_respond(self.db, query.q1)
      let resp2 = it_pir_server_respond(self.db, query.q2)
      Some(self.it_client.reconstruct(resp1, resp2))
    }
    None => None
  }
}
