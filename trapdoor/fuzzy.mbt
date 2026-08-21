///|
/// Fuzzy N-Gram Keyword Trapdoor Generator
pub struct FuzzyTrapdoorGenerator {
  generator : TrapdoorGenerator
  gram_size : Int
}

///|
/// Create new FuzzyTrapdoorGenerator
pub fn FuzzyTrapdoorGenerator::new(
  generator : TrapdoorGenerator,
  gram_size : Int,
) -> FuzzyTrapdoorGenerator {
  { generator, gram_size }
}

///|
/// Split keyword into n-grams
pub fn split_ngrams(s : String, n : Int) -> Array[String] {
  let grams : Array[String] = []
  if s.length() < n {
    grams.push(s)
    return grams
  }
  for i = 0; i <= s.length() - n; i = i + 1 {
    let buf = StringBuilder::new()
    for j = 0; j < n; j = j + 1 {
      buf.write_char(s[i + j].to_int().unsafe_to_char())
    }
    grams.push(buf.to_string())
  }
  grams
}

///|
/// Generate tokens for all n-grams of a keyword
pub fn FuzzyTrapdoorGenerator::generate_fuzzy_tokens(
  self : FuzzyTrapdoorGenerator,
  keyword : String,
  epoch : UInt,
) -> Array[SearchToken] {
  let grams = split_ngrams(keyword, self.gram_size)
  let tokens : Array[SearchToken] = []
  for i in 0..<grams.length() {
    tokens.push(self.generator.generate_search_token(grams[i], epoch))
  }
  tokens
}
