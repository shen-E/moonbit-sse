///|
test "encrypted phrase search" {
  let master_key = @crypto.hex_to_bytes(
    "6666777788889999aaaa0000111122226666777788889999aaaa000011112222",
  )
  let engine = PhraseIndexEngine::new(master_key)

  // Document 1 has phrase "searchable encryption" at pos 0 and 1
  engine.index_position("searchable", 1, 0)
  engine.index_position("encryption", 1, 1)

  // Document 2 has "encryption searchable" at pos 0 and 1 (reverse order)
  engine.index_position("encryption", 2, 0)
  engine.index_position("searchable", 2, 1)

  let res = engine.search_phrase("searchable", "encryption", 5)
  assert_eq(res.doc_ids.length(), 1)
  assert_eq(res.doc_ids[0], 1)
}

///|
test "positional posting struct" {
  let p = PositionalPosting::new(1, 42)
  assert_eq(p.doc_id, 1)
  assert_eq(p.position, 42)
}
