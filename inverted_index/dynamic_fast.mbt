///|
/// FAST-style state structure used by the reference implementation.
pub struct FastState {
  counter : Int
  state_key : Bytes
} derive(Debug)

///|
/// FAST-style dynamic index reference.
pub struct FastEngine {
  client_states : Map[String, FastState]
  master_key : Bytes
}

///|
/// Create new FastEngine
pub fn FastEngine::new(master_key : Bytes) -> FastEngine {
  { client_states: Map([]), master_key }
}

///|
/// Insert a document into the FAST-style reference index.
pub fn FastEngine::insert(
  self : FastEngine,
  server : ForwardSecureServer,
  keyword : String,
  doc_id : Int,
) -> Unit {
  let cur_c = match self.client_states.get(keyword) {
    Some(s) => s.counter
    None => 0
  }
  let new_c = cur_c + 1
  let k_w = @crypto.hmac_sha256(
    self.master_key,
    @crypto.string_to_bytes(keyword),
  )
  let state_key = @crypto.hmac_sha256(
    k_w,
    @crypto.uint32_to_be_bytes(new_c.reinterpret_as_uint()),
  )
  self.client_states[keyword] = { counter: new_c, state_key }

  let addr = @crypto.hmac_sha256(
    state_key,
    @crypto.string_to_bytes("fast-addr"),
  )
  let val_buf : FixedArray[Byte] = FixedArray::make(8, b'\x00')
  let doc_b = @crypto.uint32_to_be_bytes(doc_id.reinterpret_as_uint())
  let op_b = @crypto.uint32_to_be_bytes(1U)
  for i in 0..<4 {
    val_buf[i] = doc_b[i]
    val_buf[4 + i] = op_b[i]
  }
  let mask = @crypto.hmac_sha256(
    state_key,
    @crypto.string_to_bytes("fast-mask"),
  )
  let val = @crypto.xor_bytes(Bytes::from_array(val_buf), mask)
  let proof = @crypto.hmac_sha256(k_w, addr)

  let entry = EncryptedEntry::new(addr, val, proof)
  server.storage[@crypto.bytes_to_hex(addr)] = entry
}

///|
/// Search with FAST scheme
pub fn FastEngine::search(
  self : FastEngine,
  server : ForwardSecureServer,
  keyword : String,
) -> SearchResult {
  let max_c = match self.client_states.get(keyword) {
    Some(s) => s.counter
    None => 0
  }
  if max_c == 0 {
    return SearchResult::new([], [])
  }

  let k_w = @crypto.hmac_sha256(
    self.master_key,
    @crypto.string_to_bytes(keyword),
  )
  let docs : Array[Int] = []
  let scores : Array[Int] = []

  for c = 1; c <= max_c; c = c + 1 {
    let state_key = @crypto.hmac_sha256(
      k_w,
      @crypto.uint32_to_be_bytes(c.reinterpret_as_uint()),
    )
    let addr = @crypto.hmac_sha256(
      state_key,
      @crypto.string_to_bytes("fast-addr"),
    )
    match server.storage.get(@crypto.bytes_to_hex(addr)) {
      Some(entry) => {
        let mask = @crypto.hmac_sha256(
          state_key,
          @crypto.string_to_bytes("fast-mask"),
        )
        let unmasked = @crypto.xor_bytes(entry.val, mask)
        let doc_u = @crypto.uint32_from_be_bytes(unmasked, 0)
        docs.push(doc_u.reinterpret_as_int())
        scores.push(100)
      }
      None => ()
    }
  }

  SearchResult::new(docs, scores)
}
