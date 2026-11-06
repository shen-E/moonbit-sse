///|
test "encrypted database full flow" {
  let master_key = @crypto.hex_to_bytes(
    "0102030405060708090a0b0c0d0e0f100102030405060708090a0b0c0d0e0f10",
  )
  let db = @engine.EncryptedDatabase::new(master_key)

  let doc1 = @engine.Document::new(
    1,
    "MoonBit Language",
    "Modern high performance programming language for Cloud and WebAssembly",
    ["compiler", "wasm"],
    1000UL,
  )
  let doc2 = @engine.Document::new(
    2,
    "Searchable Encryption",
    "Privacy preserving symmetric encrypted search primitives with forward security",
    ["crypto", "security"],
    1010UL,
  )
  let doc3 = @engine.Document::new(
    3,
    "Oblivious RAM",
    "Path ORAM implementation protecting client access patterns",
    ["oram", "privacy"],
    1020UL,
  )

  db.insert_document(doc1)
  db.insert_document(doc2)
  db.insert_document(doc3)

  // Search keyword "language"
  let res_lang = db.search_keyword("language")
  assert_eq(res_lang.doc_ids.length(), 1)
  assert_eq(res_lang.doc_ids[0], 1)

  // Search keyword "privacy" -> doc 2 and 3
  let res_priv = db.search_keyword("privacy")
  assert_eq(res_priv.doc_ids.length(), 2)

  // Retrieve decrypted document 1
  let d1 = db.get_document(1)
  match d1 {
    Some(txt) => assert_true(txt.length() > 0)
    None => assert_true(false)
  }
}

///|
test "query planner optimization" {
  let opt_fast = @engine.QueryOptimizer::new(false)
  let plan1 = opt_fast.plan(["crypto"])
  assert_eq(plan1.estimated_cost_ms, 2)

  let opt_secure = @engine.QueryOptimizer::new(true)
  let plan2 = opt_secure.plan(["confidential"])
  assert_eq(plan2.estimated_cost_ms, 15)
}

///|
test "binary buffer serialization" {
  let buf = @engine.BinaryBuffer::new()
  buf.write_int(42)
  buf.write_string("hello")
  let b = buf.to_bytes()
  assert_true(b.length() >= 9)
}

///|
test "performance auditor" {
  let auditor = @engine.PerformanceAuditor::new()
  let a1 = auditor.record_insert()
  let a2 = a1.record_query()
  assert_eq(a2.total_inserts, 1)
  assert_eq(a2.total_queries, 1)
}

///|
test "document payload preserves Unicode text" {
  let db = @engine.EncryptedDatabase::new(b"Unicode document regression key!")
  db.insert_document(
    @engine.Document::new(1, "中文🔐", "安全检索", [], 0UL),
  )
  assert_eq(db.get_document(1), Some("中文🔐|||安全检索"))
}
