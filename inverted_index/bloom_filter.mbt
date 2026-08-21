///|
/// Encrypted Bloom Filter for Search Pre-filtering
pub struct BloomFilter {
  bitset : FixedArray[UInt64]
  num_bits : Int
  num_hashes : Int
  key : Bytes
}

///|
/// Create new BloomFilter
pub fn BloomFilter::new(
  num_bits : Int,
  num_hashes : Int,
  key : Bytes,
) -> BloomFilter {
  let num_words = (num_bits + 63) / 64
  let bitset : FixedArray[UInt64] = FixedArray::make(num_words, 0UL)
  { bitset, num_bits, num_hashes, key }
}

///|
/// Add keyword to Bloom Filter
pub fn BloomFilter::add(self : BloomFilter, keyword : String) -> Unit {
  let kw_bytes = @crypto.string_to_bytes(keyword)
  for h = 0; h < self.num_hashes; h = h + 1 {
    let h_bytes = @crypto.uint32_to_be_bytes(h.reinterpret_as_uint())
    let hash_val = @crypto.hmac_sha256(
      self.key,
      @crypto.xor_bytes(kw_bytes, h_bytes),
    )
    let bit_idx = (
        @crypto.uint32_from_be_bytes(hash_val, 0).reinterpret_as_int() &
        0x7FFFFFFF
      ) %
      self.num_bits
    let word_idx = bit_idx / 64
    let bit_pos = bit_idx % 64
    self.bitset[word_idx] = self.bitset[word_idx] | (1UL << bit_pos)
  }
}

///|
/// Test keyword presence in Bloom Filter
pub fn BloomFilter::contains(self : BloomFilter, keyword : String) -> Bool {
  let kw_bytes = @crypto.string_to_bytes(keyword)
  for h = 0; h < self.num_hashes; h = h + 1 {
    let h_bytes = @crypto.uint32_to_be_bytes(h.reinterpret_as_uint())
    let hash_val = @crypto.hmac_sha256(
      self.key,
      @crypto.xor_bytes(kw_bytes, h_bytes),
    )
    let bit_idx = (
        @crypto.uint32_from_be_bytes(hash_val, 0).reinterpret_as_int() &
        0x7FFFFFFF
      ) %
      self.num_bits
    let word_idx = bit_idx / 64
    let bit_pos = bit_idx % 64
    if (self.bitset[word_idx] & (1UL << bit_pos)) == 0UL {
      return false
    }
  }
  true
}
