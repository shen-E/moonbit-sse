///|
/// Expiring Trapdoor Manager with forward-secure epoch key evolution
pub struct ExpiringTrapdoorManager {
  generator : TrapdoorGenerator
  auth_key : Bytes
}

///|
/// Create new ExpiringTrapdoorManager
pub fn ExpiringTrapdoorManager::new(
  generator : TrapdoorGenerator,
) -> ExpiringTrapdoorManager {
  let auth_key = @crypto.derive_key(
    generator.master_key,
    "sse-expiring-auth-domain",
    32,
  )
  { generator, auth_key }
}

///|
/// Generate a time-bound token valid until valid_until_epoch
pub fn ExpiringTrapdoorManager::generate_time_bound_token(
  self : ExpiringTrapdoorManager,
  keyword : String,
  current_epoch : UInt,
  valid_until_epoch : UInt,
) -> TimeBoundToken {
  let token = self.generator.generate_search_token(keyword, current_epoch)
  let epoch_limit_bytes = @crypto.uint32_to_be_bytes(valid_until_epoch)
  let auth_msg = @crypto.xor_bytes(token.get_token(), epoch_limit_bytes)
  let auth_tag = @crypto.hmac_sha256(self.auth_key, auth_msg)
  TimeBoundToken::new(token, valid_until_epoch, auth_tag)
}

///|
/// Verify authenticity of time-bound token
pub fn ExpiringTrapdoorManager::verify_token(
  self : ExpiringTrapdoorManager,
  token : TimeBoundToken,
  current_epoch : UInt,
) -> Bool {
  if token.is_expired(current_epoch) {
    return false
  }
  let epoch_limit_bytes = @crypto.uint32_to_be_bytes(token.valid_until_epoch)
  let auth_msg = @crypto.xor_bytes(token.token.get_token(), epoch_limit_bytes)
  let expected_tag = @crypto.hmac_sha256(self.auth_key, auth_msg)
  @crypto.bytes_equal_const_time(token.auth_tag, expected_tag)
}
