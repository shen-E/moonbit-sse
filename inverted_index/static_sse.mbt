///|
/// Static SSE Scheme (Curtmola SSE-1/SSE-2 primitive)
pub struct StaticSseClient {
  trapdoor_gen : @trapdoor.TrapdoorGenerator
  enc_key : Bytes
}

///|
/// Create StaticSseClient with master key
pub fn StaticSseClient::new(master_key : Bytes) -> StaticSseClient {
  let trapdoor_gen = @trapdoor.TrapdoorGenerator::new(master_key)
  let enc_key = @crypto.derive_key(master_key, "static-sse-enc-key", 32)
  { trapdoor_gen, enc_key, }
}

///|
/// Static SSE Server storing encrypted posting lists
pub struct StaticSseServer {
  table : Map[String, Bytes]
}

///|
/// Create new empty StaticSseServer
pub fn StaticSseServer::new() -> StaticSseServer {
  { table: Map([]), }
}

///|
/// Client builds encrypted index from plaintext keyword-to-docs dictionary
pub fn StaticSseClient::build_index(
  self : StaticSseClient,
  raw_index : Map[String, Array[Int32]],
) -> StaticSseServer {
  let server = StaticSseServer::new()

  for kw, doc_ids in raw_index {
    let token = self.trapdoor_gen.generate_search_token(kw, 1U)
    let addr_hex = @crypto.bytes_to_hex(token.get_token())

    // Serialize and encrypt doc_ids
    let count = doc_ids.length()
    let buf : FixedArray[Byte] = FixedArray::make(count * 4, b'\x00')
    for i in 0..<count {
      let b = @crypto.uint32_to_be_bytes(doc_ids[i].reinterpret_as_uint())
      for j in 0..<4 {
        buf[i * 4 + j] = b[j]
      }
    }
    let raw_payload = Bytes::from_array(buf)
    let iv = @crypto.derive_key(self.enc_key, kw, 16)
    let enc_payload = @crypto.aes128_ctr(self.enc_key, iv, raw_payload)

    server.table[addr_hex] = enc_payload
  }

  server
}

///|
/// Client issues search token, server retrieves ciphertext, client decrypts doc_ids
pub fn StaticSseClient::search(
  self : StaticSseClient,
  server : StaticSseServer,
  keyword : String,
) -> SearchResult {
  let token = self.trapdoor_gen.generate_search_token(keyword, 1U)
  let addr_hex = @crypto.bytes_to_hex(token.get_token())

  match server.table.get(addr_hex) {
    Some(enc_payload) => {
      let iv = @crypto.derive_key(self.enc_key, keyword, 16)
      let decrypted = @crypto.aes128_ctr(self.enc_key, iv, enc_payload)
      let num_docs = decrypted.length() / 4
      let doc_ids : Array[Int32] = []
      let scores : Array[Int32] = []
      for i in 0..<num_docs {
        let doc_u = @crypto.uint32_from_be_bytes(decrypted, i * 4)
        doc_ids.push(doc_u.reinterpret_as_int())
        scores.push(100)
      }
      SearchResult::new(doc_ids, scores)
    }
    None => SearchResult::new([], [])
  }
}
