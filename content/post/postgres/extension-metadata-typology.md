---
title: "RFC: Extension Metadata Typology"
slug: extension-metadata-typology
date: 2024-02-20T22:26:51Z
lastMod: 2024-02-20T22:26:51Z
description: |
  Thinking through the PostgreSQL extension metadata use cases and
  recognizing the types of information they need.
tags: [Postgres, Extensions, Metadata, Classification, Categories, RFC]
type: post
---

Lately I've been thinking a lot about metadata for Postgres extensions.
Traditional use cases include [control file metadata][.control], which lives in
`.control` files used by `CREATE EXTENSION` and friends, and [PGXN metadata],
which lives in `META.json` files used by [PGXN] to index and publish extensions.
But these two narrow use cases for SQL behavior and source code distribution
don't provide the information necessary to enable other use cases, including
building, installing, configuration, and more.

So I have also been exploring other metadata formats, including:

*   [Go `go.mod`]
*   [Cargo Manifest File]
*   [npm `package.json`]
*   [`trunk.toml`]
*   [pgxman buildkit]

These standards from neighboring communities reveal a great deal of overlap, as
one might expect (everything has a name, a version, an author, license, and so
on), but also types of metadata that had not occurred to me. As I took notes and
gathered suggestions from colleagues and coworkers, I began to recognize natural
groupings of metadata. This lead to the realization that it might be easier ---
and more productive --- to think about these groupings rather than individual
fields.

I therefore propose a typology for Postgres extension metadata.

Extension Metadata Typology
---------------------------

### Essentials

Essential information about the extension itself, including its name (or unique
package name), version, list of authors, license, etc. Pretty much every
metadata format encompasses this data. Ecosystem applications use it for
indexing, installation locations, naming conventions, and display information.

### Artifacts

A list of links and checksums for downloading the extension in one or more
formats, including source code, binaries, system packages, and more. Apps use
this information to determine the best option for installing an extension on a
particular system.

### Resources

External information about the extension, mostly links, including source code
repository, bug reporting, documentation, badges, funding, etc. Apps use this
data for links, of course, but also full text indexing, documentation rendering,
and displaying useful information about the extension.

### Contents

A description of what's included in the extension package. Often an "extension"
consists of *multiple* extensions, such as [PostGIS], which includes `postgis`,
`postgis_tiger_geocoder`, `address_standardizer`, and more. Furthermore, some
extensions are not `CREATE EXTENSION`-type extension at all, such as [background
workers], command-line apps, libraries, etc. Each should be listed along with
documentation links where they differ from the package overall (or are simply
more specific).

### Prerequisites

A list of external dependencies required to configure, build, test, install, and
run the extension. These include not only other extensions, but also external
libraries and OS-specific lists of binary package dependencies. And let's not
forget the versions of Postgres required, as well as any OS and version
dependencies (e.g, does it work on Windows? FreeBSD? What versions?) and
architectures ([arm64], [amd64], etc.)

### How to Build It

Metadata that apps use to determine how to build the extension. Does it use the
PostgreSQL [PGXS] build pipeline? Or perhaps it needs the [cargo]-based [pgrx]
toolchain. Maybe a traditional `./configure && make` pattern? Perl, Ruby,
Python, Go, Rust, or NPM tooling? Whatever the pattern, this metadata needs to
be sufficient for an ecosystem app to programmatically determine how to build
an extension.

### How to Install It

Usually an extension of the build metadata, the install metadata describes how
to install the extension. That could be [PGXS] or [pgrx] again, but could also
use other patterns --- or multiple patterns! For example, perhaps an extension
can be built and installed with [PGXS], but it might *also* be [TLE]-safe, and
therefore provide details for handing the SQL files off to a [TLE installer].

This typology might include additional data, such as documentation files to
install ([man pages] anyone?), or directories of dependent files or libraries,
and the like --- whatever needs to be installed for the extension.

### How to Run It

Not all Postgres extensions are `CREATE EXTENSION` extensions. Some provide
[background workers] to perform various tasks; others simply provide Utility
applications like [pg_top] and [pg_repack]. In fact [pg_repack] provides *both*
a command-line application and a `CREATE EXTENSION` extension in one package!

This metadata also provides configuration information, both [control file
parameters][.control] like `trusted`, `superuser`, and `schema`, but also load
configuration information, like whether an extension needs its libraries
included in [`shared_preload_libraries`] to enable [`LOAD`] or requires a
cluster restart. (Arguably this information should be in the "install" typology
rather than "run".)

### Classification

Classification metadata lets the extension developer associate additional
information to improve discovery, such as key words. It might also allow
selections from a curated list of extension classifications, such as the
[category slugs] supported for the [cargo categories field]. Ecosystem apps use
this data to organize extensions under key words or categories, making it easier
for users to find extensions often used together or for various workloads or
tasks.

### Metrics and Reports

This final typology differs from the others in that its metadata derives from
third party sources rather than the extension developer. It includes data such
as number of downloads, build and test status on various Postgres/OS/version
combinations, binary packaging distributions, test coverage, security scan
results, vulnerability detection, quality metrics and user ratings, and more.

In the broader ecosystem, it would be the responsibility of the root registry to
ensure such data in the canonical data for each extension comes only from
trusted sources, although applications downstream of the root registry might
extend metrics and reports metadata with their own information.

## What More?

Reading through various metadata standards, I suspect this typology is fairly
comprehensive, but I'm usually mistaken about such things. What other types of
metadata do you find essential for the use cases you're familiar with? Do they
fit one of the types here, or do they require some other typology I've failed to
imagine? Hit the [#extensions] channel on the [Postgres Slack] to contribute to
the discussion, or give me a holler [on Mastodon].

Meanwhile, I'll be refining this typology and assigning all the metadata fields
to them in the coming weeks, with an eye to proposing a community-wide metadata
standard. I hope it will benefit us all; your input will ensure it does.

  [.control]: https://www.postgresql.org/docs/current/extend-extensions.html#EXTEND-EXTENSIONS-FILES
    "PostgreSQL Docs: Extension Files"
  [PGXN metadata]: https://pgxn.org/spec/
    "PGXN Meta Spec - The PGXN distribution metadata specification"
  [PGXN]: https://pgxn.org "The postgreSQL Extension Network"
  [Go `go.mod`]: https://go.dev/doc/modules/gomod-ref "go.mod file reference"
  [Cargo Manifest File]: https://doc.rust-lang.org/cargo/reference/manifest.html
    "The Cargo Book: The Manifest Format"
  [npm `package.json`]: https://docs.npmjs.com/cli/v6/configuring-npm/package-json
    "npm Docs: Specifics of npm's package.json handling"
  [`trunk.toml`]: https://github.com/tembo-io/trunk/tree/main/contrib
  [pgxman buildkit]: https://docs.pgxman.com/spec/buildkit
  [PostGIS]: http://postgis.net/
  [arm64]: https://en.wikipedia.org/wiki/AArch64 "Wikipedia: AArch64"
  [amd64]: https://en.wikipedia.org/wiki/amd64 "Wikipedia: AMD64"
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Docs: Extension Building Infrastructure"
  [cargo]: https://github.com/pgcentralfoundation/pgrx/blob/develop/cargo-pgrx/README.md
    "pgrx: cargo-pgrx"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [TLE]: https://github.com/aws/pg_tle
    "pg_tle: Framework for building trusted language extensions for PostgreSQL"
  [TLE installer]: https://github.com/aws/pg_tle/blob/main/examples/README.md
    "TLE examples/pgtle.mk README"
  [man pages]: https://en.wikipedia.org/wiki/Man_page "Wikipedia: Man page"
  [background workers]: https://www.postgresql.org/docs/current/bgworker.html
    "PostgreSQL Docs: Background Worker Processes"
  [pg_repack]: https://reorg.github.io/pg_repack/
    "pg_repack --- Reorganize tables in PostgreSQL databases with minimal locks"
  [pg_top]: https://pg_top.gitlab.io "Welcome to the PostgreSQL top Project Home Page"
  [`shared_preload_libraries`]: https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-SHARED-PRELOAD-LIBRARIES
    "PostgreSQL Docs: shared_preload_libraries"
  [`LOAD`]: https://www.postgresql.org/docs/current/sql-load.html
    "PostgreSQL Docs: LOAD"
  [category slugs]: https://crates.io/category_slugs "crates.io: All Valid Category Slugs"
  [cargo categories field]: https://doc.rust-lang.org/cargo/reference/manifest.html#the-categories-field
    "The Cargo Book: The Manifest Format --- Categories"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [on Mastodon]: {{% param "mastodon.url" %}} "{{% param "mastodon.user" %}}"
