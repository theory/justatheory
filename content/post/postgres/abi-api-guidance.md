---
title: "Patch: Postgres ABI and API Guidance"
slug: abi-api-guidance
date: 2024-06-27T18:05:04Z
lastMod: 2024-11-14T23:24:23Z
description: |
  Dear Postgres extension developers: Please review and give feedback on the
  proposed patch adding ABI and API guidance to the C language documentation.
tags: [Postgres, Extensions, Patch, ABI, API]
type: post
---

> [!NOTE] Update 2011-11-14
>
> I forgot to update this post at the time, but on July 31, [Peter Eisentraut]
> committed [the patch][patch] adding ABI and API guidance to the C language
> documentation. I only noticed because [today's releases] contained a
> modified ABI that broke a number of extensions. See the [hackers thread] for
> details.

> [!TIP] TL;DR
>
> If you're a Postgres extension developer interested in understanding what to
> expect from core API and ABI stability, please review and give feedback on
> [this patch][patch] (or [pull request]) adding ABI and API Guidance to the
> documentation.

----

In my [PGConf.dev report] a couple days ago, I mentioned that a few actionable
items came out of the [Improving extensions in core] unconference session. One
was the need to document the heretofore unofficial policy for [API] and [ABI]
stability between major and, especially, minor versions of Postgres.

A frequent topic at the [Extension Summit and Mini-Summits] and a number of
PCConf sessions has been concern regarding compatibility changes between minor
releases of Postgres. At [Mini Summit Five], for example, Yurri Rashkovskii
presented a few examples of such changes, leading him to conclude, along with
several others in the community, that C API-using extensions can only be used
when built against the minor release with which they're used.

In the Unconference session, core committers reported that such changes are
carefully made, and rarely, if ever, affect extensions compiled for different
minor releases of the same major version. Furthermore, they carefully make
such changes to avoid compatibility issues. In [the case Yurii
found][padding-fix], for example, a field was added to a struct's padding,
without affecting the ordering of other fields, thus minimizing the risk of
runtime failures.

It became clear that, although the committers follow a policy --- and read new
committers into it via patch review --- it's not documented anywhere. The
result has been a bunch of sturm und drang amongst extension developer unsure
what level of compatibility to depend on and what changes to expect.

The week after the conference, I started a [pgsql-hackers thread] proposing to
document the committer policy. Following some discussion and review of
potential ABI breaks in minor releases, the consensus seemed to be that the
committers strive to avoid such breaks, that they're quite uncommon in minor
releases, and that most of the reported issues were due to using more obscure
APIs.

As a result, we started drafting a policy, and after a few iterations, [Peter
Eisentraut] pulled things together from the perspective of a core team member,
reframed as "Server API and ABI Guidance". I converted it into a [patch] (and
[pull request]) to add it to the [C Language docs]. A key statement on minor
releases:

> In general, extension code that compiles and works with a minor release
> should also compile and work with any other minor release of the same major
> version, past or future.

I hope this document clarifies things. Even if it's not as strict as some
might hope, it at least documents the project approach to compatibility, so we
have a better idea what to expect when using the C APIs. If you see gaps, or
you have additional questions, please respond to [pgsql-hackers thread] --- or
the [pull request] (I'll propagate comments to hackers).

  [PGConf.dev report]: {{% ref "/post/postgres/pgconf-future-ecosystem" %}}
    "PGConf.dev 2024"
  [Improving extensions in core]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Developer_Unconference#Improving_extensions_in_core
  [API]: https://en.wikipedia.org/wiki/API "Wikipedia: API"
  [ABI]: https://en.wikipedia.org/wiki/Application_binary_interface
    "Wikipedia: Application binary interface"
  [Extension Summit and Mini-Summits]: {{% ref "/post/postgres/extension-ecosystem-summit" %}}
    "Extension Ecosystem Summit 2024"
  [Mini Summit Five]: {{% ref "/post/postgres/mini-summit-five" %}}
  [padding-fix]: https://x.com/petervgeoghegan/status/1785720228237717627
    "Peter Geoghegan on Twitter: You must be referring to my commit 714780dc…"
  [pgsql-hackers thread]: https://www.postgresql.org/message-id/flat/5DA9F9D2-B8B2-43DE-BD4D-53A4160F6E8D@justatheory.com
    "pgsql-hackers: Proposal: Document ABI Compatibility"
  [Peter Eisentraut]: https://peter.eisentraut.org
  [patch]: https://commitfest.postgresql.org/48/5080/
    "Commitfest — Docs: API & ABI Guidance"
  [pull request]: https://github.com/theory/postgres/pull/6
    "theory/postgres: Add API an ABI guidance to the C language docs"
  [C Language docs]: https://www.postgresql.org/docs/current/xfunc-c.html
    "PostgreSQL Docs: C-Language Functions"
  [today's releases]: https://www.postgresql.org/about/news/postgresql-171-165-159-1414-1317-and-1221-released-2955/
    "PostgreSQL 17.1, 16.5, 15.9, 14.14, 13.17, and 12.21 Released!"
  [hackers thread]: https://postgr.es/m/CABOikdNmVBC1LL6pY26dyxAS2f%2BgLZvTsNt%3D2XbcyG7WxXVBBQ%40mail.gmail.com
    "pgsql-hackers: Potential ABI breakage in upcoming minor releases"
