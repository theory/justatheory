---
title: Auto-Release PostgreSQL Extensions on PGXN
slug: release-on-pgxn
date: 2025-05-20T15:49:30Z
lastMod: 2025-05-20T15:49:30Z
description: |
  Step-by-step instructions to publish PostgreSQL extensions and utilities on
  the PostgreSQL Extension Network (PGXN).
tags: [Postgres, PGXN, Extension, GitHub, GitHub Actions, Automation, CI/CD]
type: post
---

I last wrote about auto-releasing PostgreSQL extensions on PGXN [back in
2020][release-extensions], but I thought it worthwhile, following my [Postgres
Extensions Day][pgext] talk last week, to return again to the basics. With the
goal to get as many extensions distributed on [PGXN] as possible, this post
provides step-by-step instructions to help the author of any extension or
Postgres utility to quickly and easily publish every release.

## TL;DR

1.  Create a [PGXN Manager] account
2.  Add a [`META.json`][spec] file to your project
3.  Add a [pgxn-tools] powered CI/CD pipeline to publish on tag push
4.  [Fully-document](#write-killer-docs) your extensions

## Release your extensions on PGXN

[PGXN] aims to become the defacto source for all open-source PostgreSQL
extensions and tools, in order to help users quickly find and learn how to use
extensions to meet their needs. Currently, PGXN distributes source releases
for around 400 extensions (stats on the [about page]), a fraction of the ca.
[1200 known extensions]. Anyone looking for an extension might exist to solve
some problem must rely on search engines to find potential solutions between
PGXN, GitHub, GitLab, blogs, social media posts, and more. Without a single
trusted source for extensions, and with the proliferation of [AI Slop] in
search engine results, finding extensions aside from a few well-known
solutions proves a challenge.

By publishing releases and full documentation --- all fully indexed by its
search index --- PGXN aims to be that trusted source. Extension authors
provide all the documentation, which PGXN formats for legibility and linking.
See, for example, the [pgvector docs].

If you want to make it easier for users to find your extensions, to read your
documentation --- not to mention provide sources for binary packaging systems
--- publish every release on PGXN.

Here's how.

### Create an Account

Step one: create a [PGXN Manager] account. The *Email*, *Nickname*, and *Why*
fields are required. The form asks "why" as a simple filter for bad actors.
Write a sentence describing what you'd like to release --- ideally with a link
to the source repository --- and submit. We'll get the account approved
forthwith, which will send a confirmation email to your address. Follow the
link in the email and you'll be good to go.

### Anatomy of a Distribution

A PostgreSQL extension source tree generally looks something like this (taken
from the [pair repository]):

```tree
pair
├── Changes
├── doc
│   └── pair.md
├── Makefile
├── META.json
├── pair.control
├── README.md
├── sql
│   ├── pair--unpackaged--0.1.2.sql
│   └── pair.sql
└── test
    ├── expected
    │   └── base.out
    └── sql
        └── base.sql
```

Extension authors will recognize the standard [PGXS] (or [pgrx]) source
distribution files; only `META.json` file needs explaining. The `META.json`
file is, frankly, the only file that PGXN requires in a release. It contains
the metadata to describe the release, following the [PGXN Meta Spec][spec].
This example contains only the required fields:

```json
{
  "name": "pair",
  "version": "0.1.0",
  "abstract": "A key/value pair data type",
  "maintainer": "David E. Wheeler <david@justatheory.com>",
  "license": "postgresql",
  "provides": {
    "pair": {
      "file": "sql/pair.sql",
      "version": "0.1.0"
    }
  },
  "meta-spec": {
    "version": "1.0.0"
  }
}
```

Presumably these fields contain no surprises, but a couple of details:

*   It starts with the name of the distribution, `pair`, and the release
    version, `0.1.0`.
*   The `abstract` provides a brief description of the extension, while the
    `maintainer` contains contact information.
*   The `license` stipulates the distribution license, of course, usually one
    of a few known, but may be [customized][license].
*   The `provides` object lists the extensions or tools provided, each named
    by an object key that points to details about the extension, including
    main file, version, and potentially an abstract and documentation file.
*   The `meta-spec` object identifies the meta spec version used for the
    `META.json` itself.

### Release It!

This file with these fields is all you need to make a release. Assuming Git,
package up the extension source files like so (replacing your extension name
and version as appropriate).

```
git archive --format zip --prefix=pair-0.1.0 -o pair-0.1.0.zip HEAD
```

Then navigate to the [release page], authenticate, and upload the resulting
`.zip` file.

{{% figure
    src = "upload-to-pgxn.png"
    class = "frame"
    alt = "Screenshot with a box labeled “Upload a Distribution Archive”. It contains an “Archive” label in front of a button labeled “Choose File”. Next to it is a zip file icon and  the text “pair-0.1.0.zip”. Below the box is another button labeled “Release It!”"
%}}

And that's it! Your release will appear on [pgxn.org][PGXN] and on [Mastodon]
within five minutes.

## Let's Automate it!

All those steps would be a pain in the ass to follow for every release. Let's
automate it using [pgxn-tools]! This OCI image contains the tools necessary to
package and upload an extension release to PGXN. Ideally, use a [CI/CD]
pipeline like a [GitHub Workflow] to publish a release on every version tag.

### Set up Secrets

[pgxn-tools] uses your PGXN credentials to publish releases. To keep them
safe, use the secrets feature of your preferred CI/CD tool. This figure shows
the "Secrets and variables" configuration for a GitHub repository, with two
repository secrets: `PGXN_USERNAME` and `PGXN_PASSWORD`:

{{% figure
    src = "github-secrets.png"
    class = "frame"
    alt = "Screenshot of GitHub Secrets configuration featuring two repository secrets: `PGXN_USERNAME` and `PGXN_PASSWORD`."
%}}

### Create a Pipeline

Use those secrets and [pgxn-tools] in CI/CD pipeline. Here, for example, is a
minimal GitHub workflow to publish a release for every [SemVer] tag:

```yaml {linenos=table}
on:
  push:
    tags: ['v[0-9]+.[0-9]+.[0-9]+']
jobs:
  release:
    name: Release on PGXN
    runs-on: ubuntu-latest
    container: pgxn/pgxn-tools
    env:
      PGXN_USERNAME: ${{ secrets.PGXN_USERNAME }}
      PGXN_PASSWORD: ${{ secrets.PGXN_PASSWORD }}
    steps:
    - name: Check out the repo
      uses: actions/checkout@v4
    - name: Bundle the Release
      run: pgxn-bundle
    - name: Release on PGXN
      run: pgxn-release
```

Details:

*   Line 3 configures the workflow to run on a [SemVer] tag push, typically
    used to denote a release.
*   Line 8 configures the workflow job to run inside a [pgxn-tools] container.
*   Lines 10-11 set environment variables with the credentials from the
    secrets.
*   Line 16 bundles the release using either `git archive` or `zip`.
*   Line 18 publishes the release on PGXN.

Now publishing a new release is as simple as pushing a [SemVer] tag, like so:

```sh
git tag v0.1.0 -sm 'Tag v0.1.0'
git push --follow-tags
```

That's it! The workflow will automatically publish the extension for every
release, ensuring the latest and greatest always make it to PGXN where users
and packagers will find them.

The [pgxn-tools] image also provides tools to easily test a [PGXS] or [pgrx]
extension on supported PostgreSQL versions (going back as far as 8.2), also
super useful in a CI/CD pipeline. See [Test Postgres Extensions With GitHub
Actions] for instructions. Depending on your CI/CD tool of choice, you might
take additional steps, such as publishing a release on GitHub, as [previously
described][release-extensions].

## Optimizing for PGXN

But let's dig deeper into how to optimize extensions for maximum
discoverability and user visibility on [PGXN].

### Add More Metadata

The `META.json` file supports many more fields that PGXN indexes and
references. These improve the chances users will find what they're looking
for. This detailed example demonstrates how a [PostGIS] `META.json` file might
start to provide additional metadata:

```json {linenos=table}
{
   "name": "postgis",
   "abstract": "Geographic Information Systems Extensions to PostgreSQL",
   "description": "This distribution contains a module which implements GIS simple features, ties the features to R-tree indexing, and provides many spatial functions for accessing and analyzing geographic data.",
   "version": "3.5.0",
   "maintainer": [
      "Paul Ramsey <pramsey@example.com>",
      "Sandro Santilli <sandro@examle.net>"
   ],
   "license": [ "gpl_2", "gpl_3" ],
   "provides": {
      "postgis": {
         "abstract": "PostGIS geography spatial types and functions",
         "file": "extensions/postgis/postgis.control",
         "docfile": "extensions/postgis/doc/postgis.md",
         "version": "3.5.0"
      },
      "address_standardizer": {
         "abstract": "Used to parse an address into constituent elements. Generally used to support geocoding address normalization step.",
         "file": "extensions/address_standardizer/address_standardizer.control",
         "docfile": "extensions/address_standardizer/README.address_standardizer",
         "version": "3.5.0"
      }
   },
   "prereqs": {
      "runtime": {
         "requires": {
            "PostgreSQL": "12.0.0",
            "plpgsql": 0
         }
      },
      "test": {
         "recommends": {
            "pgTAP": 0
         }
      }
   },
   "resources": {
      "bugtracker": {
         "web": "https://trac.osgeo.org/postgis/"
      },
      "repository": {
         "url": "https://git.osgeo.org/gitea/postgis/postgis.git",
         "web": "https://git.osgeo.org/gitea/postgis/postgis",
         "type": "git"
      }
   },
   "generated_by": "David E. Wheeler",
   "meta-spec": {
      "version": "1.0.0",
      "url": "https://pgxn.org/meta/spec.txt"
   },
   "tags": [
      "gis",
      "spatial",
      "geometry",
      "raster",
      "geography",
      "location"
   ]
}
```

*   Line 4 contains a longer description of the distribution.
*   Lines 6-9 show how to list multiple maintainers as an array.
*   Line 10 demonstrates support for an array of licenses.
*   Lines 11-24 list multiple extensions included in the distribution, with
    abstracts and documentation files for each.
*   Lines 25-37 identify dependencies for various phases of the distribution
    lifecycle, including configure, build, test, runtime, and develop. Each
    contains an object identifying PostgreSQL or extension dependencies.
*   Lines 38-47 lists resources for the distribution, including issue
    tracking and source code repository.
*   Lines 53-60 contains an array of tags, an arbitrary list of keywords for a
    distribution used both in the search index and the [PGXN tag cloud].

Admittedly the [PGXN Meta Spec][spec] provides a great deal of information.
Perhaps the simplest way to manage it is to copy an existing `META.json` from
another project (or above) and edit it. In general, only the `version` fields
require updating for each release.

### Write Killer Docs

The most successful extensions provide ample descriptive and reference
documentation, as well as examples. Most extensions feature a README, of
course, which contains basic information, build and install instructions, and
contact info. But as the [pair tree](#anatomy-of-a-distribution), illustrates,
PGXN also supports extension-specific documentation in a variety of formats,
including:

*   [Asciidoc](https://asciidoc.org)
*   [BBcode](https://www.bbcode.org)
*   [Creole](https://www.wikicreole.org)
*   [HTML](https://whatwg.org/html)
*   [Markdown](https://daringfireball.net/projects/markdown/)
*   [MediaWiki](https://en.wikipedia.org/wiki/Help:Contents/Editing_Wikipedia)
*   [MultiMarkdown](https://fletcherpenney.net/multimarkdown/)
*   [Pod](https://metacpan.org/dist/perl/view/pod/perlpodspec.pod)
*   [reStructuredText](https://docutils.sourceforge.io/rst.html)
*   [Textile](https://textile-lang.com)
*   [Trac](https://trac.edgewall.org/wiki/WikiFormatting)

Some examples:

*   [jsonschema](https://github.com/theory/pg-jsonschema-boon/blob/main/doc/jsonschema.md) (Markdown)
*   [semver](https://github.com/theory/pg-semver/blob/main/doc/semver.mmd)
    (MultiMarkdown)

PGXN will also index and format additional documentation files in any of the
above formats. See, for example, all the files formatted for [orafce].

### Exclude Files from Release

Use [gitattributes] to exclude files from the release. For example,
distributions don't generally include `.gitignore` or the contents of the
`.github` directory. Exclude them from the archive created by `git archive` by
assigning `export-ignore` to each path to exclude in the `.gitattributes`
file, like so:

```
.gitignore export-ignore
.gitattributes export-ignore
.github export-ignore
```

## What's It All For?

[PGXN] aims to be the trusted system of record for open-source PostgreSQL
extensions. Of course that requires that it contain all (or nearly all) of
said extensions. Hence this post.

Please help make it so by adding your extensions, both to help users find the
extensions they need, and to improve the discoverability of your extensions.
Over time, we aim to feed downstream extension distribution systems, such as
[Yum], [APT], [CloudNativePG], [OCI], and more.

Let's make extensions available everywhere to everyone.

  [release-extensions]: {{% ref "/post/postgres/release-extensions" %}}
    "Automate Postgres Extension Releases on GitHub and PGXN"
  [pgext]: https://pgext.day "Postgres Extensions Day Montréal 2025"
  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [about page]: https://pgxn.org/about/ "About PGXN"
  [1200 known extensions]: https://gist.github.com/joelonsql/e5aa27f8cc9bd22b8999b7de8aee9d47
    "🗺🐘 1000+ PostgreSQL EXTENSIONs"
  [AI Slop]: https://en.wikipedia.org/wiki/AI_slop "Wikipedia: AI Slop"
  [pgvector docs]: https://pgxn.org/dist/vector/README.html
  [PGXN Manager]: https://manager.pgxn.org/account/register
    "Request a PGXN Account"
  [pair repository]: https://github.com/theory/kv-pair/
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Docs: Extension Building Infrastructure"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [spec]: https://rfcs.pgxn.org/0001-meta-spec-v1.html
  [license]: https://rfcs.pgxn.org/0001-meta-spec-v1.html#license
  [Mastodon]: https://mastodon.social/@pgxn
  [release page]: https://manager.pgxn.org/upload
  [pgxn-tools]: https://hub.docker.com/r/pgxn/pgxn-tools
  [CI/CD]: https://en.wikipedia.org/wiki/CI/CD "Wikipedia: CI/CD"
  [GitHub Workflow]: https://docs.github.com/en/actions/writing-workflows
  [SemVer]: https://semver.org "Semantic Versioning 2.0.0"
  [Test Postgres Extensions With GitHub Actions]: {{% ref "/post/postgres/pgxn-tools" %}}
  [gitattributes]: https://git-scm.com/docs/gitattributes
  [PostGIS]: https://postgis.net "PostGIS"
  [PGXN tag cloud]: https://pgxn.org/tags "PGXN Release Tags"
  [orafce]: https://pgxn.org/dist/orafce/
  [Yum]: https://yum.postgresql.org "PostgreSQL Yum Repository"
  [APT]: https://wiki.postgresql.org/wiki/Apt "The PostgreSQL Wiki: “Apt”"
  [CloudNativePG]: https://cloudnative-pg.io "Run PostgreSQL. The Kubernetes way."
  [OCI]: {{% ref "/post/postgres/trunk-oci-poc/index" %}} "POC: Distributing Trunk Binaries via OCI"
