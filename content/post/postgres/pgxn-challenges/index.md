---
title: PGXN Challenges
slug: pgxn-challenges
date: 2024-01-29T15:57:46Z
lastMod: 2024-01-29T15:57:46Z
description: |
  Some thoughts on the challenges for PGXN's role in the ideal PostgreSQL
  extension ecosystem of the future.
tags: [Postgres, PGXN, Extensions]
type: post
draft: true
image:
  src: pgxn-gear.png
  alt: PGXN Gear
  width: 256
  height: 256
  class: left frame

---

Last week, I informally shared [Extension Ecosystem: Jobs and Tools] with
colleagues in the [#extensions] channel on the [Postgres Slack]. The document
surveys the [jobs to be done] by the ideal Postgres extension ecosystem and the
suggests the tools and services required to do those jobs --- without reference
to existing extension registries and packaging systems.

The last section enumerates some questions we need to ponder and answer. The
first one on the list is:

> What will [PGXN]'s role be in this ideal extension ecosystem?

The PostgreSQL Extension Network, or [PGXN], is the original extension
distribution system, created 2010--11. It has been a moderate success, but as we
in the Postgres community imagine the ideal extension distribution future, it's
worthwhile to also critically examine existing tools like PGXN, both to inform
the project and to realistically determine their roles in that future.

With that in mind, I here jot down some thoughts on the challenges with PGXN.

PGXN Challenges
---------------

PGXN sets a lot of precedents, particularly in its decoupling of the registry
from the APIs and services that depend on it. It's not an all-in-one thing, and
designed for maximum distributed dissemination via rsync and static JSON files.

But there are a number of challenges with PGXN as it currently stands; a
sampling:

*   PGXN has not comprehensively indexed all public PostgreSQL extensions. While
    it indexes more extensions than any other registry, it falls far short of
    all [known extensions]. To be a truly canonical registry, we need to make it
    as simple as possible for developers to register their extensions. (More
    thoughts on that topic in a forthcoming post.)
    
*   In that vein, releasing extensions is largely a manual process. The
    [pgxn-tools] Docker image has improved the situation, allowing developers to
    create relatively simple GitHub workflows to automatically [test] and
    [release] extensions. Still, it requires intention and work by extension
    developers. The more seamless we can make publishing extensions the better.
    (More thoughts on that topic in a forthcoming post.)

*   It's written in [Perl], and therefore doesn't feel modern or easily
    accessible to other developers. It's also a challenge to build and
    distribute the Perl services, though Docker images could mitigate this
    issue. Adopting a modern compiled language like [Go] or [Rust] might
    increase community credibility and attract more contributions.

*   Similarly, [pgxnclient] is written in [Python] and the [pgxn-utils]
    developer tools in [Ruby], increasing the universe of knowledge and skill
    required for developers to maintain all the tools. They're also more
    difficult to distribute than compiled tools would be. Modern
    cross-compilable languages like [Go] and [Rust] once again simplify
    distribution and are well-suited to building both web services and CLIs (but
    not, perhaps native UX applications ---  but then neither are dynamic
    languages like Ruby and Python).

*   The [PGXN Search API] uses the [Apache Lucy] search engine library, a
    project that [retired] in 2018. Moreover, the feature never worked very
    well, thanks to the decision to expose separate search indexes for different
    objects --- and requiring the user to select which to search. People often
    can't find what they need because the selected index doesn't contain it.
    Worse, the default index on [the site][pgxn] is "Documentation", on the
    surface a good choice. But most extensions include no documentation other
    than the README, which appears in the "Distribution" index, not
     "Documentation". Fundamentally the search API and UX needs to be completely
    re-architected and -implemented.

*   PGXN uses its own very simple identity management and [basic
    authentication]. It would be better to have tighter community identity,
    perhaps through the [PostgreSQL community account].

Given these issues, should we continue building on PGXN, rewrite some or all of
its components, or abandon it for new services. The answer may come as a natural
result of designing the overall extension ecosystem architecture or from the
motivations of community consensus. But perhaps not. In the end, we'll need a
clear answer to the question.

What are your thoughts? Hit us up in the [#extensions] channel on the [Postgres
Slack], or give me a holler [on Mastodon] or via email. We expect to start
building in earnest in February, so now's the time!

  [Extension Ecosystem: Jobs and Tools]: https://gist.github.com/theory/898c8802937ad8361ccbcc313054c29d
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [jobs to be done]: https://strategyn.com/jobs-to-be-done/jobs-to-be-done-theory/
  [PGXN]: https://pgxn.org "The postgreSQL Extension Network"
  [known extensions]: https://gist.github.com/joelonsql/e5aa27f8cc9bd22b8999b7de8aee9d47
    "GitHub Gist: 🗺🐘 1000+ PostgreSQL EXTENSIONs"
  [pgxn-tools]: https://github.com/pgxn/docker-pgxn-tools
    "pgxn/docker-pgxn-tools: Test image for PostgreSQL & PGXN extensions"
  [test]: https://github.com/theory/kv-pair/blob/main/.github/workflows/ci.yml
    "kv-pair extension CI workflow"
  [release]: https://github.com/theory/kv-pair/blob/main/.github/workflows/release.yml
    "kv-pair extension release workflow"
  [Perl]: https://www.perl.org
    "Perl is a highly capable, feature-rich programming language with over 36 years of development."
  [Go]: https://go.dev "Build simple, secure, scalable systems with Go"
  [Rust]: https://www.rust-lang.org
    "A language empowering everyone to build reliable and efficient software"
  [pgxnclient]: https://pgxn.github.io/pgxnclient/
    "PGXN Client’s documentation"
  [Python]: https://www.python.org
    "Python is a programming language that lets you work quickly and integrate systems more effectively"
  [pgxn-utils]: https://github.com/guedes/pgxn-utils
    "PGXN extension development and release utilities"
  [Ruby]: https://www.ruby-lang.org/
    "A dynamic, open source programming language with a focus on simplicity and productivity."
  [PGXN Search API]: https://github.com/pgxn/pgxn-api/wiki/search-api
  [Apache Lucy]: https://lucy.apache.org
    "A “loose C” port of the Apache Lucene™ search engine library for Java."
  [retired]: https://attic.apache.org/projects/lucy.html
    "Apache Lucy moved into the Attic in June 2018"
  [basic authentication]: https://en.wikipedia.org/wiki/Basic_access_authentication
    "Wikipedia: “Basic access authentication”"
  [PostgreSQL community account]: https://www.postgresql.org/account/
    "Your PostgreSQL community account"
  [on Mastodon]: {{% param "mastodon.url" %}} "{{% param "mastodon.user" %}}"
