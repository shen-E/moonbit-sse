///|
/// Blind Index Table: PIR-backed oblivious keyword index lookup
pub struct BlindIndexTable {
  db : DatabaseVector
  keyword_map : Map[String, Int]
}

///|
/// Create new BlindIndexTable
pub fn BlindIndexTable::new(record_size : Int) -> BlindIndexTable {
  let db = DatabaseVector::new([], record_size)
  { db, keyword_map: Map([]) }
}

///|
/// Populate blind index with encrypted posting lists
pub fn BlindIndexTable::add_entry(
  self : BlindIndexTable,
  keyword : String,
  encrypted_payload : Bytes,
) -> Unit {
  let idx = self.db.records.length()
  self.db.records.push(encrypted_payload)
  self.keyword_map[keyword] = idx
}

///|
/// Lookup keyword position in blind index
pub fn BlindIndexTable::get_slot(
  self : BlindIndexTable,
  keyword : String,
) -> Int? {
  self.keyword_map.get(keyword)
}
