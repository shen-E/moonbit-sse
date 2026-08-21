///|
test "cli helpers parse and format" {
  let cmd = parse_cli_command("search privacy security")
  assert_eq(cmd.action, "search")
  assert_eq(cmd.args.length(), 2)

  let res = @inverted_index.SearchResult::new([1, 2], [100, 80])
  let formatted = format_search_results(res)
  assert_true(formatted.length() > 0)
}
