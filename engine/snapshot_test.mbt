///|
test "database snapshot and verification" {
  let master_key = @crypto.hex_to_bytes(
    "0000111122223333444455556666777700001111222233334444555566667777",
  )
  let db = EncryptedDatabase::new(master_key)
  let snap_mgr = SnapshotManager::new(master_key)

  let doc = Document::new(1, "Title", "Body", ["tag"], 100UL)
  db.insert_document(doc)

  let snap = snap_mgr.create_snapshot(1UL, db)
  assert_eq(snap.num_documents, 1)
  assert_true(snap_mgr.verify_snapshot(snap))
}
