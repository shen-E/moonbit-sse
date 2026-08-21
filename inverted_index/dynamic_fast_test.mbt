///|
test "fast dynamic forward secure scheme" {
  let master_key = @crypto.hex_to_bytes(
    "444455556666777788889999aaaa0000444455556666777788889999aaaa0000",
  )
  let engine = FastEngine::new(master_key)
  let server = ForwardSecureServer::new()

  engine.insert(server, "moonbit", 201)
  engine.insert(server, "moonbit", 202)

  let res = engine.search(server, "moonbit")
  assert_eq(res.doc_ids.length(), 2)
  assert_eq(res.doc_ids[0], 201)
  assert_eq(res.doc_ids[1], 202)
}
