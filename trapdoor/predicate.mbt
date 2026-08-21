///|
/// Inner-Product Predicate Vector Token
pub struct PredicateToken {
  weight_vectors : Array[Bytes]
  threshold : Int
} derive(Debug)

///|
/// Create new PredicateToken
pub fn PredicateToken::new(
  weight_vectors : Array[Bytes],
  threshold : Int,
) -> PredicateToken {
  { weight_vectors, threshold }
}

///|
/// Predicate Trapdoor Generator for multi-attribute matching
pub struct PredicateGenerator {
  generator : TrapdoorGenerator
}

///|
/// Create new PredicateGenerator
pub fn PredicateGenerator::new(
  generator : TrapdoorGenerator,
) -> PredicateGenerator {
  { generator, }
}

///|
/// Generate predicate search token for attribute weights
pub fn PredicateGenerator::generate_predicate_token(
  self : PredicateGenerator,
  attributes : Array[String],
  weights : Array[Int],
  threshold : Int,
  epoch : UInt,
) -> PredicateToken {
  let weight_vectors : Array[Bytes] = []
  for i in 0..<attributes.length() {
    let kw_token = self.generator.generate_search_token(attributes[i], epoch)
    let w_bytes = @crypto.uint32_to_be_bytes(weights[i].reinterpret_as_uint())
    let masked_weight = @crypto.xor_bytes(
      kw_token.get_token(),
      @crypto.sha256(w_bytes),
    )
    weight_vectors.push(masked_weight)
  }
  PredicateToken::new(weight_vectors, threshold)
}
