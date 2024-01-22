---
title: I'm a Postgres Extensions Tembonaut
slug: tembonaut
date: 2024-01-22T17:00:26Z
lastMod: 2024-01-22T17:00:26Z
description: |
  Near year, new job. I accepted a new position at Tembo to work on improving
  the PostgreSQL extension ecosystem full time.
tags: [Personal, Work, Tembo, Postgres, Extensions]
type: post
image:
  src: tembo.svg
  alt: Tembo Logo
  copyright: ©️ 2023 Tembo Data Systems, Inc.
  width: 304
  height: 285
  class: "right"
---

New year, new job.

I'm pleased to announce that I started a new job on January 2 at [Tembo], a
fully-managed [PostgreSQL] developer platform. Tembo [blogged the news], too.

I first heard from Tembo CTO [Samay Sharma] last summer, when he inquired about
the status of [PGXN], the PostgreSQL Extension Network, which I built in
2010--11. Tembo bundles extensions into Postgres [stacks], which let developers
quickly spin up Postgres clusters with tools and features optimized for specific
use cases and workloads. The company therefore needs to provide a wide variety
of easy-to-install and well-documented extensions to power those use cases.
Could PGXN play a role?

I've tended to PGXN's maintenance for the last fourteen years, and thanks in no
small part to hosting provided by [depesz]. As of today's [stats] it distributes
376 extensions on behalf of 419 developers. PGXN has been a moderate success,
but Samay asked how we could collaborate to build on its precedent to improve
the extensions ecosystem overall.

It quickly became apparent that we share a vision for what that ecosystem could
become, including:

*   Establishing the canonical Postgres community index of extensions, something
    PGXN has yet to achieve
*   Improving metadata standards to enable new patterns, such as automated binary
    packaging
*   Working with the Postgres community to establish documentation standards
    that encourage developers to provide comprehensive extension docs
*   Designing and building developer tools that empower more developers to
    build, test, distribute, and maintain extensions

Over the the past decade I've have many ideas and discussion on these topics,
but seldom had the bandwidth to work on them. In the last couple years I've
[enabled TLS and improved the site display], [increased password security], and
[added a notification queue] with hooks that post to both Twitter (RIP [@pgxn])
and Mastodon ([@pgxn@botsin.space]). Otherwise, aside from keeping the site
going, periodically improving new accounts, and eyeing the latest releases, I've
had little bandwidth for PGXN or the broader extension ecosystem.

Now, thanks to the vision and strategy of Samay and Tembo CEO [Ry Walker], I
will focus on these projects full time. The Tembo team have already helped me
enumerate the extension ecosystem [jobs to be done] and the tools required to do
them. This week I'll submit it to collaborators from across the Postgres
community[^others] to fill in the missing parts, make adjustments and
improvements, and work up a project plan.

The work also entails determining the degree to which PGXN and other extension
registries (e.g., [dbdev], [trunk], [pgxman], [pgpm][] (WIP), etc.) will play a
role or provide inspiration, what bits should be adopted, rewritten, or
discarded.[^darlings] Our goal is to build the foundations for a community-owned
extensions ecosystem that people care about and will happily adopt and
contribute to.

I'm thrilled to return to this problem space, re-up my participation in the
PostgreSQL community, and work with great people to build out the extensions
ecosystem for future.

Want to help out or just follow along? Join the [#extensions] channel on the
[Postgres Slack]. See you there.

  [^others]: Tembo was not the only company whose representatives have reached
    out in the past year to talk about PGXN and improving extensions. I've also
    had conversations with [Supabase], [Omnigres], [Hydra], and others.

  [^darlings]: Never be afraid to [kill your darlings].

  [Tembo]: https://tembo.io/ "Tembo: Goodbye Database Sprawl, Hello Postgres"
  [PostgreSQL]: https://www.postgresql.org
    "PostgreSQL: The world's most advanced open source database"
  [blogged the news]: https://tembo.io/blog/welcoming-david-wheeler
    "PGXN Creator David Wheeler Joins Tembo to Strengthen the Postgres Extension Ecosystem"
  [Samay Sharma]: https://www.linkedin.com/in/samay-sharma-b6465122
    "Samay Sharma - Chief Technology Officer - Tembo | LinkedIn"
  [PGXN]: https://pgxn.org/ "The PostgreSQL Extension Network"
  [stacks]: https://tembo.io/docs/category/tembo-stacks/
    "Tembo Docs: Tembo Stacks"
  [depesz]: https://www.depesz.com "select * from depesz;"
  [stats]: https://pgxn.org/about/ "About PGXN"
  [enabled TLS and improved the site display]: https://blog.pgxn.org/post/651216661677064192/a-few-belated-pgxn-updates
    "PGXN Blog: “A Few Belated PGXN Updates”"
  [increased password security]: https://blog.pgxn.org/post/655912318549606400/password-storage-update
    "PGXN Blog: “Password Storage Update”"
  [added a notification queue]: https://blog.pgxn.org/post/709635160523620352/hello-mastodon
    "PGXN Blog: “Hello Mastodon 🐘”"
  [@pgxn]: https://twitter.com/pgxn/ "PGXN on Twitter"
  [@pgxn@botsin.space]: https://botsin.space/@pgxn
    "PGXN on Mastodon"
  [Ry Walker]: https://www.linkedin.com/in/rywalker "Ry Walker - Tembo, Inc. |
    LinkedIn"
  [jobs to be done]: https://strategyn.com/jobs-to-be-done/jobs-to-be-done-theory/
    "Fundamentals of Jobs-to-be-Done Theory"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [pgxman]: https://pgxman.com/ "npm for PostgreSQL"
  [dbdev]: https://database.dev "The Database Package Manager"
  [pgpm]: http://www.postgres.pm
  [trunk]: https://pgt.dev "Trunk — A Postgres Extension Registry"
  [Supabase]: https://supabase.com "Supabase | The Open Source Firebase Alternative"
  [Omnigres]: https://omnigres.com "Omnigres: Postgres as a Platform"
  [Hydra]: https://www.hydra.so "Hydra - Fast Postgres Analytics ++"
  [kill your darlings]: https://www.masterclass.com/articles/what-does-it-mean-to-kill-your-darlings
    "MasterClass: “What Does It Mean to Kill Your Darlings?”"
