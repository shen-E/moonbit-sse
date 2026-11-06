///|
/// State-chained dynamic SSE reference client (Sophos/FAST-style shape).
pub struct ForwardSecureClient {
  trapdoor_gen : @trapdoor.TrapdoorGenerator
  master_key : Bytes
  state_map : Map[String, Int32]
}

///|
/// Create new ForwardSecureClient
pub fn ForwardSecureClient::new(master_key : Bytes) -> ForwardSecureClient {
  let trapdoor_gen = @trapdoor.TrapdoorGenerator::new(master_key)
  { trapdoor_gen, master_key, state_map: Map([]), }
}

///|
/// Server storing dynamic encrypted inverted entries for the reference demo.
pub struct ForwardSecureServer {
  storage : Map[String, EncryptedEntry]
}

///|
/// Create new empty ForwardSecureServer
pub fn ForwardSecureServer::new() -> ForwardSecureServer {
  { storage: Map([]), }
}

///|
/// Client performs an insert update with forward security
pub fn ForwardSecureClient::insert(
  self : ForwardSecureClient,
  server : ForwardSecureServer,
  keyword : String,
  doc_id : Int32,
) -> Unit {
  let cur_c = match self.state_map.get(keyword) {
    Some(c) => c
    None => 0
  }
  let new_c = cur_c + 1
  self.state_map[keyword] = new_c

  let token = self.trapdoor_gen.generate_update_token(
    keyword, doc_id, 1, new_c, 1U,
  )
  let addr_hex = @crypto.bytes_to_hex(token.get_addr())
  let entry = EncryptedEntry::new(
    token.get_addr(),
    token.get_val_mask(),
    token.get_proof(),
  )
  server.storage[addr_hex] = entry
}

///|
/// Client performs a delete update
pub fn ForwardSecureClient::delete(
  self : ForwardSecureClient,
  server : ForwardSecureServer,
  keyword : String,
  doc_id : Int32,
) -> Unit {
  let cur_c = match self.state_map.get(keyword) {
    Some(c) => c
    None => 0
  }
  let new_c = cur_c + 1
  self.state_map[keyword] = new_c

  let token = self.trapdoor_gen.generate_update_token(
    keyword, doc_id, 0, new_c, 1U,
  )
  let addr_hex = @crypto.bytes_to_hex(token.get_addr())
  let entry = EncryptedEntry::new(
    token.get_addr(),
    token.get_val_mask(),
    token.get_proof(),
  )
  server.storage[addr_hex] = entry
}

///|
/// Search with Forward Security: iterates over historical state chains
pub fn ForwardSecureClient::search(
  self : ForwardSecureClient,
  server : ForwardSecureServer,
  keyword : String,
) -> SearchResult {
  let max_c = match self.state_map.get(keyword) {
    Some(c) => c
    None => 0
  }
  if max_c == 0 {
    return SearchResult::new([], [])
  }

  let results_map : Map[Int32, Int32] = Map([])
  let mask_prf_key = self.trapdoor_gen.mask_prf_key

  for c = max_c; c >= 1; c = c - 1 {
    let kw_key = self.trapdoor_gen.derive_keyword_key(keyword)
    let ctr_bytes = @crypto.uint32_to_be_bytes(c.reinterpret_as_uint())
    let addr = @crypto.hmac_sha256(
      self.trapdoor_gen.update_prf_key,
      @crypto.xor_bytes(kw_key, ctr_bytes),
    )
    let addr_hex = @crypto.bytes_to_hex(addr)

    match server.storage.get(addr_hex) {
      Some(entry) => {
        let mask_stream = @crypto.hmac_sha256(mask_prf_key, addr)
        let unmasked = @crypto.xor_bytes(entry.val, mask_stream)
        let doc_u = @crypto.uint32_from_be_bytes(unmasked, 0)
        let op_u = @crypto.uint32_from_be_bytes(unmasked, 4)
        let doc = doc_u.reinterpret_as_int()
        let op = op_u.reinterpret_as_int()

        if op == 1 {
          match results_map.get(doc) {
            Some(_) => ()
            None => results_map[doc] = 1
          }
        } else if op == 0 {
          results_map[doc] = 0
        }
      }
      None => ()
    }
  }

  let final_docs : Array[Int32] = []
  let final_scores : Array[Int32] = []
  for doc, status in results_map {
    if status == 1 {
      final_docs.push(doc)
      final_scores.push(100)
    }
  }
  SearchResult::new(final_docs, final_scores)
}
