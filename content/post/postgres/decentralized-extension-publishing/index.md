---
title: Contemplating Decentralized Extension Publishing
slug: decentralized-extension-publishing
date: 2024-02-01T15:50:00Z
lastMod: 2024-02-01T15:50:00Z
description: |-
  The Go package ecosystem uses distributed publishing to release modules
  without authentication or uploads. Could we do something similar for
  Postgres extensions?
tags: [Postgres, PGXN, Extensions, Go, Packaging, Distributed Publishing]
type: post
---

### TL;DR ###

As I think through the future of the Postgres extension ecosystem as a key part
of the [new job], I wanted to understand how [Go decentralized publishing]
works. In this post I work it out, and think through how we might do something
similar for Postgres extension publishing. It covers the
[Go architecture](#decentralized-publishing), [namespacing challenges](#namespacing),
and [PGXS abuse](#installer-abuse); then experiments with
[URL-based namespacing](#namespacing-experiment) and ponders
[reorganizing installed extension files](#proposal-update-postgres-extension-packaging);
and closes with a [high-level design](#back-to-decentralized-publishing) for
making it work now and in the future.

It is, admittedly, *a lot,* mainly written for my own edification and for the
information of my fellow extension-releasing travelers.

I find it fascinating and learned a ton. Maybe you will too! But feel free to
skip this post if you're less interested in the details of the journey and want
to wait for more decisive posts once I've reached the destination.

## Introduction

Most language registries require developers to take some step to make releases.
Many automate the process in CI/CD pipelines, but it requires some amount of
effort on the developer's part:

*   Register for an account
*   Learn how to format things to publish a release
*   Remember to publish again for every new version
*   Create a pipeline to automate publishing (e.g., a GitHub workflow)

## Decentralized Publishing

[Go decentralized publishing] has revised this pattern: it does not require user
registration or authentication to to publish a module to [pkg.go.dev]. Rather,
Go developers simply tag the source repository, and the first time someone
[refers to the tag in Go tools], the [Go module index] will include it.

For example, publishing `v1.2.1` of a module in the `github.com/golang/example`
repository takes just three commands:

```sh
git tag v1.2.1 -sm 'Tag v1.2.1'
git push --tags
go list -m github.com/golang/example@v1.2.1
```

After a few minutes, the module will show up in [the index] and then on
[pkg.go.dev]. Anyone can run `go get -u github.com/golang/example` to get the
latest version. Go developers rest easy in the knowledge that they're getting
the exact module they need thanks to the [global checksum database], which Go
uses "in many situations to detect misbehavior by proxies or origin servers".

This design requires `go get` to understand multiple source code management
systems: it supports Git, Subversion, Mercurial, Bazaar, and Fossil.[^or_does_it]
It also needs the `go.mod` metadata file to live in the project defining the
package.

But that's really it. From the developer's perspective it could not be easier to
publish a module, because it's a natural extension of the module development
tooling and workflow of committing, tagging, and fetching code.

## Decentralized Extension Publishing

Could we publish Postgres extensions in such a decentralized pattern? It might
look something like this:

*   The developer places a metadata file in the proper location ([control file],
    `META.json`, `Cargo.toml`, whatever --- standard TBD)
*   To publish a release, the developer tags the repository and calls some sort
    of indexing service hook (perhaps from a tag-triggered release workflow)
*   The indexing service validates the extension and adds it to the index

Note that there is no registration required. It simply trusts the source code
repository. It also avoids name collision: `github.com/bob/hash`
is distinct from `github.com/carol/hash`.

This design does raise challenges for clients, whether they're compiling
extensions on a production system or building binary packages for distribution:
they have to support various version control systems to pull the code (though
starting with Git is a decent 90% solution).

## Namespacing

Then there's name conflicts. Perhaps `github.com/bob/hash` and
`github.com/carol/hash` both create an extension named `hash`. By the current
[control file] format, the script directory and module path can use any name,
but in all likelihood the use these defaults:

```ini
directory = 'extension'
module_pathname = '$libdir/hash'
```

Meaning `.sql` files will be installed in the Postgres `share/extension`
subdirectory --- along with all the other installed extensions --- and library
files will be installed in the library directory along with all other libraries.
Something like this:

```tree
pgsql
├── lib
│   └── hash.so
└── share
    └── extension
    │   └── hash.control
    │   ├── hash--1.0.0.sql
    └── doc
        └── hash.md
```

If both projects include, say, `hash.control`, `hash--1.0.0.sql`, and `hash.so`,
the files from one will stomp all over the files of the other.

## Installer Abuse

Go avoids this issue by using the domain and path from each package's repository
in its directory structure. For example, here's a list of modules from
`google.golang.org` repositories:

``` console
$ ls -1 ~/go/pkg/mod/google.golang.org
api@v0.134.0
api@v0.152.0
appengine@v1.6.7
genproto
genproto@v0.0.0-20230731193218-e0aa005b6bdf
grpc@v1.57.0
grpc@v1.59.0
protobuf@v1.30.0
protobuf@v1.31.0
protobuf@v1.32.0
```

The `~/go/pkg/mod` directory has subdirectories for each VCS host name, and each
then subdirectories for package paths. For the `github.com/bob/hash` example,
the files would all live in `~/go/pkg/mod/github.com/bob/hash`.

Could a Postgres extension build tool follow a similar distributed pattern by
renaming the control file and installation files and directories to something
specific for each, say `github.com+bob+hash` and `github.com+carol+hash`? That
is, using the repository host name and path, but replacing the slashes in the
path with some other character that wouldn't create subdirectories --- because
PostgreSQL won't find control files in subdirectories. The control file entries
for `github.com/carol/hash` would look like this:

```ini
directory = 'github.com+carol+hash'
module_pathname = '$libdir/github.com+carol+hash'
```

Since PostgreSQL expects the control file to have the same name as the
extension, and for SQL scripts to start with that name, the files would have to
be named like so:

```tree
hash
├── Makefile
├── github.com+carol+hash.control
└── sql
    └── github.com+carol+hash--1.0.0.sql
```

And the `Makefile` contents:

``` makefile
EXTENSION  = github.com+carol+hash
MODULEDIR  = $(EXTENSION)
DATA       = sql/$(EXTENSION)--1.0.0.sql
PG_CONFIG ?= pg_config

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
```

In other words, the extension name is the full repository host name and path and
the Makefile `MODULEDIR` variable tells `pg_config` to put all the SQL and
documentation files into a directories named `github.com+carol+hash` ---
preventing them from conflicting with any other extension.

Finally, the `github.com+carol+hash.control` file --- so named becaus it must
have the same name as the extension --- contains:

``` ini
default_version = '1.0.0'
relocatable = true
directory = 'github.com+carol+hash'
module_pathname = '$libdir/github.com+carol+hash'
```

Note the `directory` parameter, which must match `MODULEDIR` from the
`Makefile`, so that `CREATE EXTENSION` can find the SQL files. Meanwhile,
`module_pathname` ensures that the library file has a unique name --- the same
as the long extension name --- again to avoid conflicts with other projects.

That unsightly naming extends to SQL: using the URL format could get to be a
mouthful:

```sql
CREATE EXTENSION "github.com+carol+hash";
```

Which is do-able, but some new SQL syntax might be useful, perhaps something
like:

```sql
CREATE EXTENSION hash FROM "github.com+carol+hash";
```

Or, if we're gonna really go for it, use slashes after all!

```sql
CREATE EXTENSION hash FROM "github.com/carol/hash";
```

Want to use both extensions but they have conflicting objects (e.g., both create
a "hash" data type)? Put them into separatre schemas (assuming
`relocatable = true` in the control file):

```sql
CREATE EXTENSION hash FROM "github.com/carol/hash" WITH SCHEMA carol;
CREATE EXTENSION hash FROM "github.com/bob/hash" WITH SCHEMA bob;
CREATE TABLE try (
    h1 carol.hash,
    h2 bob.hash
);
```

Of course it would be nice if PostgreSQL added support for something like
[Oracle packages], but using schemas in the meantime may be sufficient.

Clearly we're getting into changes to the PostgreSQL core, so put that aside and
we can just use long names for creating, modifying, and dropping extensions, but
not necessarily otherwise:

```sql
CREATE EXTENSION "github.com+carol+hash" WITH SCHEMA carol;
CREATE EXTENSION "github.com+bob+hash" WITH SCHEMA bob;
CREATE EXTENSION "gitlab.com+barack+kicker_type";
CREATE TABLE try (
    h1 carol.hash,
    h2 bob.hash
    kt kicker
);
```

## Namespacing Experiment

To confirm that this approach might work, I committed [24134fd] and pushed it in
the [namespace-experiment] branch of [the semver extension]. This commit changes
the extension name from `semver` to `github.com+theory+pg-semver`, and follows
the above steps to ensure that its files are installed with that name.

Abusing the Postgres extension installation infrastructure like this *does*
work, but suffers from a number of drawbacks, including:

*   The extension name is super long, as before, but now so too are the files in
    the repository (as opposed to the installer renaming them on install). The
    shared library file has to have the long name, so therefore does the `.c`
    source file. The SQL files must all start with
    `github.com+theory+pg-semver`, although I skipped that bit in this commit;
    instead the `Makefile` generates just one from `sql/semver.sql`.
*   Any previous installation of the `semver` type would remain unchanged, with
    no upgrade path. Changing an extension's name isn't a great idea.

I could probably script renaming and modifying file contents like this and make
it part of the build process, but it starts to get complicated. We could also
modify installers to make the changes, but there are a bunch of moving parts
they would have to compensate for, and given how dynamic this can be (e.g., the
semver `Makefile` reads the extension name from `META.json`), we would rapidly
enter the territory of edge case [whac-a-mole]. I suspect it's simply too
error-prone.

## Proposal: Update Postgres Extension Packaging

Perhaps the Go directory pattern could inspire a similar model in Postgres,
eliminating the namespace issue by teaching the Postgres extension
infrastructure to include *all but one* of the files for an extension in a
single directory. In other words, rather than files distributed like so for
semver:

```tree
pgsql
├── lib
│   └── semver.so
└── share
    └── extension
    │   └── semver.control
    │   ├── semver--0.32.1.sql
    │   ├── semver--0.32.0--0.32.1.sql
    └── doc
        └── semver.md
```

Make it more like this:

```tree
pgsql
└── share
    └── extension
        └── github.com
            └── theory
                └── pg-semver
                    └── extension.control
                    └── lib
                    │   └── semver.so
                    └── sql
                    │   └── semver--0.32.1.sql
                    │   └── semver--0.32.0--0.32.1.sql
                    └── doc
                        └── semver.md
```

Or perhaps:

```tree
pgsql
└── share
    └── extension
        └── github.com
            └── theory
                └── pg-semver
                    └── extension.control
                    └── semver.so
                    └── semver--0.32.1.sql
                    └── semver--0.32.0--0.32.1.sql
                    └── semver.md
```

The idea is to copy the files exactly as they're stored in or compiled in the
repository. Meanwhile, the new `semver.name` file --- the only relevant file
stored outside the extension module directory --- simply points to that path:

``` text
github.com/theory/pg-semver
```

Then for `CREATE EXTENSION semver`, Postgres reads `semver.name` and knows where
to find all the files to load the extension.

This configuration would require updates to the control file, now named
`extension.control`, to record the full package name and appropriate locations.
Add:

```ini
name = 'semver'
package = 'github.com/theory/pg-semver'
```

This pattern could also allow aliasing. Say we try to install a different
`semver` extension from `github.com/example/semver`. This is in its
`extension.control` file:

```ini
name = 'semver'
package = 'github.com/example/pg-semver'
```

The installer detects that `semver.name` already exists for a different package
and raises an error. The user could then give it a different name by running
something like:

```sh
make install ALIAS_EXTENSION_NAME=semver2
```

This would add `semver2.name` right next to `semver.name`, and its contents
would contain `github.com/example/semver`, where all of its files are installed.
This would allow `CREATE EXTENSION semver2` to load the it without issue
(assuming no object conflicts, hopefully resolved by relocate-ability).

I realize a lot of extensions with libraries could wreak some havoc on the
library resolver having to search so many library directories, but perhaps
there's some way around that as well? Curious what techniques experienced C
developers might have adopted.

## Back to Decentralized Publishing

An updated installed extension file structure would be nice, and is surely worth
a discussion, but even if it shipped in Postgres 20, we need an updated
extension ecosystem today, to work well with all supported versions of Postgres.
So let's return to the idea of decentralized publishing without such changes.

I can think of two pieces that'd be required to get Go-style decentralized
extension publishing to work with the current infrastructure.

### Module Uniqueness

The first is to specify a new metadata field to be unique for the entire index,
and which would contain the repository path. Call it `module`, after Go (a
single Git repository can have multiple modules). In [PGXN Meta Spec]-style JSON
it'd look something like this:

```json
{
    "module": "github.com/theory/pg-semver",
    "version": "0.32.1",
    "provides": {
      "semver": {
         "abstract": "A semantic version data type",
      }
    }
}
```

Switch from the PGXN-style uniqueness on the distribution name (usually the name
of the extension) and let the module be globally unique. This would allow
another party to release an extension with the same name. Even a fork where only
the `module` is changed:

```json
{
    "module": "github.com/example/pg-semver",
    "version": "0.32.1",
    "provides": {
      "semver": {
         "abstract": "A semantic version data type",
      }
    }
}
```

Both would be indexed and appear under the module name, and both would be
find-able by the provided extension name, `semver`.

Where that name must still be unique is in a given install. In other words,
while `github.com/theory/pg-semver` and `github.com/example/pg-semver` both
exist in the index, the `semver` extension can be installed from only one of
them in a given Postgres system, where the extension name `semver` defines its
uniqueness.

This pattern would allow for much more duplication of ideas while preserving the
existing per-cluster namespacing. It also allows for a future Postgres release
that supports something like the flexible per-cluster packaging as described
above.[^module_standard]

### Extension Toolchain App

The second piece is an extension management application that understands all
this stuff and makes it possible. It would empower both extension development
workflows --- including testing, metadata management, and releasing --- and
extension user workflows --- finding, downloading, building, and installing.

Stealing from Go, imagine a developer making a release with something like this:

``` sh
git tag v1.2.1 -sm 'Tag v1.2.1'
git push --tags
pgmod list -m github.com/theory/pg-semver@v1.2.1
```

The creatively named `pgmod` tells the registry to index the new version
directly from its Git repository. Thereafter anyone can find it and install it
with:


*   `pgmod get github.com/theory/pg-semver@v1.2.1` --- installs the specified version
*   `pgmod get github.com/theory/pg-semver` --- installs the latest version
*   `pgmod get semver` --- installs the latest version or shows a list of
    matching modules to select from

Any of these would fail if the cluster already has an extension named `semver`
with a different module name. But with something like the updated extension
installation locations in a future version of Postgres, that limitation could be
loosened.

### Challenges

Every new idea comes with challenges, and this little thought experiment is no
exception. Some that immediately occur to me:

*   Not every extension can be installed directly from its repository. Perhaps
    the metadata could include a download link for a tarball with the results of
    any pre-release execution?
*   Adoption of a new CLI could be tricky. It would be useful to include the
    functionality in existing tools people already use, like [pgrx].
*   Updating the uniqueness constraint in existing systems like [PGXN] might be
    a challenge. Most record the repository info in the [resources META.json
    object], so it would be do-able to adapt into a new META format, either
    on [PGXN] itself or in a new registry, should we choose to build one.
*   Getting everyone to standardize on standardized versioning tags might take
    some effort. Go had the benefit of controlling its entire toolchain, while
    Postgres extension versioning and release management has been all over the
    place. However [PGXN] long ago standardized on [semantic versioning] and
    those who have released extensions on PGXN have had few issues (one can
    still use other version formats in the control file, for better or worse).
*   Some PGXN distributions have shipped different versions of extensions in a
    single release, or the same version as in other releases. The release
    version of the overall package (repository, really) would have to become
    canonical.

I'm sure there are more, I just thought of these offhand. What have you thought
of? Post 'em if you got 'em   in the [#extensions] channel on the [Postgres
Slack], or give me a holler [on Mastodon] or via email.

  [^or_does_it]: Or does it? Yes, it does. Although the Go CLI downloads most
    public modules from a [module proxy server] like `proxy.golang.org`, it
    still must know how to [download modules from a version control system] when
    a proxy is not available.

  [^bug]: Perhaps not. It looks like PostgreSQL [currently ignores the `directory`
    parameter][directory-bug].

  [^module_standard]: Assuming, of course, that if and when the Postgres core
    adopts more bundled packaging that they'd use the same naming convention as
    we have in the broader ecosystem. Not a perfectly safe assumption, but given
    the Go precedent and wide adoption of host/path-based projects, it seems
    sound.

  [new job]: {{% ref "/post/personal/tembonaut/index.md" %}}
    "I'm a Postgres Extensions Tembonaut"
  [Go decentralized publishing]: https://go.dev/doc/modules/developing#decentralized
    "go.dev: Developing and publishing modules"
  [pkg.go.dev]: https://pkg.go.dev
  [Go module index]: https://index.golang.org
  [the index]: https://index.golang.org/index "Go module index feed"
  [global checksum database]: https://go.dev/ref/mod#checksum-database
    "Go Modules Reference: Checksum database"
  [refers to the tag in Go tools]: https://pkg.go.dev/about#adding-a-package
    "pkg.go.dev: Adding a package"
  [control file]: https://www.postgresql.org/docs/current/extend-extensions.html#EXTEND-EXTENSIONS-FILES
    "PostgreSQL Docs: Extension Files"
  [Oracle packages]: https://docs.oracle.com/database/121/LNPLS/packages.htm
    "Oracle Docs: PL/SQL Packages"
  [module proxy server]: https://go.dev/ref/mod#goproxy-protocol
    "Go Modules Reference: GOPROXY protocol"
  [download modules from a version control system]: https://go.dev/ref/mod#vcs
    "Go Modules Reference: Version control systems"
  [directory-bug]: https://github.com/theory/test-extension-directory
    "Test case for a PostgreSQL extension control file bug report"
  [24134fd]: https://github.com/theory/pg-semver/commit/24134fd
    "pg-semver@24134fd: Use domain-qualified name for extension"
  [namespace-experiment]: https://github.com/theory/pg-semver/tree/namespace-experiment
    "pg_semver@namespace-experiment: Experimental branch to try naming an extension with a source code repository URL similar to Go packages"
  [the semver extension]: https://github.com/theory/pg-semver
  [whac-a-mole]: https://en.wikipedia.org/wiki/Whac-A-Mole
    "Wikipedia: “Whac-A-Mole”"
  [PGXN]: https://pgxn.org "PGXN — PostgreSQL Extension Network"
  [PGXN Meta Spec]: https://pgxn.org/spec/
    "PGXN Meta Spec - The PGXN distribution metadata specification"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx is a framework for developing PostgreSQL extensions in Rust and strives to be as idiomatic and safe as possible"
  [resources META.json object]: https://pgxn.org/spec/#resources
  [semantic versioning]: https://semver.org "Semantic Versioning 2.0.0"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [on Mastodon]: {{% param "mastodon.url" %}} "{{% param "mastodon.user" %}}"
