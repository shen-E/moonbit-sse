///|
test "database snapshot and verification" {
  let master_key = @crypto.hex_to_bytes(
    "0000111122223333444455556666777700001111222233334444555566667777",
  )
  let db = @engine.EncryptedDatabase::new(master_key)
  let snap_mgr = @engine.SnapshotManager::new(master_key)

  let doc = @engine.Document::new(1, "Title", "Body", ["tag"], 100UL)
  db.insert_document(doc)

  let snap = snap_mgr.create_snapshot(1UL, db)
  assert_eq(snap.num_documents, 1)
  assert_true(snap_mgr.verify_snapshot(snap))
}

///|
test "snapshot authentication binds all ID bits, counts, and tag" {
  let key = @crypto.string_to_bytes("snapshot authentication regression key")
  let db = @engine.EncryptedDatabase::new(key)
  let manager = @engine.SnapshotManager::new(key)
  let snapshot = manager.create_snapshot(1UL, db)
  for id in [0UL, 2UL, 0x100000001UL, 0xFFFFFFFFFFFFFFFFUL] {
    let changed = @engine.DatabaseSnapshot::new(
      id,
      snapshot.num_documents,
      snapshot.index_entries_count,
      snapshot.integrity_tag,
    )
    assert_false(manager.verify_snapshot(changed))
  }
  for (documents, entries) in [(1, 0), (0, 1), (-1, 0), (0, -1)] {
    let changed = @engine.DatabaseSnapshot::new(
      1UL,
      documents,
      entries,
      snapshot.integrity_tag,
    )
    assert_false(manager.verify_snapshot(changed))
  }
  let changed_tag = @engine.DatabaseSnapshot::new(1UL, 0, 0, b"incorrect tag")
  assert_false(manager.verify_snapshot(changed_tag))
  let other_manager = @engine.SnapshotManager::new(b"another key")
  assert_false(other_manager.verify_snapshot(snapshot))
}

///|
test "snapshot v2 rejects the old counts-only authentication tag" {
  let key = b"snapshot migration regression key"
  let manager = @engine.SnapshotManager::new(key)
  let old_key = @crypto.derive_key(key, "db-snapshot-integrity", 32)
  let counts = @engine.BinaryBuffer::new()
  counts.write_int(0)
  counts.write_int(0)
  let legacy = @engine.DatabaseSnapshot::new(
    1UL,
    0,
    0,
    @crypto.hmac_sha256(old_key, counts.to_bytes()),
  )
  assert_false(manager.verify_snapshot(legacy))
}
