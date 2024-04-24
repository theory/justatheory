---
title: Test and Release pgrx Extensions with pgxn-tools
slug: pgxn-tools-pgrx
date: 2024-04-24T19:34:19Z
lastMod: 2024-04-24T19:34:19Z
description: |
  The v1.6.0 release of the pgxn-tools Docker image adds a new command to
  efficiently build and test pgrx extensions on a wide variety of Postgres
  versions.
tags: [Postgres, PGXN, pgrx, pgxn-tools]
type: post
link: 
---

Yesterday I released v1.6.0 of the [pgxn/pgxn-tools Docker image] with a new
command: [`pgrx-build-test`] works much like the existing [`pg-build-test`]
utility for [PGXS] extensions, but for [pgrx] extensions. Here's an example
[from pg-jsonschema-boon], a pgrx extension I've been working on:

```yaml
name: 🧪 Test
on:
  push:
jobs:
  test:
    runs-on: ubuntu-latest
    container: pgxn/pgxn-tools
    strategy:
      matrix:
        pg: [11, 12, 13, 14, 15, 16]
    name: 🐘 Postgres ${{ matrix.pg }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Start PostgreSQL ${{ matrix.pg }}
        run: pg-start ${{ matrix.pg }}
      - name: Setup Rust Cache
        uses: Swatinem/rust-cache@v2
      - name: Test on PostgreSQL ${{ matrix.pg }}
        run: pgrx-build-test
```

The format is the same as for `pg-build-test`, starting with installing a
specific version of Postgres from the [Postgres Apt repository] (supporting
versions 8.2 – 17). It then adds the [Swatinem/rust-cache] action to speed up
Rust builds by caching dependencies, and then simply calls `pgrx-build-test`
instead of `pg-build-test`. Here's what it does:

*   Extracts the pgrx version from the `Cargo.toml` file and installs it
    (requires v0.11.4 or higher)
*   Initializes pgrx to use the Postgres installed by `pg-start`
*   Builds the extension with `cargo pgrx package`
*   Tests the extension with `cargo pgrx test`
*   Installs the extension with `cargo pgrx install`
*   Checks for a `Makefile` with `installcheck` configured and, if it exists,
    runs `make installcheck`

This last step allows one to include [PGXS]-style `pg_regress` tests in
addition to Rust/pgrx tests, as pg-jsonschema-boon does. Here's a [successful
run].

Special thanks to Eric Ridge and @Jubilee for all the help and improvements in
[pgrx v0.11.4] that enable this to work transparently.

## pgrx Release Pattern

The pattern for releasing a prgx extension on PGXN is the same as before,
although you may want to generate the `META.json` file from a template. For
example, the [pg-jsonschema-boon Makefile] creates `META.json` from
`META.json.in` by reading the version from `Cargo.toml` and replacing
`@CARGO_VERSION@`, like so:

``` makefile
DISTVERSION = $(shell perl -nE '/^version\s*=\s*"([^"]+)/ && do { say $$1; exit }' Cargo.toml)

META.json: META.json.in Cargo.toml
	@sed "s/@CARGO_VERSION@/$(DISTVERSION)/g" $< > $@
```

The release workflow uses it like so:

``` yaml
name: 🚀 Release on PGXN
on:
  push:
    # Release on semantic version tag.
    tags: ['v[0-9]+.[0-9]+.[0-9]+']
jobs:
  release:
    name: 🚀 Release on PGXN
    runs-on: ubuntu-latest
    container: pgxn/pgxn-tools
    env:
      PGXN_USERNAME: ${{ secrets.PGXN_USERNAME }}
      PGXN_PASSWORD: ${{ secrets.PGXN_PASSWORD }}
    steps:
    - name: Check out the repo
      uses: actions/checkout@v4
    - name: Bundle the Release
      env: { GIT_BUNDLE_OPTS: --add-file META.json }
      run: make META.json && pgxn-bundle
    - name: Release on PGXN
      run: pgxn-release
```

Note the "Bundle the Release" step, which first calls `make META.json` to
generate the dated file, and tells `pgxn-bundle` to add the `META.json`
via the `GIT_BUNDLE_OPTS` environment variable. The project also excludes
the `META.json.in` file from the bundle in [its `.gitattributes`] file,
and excludes `META.json` from the project repository in [its `.gigignore`] file.

Looking forward to seeing all your pgrx projects on [PGXN]!

  [pgxn/pgxn-tools Docker image]: https://github.com/pgxn/docker-pgxn-tools/
  [`pgrx-build-test`]: https://github.com/pgxn/docker-pgxn-tools?tab=readme-ov-file#pgrx-build-test
  [`pg-build-test`]: https://github.com/pgxn/docker-pgxn-tools?tab=readme-ov-file#pg-build-test
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
  [from pg-jsonschema-boon]: https://github.com/tembo-io/pg-jsonschema-boon/blob/ea64888/.github/workflows/lint-and-test.yml
  [Postgres Apt repository]: https://wiki.postgresql.org/wiki/Apt
  [Swatinem/rust-cache]: https://github.com/Swatinem/rust-cache
  [successful run]: https://github.com/tembo-io/pg-jsonschema-boon/actions/runs/8809394356
  [pgrx v0.11.4]: https://github.com/pgcentralfoundation/pgrx/releases/tag/v0.11.4
  [pg-jsonschema-boon Makefile]: https://github.com/tembo-io/pg-jsonschema-boon/blob/ea64888/Makefile
  [its `.gitattributes`]: https://github.com/tembo-io/pg-jsonschema-boon/blob/ea64888/.gitattributes
  [its `.gigignore`]: https://github.com/tembo-io/pg-jsonschema-boon/blob/ea64888/.gitignore
  [PGXN]: https://pgxn.org/
