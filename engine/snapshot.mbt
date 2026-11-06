///|
/// Authenticated snapshot metadata (ID and counts, excluding document content).
#derive(Debug)
pub struct DatabaseSnapshot {
  snapshot_id : UInt64
  num_documents : Int32
  index_entries_count : Int32
  integrity_tag : Bytes
}

///|
/// Create new DatabaseSnapshot
pub fn DatabaseSnapshot::new(
  snapshot_id : UInt64,
  num_documents : Int32,
  index_entries_count : Int32,
  integrity_tag : Bytes,
) -> DatabaseSnapshot {
  { snapshot_id, num_documents, index_entries_count, integrity_tag, }
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
  { master_key, snapshot_key, }
}

///|
/// Create authenticated metadata using the v2 snapshot tag format.
pub fn SnapshotManager::create_snapshot(
  self : SnapshotManager,
  snapshot_id : UInt64,
  db : EncryptedDatabase,
) -> DatabaseSnapshot {
  let num_docs = db.doc_store.length()
  let index_count = db.server_index.storage.length()

  let buf = BinaryBuffer::new()
  buf.write_string("moonbit-sse/snapshot/v2")
  buf.write_bytes(@crypto.uint64_to_be_bytes(snapshot_id))
  buf.write_int(num_docs)
  buf.write_int(index_count)
  let integrity_tag = @crypto.hmac_sha256(self.snapshot_key, buf.to_bytes())

  DatabaseSnapshot::new(snapshot_id, num_docs, index_count, integrity_tag)
}

///|
/// Verify metadata integrity. This does not check content or prevent replay.
pub fn SnapshotManager::verify_snapshot(
  self : SnapshotManager,
  snapshot : DatabaseSnapshot,
) -> Bool {
  guard snapshot.num_documents >= 0 && snapshot.index_entries_count >= 0 else {
    return false
  }
  let buf = BinaryBuffer::new()
  buf.write_string("moonbit-sse/snapshot/v2")
  buf.write_bytes(@crypto.uint64_to_be_bytes(snapshot.snapshot_id))
  buf.write_int(snapshot.num_documents)
  buf.write_int(snapshot.index_entries_count)
  let expected_tag = @crypto.hmac_sha256(self.snapshot_key, buf.to_bytes())
  @crypto.bytes_equal_const_time(snapshot.integrity_tag, expected_tag)
}

///|
pub extend DatabaseSnapshot with @debug.Debug::{to_repr}
