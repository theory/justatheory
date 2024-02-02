---
title: Pgxn Architecture
slug: pgxn-architecture
date: 2024-02-02T16:01:03Z
lastMod: 2024-02-02T16:01:03Z
description: I made a presentation on the PGXN architecture for the Tembo team.
tags: [PGXN, Software Architecture, REST, JSON, Tembo]
type: post
link: https://tembo.io/blog/pgxn-architecture
---

As I started digging into the [jobs and tools] for the Postgres extension
ecosystem as part of my [new gig], I realized that most people have little
knowledge of the [PGXN] architecture. I learned a lot designing PGXN and its
services, and am quite pleased with where it ended up, warts and all. So I
thought it worthwhile to put together a brief presentation on the fundamental
design principals (static REST file API), inter-related services ([root mirror],
[manager], [API], [site][PGXN]) and tools ([CLI], [CI/CD]).

Yesterday, the Tembo blog [published the presentation], including [the video]
and slides, along with a high-level architecture diagram. I hope it's a useful
point of reference for the Postgres community as we look to better distribute
extensions in the future.

  [jobs and tools]: https://gist.github.com/theory/898c8802937ad8361ccbcc313054c29d
    "Extension Ecosystem: Jobs and Tools"
  [new gig]: {{% ref "/post/personal/tembonaut/index.md" %}}
    "I'm a Postgres Extensions Tembonaut"
  [PGXN]: https://pgxn.org "PGXN — PostgreSQL Extension Network"
  [manager]: https://manager.pgxn.org/howto "PGXN How To"
  [root mirror]: https://master.pgxn.org/ "PGXN Root Mirror"
  [API]: https://github.com/pgxn/pgxn-api/wiki "PGXN API"
  [CLI]: https://pgxn.github.io/pgxnclient/ "PGXN Client documentation"
  [CI/CD]: https://hub.docker.com/r/pgxn/pgxn-tools "pgxn/pgxn-tools Docker image"
  [published the presentation]: https://tembo.io/blog/pgxn-architecture
    "Presentation: Introduction to the PGXN Architecture"
 [the video]: https://www.youtube.com/watch?v=sjZPA3HA_q8
   "YouTube Tembo Channel: “David Wheeler - The Architecture of PGXN”"
