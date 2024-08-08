---
title: "Release: pgxn_meta v0.1.0"
slug: pgxn_meta_release
date: 2024-08-08T16:13:21Z
lastMod: 2024-08-08T16:13:21Z
description: |
  Today I released pgxn_meta v0.1.0, a Rust crate and executable for validating
  PGXN Meta v1 and v2 `META.json` files.
tags: [Postgres, PGXN, JSON Schema, Rust, Metadata]
type: post
---

Following the recent spate of work drafting [RFCs] for a [binary distribution
format][trunk] and [Meta Spec v2][meta], and bearing in mind the [vote] to
implementing [PGXN v2] apps in Rust, over the last few weeks I've switched
gears to write some code.

First I wrote [JSON Schemas for the v1 spec][meta#3] and then wrote a [full
test suite][meta#4] using the [boon crate]. Next I wrote and tested [JSON
Schemas for the v2 spec][meta#6]. This process informed revisions to the
[RFC][meta], uncovering inconsistencies and unnecessary complexities.

With `META.json` file JSON Schema validation fully worked up, I decided to
work the functionality into a proper Rust crate and CLI to eventually replace
the old [PGXN::Meta::Validator] Perl module and its `validate_pgxn_meta` CLI.
This turned out to be a decent Rust starter project, requiring a fairly simple
crate and CLI, but also allowed me to develop patterns to build and release
binaries for a variety of platforms and architecture.

As a result, I'm happy to announce the release today of the [pgxn_meta crate]
and [pgxn_meta CLI v0.1.0][v0.1.0], available for download on these platforms,
thanks to [cross] and [houseabsolute/actions-rust-cross]:

*   darwin-amd64
*   darwin-arm64
*   freebsd-amd64
*   freebsd-i686
*   illumos-amd64
*   linux-amd64
*   linux-arm
*   linux-arm64
*   linux-i686
*   linux-powerpc
*   linux-powerpc64
*   linux-powerpc64le
*   linux-riscv64
*   linux-s390x
*   linux-sparc64
*   netbsd-amd64
*   solaris-amd64
*   solaris-sparcv9
*   windows-amd64
*   windows-arm64
*   windows-i686

Download the archive file appropriate to your platform, decompress it, and put
the `pgxn_meta` (or `pgxn_meta.exe`) binary in your path. Or use the
[universal binary installer (ubi)][ubi] to install it:

``` sh
ubi --project pgxn/meta --in ~/bin
```

And of course you can use `cargo` to compile it from source:

``` sh
cargo install pgxn_meta
```

Usage is simple: just run `pgxn_meta` in a directory containing the
`META.json` file to validate:

```console
❯ pgxn_meta 
META.json is OK
```

And optionally pass it the name of the file, as in this example parsing a test
file with no `version` property:

```console
❯ pgxn_meta corpus/invalid.json 
Error: "corpus/invalid.json jsonschema validation failed with https://pgxn.org/meta/v2/distribution.schema.json#\n- at '': missing properties 'version'"```
```

That's it!

What's Next?
------------

Now that I've implemented validation and figured out multi-platform binary
support for Rust apps, my next tasks are to:

*   Implement a pattern to convert a v1 `META.json` to the v2 format
*   Create a pattern to merge multiple `META.json` files into one
*   Write code to build [PGXS] extension into [trunk] packages
*   Develop patterns to satisfy third-party dependencies for multiple
    platforms

Should keep me busy for a few weeks. Updates as I have them.

  [RFCs]: https://rfcs.pgxn.org "PGXN RFCs — PGXN Book"
  [trunk]: https://github.com/pgxn/rfcs/pull/2 "RFC: Binary Distribution Format"
  [meta]: https://github.com/pgxn/rfcs/pull/3 "RFC: Meta Spec v2"
  [PGXN v2]: https://wiki.postgresql.org/wiki/PGXN_v2
  [vote]: {{% ref "/post/postgres/pgxn-language-poll-result" %}}
    "PGXN Language Poll Result"
  [meta#3]: https://github.com/pgxn/meta/pull/3
    "Implement JSON Schema for PGXN Meta Spec v1"
  [meta#4]: https://github.com/pgxn/meta/pull/4
    "Fully test schema and fix issues found"
  [boon crate]: https://crates.io/crates/boon "boon JSON Schema Validation crate"
  [meta#6]: https://github.com/pgxn/meta/pull/6 "Implement v2 Spec JSON Schema" 
  [PGXN::Meta::Validator]: https://metacpan.org/dist/PGXN-Meta-Validator 
  [pgxn_meta crate]: https://crates.io/crates/pgxn_meta "pgxn_meta on crates.io"
  [v0.1.0]: https://github.com/pgxn/meta/releases/tag/v0.1.0 "pgxn_meta Release v0.1.0"
  [cross]: https://github.com/cross-rs/cross
    "“Zero setup” cross compilation and “cross testing” of Rust crates"
  [houseabsolute/actions-rust-cross]: https://github.com/houseabsolute/actions-rust-cross
    "GitHub Action to compile Rust with cross"
  [ubi]: https://github.com/houseabsolute/ubi
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Extension Building Infrastructure"
