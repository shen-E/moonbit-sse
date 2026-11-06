///|
/// CLI Command Parser and Formatter
#derive(Debug)
pub struct CliCommand {
  action : String
  args : Array[String]
}

///|
/// Parse string input into CliCommand
pub fn parse_cli_command(line : String) -> CliCommand {
  let parts = tokenize_text(line)
  if parts.length() == 0 {
    return { action: "help", args: [], }
  }
  let action = parts[0]
  let args : Array[String] = []
  for i = 1; i < parts.length(); i = i + 1 {
    args.push(parts[i])
  }
  { action, args, }
}

///|
/// Format search results table
pub fn format_search_results(res : @inverted_index.SearchResult) -> String {
  let buf = StringBuilder()
  buf.write_string("Matches Found: ")
  buf.write_string(res.doc_ids.length().to_string())
  buf.write_char('\n')
  for i in 0..<res.doc_ids.length() {
    buf.write_string("  [")
    buf.write_string((i + 1).to_string())
    buf.write_string("] Document ID: ")
    buf.write_string(res.doc_ids[i].to_string())
    buf.write_string(" (Score: ")
    buf.write_string(res.scores[i].to_string())
    buf.write_string(")\n")
  }
  buf.to_string()
}

///|
pub extend CliCommand with @debug.Debug::{to_repr}
