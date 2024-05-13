---
title: Extension Summit Topic Review
slug: extension-summit-topics
date: 2024-05-13T19:12:51Z
lastMod: 2024-05-13T19:12:51Z
description: |
  Final Postgres Extension Mini-Summit! On Wednesday May 15 at noon Eastern /
  16:00 UTC, we'll review some of the topics that have come up in previous
  Mini-Summits with the goal to winnow down and select issues to address at
  PGConf.dev.
tags: [Postgres, Yum, PGConf, Summit]
type: post
---

Boy howdy that went fast.

This Wednesday, May 15, the final Postgres [extension ecosystem
mini-summit][mini-summit] will review topics covered in previous Mini-Summits,
various [Planet PostgreSQL] posts, the [#extensions] channel on the [Postgres
Slack] and the [Postgres Discord]. Following a brief description of each,
we'll determine how to reduce the list to the most important topics to take on
at the [Extension Ecosystem Summit] at [PGConf.dev] in Vancouver on May 28.
I'll post a summary later this week along with details for how to participate
in the selection process.

In the meantime, here's the list as of today:

*   Metadata:
    *   Third-party dependencies
    *   Types of extensions
    *   Taxonomies
    *   System requirements (OS, version, CPU, etc.)
    *   Categorization
    *   Versioning
*   Registry:
    *   Identity, namespacing, and uniqueness
    *   Distributed vs. centralized publishing
    *   Binary packaging and distribution patterns
    *   Federated distribution
    *   Services and tools to improve or build
    *   Stats, Reports, Badging: (stars, reviews, comments, build & test matrices, etc.)
*   Packaging:
    *   Formats (e.g., tarball, OCI, RPM, wheel, etc.)
    *   Include dynamic libs in binary packaging format? (precedent: Python wheel)
    *   Build farming
    *   Platforms, architectures, and OSes
    *   Security, trust, and verification
*   Developer:
    *   Extension developer tools
    *   Improving the release process
    *   Build pipelines: Supporting PGXS, prgx, Rust, Go, Python, Ruby, Perl, and more
*   Community:
    *   Community integration: identity, infrastructure, and support
    *   How-Tos, tutorials, documentation for creating, maintaining, and distributing extensions
    *   Docs/references for different types of extensions: `CREATE EXTENSION`, hooks, background workers, CLI apps/services, web apps, native apps, etc.
*   Core:
    *   [Second extension directory] (a.k.a. variable installation location, search path)
    *   Keeping all files in a single directory
    *   Documentation standard
    *   Inline extensions: UNITs, PACKAGEs, TLEs, etc.
    *   Minimizing restarts
    *   Namespacing
    *   Sandboxing, code signing, security, trust
    *   Dynamic module loading (e.g., `use Thing` in PL/Perl could try to load `Thing.pm`
    *   from a table of acceptable libraries maintained by the DBA)
    *   Binary compatibility of minor releases and/or /ABI stability

Is your favorite topic missing? Join us at the [mini-summit] or drop
suggestions into the [#extensions] channel on the [Postgres Slack].

  [mini-summit]: https://www.eventbrite.com/e/851125899477/
    "Postgres Extension Ecosystem Mini-Summit"
  [Planet PostgreSQL]: https://planet.postgresql.org
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [Postgres Discord]: https://discord.com/invite/bW2hsax8We
  [Extension Ecosystem Summit]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/191-extension-ecosystem-summit/
    "PGConf.dev: Extensions Ecosystem Summit: Enabling comprehensive indexing, discovery, and binary distribution"
  [PGConf.dev]: https://2024.pgconf.dev "PostgreSQL Development Conference 2024"
  [Second extension directory]: https://www.postgresql.org/message-id/flat/E7C7BFFB-8857-48D4-A71F-88B359FADCFD@justatheory.com
    "pgsql-hackers: RFC: Additional Directory for Extensions"
  