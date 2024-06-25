---
title: "PGConf.dev 2024"
slug: pgconf-future-ecosystem
date: 2024-06-25T21:41:35Z
lastMod: 2024-06-25T21:41:35Z
description: |
  At PGConf.dev, I attended some great talks, made one of my own, and enjoyed
  the commearderie of fellow PostgreSQL extension authors and core developers. A
  brief report.
tags: [Postgres, PGXN, Extensions, PGConf, Vancouver]
type: post
---

In addition to the afore-blogged [Extension Summit], I also attended a slew of
the regular [PGConf.dev] sessions, gave a talk on the future of the extension
ecosystem, socialized with extension authors and core developers, and joined
discussions in a number of unconference sessions. Some notes on selected talks
and events:

Sessions
--------

I enjoyed [The road to new SQL/JSON features], where [Álvaro Herrera] gave a
brief history of SQL/JSON in Postgres, starting with the JSON type in 9.2
(2012), JSONB in 2014, and SQL standard jsonpath in Postgres 12 (2017).
Getting the SQL/JSON syntax finished turned out to be substantially more
difficult, thanks to parsing issues. It took many attempts and a couple of
reversions before most of the functionality was completed last year and
included in Postgres 16. The forthcoming Postgres 17 finishes the work, with
the standard fully supported except for "the `JSON_TABLE` plan param and json
simplified accessor."

It's a great time to use Postgres for JSON object storage and management.

In [Anarchy in the Database], subtitled "A Survey and Evaluation of Database
Management System Extensibility", Abigale Kim described her Master's thesis
work investigating Postgres extension incompatibilities. Installing and
running tests for pairs of extensions, she found a number of conflicts and
issues, such as a bug when [Citus] was paired with [auto_explain] (fixed in
May). In all, 17% of pairs failed! Abi also found that 19% of extensions
contain code copied from the Postgres core; [page_inspect] is 75% copied code!

Abi advocates for adding an extension manager into core, with well-defined
hooks to manage extension load order and to streamline enabling and disabling
extensions. Very interesting research, highlighting the need to think more
deeply about how best to enable and empower the extension ecosystem.

[Jeff Davis] and [Jeremy Schneider] gave a thorough overview of [Collations
from A to Z]. The problem rose to wide attention about six years ago when an
libc upgrade changed a collation, leading to data loss, crashes, and duplicate
primary keys. Ideally, sort orders would never change. But humans gotta human,
language will evolve, and the order of things will need to be updated. In such
situations, one must be aware of the changes and reindex or rebuild all
indexes (and replace hot standbys, which can't be reindexed).

I very much appreciated the context, as the ongoing issue with collations and
upgrades has confused me. Should application authors choose collations or
should DBAs? The new [builtin] collation provider in PostgresSQL 17 tries
tries to bridge the gap by supporting unchanging Unicode code-point collation
ordering that's reasonably meaningful to humans. But I also realize that, for
some projects with no need for human sort ordering, the `C` collations is more
than sufficient.

In her keynote, [When Hardware and Databases Collide], [Margo Seltzer] offered
a provocation: Could PostgreSQL adopt something like [CXL] to scale to a
virtually infinite pool of memory? Could one build a "complete fabric of CXL
switches to turn an entire data center into a database"? I have no idea! It
sure sounds like it could enable gigantic in-memory databases.

[Tricks from in-memory databases] by [Andrey Borodin] mostly went over my
head, but each of the experiments sped things up a few percentage points.
Together they might add up to something.

The [Making PostgreSQL Hacking More Inclusive] panel was terrific, and
much-needed. I'm grateful that [Amit Langote], [Masahiko Sawada], and [Melanie
Plageman] shared their experiences as up-and-coming non-white-male committers.
I think the resulting discussion will help drive new inclusion initiatives in
the PostgreSQL community, such as session moderator [Robert Haas]'s
recently-announced [Mentoring Program for Code Contributors][mentoring].

Oh, and I gave a talk, [The future of the extension ecosystem], in which I
expanded on my [mini-summit talk] to suss out the needs of various members of
the extension ecosystem (authors, users, DBAs, industry) and our plans to meet
those needs in [PGXN v2]. Links:

*   [Video](https://www.youtube.com/watch?v=cJsy8eUopMw)
*   [PDF]({{% link "pgconf-future-ecosystem.pdf" %}})
*   [PDF with Notes]({{% link "pgconf-future-ecosystem-notes.pdf" %}})
*   [Keynote]({{% link "pgconf-future-ecosystem.key" %}})

Unconference
------------

I also participated in the Friday [Unconference]. [Abi][Abigale Kim], [Yurii],
and I led a discussion on [Improving extensions in core]. We discussed the
need for an ABI stability policy, extension management, smoke testing
(including for conflicts between extensions), a coalition to advocate for
extensions in core (since launched as the [Postgres Extension Developers
Coalition]), inline extensions, [WASM]-based extensions, and server
installation immutability. Great discussions and a few actionable outcomes,
some of which I've been working on. More soon in future posts.

In [Increase Community Participation], we talked about the challenges for
broadening the PostgreSQL contributor community, attracting and retaining
contributors, recognizing contributions, and how to address issues of burnout
and allow people to "retire". I joined the discourse on how we could adopt or
at least support GitHub workflows, such as pull requests, to encourage more
patch review in a familiar environment. Personally, I've been creating [pull
requests in my fork][fork] for my patches for this very reason.

We also touched on training and mentoring new contributors (hence the
[mentoring announcement][mentoring]) and changes to postgresql.org, notably
adding dedicated pages for each project governance committee, especially for
the Contributors Committee (there's a Contributors Committee?), as well as
information for how to become a contributor and be listed on the [contributor
page].

Final Thoughts
--------------

I attended [PGCon] from 2009 to 2014, and always enjoyed the commearderie in
Ottawa every year. Most people went to the same pub after sessions every night
(or for some part of each evening), where random connections and deep
technical nerdery would continue into the small hours, both indoors and out.
The Black Oak was a highlight of the conference for me, every year.

In the intervening years I got busy with non-Postgres work and scaled back my
participation. I finally returned in 2023 (other than a virtual unconference
in 2022), and found it much the same, although the Black Oak had closed, and
now there were 2-3 where people went, diluting the social pool a bit ---
though still a highlight.

As the new iteration of the Postgres Developer Conference, PGConf.dev is a
worthy successor. Vancouver was a nice city for it, and people bought the same
energy as always. I connected with far more people, and more meaningfully,
than at any other conference. But other than the reception and dinner on
Wednesday, there was no one (or three) place where people tended to aggregate
into the wee hours. Or at least I wasn't aware of it. The end of PGCon is
bittersweet for me, but I'm happy to continue to participate in PGCONf.dev.

See you next year!

  [Extension Summit]: {{% ref "/post/postgres/extension-ecosystem-summit-2024" %}}
    "🏔 Extension Ecosystem Summit 2024"
  [PGConf.dev]: https://2024.pgconf.dev "PostgreSQL Development Conference 2024"
  [The road to new SQL/JSON features]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/174/
  [Álvaro Herrera]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/75/
  [Anarchy in the Database]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/49/
  [Abigale Kim]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/42/
  [Citus]: https://pgxn.org/dist/citus/ "citus: Scalable PostgreSQL for real-time workloads"
  [auto_explain]: https://www.postgresql.org/docs/current/auto-explain.html
    "PostgreSQL Docs: auto_explain — log execution plans of slow queries"
  [page_inspect]: https://www.postgresql.org/docs/current/pageinspect.html
    "PostgreSQL Docs pageinspect — low-level inspection of database pages"
  [Jeff Davis]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/88-jeff-davis/
  [Jeremy Schneider]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/13-jeremy-schneider/
  [Collations from A to Z]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/95/
  [When Hardware and Databases Collide]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/192/
  [Margo Seltzer]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/139-margo-seltzer/
  [CXL]: https://en.wikipedia.org/wiki/Compute_Express_Link "Wikipedia: “Compute Express Link”"
  [Tricks from in-memory databases]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/119/
  [Andrey Borodin]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/97-andrey-borodin/
  [Making PostgreSQL Hacking More Inclusive]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/86/
  [Amit Langote]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/48-amit-langote/
  [Masahiko Sawada]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/20-masahiko-sawada/
  [Melanie Plageman]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/8-melanie-plageman/
  [Robert Haas]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/27-robert-haas/
  [mentoring]: https://rhaas.blogspot.com/2024/06/mentoring-program-for-code-contributors.html
  [The future of the extension ecosystem]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/91/
  [mini-summit talk]: {{% ref "/post/postgres/mini-summit-one" %}} "Mini Summit One"
   [PGXN v2]: https://wiki.postgresql.org/wiki/PGXN_v2
  [Unconference]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Developer_Unconference
    "PostgreSQL Wiki: PGConf.dev 2024 Developer Unconference"
  [Yurii]: https://www.pgevents.ca/events/pgconfdev2024/schedule/speaker/6-yurii-rashkovskii/
  [Improving extensions in core]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Developer_Unconference#Improving_extensions_in_core
  [Postgres Extension Developers Coalition]: https://github.com/pgedc
  [WASM]: https://webassembly.org
  [Increase Community Participation]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Developer_Unconference#Increase_Community_Participation
  [fork]: https://github.com/theory/postgres/pulls "theory/postgres: Pull Requests"
  [contributor page]: https://www.postgresql.org/community/contributors/
    "PostgreSQL Contributor Profiles"
  [PGCon]: https://www.pgcon.org/ "PGCon: The PostgreSQL Conference"
