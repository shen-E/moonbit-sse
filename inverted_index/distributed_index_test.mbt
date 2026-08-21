///|
test "distributed sharded sse index" {
  let master_key = @crypto.hex_to_bytes(
    "55556666777788889999aaaa0000111155556666777788889999aaaa00001111",
  )
  let coord = DistributedIndexCoordinator::new(master_key, 4)

  coord.insert("parallel", 10)
  coord.insert("parallel", 11)
  coord.insert("parallel", 12)
  coord.insert("parallel", 13)

  let res = coord.search_distributed("parallel")
  assert_eq(res.doc_ids.length(), 4)
}
