---
title: ⛰️ Postgres Ecosystem Summit EU
slug: postgres-ecosystem-summit-eu
date: 2024-10-09T15:27:43Z
lastMod: 2024-10-09T15:27:43Z
description: |
  The sequel to the successful PGConf.dev event, the Extension Ecosystem Summit
  EU will showcases some exemplary extension use cases.
tags: [Postgres, PGXN, Extensions, PGConf, Athens, Summit]
type: post
---

Given the success of the [Extension Ecosystem Summit][ees] at [PGConf.dev]
back in May, my colleague [Floor Drees] has organized a sequel, the [Extension
Ecosystem Summit EU][invite] on Tuesday, October 22, at the Divani Caravel
Hotel in Athens. That's "Day 0" at the same hotel as [PGConf.eu]. [Tembo],
[Percona], [Xata], and [Timescale] co-sponsor.

While the [May event][ees] took the form of an [open-space technology]
(OST)-style [unconference] aimed at extension developers, the EU event aims to
inform an audience of Postgres users about the history and some exemplary use
cases for extensions. From the [invite]:

> Join us for a gathering to explore the current state and future of Postgres
> extension development, packaging, and distribution. Bring your skills and
> your devices and start contributing to tooling underpinning many large
> Postgres installations.
>
> *   Jimmy Angelakos - [pg_statviz]: pg_statviz is a minimalist extension and
>     utility pair for time series analysis and visualization of PostgreSQL
>     internal statistics.
> *   Adam Hendel (Tembo) - [pgmq]: pgmq is a lightweight message queue. Like
>     AWS SQS and RSMQ but on Postgres. Adam is pgmq’s maintainer since 2023,
>     and will present a journey from pure Rust → pgrx → pl/pgsql.
> *   Alastair Turner (Percona) - [pg_tde]: pg_tde offers transparent
>     encryption of table contents at rest, through a Table Access Method
>     extension. Percona has developed pg_tde to deliver the benefits of
>     encryption at rest without requiring intrusive changes to the Postgres
>     core.
> *   Gülçin Yıldırım Jelínek (Xata) - [pgzx]: pgzx is a library for
>     developing PostgreSQL extensions written in Zig.
> *   Mats Kindahl (Timescale) - TimescaleDB (C), [pgvectorscale] (Rust) and
>     [pgai] (Python): maintaining extensions written in different languages.

I will also deliver the opening remarks, including a brief history of Postgres
extensibility. Please join us if you're in the area or planning to attend
[PGConf.eu]. See you there!

  [ees]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/191
    "PGConf.dev 2024 Extension Ecosystem Summit"
  [PGConf.dev]: https://2024.pgconf.dev "PostgreSQL Development Conference 2024"
  [Floor Drees]: https://dev.to/@floord
  [invite]: https://www.eventbrite.com/e/1022518730047 "Extension Ecosystem Summit EU"
  [PGConf.eu]: https://2024.pgconf.eu "PostgreSQL Conference Europe 2024"
  [Tembo]: https://tembo.io "Tembo: Goodbye Database Sprawl, Hello Postgres"
  [Percona]: https://www.percona.com "Percona: Open Source Database Software Support & Services"
  [Xata]: https://xata.io "Xata: Database platform for PostgreSQL"
  [Timescale]: https://www.timescale.com "Timescale PostgreSQL ++ for time series and events"
  [open-space technology]: https://en.wikipedia.org/wiki/Open_space_technology
    "Wikipedia: Open space technology"
  [unconference]: https://en.wikipedia.org/wiki/Unconference "Wikipedia: Unconference"
  [pg_statviz]: https://github.com/vyruss/pg_statviz
  [pgmq]: https://github.com/tembo-io/pgmq
  [pg_tde]: https://github.com/Percona-Lab/pg_tde
  [pgzx]: https://github.com/xataio/pgzx
  [pgvectorscale]: https://github.com/timescale/pgvectorscale "GitHub: timescale/pgvectorscale"
  [pgai]: https://github.com/timescale/pgai "GitHub: timescale/pgai"
