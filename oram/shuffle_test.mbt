///|
test "oblivious sort and shuffle" {
  let blocks : Array[@oram.Block] = [
    @oram.Block::real(40, @crypto.string_to_bytes("d40")),
    @oram.Block::real(10, @crypto.string_to_bytes("d10")),
    @oram.Block::real(30, @crypto.string_to_bytes("d30")),
    @oram.Block::real(20, @crypto.string_to_bytes("d20")),
  ]

  @oram.oblivious_sort(blocks, 0, 4, true)
  assert_eq(blocks[0].id, 10)
  assert_eq(blocks[1].id, 20)
  assert_eq(blocks[2].id, 30)
  assert_eq(blocks[3].id, 40)

  let prg = @crypto.Prg::new(
    @crypto.hex_to_bytes(
      "0123012301230123012301230123012301230123012301230123012301230123",
    ),
  )
  @oram.oblivious_shuffle(blocks, prg)
  assert_eq(blocks.length(), 4)
}
