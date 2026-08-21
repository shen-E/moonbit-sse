///|
test "database transaction manager" {
  let master_key = @crypto.hex_to_bytes(
    "dddd0000111122223333444455556666dddd0000111122223333444455556666",
  )
  let db = EncryptedDatabase::new(master_key)
  let tx_mgr = TransactionManager::new(db)

  tx_mgr.begin()
  let doc = Document::new(10, "TxDoc", "Body", ["tx"], 500UL)
  tx_mgr.record_insert(doc)
  let committed = tx_mgr.commit()
  assert_eq(committed, 1)
}
