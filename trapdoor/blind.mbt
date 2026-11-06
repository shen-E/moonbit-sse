///|
/// Blind a search token with a random blinding factor for outsourced routing
pub fn blind_search_token(
  token : SearchToken,
  blinding_factor : Bytes,
) -> BlindedToken {
  let blinded_bytes = @crypto.xor_bytes(token.get_token(), blinding_factor)
  BlindedToken::new(blinded_bytes, blinding_factor)
}

///|
/// Verify and unblind blinded token at destination
pub fn unblind_search_token(
  blinded : BlindedToken,
  label : Bytes,
  epoch : UInt32,
) -> SearchToken {
  let unblinded = blinded.unblind()
  SearchToken::new(unblinded, label, epoch)
}
