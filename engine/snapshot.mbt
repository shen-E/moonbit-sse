///|
/// Encrypted Database State Snapshot with Integrity Authentication
pub struct DatabaseSnapshot {
  snapshot_id : UInt64
  num_documents : Int
  index_entries_count : Int
  integrity_tag : Bytes
} derive(Debug)

///|
/// Create new DatabaseSnapshot
pub fn DatabaseSnapshot::new(
  snapshot_id : UInt64,
  num_documents : Int,
  index_entries_count : Int,
  integrity_tag : Bytes,
) -> DatabaseSnapshot {
  { snapshot_id, num_documents, index_entries_count, integrity_tag }
}

///|
/// Snapshot Manager
pub struct SnapshotManager {
  master_key : Bytes
  snapshot_key : Bytes
}

///|
/// Create new SnapshotManager
pub fn SnapshotManager::new(master_key : Bytes) -> SnapshotManager {
  let snapshot_key = @crypto.derive_key(master_key, "db-snapshot-integrity", 32)
  { master_key, snapshot_key }
}

///|
/// Create authenticated database snapshot
pub fn SnapshotManager::create_snapshot(
  self : SnapshotManager,
  snapshot_id : UInt64,
  db : EncryptedDatabase,
) -> DatabaseSnapshot {
  let num_docs = db.doc_store.length()
  let index_count = db.server_index.storage.length()

  let buf = BinaryBuffer::new()
  buf.write_int(num_docs)
  buf.write_int(index_count)
  let integrity_tag = @crypto.hmac_sha256(self.snapshot_key, buf.to_bytes())

  DatabaseSnapshot::new(snapshot_id, num_docs, index_count, integrity_tag)
}

///|
/// Verify snapshot integrity
pub fn SnapshotManager::verify_snapshot(
  self : SnapshotManager,
  snapshot : DatabaseSnapshot,
) -> Bool {
  let buf = BinaryBuffer::new()
  buf.write_int(snapshot.num_documents)
  buf.write_int(snapshot.index_entries_count)
  let expected_tag = @crypto.hmac_sha256(self.snapshot_key, buf.to_bytes())
  @crypto.bytes_equal_const_time(snapshot.integrity_tag, expected_tag)
}
