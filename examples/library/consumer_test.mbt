///|
test "crypto consumer uses strict UTF-8 and hex decoding" {
  assert_eq(
    @crypto.bytes_to_string(@crypto.string_to_bytes("中文🔐")),
    "中文🔐",
  )
  try @crypto.hex_to_bytes("zz") catch {
    @crypto.CryptoInputError::InvalidHexDigit(0) => ()
    _ => fail("expected InvalidHexDigit")
  } noraise {
    _ => fail("invalid hex was accepted")
  }
}

///|
test "trapdoor consumer derives repeatable search tokens" {
  let generator = @trapdoor.TrapdoorGenerator::new(b"consumer reference key")
  let first = generator.generate_search_token("privacy", 1U)
  let second = generator.generate_search_token("privacy", 1U)
  assert_true(
    @crypto.bytes_equal_const_time(first.get_token(), second.get_token()),
  )
}

///|
test "index consumer builds and searches an index" {
  let client = @inverted_index.StaticSseClient::new(b"consumer reference key")
  let index : Map[String, Array[Int32]] = { "privacy": [1, 3] }
  let server = client.build_index(index)
  assert_eq(client.search(server, "privacy").doc_ids, [1, 3])
}

///|
test "ORAM consumer writes and reads a reference block" {
  let storage = @oram.PathOram::new(3, 4, 16, b"consumer reference key")
  let _ = storage.access(@oram.AccessOp::Write(b"reference block!"), 1)
  assert_eq(storage.access(@oram.AccessOp::Read, 1).data, b"reference block!")
}

///|
test "PIR consumer reconstructs a selected record" {
  let database = @pir.DatabaseVector::new([b"one!", b"two!"], 4)
  let client = @pir.ItPirClient::new(2, 4, b"consumer reference key")
  let query = client.generate_query(1)
  let first = @pir.it_pir_server_respond(database, query.q1)
  let second = @pir.it_pir_server_respond(database, query.q2)
  assert_eq(client.reconstruct(first, second), b"two!")
}

///|
test "engine consumer authenticates snapshot IDs and round trips Unicode" {
  let key = b"consumer reference key"
  let database = @engine.EncryptedDatabase::new(key)
  database.insert_document(
    @engine.Document::new(1, "中文", "检索🔐", [], 0UL),
  )
  assert_eq(database.get_document(1), Some("中文|||检索🔐"))
  let manager = @engine.SnapshotManager::new(key)
  let snapshot = manager.create_snapshot(7UL, database)
  assert_true(manager.verify_snapshot(snapshot))
  let changed = @engine.DatabaseSnapshot::new(
    8UL,
    snapshot.num_documents,
    snapshot.index_entries_count,
    snapshot.integrity_tag,
  )
  assert_false(manager.verify_snapshot(changed))
}
