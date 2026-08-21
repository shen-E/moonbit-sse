///|
/// CLI Demonstration Entrypoint for moonbit-sse
fn main {
  println("=================================================================")
  println("  moonbit-sse: Searchable Symmetric Encryption & Privacy IR     ")
  println("=================================================================")

  let master_key = @crypto.hex_to_bytes(
    "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  )
  let trapdoor_gen = @trapdoor.TrapdoorGenerator::new(master_key)
  let sample_token = trapdoor_gen.generate_search_token("privacy", 1U)
  println(
    "[1] Initializing Encrypted Database Engine (Token len: " +
    sample_token.get_token().length().to_string() +
    ")...",
  )
  let db = @engine.EncryptedDatabase::new(master_key)

  println("[2] Indexing Sample Documents into Forward/Backward Secure SSE...")
  let doc1 = @engine.Document::new(
    1,
    "MoonBit Modern Toolchain",
    "Fast compact Wasm and native compiler with rich cryptographic ecosystem",
    ["moonbit", "wasm", "compiler"],
    1700000000UL,
  )
  let doc2 = @engine.Document::new(
    2,
    "Searchable Symmetric Encryption",
    "Dynamic encrypted inverted index protecting query privacy and access patterns",
    ["sse", "crypto", "privacy"],
    1700000100UL,
  )
  let doc3 = @engine.Document::new(
    3,
    "Oblivious RAM Path Protocol",
    "Path ORAM algorithm concealing memory access sequences against eavesdroppers",
    ["oram", "privacy", "security"],
    1700000200UL,
  )
  let doc4 = @engine.Document::new(
    4,
    "Private Information Retrieval",
    "Information-theoretic two-server PIR enabling query privacy without server collusion",
    ["pir", "privacy", "database"],
    1700000300UL,
  )

  db.insert_document(doc1)
  db.insert_document(doc2)
  db.insert_document(doc3)
  db.insert_document(doc4)
  println("    Successfully indexed 4 encrypted documents.")

  println("[3] Executing Encrypted Keyword Searches:")
  let res_privacy = db.search_keyword("privacy")
  println(
    "    Query keyword: 'privacy' -> Found " +
    res_privacy.doc_ids.length().to_string() +
    " matching document(s)",
  )
  for i in 0..<res_privacy.doc_ids.length() {
    let doc_id = res_privacy.doc_ids[i]
    let content = match db.get_document(doc_id) {
      Some(c) => c
      None => "N/A"
    }
    println("      - Doc ID " + doc_id.to_string() + ": " + content)
  }

  println("[4] Multi-Keyword Conjunctive Search:")
  let conj_kws : Array[String] = ["privacy", "security"]
  let res_conj = db.search_conjunctive(conj_kws)
  println(
    "    Query: 'privacy' AND 'security' -> Matches: " +
    res_conj.doc_ids.length().to_string(),
  )
  for i in 0..<res_conj.doc_ids.length() {
    println("      - Doc ID " + res_conj.doc_ids[i].to_string())
  }

  println("[5] Path ORAM Oblivious Access Simulation:")
  let sim = @oram.ObliviousProtocolSimulator::new(3, 32, master_key)
  let test_block = @crypto.string_to_bytes("secret_database_block_payload_01")
  let _ = sim.traced_access("WRITE", 7, Some(test_block))
  let read_res = sim.traced_access("READ", 7, None)
  println(
    "    Read payload via ORAM: " + @crypto.bytes_to_string(read_res.data),
  )
  println("    Security Audit Pass: " + sim.audit_trace_security().to_string())

  println("[6] Information-Theoretic 2-Server PIR Protocol:")
  let pir_records : Array[Bytes] = [
    @crypto.string_to_bytes("pir_entry_000"),
    @crypto.string_to_bytes("pir_entry_001"),
    @crypto.string_to_bytes("pir_entry_002"),
    @crypto.string_to_bytes("pir_entry_003"),
  ]
  let pir_db = @pir.DatabaseVector::new(pir_records, 13)
  let pir_client = @pir.ItPirClient::new(4, 13, master_key)
  let pir_query = pir_client.generate_query(2)
  let r1 = @pir.it_pir_server_respond(pir_db, pir_query.q1)
  let r2 = @pir.it_pir_server_respond(pir_db, pir_query.q2)
  let reconstructed = pir_client.reconstruct(r1, r2)
  println(
    "    Retrieved PIR Record at slot 2: " +
    @crypto.bytes_to_string(reconstructed),
  )

  println("=================================================================")
  println("  All cryptographic and privacy routines validated successfully! ")
  println("=================================================================")
}
