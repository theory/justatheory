---
title: "RFC: PGXN Meta Spec v2"
slug: rfc-pgxn-meta-v2
date: 2024-07-15T19:15:08Z
lastMod: 2024-07-15T19:15:08Z
description: |
  PGXN Meta Spec v2 represents a significant reworking of the original spec
  for PGXN distributions. It would very much benefit from feedback from
  Postgres extension and developers.
tags: [Postgres, PGXN, RFC, Trunk, Distribution, Metadata]
type: post
---

Two bits of news on the "PGXN v2" project.

PGXN RFCs: The Book
-------------------

First, I've moved the RFC process (again, sorry) from [PGXN Discussions],
which were a bit fussy about Markdown formatting and don't support inline
comments, to the [PGXN RFCs] project, where use of pull requests on
[CommonMark] Markdown documents address these issues. This process borrows
heavily from the [Rust RFCs] project, right down to publishing accepted RFCs
as a "book" site.

So I'd also like to introduce [rfcs.pgxn.org], a.k.a., the *PGXN RFCs Book.*

It currently houses only one RFC: [Meta Spec v1], dating from 2010. This
document defines the structure of the `META.json` file required in archives
published on [PGXN]. 

But I expect many more RFCs to be drafted in the coming years, starting with
[draft RFC--2][RFC-2], the binary distribution RFC I [POCed] a few weeks ago.
There has already been some great feedback in that pull request, in addition
to the [previous discussion]. More eyes will make it even better.

PGXN Meta Spec v2 RFC
---------------------

Last week I also iterated on the [PGXN Metadata Sketch] several times to
produce [draft RFC--3: Meta Spec v2][RFC-3]. This represents a major reworking
of the [original spec][Meta Spec v1] in an attempt to meet the following
goals:

*   Allow more comprehensive dependency specification, to enable packagers to
    identify and install system dependencies and dependencies from other
    packaging systems, like [PyPI] and [CPAN]
*   Adopt more industry-standard formats like [SPDX License Expressions] and
    [purls].
*   Improve support multiple types of Postgres extensions, including apps,
    [`LOAD`]able modules, background workers, and [TLEs].
*   Improve curation and evaluation via categories, badging, and additional
    download links.

There's a lot here, but hope the result can better serve the community for the
next decade, and enable lots of new services and features.

The proof will be in the application, so my next task is to start building the
tooling to turn PGXN distributions into [binary distributions][RFC-2]. I
expect experimentation will lead to additional iterations, but feel confident
that the current state of both [RFC--2][RFC-2] and [RFC--3][RFC-3] is on the
right track.

  [PGXN Discussions]: https://github.com/orgs/pgxn/discussions
  [PGXN RFCs]: https://github.com/pgxn/rfcs "RFCs for Changes to PGXN"
  [CommonMark]: https://commonmark.org
    "A strongly defined, highly compatible specification of Markdown"
  [Rust RFCs]: https://github.com/rust-lang/rfcs "RFCs for changes to Rust"
  [rfcs.pgxn.org]: https://rfcs.pgxn.org "PGXN RFCs — PGXN Book"
  [Meta Spec v1]: https://rfcs.pgxn.org/0001-meta-spec-v1.html
    "PGXN Meta Spec - The PGXN distribution metadata specification"
  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [POCed]: {{% ref "/post/postgres/trunk-poc" %}}
    "POC: PGXN Binary Distribution Format"
  [previous discussion]: https://github.com/orgs/pgxn/discussions/2
    "Proposal: Binary Distribution Format (closed)"
  [RFC-2]: https://github.com/pgxn/rfcs/pull/2
    "pgxn/rfcs#2 – RFC: Binary Distribution Format"
  [PGXN Metadata Sketch]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}
    "RFC: PGXN Metadata Sketch"
  [RFC-3]: https://github.com/pgxn/rfcs/pull/3
    "pgxn/rfcs#2 – RFC: Meta Spec v2"
  [PyPI]: https://pypi.org
    "Find, install and publish Python packages with the Python Package Index"
  [CPAN]: https://www.cpan.org "Comprehensive Perl Archive Network"
  [SPDX License Expressions]: https://spdx.github.io/spdx-spec/v3.0/annexes/SPDX-license-expressions/
  [purls]: https://github.com/package-url/purl-spec
    "A minimal specification for purl aka. a package “mostly universal” URL"
  [`LOAD`]: https://www.postgresql.org/docs/current/sql-load.html
    "PostgreSQL Docs: LOAD"
  [TLEs]: https://github.com/aws/pg_tle
    "Trusted Language Extensions for PostgreSQL (pg_tle)"
