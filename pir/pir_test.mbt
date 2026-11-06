///|
test "information-theoretic 2-server pir correctness" {
  let seed = @crypto.hex_to_bytes(
    "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f",
  )
  let num_records = 8
  let record_size = 16

  let records : Array[Bytes] = []
  for i in 0..<num_records {
    let msg = @crypto.string_to_bytes("record_content_" + i.to_string())
    records.push(msg)
  }
  let db = @pir.DatabaseVector::new(records, record_size)

  let client = @pir.ItPirClient::new(num_records, record_size, seed)

  let query = client.generate_query(3)
  let resp1 = @pir.it_pir_server_respond(db, query.q1)
  let resp2 = @pir.it_pir_server_respond(db, query.q2)

  let reconstructed = client.reconstruct(resp1, resp2)
  assert_eq(@crypto.bytes_to_string(reconstructed), "record_content_3")
}

///|
test "batch pir multiple retrievals" {
  let seed = @crypto.hex_to_bytes(
    "9999888877776666555544443333222299998888777766665555444433332222",
  )
  let num_records = 6
  let record_size = 10

  let records : Array[Bytes] = []
  for i in 0..<num_records {
    let msg = @crypto.string_to_bytes("batch_rec" + i.to_string())
    records.push(msg)
  }
  let db = @pir.DatabaseVector::new(records, record_size)

  let batch_coord = @pir.BatchPirCoordinator::new(
    num_records, record_size, seed,
  )
  let targets : Array[Int32] = [1, 4, 0]
  let retrieved = batch_coord.batch_retrieve(db, targets)

  assert_eq(retrieved.length(), 3)
  assert_eq(@crypto.bytes_to_string(retrieved[0]), "batch_rec1")
  assert_eq(@crypto.bytes_to_string(retrieved[1]), "batch_rec4")
  assert_eq(@crypto.bytes_to_string(retrieved[2]), "batch_rec0")
}

///|
test "pir metrics computation" {
  let m = @pir.PirMetrics::new(1024, 64, 16, 0.078)
  assert_eq(m.database_size_bytes, 1024)
}
