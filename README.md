# moonbit-sse

[![CI](https://github.com/shen-E/moonbit-sse/actions/workflows/ci.yml/badge.svg)](https://github.com/shen-E/moonbit-sse/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

`moonbit-sse` is an Apache-2.0 MoonBit reference implementation for searchable
encrypted indexes, oblivious-storage data structures, and two-server private
information retrieval. It is designed for MoonBit ecosystem development and
experimentation, not as a production cryptography package.

## Scope

- `crypto`: SHA-256, SHA-3, HMAC-SHA256, PBKDF2, AES block/CTR/CBC,
  ChaCha20, constant-time byte comparison, PRG, and PRP helpers.
- `trapdoor`: keyed derivation, search/update tokens, conjunctive tokens,
  expiring tokens, blinded tokens, and fuzzy-token helpers.
- `inverted_index`: static and dynamic encrypted-index reference schemes,
  boolean/range/phrase queries, revocation filtering, and posting compression.
- `oram`: in-memory Path/Square-Root/Recursive ORAM-shaped data structures and
  an observable-trace simulator for experimenting with access paths.
- `pir`: information-theoretic two-server PIR, batch retrieval, and matrix
  query helpers. The matrix helpers are not a standalone cryptographic PIR.
- `engine`: an in-memory encrypted document/search demonstration with HMAC
  snapshot checks; it is not a durable database or an ACID implementation.

## Security status

This repository has not undergone an independent cryptographic audit. The
SSE, ORAM, trapdoor, and PIR modules are reference implementations and do not
come with a formal security proof. The document demo uses deterministic
derivation for its sample storage keys and AES-CTR without authenticated
encryption; do not use it to protect real data without a reviewed AEAD design,
nonce management, integrity protection, and a threat-model review.

The test suite checks functional behavior and selected standard vectors. A
passing test run does not establish confidentiality, forward security,
backward security, obliviousness, or production performance.

## Quick start

Prerequisite: MoonBit toolchain with `moonc >= v0.10.9`.

```bash
git clone https://github.com/shen-E/moonbit-sse.git
cd moonbit-sse
moon version --all
moon fmt --check
moon check --target all --deny-warn
moon test --target all --deny-warn
moon info
moon run cmd/sse_cli
```

The CLI runs a small end-to-end demonstration of document indexing, keyword
queries, an ORAM trace simulation, and two-server IT-PIR retrieval. Its output
is a demonstration result, not a cryptographic validation certificate.

## Layout

```text
crypto/          cryptographic primitives and test vectors
trapdoor/        keyed token derivation helpers
inverted_index/  encrypted-index reference implementations
oram/            in-memory oblivious-storage structures
pir/             two-server PIR and batch query helpers
engine/          document/search demonstration engine
cmd/sse_cli/     runnable CLI example
```

Design references and provenance notes are collected in
[`REFERENCES.md`](REFERENCES.md).

CI is defined in `.github/workflows/ci.yml`. It installs MoonBit using the
official installer, checks all targets, runs all tests, verifies formatting and
generated public interfaces, and runs the CLI example on Linux, macOS, and
Windows runners.

## License

This project is licensed under the [Apache-2.0 License](LICENSE).
