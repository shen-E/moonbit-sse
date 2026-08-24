///|
/// Document Model
pub struct Document {
  id : Int
  title : String
  body : String
  tags : Array[String]
  created_at : UInt64
} derive(Debug)

///|
/// Create new Document
pub fn Document::new(
  id : Int,
  title : String,
  body : String,
  tags : Array[String],
  created_at : UInt64,
) -> Document {
  { id, title, body, tags, created_at }
}

///|
/// Simple word tokenizer splitting on spaces and punctuation
pub fn tokenize_text(text : String) -> Array[String] {
  let words : Array[String] = []
  let buf = StringBuilder()
  for i in 0..<text.length() {
    let c_code = text[i].to_int()
    let is_alphanumeric = (c_code >= 'a'.to_int() && c_code <= 'z'.to_int()) ||
      (c_code >= 'A'.to_int() && c_code <= 'Z'.to_int()) ||
      (c_code >= '0'.to_int() && c_code <= '9'.to_int())
    if is_alphanumeric {
      // Lowercase conversion
      let lower_code = if c_code >= 'A'.to_int() && c_code <= 'Z'.to_int() {
        c_code + 32
      } else {
        c_code
      }
      buf.write_char(lower_code.unsafe_to_char())
    } else {
      let word = buf.to_string()
      if word.length() > 0 {
        words.push(word)
        buf.reset()
      }
    }
  }
  let last_word = buf.to_string()
  if last_word.length() > 0 {
    words.push(last_word)
  }
  words
}

///|
/// End-to-End Encrypted Database Engine
pub struct EncryptedDatabase {
  master_key : Bytes
  trapdoor_gen : @trapdoor.TrapdoorGenerator
  pir_client : @pir.ItPirClient
  doc_enc_key : Bytes
  sse_engine : @inverted_index.BackwardSecureEngine
  server_index : @inverted_index.ForwardSecureServer
  oram_storage : @oram.TreeOramEngine
  doc_store : Map[Int, Bytes] // Encrypted document payload storage
}

///|
/// Initialize EncryptedDatabase with master secret key
pub fn EncryptedDatabase::new(master_key : Bytes) -> EncryptedDatabase {
  let trapdoor_gen = @trapdoor.TrapdoorGenerator::new(master_key)
  let pir_client = @pir.ItPirClient::new(100, 32, master_key)
  let doc_enc_key = @crypto.derive_key(master_key, "db-document-encryption", 32)
  let sse_engine = @inverted_index.BackwardSecureEngine::new(master_key)
  let server_index = @inverted_index.ForwardSecureServer::new()
  let oram_storage = @oram.TreeOramEngine::new(4, 128, master_key)
  {
    master_key,
    trapdoor_gen,
    pir_client,
    doc_enc_key,
    sse_engine,
    server_index,
    oram_storage,
    doc_store: Map([]),
  }
}

///|
/// Encrypt and insert a document into the database with searchable index
pub fn EncryptedDatabase::insert_document(
  self : EncryptedDatabase,
  doc : Document,
) -> Unit {
  // 1. Extract keywords from title, body, and tags
  let title_words = tokenize_text(doc.title)
  let body_words = tokenize_text(doc.body)
  let kw_set : Map[String, Bool] = Map([])

  for i in 0..<title_words.length() {
    kw_set[title_words[i]] = true
  }
  for i in 0..<body_words.length() {
    kw_set[body_words[i]] = true
  }
  for i in 0..<doc.tags.length() {
    kw_set[doc.tags[i]] = true
  }

  // 2. Index keywords into the dynamic SSE reference index
  for kw, _ in kw_set {
    self.sse_engine.insert(self.server_index, kw, doc.id)
  }

  // 3. Encrypt document body and store
  let payload = @crypto.string_to_bytes(doc.title + "|||" + doc.body)
  let iv = @crypto.derive_key(
    self.doc_enc_key,
    "doc-iv-" + doc.id.to_string(),
    16,
  )
  let encrypted_payload = @crypto.aes128_ctr(self.doc_enc_key, iv, payload)
  self.doc_store[doc.id] = encrypted_payload

  // 4. Store in ORAM for oblivious retrieval
  let _ = self.oram_storage.write(doc.id, encrypted_payload)
}

///|
/// Delete document from index and storage
pub fn EncryptedDatabase::delete_document(
  self : EncryptedDatabase,
  doc_id : Int,
  keywords : Array[String],
) -> Unit {
  for i in 0..<keywords.length() {
    self.sse_engine.delete(self.server_index, keywords[i], doc_id)
  }
  self.doc_store.remove(doc_id)
}

///|
/// Search by single keyword and retrieve matching document IDs
pub fn EncryptedDatabase::search_keyword(
  self : EncryptedDatabase,
  keyword : String,
) -> @inverted_index.SearchResult {
  self.sse_engine.search(self.server_index, keyword)
}

///|
/// Search by conjunctive multi-keywords (w1 AND w2)
pub fn EncryptedDatabase::search_conjunctive(
  self : EncryptedDatabase,
  keywords : Array[String],
) -> @inverted_index.SearchResult {
  @inverted_index.search_conjunctive(
    self.sse_engine.client,
    self.server_index,
    keywords,
  )
}

///|
/// Decrypt document payload
pub fn EncryptedDatabase::get_document(
  self : EncryptedDatabase,
  doc_id : Int,
) -> String? {
  match self.doc_store.get(doc_id) {
    Some(enc_payload) => {
      let iv = @crypto.derive_key(
        self.doc_enc_key,
        "doc-iv-" + doc_id.to_string(),
        16,
      )
      let decrypted = @crypto.aes128_ctr(self.doc_enc_key, iv, enc_payload)
      Some(@crypto.bytes_to_string(decrypted))
    }
    None => None
  }
}
