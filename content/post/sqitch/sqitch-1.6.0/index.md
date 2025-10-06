---
title: "Sqitch 1.6.0: Now with ClickHouse!"
slug: sqitch-1.6.0
date: 2025-10-06T22:01:19Z
lastMod: 2025-10-06T22:01:19Z
description: |
  Sqitch 1.6.0, out today, adds support for managing ClickHouse databases.
tags: [Sqitch, ClickHouse]
type: post
image:
  src: sqitch-clickhouse.png
  alt: ClickHouse Logo, A ❤️, Sqitch Logo
  class: clear
  title: "Sqitch: Sensible database change management for ClickHouse"
---

Out today: [Sqitch] v1.6.0. This release adds a brand new engine:
[ClickHouse]. I started a new job at ClickHouse on September 2, and my first
task, as a way to get to know the database, was to add it to Sqitch.
Fortuitously, ClickHouse added support for updates and deletes, which Sqitch
requires, in the August release. Sqitch v1.6.0 therefore supports ClickHouse
25.8 or later.

As for the other engines Sqitch supports, this release includes a [ClickHouse
tutorial], the `--with-clickhouse-support` option in the [Homebrew
tap][Homebrew], and [Sqitch ClickHouse Docker tags].

Find it in the usual places:

*   [sqitch.org][Sqitch]
*   [GitHub]
*   [CPAN]
*   [Docker]
*   [Homebrew]

Thanks for using Sqitch, and [do let me know] if you use it to manage a
ClickHouse database, or if you run into any issues or challenges.

  [Sqitch]: https://sqitch.org "Sqitch: Sensible database change management"
  [ClickHouse]: https://clickhouse.com/clickhouse
    "Real-Time Data Analytics Platform | ClickHouse"
  [ClickHouse tutorial]: https://sqitch.org/docs/manual/sqitchtutorial-clickhouse/
    "Sqitch ClickHouse Tutorial"
  [Sqitch ClickHouse Docker tags]: https://hub.docker.com/r/sqitch/sqitch/tags?name=clickhouse
    "Sqitch ClickHouse Tags on Docker Hub"
  [Docker]: https://hub.docker.com/r/sqitch/sqitch
  [issue]: https://github.com/sqitchers/sqitch/issues "Sqitch Issues"
  [GitHub]: https://github.com/sqitchers/sqitch
  [CPAN]: https://metacpan.org/dist/App-Sqitch
  [Homebrew]: https://github.com/sqitchers/homebrew-sqitch
  [do let me know]: /about "About Just a Theory"
