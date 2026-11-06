///|
/// Search Token for single-keyword queries
#derive(Debug)
pub struct SearchToken {
  token : Bytes
  label : Bytes
  epoch : UInt32
}

///|
/// Create a new SearchToken
pub fn SearchToken::new(
  token : Bytes,
  label : Bytes,
  epoch : UInt32,
) -> SearchToken {
  { token, label, epoch, }
}

///|
/// Get the token bytes
pub fn SearchToken::get_token(self : SearchToken) -> Bytes {
  self.token
}

///|
/// Get the label bytes
pub fn SearchToken::get_label(self : SearchToken) -> Bytes {
  self.label
}

///|
/// Get the epoch
pub fn SearchToken::get_epoch(self : SearchToken) -> UInt32 {
  self.epoch
}

///|
/// Update Token for encrypted index updates (insert/delete)
#derive(Debug)
pub struct UpdateToken {
  addr : Bytes
  val_mask : Bytes
  proof : Bytes
  epoch : UInt32
}

///|
/// Create a new UpdateToken
pub fn UpdateToken::new(
  addr : Bytes,
  val_mask : Bytes,
  proof : Bytes,
  epoch : UInt32,
) -> UpdateToken {
  { addr, val_mask, proof, epoch, }
}

///|
/// Get update address
pub fn UpdateToken::get_addr(self : UpdateToken) -> Bytes {
  self.addr
}

///|
/// Get value mask
pub fn UpdateToken::get_val_mask(self : UpdateToken) -> Bytes {
  self.val_mask
}

///|
/// Get update proof
pub fn UpdateToken::get_proof(self : UpdateToken) -> Bytes {
  self.proof
}

///|
/// Get update epoch
pub fn UpdateToken::get_epoch(self : UpdateToken) -> UInt32 {
  self.epoch
}

///|
/// Conjunctive Search Token for multi-keyword AND queries
#derive(Debug)
pub struct ConjunctiveToken {
  primary_token : SearchToken
  cross_tags : Array[Bytes]
}

///|
/// Create a new ConjunctiveToken
pub fn ConjunctiveToken::new(
  primary_token : SearchToken,
  cross_tags : Array[Bytes],
) -> ConjunctiveToken {
  { primary_token, cross_tags, }
}

///|
/// Get primary search token
pub fn ConjunctiveToken::get_primary_token(
  self : ConjunctiveToken,
) -> SearchToken {
  self.primary_token
}

///|
/// Get cross-tags array
pub fn ConjunctiveToken::get_cross_tags(
  self : ConjunctiveToken,
) -> Array[Bytes] {
  self.cross_tags
}

///|
/// Time-bound expiring search token
#derive(Debug)
pub struct TimeBoundToken {
  token : SearchToken
  valid_until_epoch : UInt32
  auth_tag : Bytes
}

///|
/// Create a new TimeBoundToken
pub fn TimeBoundToken::new(
  token : SearchToken,
  valid_until_epoch : UInt32,
  auth_tag : Bytes,
) -> TimeBoundToken {
  { token, valid_until_epoch, auth_tag, }
}

///|
/// Check if the time-bound token is expired at given epoch
pub fn TimeBoundToken::is_expired(
  self : TimeBoundToken,
  current_epoch : UInt32,
) -> Bool {
  current_epoch > self.valid_until_epoch
}

///|
/// Blinded search token for oblivious query routing
#derive(Debug)
pub struct BlindedToken {
  blinded_token : Bytes
  blinding_factor : Bytes
}

///|
/// Create a new BlindedToken
pub fn BlindedToken::new(
  blinded_token : Bytes,
  blinding_factor : Bytes,
) -> BlindedToken {
  { blinded_token, blinding_factor, }
}

///|
/// Unblind token using the blinding factor
pub fn BlindedToken::unblind(self : BlindedToken) -> Bytes {
  @crypto.xor_bytes(self.blinded_token, self.blinding_factor)
}

///|
pub extend BlindedToken with @debug.Debug::{to_repr}

///|
pub extend ConjunctiveToken with @debug.Debug::{to_repr}

///|
pub extend SearchToken with @debug.Debug::{to_repr}

///|
pub extend TimeBoundToken with @debug.Debug::{to_repr}

///|
pub extend UpdateToken with @debug.Debug::{to_repr}
