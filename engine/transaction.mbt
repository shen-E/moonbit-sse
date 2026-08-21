///|
/// Transaction Operation Log Record
pub struct TxLogRecord {
  op_type : String
  doc_id : Int
  keyword : String
} derive(Debug)

///|
/// Encrypted Database Transaction Manager
pub struct TransactionManager {
  db : EncryptedDatabase
  log : Array[TxLogRecord]
  mut in_tx : Bool
}

///|
/// Create new TransactionManager
pub fn TransactionManager::new(db : EncryptedDatabase) -> TransactionManager {
  { db, log: [], in_tx: false }
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
    self.log.push({ op_type: "INSERT", doc_id: doc.id, keyword: doc.title })
    self.db.insert_document(doc)
  }
}

///|
/// Commit transaction
pub fn TransactionManager::commit(self : TransactionManager) -> Int {
  let count = self.log.length()
  self.log.clear()
  self.in_tx = false
  count
}

///|
/// Rollback transaction
pub fn TransactionManager::rollback(self : TransactionManager) -> Unit {
  self.log.clear()
  self.in_tx = false
}
