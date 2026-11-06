///|
/// Multi-keyword trapdoor derivation engine
pub struct ConjunctiveDerivator {
  generator : TrapdoorGenerator
  cross_key : Bytes
}

///|
/// Create new ConjunctiveDerivator
pub fn ConjunctiveDerivator::new(
  generator : TrapdoorGenerator,
) -> ConjunctiveDerivator {
  let cross_key = @crypto.derive_key(
    generator.master_key,
    "sse-cross-tag-domain",
    32,
  )
  { generator, cross_key, }
}

///|
/// Compute cross tag between primary keyword and auxiliary keyword
pub fn ConjunctiveDerivator::compute_cross_tag(
  self : ConjunctiveDerivator,
  primary_kw : String,
  aux_kw : String,
) -> Bytes {
  let primary_key = self.generator.derive_keyword_key(primary_kw)
  let aux_key = self.generator.derive_keyword_key(aux_kw)
  let combined = @crypto.xor_bytes(primary_key, aux_key)
  @crypto.hmac_sha256(self.cross_key, combined)
}

///|
/// Generate conjunctive search token for multiple keywords (w1 AND w2 AND ... AND wn)
pub fn ConjunctiveDerivator::generate_conjunctive_token(
  self : ConjunctiveDerivator,
  primary_kw : String,
  aux_keywords : Array[String],
  epoch : UInt32,
) -> ConjunctiveToken {
  let primary_token = self.generator.generate_search_token(primary_kw, epoch)
  let cross_tags : Array[Bytes] = []
  for i in 0..<aux_keywords.length() {
    let tag = self.compute_cross_tag(primary_kw, aux_keywords[i])
    cross_tags.push(tag)
  }
  ConjunctiveToken::new(primary_token, cross_tags)
}
