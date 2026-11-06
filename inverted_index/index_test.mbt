///|
test "static sse build and search" {
  let master_key = @crypto.hex_to_bytes(
    "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff",
  )
  let client = @inverted_index.StaticSseClient::new(master_key)

  let raw_index : Map[String, Array[Int32]] = Map([])
  raw_index["privacy"] = [1, 5, 9]
  raw_index["crypto"] = [2, 5, 8]
  raw_index["moonbit"] = [1, 2, 3, 5]

  let server = client.build_index(raw_index)

  let res_priv = client.search(server, "privacy")
  assert_eq(res_priv.doc_ids.length(), 3)
  assert_eq(res_priv.doc_ids[0], 1)
  assert_eq(res_priv.doc_ids[1], 5)
  assert_eq(res_priv.doc_ids[2], 9)

  let res_none = client.search(server, "nonexistent")
  assert_eq(res_none.doc_ids.length(), 0)
}

///|
test "forward and backward secure sse dynamic updates" {
  let master_key = @crypto.hex_to_bytes(
    "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
  )
  let engine = @inverted_index.BackwardSecureEngine::new(master_key)
  let server = @inverted_index.ForwardSecureServer::new()

  // Insert documents
  engine.insert(server, "search", 101)
  engine.insert(server, "search", 102)
  engine.insert(server, "search", 103)

  let res1 = engine.search(server, "search")
  assert_eq(res1.doc_ids.length(), 3)

  // Delete document 102
  engine.delete(server, "search", 102)
  let res2 = engine.search(server, "search")
  assert_eq(res2.doc_ids.length(), 2)
}

///|
test "multi-keyword conjunctive and disjunctive search" {
  let master_key = @crypto.hex_to_bytes(
    "fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210",
  )
  let client = @inverted_index.ForwardSecureClient::new(master_key)
  let server = @inverted_index.ForwardSecureServer::new()

  client.insert(server, "database", 1)
  client.insert(server, "database", 2)
  client.insert(server, "encrypted", 2)
  client.insert(server, "encrypted", 3)

  // Conjunctive: database AND encrypted -> [2]
  let kws : Array[String] = ["database", "encrypted"]
  let conj_res = @inverted_index.search_conjunctive(client, server, kws)
  assert_eq(conj_res.doc_ids.length(), 1)
  assert_eq(conj_res.doc_ids[0], 2)

  // Disjunctive: database OR encrypted -> [1, 2, 3]
  let disj_res = @inverted_index.search_disjunctive(client, server, kws)
  assert_eq(disj_res.doc_ids.length(), 3)
}

///|
test "boolean query evaluation" {
  let master_key = @crypto.hex_to_bytes(
    "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
  )
  let client = @inverted_index.ForwardSecureClient::new(master_key)
  let server = @inverted_index.ForwardSecureServer::new()

  client.insert(server, "tagA", 10)
  client.insert(server, "tagA", 20)
  client.insert(server, "tagB", 20)
  client.insert(server, "tagB", 30)

  let universe : Array[Int32] = [10, 20, 30, 40]
  // Query: tagA AND NOT tagB -> should be [10]
  let query = @inverted_index.BoolQuery::And(
    @inverted_index.BoolQuery::Term("tagA"),
    @inverted_index.BoolQuery::Not(@inverted_index.BoolQuery::Term("tagB")),
  )
  let res = @inverted_index.evaluate_bool_query(client, server, universe, query)
  assert_eq(res.doc_ids.length(), 1)
  assert_eq(res.doc_ids[0], 10)
}

///|
test "encrypted range query index" {
  let master_key = @crypto.hex_to_bytes(
    "11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff",
  )
  let range_idx = @inverted_index.RangeIndex::new(master_key, "age", 100)

  range_idx.insert(1, 25)
  range_idx.insert(2, 30)
  range_idx.insert(3, 45)
  range_idx.insert(4, 50)

  let res = range_idx.search_range(20, 35)
  assert_eq(res.doc_ids.length(), 2)
}
