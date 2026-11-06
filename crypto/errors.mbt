///|
/// Invalid encoded data or parameters supplied to a cryptographic helper.
#derive(Debug, Eq)
pub(all) suberror CryptoInputError {
  OddHexLength(Int32)
  InvalidHexDigit(Int32)
  InvalidUtf8
  InvalidIterations(Int32)
  InvalidKeyLength(Int32)
}

///|
pub extend CryptoInputError with @debug.Debug::{to_repr}

///|
pub extend CryptoInputError with Eq::{not_equal, equal}
