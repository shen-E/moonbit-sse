///|
test "end to end full lifecycle integration test" {
  let master_key = @crypto.hex_to_bytes(
    "1234567812345678123456781234567812345678123456781234567812345678",
  )
  let db = EncryptedDatabase::new(master_key)
  let snap_mgr = SnapshotManager::new(master_key)
  let tx_mgr = TransactionManager::new(db)

  // 1. Bulk Ingest Documents inside Transaction
  tx_mgr.begin()
  for i = 1; i <= 10; i = i + 1 {
    let doc = Document::new(
      i,
      "Article Number " + i.to_string(),
      "Content discussing security, privacy, and encryption protocol " +
      i.to_string(),
      ["security", "privacy", "tag_" + (i % 3).to_string()],
      1700000000UL + i.to_uint64(),
    )
    tx_mgr.record_insert(doc)
  }
  let committed = tx_mgr.commit()
  assert_eq(committed, 10)

  // 2. Search Keyword Tests
  let res_sec = db.search_keyword("security")
  assert_eq(res_sec.doc_ids.length(), 10)

  let res_tag0 = db.search_keyword("tag_0")
  assert_eq(res_tag0.doc_ids.length(), 3) // docs 3, 6, 9

  // 3. Conjunctive Search
  let res_conj = db.search_conjunctive(["privacy", "tag_0"])
  assert_eq(res_conj.doc_ids.length(), 3)

  // 4. Deletion and Backward Security verification
  db.delete_document(3, ["security", "privacy", "tag_0"])
  let res_after_del = db.search_keyword("tag_0")
  assert_eq(res_after_del.doc_ids.length(), 2) // docs 6, 9

  // 5. Snapshot creation and verification
  let snap = snap_mgr.create_snapshot(100UL, db)
  assert_true(snap_mgr.verify_snapshot(snap))
}
