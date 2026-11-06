# Changelog

## 0.2.0

- Encode text as UTF-8 and decode it strictly, preserving Chinese, emoji, NUL,
  and a leading BOM. Invalid UTF-8 raises `CryptoInputError::InvalidUtf8`.
- Reject odd hexadecimal lengths and invalid digits instead of truncating or
  replacing input. `hex_to_bytes` now raises `CryptoInputError`.
- Reject nonpositive PBKDF2 iteration counts and output lengths with typed
  errors. Preserve standard results for valid parameters.
- Authenticate all 64 bits of the snapshot ID and both counts using a
  domain-separated v2 HMAC payload. Reject legacy counts-only tags.
- Update formatting, explicit trait method extensions, tests, and generated
  interfaces for MoonBit 0.10.20. Add weekly CI and registry consumer checks.

### Migration from 0.1.0

`hex_to_bytes`, `bytes_to_string`, `pbkdf2_hmac_sha256`, and
`EncryptedDatabase::get_document` now raise `CryptoInputError`. Propagate or
handle the error in callers. Decoding arbitrary binary data as Latin-1 is no
longer supported by `bytes_to_string`; keep binary data as `Bytes`.

UTF-8 changes the bytes used for non-ASCII passwords, keywords, and document
payloads. Rebuild reference indexes and regenerate derived artifacts from the
original text; truncated 0.1.0 text cannot be reconstructed automatically.
ASCII-derived values remain unchanged.

Regenerate snapshot metadata with 0.2.0. Version 0.1.0 tags are deliberately
rejected. Snapshot authentication covers metadata, excludes document content,
and does not prevent replay. The document engine remains an unauthenticated
AES-CTR demonstration, as described in the README.
