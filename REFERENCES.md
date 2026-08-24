# References and provenance

This repository contains an original MoonBit implementation. It does not copy
source code from the references below; the links document the standards and
research ideas used to design the examples.

## Primitive specifications

- [FIPS 180-4: Secure Hash Standard](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf)
- [FIPS 197: Advanced Encryption Standard](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197-upd1.pdf)
- [FIPS 202: SHA-3 Standard](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.202.pdf)
- [RFC 4231: HMAC-SHA-224/256/384/512 Test Cases](https://www.rfc-editor.org/rfc/rfc4231)
- [RFC 8018: PBKDF2](https://www.rfc-editor.org/rfc/rfc8018)
- [RFC 8439: ChaCha20 and Poly1305 for IETF Protocols](https://www.rfc-editor.org/rfc/rfc8439)

The repository currently implements and tests the listed hash, AES, HMAC,
PBKDF2, and ChaCha20 examples. Poly1305 is referenced for protocol context but
is intentionally not included as an implementation.

## Protocol and data-structure context

- [Searchable Symmetric Encryption](https://eprint.iacr.org/2006/210.pdf),
  Curtmola et al.
- [Path ORAM](https://eprint.iacr.org/2013/280), Stefanov et al.
- [Private Information Retrieval](https://dl.acm.org/doi/10.1145/237814.237817),
  Chor et al.

The SSE, ORAM, and PIR packages are educational reference implementations.
Their code and tests do not constitute a formal security proof or an
independent audit of the cited constructions.
