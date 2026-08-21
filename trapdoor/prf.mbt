///|
/// Master Trapdoor Generator utilizing cryptographic PRFs
pub struct TrapdoorGenerator {
  master_key : Bytes
  search_prf_key : Bytes
  update_prf_key : Bytes
  mask_prf_key : Bytes
}

///|
/// Initialize TrapdoorGenerator with master secret key
pub fn TrapdoorGenerator::new(master_key : Bytes) -> TrapdoorGenerator {
  let search_prf_key = @crypto.derive_key(
    master_key, "sse-prf-search-domain", 32,
  )
  let update_prf_key = @crypto.derive_key(
    master_key, "sse-prf-update-domain", 32,
  )
  let mask_prf_key = @crypto.derive_key(master_key, "sse-prf-mask-domain", 32)
  { master_key, search_prf_key, update_prf_key, mask_prf_key }
}

///|
/// Derive keyword specific key: K_w = HMAC(K_master, keyword)
pub fn TrapdoorGenerator::derive_keyword_key(
  self : TrapdoorGenerator,
  keyword : String,
) -> Bytes {
  @crypto.hmac_sha256(self.master_key, @crypto.string_to_bytes(keyword))
}

///|
/// Generate search token for given keyword and epoch
pub fn TrapdoorGenerator::generate_search_token(
  self : TrapdoorGenerator,
  keyword : String,
  epoch : UInt,
) -> SearchToken {
  let kw_key = self.derive_keyword_key(keyword)
  let epoch_bytes = @crypto.uint32_to_be_bytes(epoch)

  let token = @crypto.hmac_sha256(
    self.search_prf_key,
    @crypto.xor_bytes(kw_key, @crypto.sha256(epoch_bytes)),
  )
  let label = @crypto.hmac_sha256(
    kw_key,
    @crypto.string_to_bytes("keyword-label-seed"),
  )

  SearchToken::new(token, label, epoch)
}

///|
/// Generate update token for inserting/deleting (keyword, doc_id, counter)
pub fn TrapdoorGenerator::generate_update_token(
  self : TrapdoorGenerator,
  keyword : String,
  doc_id : Int,
  op : Int,
  counter : Int,
  epoch : UInt,
) -> UpdateToken {
  let kw_key = self.derive_keyword_key(keyword)
  let ctr_bytes = @crypto.uint32_to_be_bytes(counter.reinterpret_as_uint())

  let addr = @crypto.hmac_sha256(
    self.update_prf_key,
    @crypto.xor_bytes(kw_key, ctr_bytes),
  )

  let val_buf : FixedArray[Byte] = FixedArray::make(8, b'\x00')
  let doc_bytes = @crypto.uint32_to_be_bytes(doc_id.reinterpret_as_uint())
  let op_bytes = @crypto.uint32_to_be_bytes(op.reinterpret_as_uint())
  for i in 0..<4 {
    val_buf[i] = doc_bytes[i]
    val_buf[4 + i] = op_bytes[i]
  }

  let mask_stream = @crypto.hmac_sha256(self.mask_prf_key, addr)
  let val_mask = @crypto.xor_bytes(Bytes::from_array(val_buf), mask_stream)

  let proof = @crypto.hmac_sha256(kw_key, addr)

  UpdateToken::new(addr, val_mask, proof, epoch)
}
