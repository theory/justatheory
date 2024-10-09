---
title: PGXN v2 Update
slug: pgxn-v2-update
date: 2024-10-09T17:14:53Z
lastMod: 2024-10-09T17:14:53Z
description: |
  A lot has happened in he five months since the last PGXN v2 update. The time
  has been used for continuing community discussions, planning, designs, and the
  start of implementation. Read on for a full accounting.
tags: [PGXN]
type: post
link: https://tembo.io/blog/pgxn-v2-update
---

Speaking of PGXN news, I neglected to link to [this post] I wrote for the
[Tembo Blog] last month, a fairly detailed accounting of what's been happening
on the [PGXN v2] project:

> Forgive me Postgres community, for it has been five months since [my last
> PGXN v2 Update]. In my defense, it has been super busy! The time went into
> ongoing community discussions, planning, designs, and the start of
> implementation. Join me below for the lowdown.

A few highlights:

*   [PGXN RFCs Repository] and [rfcs.pgxn.org]
*   [Binary Distributution POC] and [OCI POC]
*   [Extension Ecosystem Summit]
*   [API and ABI guidance]
*   [pgxn_meta v0.1.0]
*   [PGXN Meta JSON Schemas]
*   [project plan]

There's been quite a bit of activity since then, including the [aforementioned]
[PGXN RFC–5 — Release Certification]. More soon!

  [this post]: https://tembo.io/blog/pgxn-v2-update "What's New on the PGXN v2 Project"
  [Tembo Blog]: https://tembo.io/blog/ "Tembo's Blog"
  [PGXN v2]: https://wiki.postgresql.org/wiki/PGXNv2 "Postgres Wiki: PGXN v2"
  [my last PGXN v2 Update]: https://tembo.io/blog/pgxn-v2-status
    "What’s Happening on the PGXN v2 Project"
  [PGXN RFCs Repository]: https://github.com/pgxn/rfcs/
    "RFCs for Changes to PGXN"
  [rfcs.pgxn.org]: https://rfcs.pgxn.org
  [OCI POC]: {{% ref "/post/postgres/trunk-oci-poc" %}}
    "POC: Distributing Trunk Binaries via OCI"
  [Binary Distributution POC]: {{% ref "/post/postgres/trunk-poc" %}}
    "POC: PGXN Binary Distribution Format"
  [Extension Ecosystem Summit]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/191
    "PGConf.dev: Extensions Ecosystem Summit: Enabling comprehensive indexing, discovery, and binary distribution"
  [API and ABI guidance]: https://github.com/postgres/postgres/commit/e54a42a
    "postgres/postgres@e54a42a: Add API and ABI stability guidance to the C language docs"
  [pgxn_meta v0.1.0]: https://github.com/pgxn/meta/releases/tag/v0.1.0
  [PGXN Meta JSON Schemas]: https://github.com/pgxn/meta/tree/main/schema
    "v1 and v2 JSON Schema Definitions"
  [project plan]: https://github.com/pgxn/planning/milestones?direction=asc&sort=due_date&state=open
    "PGXN v2 Project Milestones"
  [aforementioned]: {{% ref "/post/postgres/pgxn-certifications-rfc" %}}
  [PGXN RFC–5 — Release Certification]: https://github.com/pgxn/rfcs/pull/5
    "pgxn/rfcs#5 Add RFC for JWS-signing PGXN releases"
