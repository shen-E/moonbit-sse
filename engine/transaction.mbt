///|
/// Transaction Operation Log Record
#derive(Debug)
pub struct TxLogRecord {
  op_type : String
  doc_id : Int32
  keyword : String
}

///|
/// In-memory transaction operation-log demo.
///
/// Rollback discards the pending log but does not undo mutations already
/// applied to the database. It is not a durable or ACID transaction manager.
pub struct TransactionManager {
  db : EncryptedDatabase
  log : Array[TxLogRecord]
  mut in_tx : Bool
}

///|
/// Create new TransactionManager
pub fn TransactionManager::new(db : EncryptedDatabase) -> TransactionManager {
  { db, log: [], in_tx: false, }
}

///|
/// Begin a new transaction
pub fn TransactionManager::begin(self : TransactionManager) -> Unit {
  self.log.clear()
  self.in_tx = true
}

///|
/// Record operation in transaction
pub fn TransactionManager::record_insert(
  self : TransactionManager,
  doc : Document,
) -> Unit {
  if self.in_tx {
    self.log.push({ op_type: "INSERT", doc_id: doc.id, keyword: doc.title, })
    self.db.insert_document(doc)
  }
}

///|
/// Commit transaction
pub fn TransactionManager::commit(self : TransactionManager) -> Int32 {
  let count = self.log.length()
  self.log.clear()
  self.in_tx = false
  count
}

///|
/// Discard the pending operation log without reverting prior mutations.
pub fn TransactionManager::rollback(self : TransactionManager) -> Unit {
  self.log.clear()
  self.in_tx = false
}

///|
pub extend TxLogRecord with @debug.Debug::{to_repr}
