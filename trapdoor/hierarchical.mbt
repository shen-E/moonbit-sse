///|
/// Hierarchical Identity / Scope Based Trapdoor Derivation
pub struct HierarchicalTrapdoor {
  generator : TrapdoorGenerator
  root_domain : String
}

///|
/// Create new HierarchicalTrapdoor
pub fn HierarchicalTrapdoor::new(
  generator : TrapdoorGenerator,
  root_domain : String,
) -> HierarchicalTrapdoor {
  { generator, root_domain }
}

///|
/// Derive scoped token for sub-path / namespace e.g. "org/dept/user"
pub fn HierarchicalTrapdoor::derive_scoped_token(
  self : HierarchicalTrapdoor,
  path_scopes : Array[String],
  keyword : String,
  epoch : UInt,
) -> SearchToken {
  let buf = StringBuilder::new()
  buf.write_string(self.root_domain)
  for i in 0..<path_scopes.length() {
    buf.write_char('/')
    buf.write_string(path_scopes[i])
  }
  let full_scope = buf.to_string()
  let scoped_kw = full_scope + "::" + keyword
  self.generator.generate_search_token(scoped_kw, epoch)
}
