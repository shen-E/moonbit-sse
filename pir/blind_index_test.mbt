///|
test "blind index maps keywords to posting slots" {
  let table = BlindIndexTable::new(8)
  table.add_entry("privacy", @crypto.string_to_bytes("posting_0"))
  table.add_entry("search", @crypto.string_to_bytes("posting_1"))

  match table.get_slot("privacy") {
    Some(slot) => assert_eq(slot, 0)
    None => assert_true(false)
  }
  match table.get_slot("search") {
    Some(slot) => assert_eq(slot, 1)
    None => assert_true(false)
  }
  match table.get_slot("missing") {
    Some(_) => assert_true(false)
    None => ()
  }
}
