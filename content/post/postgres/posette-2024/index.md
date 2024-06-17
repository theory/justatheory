---
title: POSETTE 2024
slug: posette
date: 2024-06-17T20:33:22Z
lastMod: 2024-06-17T20:33:22Z
description: |
  I attended and gave a presentation at POSETTE, an event for Postgres.
  This post highlights some talks and the slides for my own.
tags: [Postgres, PGXN, POSETTE, Presentation]
type: post
image:
  src: posette-elephant.svg
  class: clear
  link: https://www.citusdata.com/posette/2024
  title: POSETTE 2024
  alt: alt text for *image*
  copyright: 2024 Microsoft
---

Last week, I attended and presented at [POSETTE], An Event for Postgres. A
selection of the presentations I found worthy of attention.

Good Talks
----------

[Comparing Postgres connection pooler support for prepared statements] by
[Jelte Fennema-Nio]. Jelte did a great job outlining the challenges he
encountered adding protocol-level prepared query support to [PgBouncer]. So
many edge cases! Very much a worthwhile effort, and an important contribution.
In the Discord "hallway track", Jelte said he has some ideas how to add
support for [LISTEN]/[NOTIFY], which also requires connection affinity. Alas,
there's no protocol-level support, so it'll be tricky. I suspect I'll
eventually move the [PGXN Bot] to something like [pgmq] to avoid the issue.

[How to work with other people] by [Jimmy Angelakos] and [Floor Drees]. Jimmy
& Floor capably highlighted issues of neurodiversity and mental health in the
Postgres community and the workplace. I greatly appreciate the increasing
awareness of and discussions about these issues, which for far to long have
remained hidden or misunderstood. All too often they still are. The more
people talk about them, the more they'll be accepted and the better things
will become. Love seeing this.

[Even JSONB In Postgres Needs Schemas] by [Chris Ellis]. Chris concisely
introduced the concept of JSON validation via [check constraints] to ensure
the integrity of data. He started with simple validation with `json_typeof()`,
moved to more comprehensive validation of various parts of a JSON or JSONB
object, and ultimately full [JSON Schema] validation with the [pg_jsonschema]
extension. Having recently written my own [JSON Schema extension], I was happy
to see this topic receive more attention. The tool Chris developed to [convert
JSON schema to a SQL function][gen] seems super neat, too --- a great way to
bootstrap a check constraint from a JSON Schema where no such extension
exists, such as the big cloud providers.

I Also Spoke
------------

I also gave a talk, [State of the Postgres Extension Ecosystem], expanding
upon my [mini-Summit session]. I think it came out pretty well, and hope it
helps to get more people interested in extensions and solve the challenges for
finding, evaluating, installing, and using them everywhere. Slides:

*   [PDF]({{% link "state-of-the-ecosystem-posette.pdf" %}})
*   [Keynote]({{% link "state-of-the-ecosystem-posette.key" %}})

Next Year
---------

I found [POSETTE] a very nice Postgres conference. I applaud its commitment to
a fully-virtual venue. In-person get-togethers are great, but not everyone can
travel to them for reasons of cost, time, family, health, and more. Better
still, the speakers recorded their presentations in advance, allows us to
fully participate in discussion during our talks! (I mostly used my time to
offer corrections and links to relevant resources.)

For those interested in Postgres, I heartily endorse this free, fully remote
conference. Perhaps I'll "see" you there next year.

  [POSETTE]: https://www.citusdata.com/posette/2024
    "POSETTE: An Event for Postgres 2024"
  [Comparing Postgres connection pooler support for prepared statements]: https://www.youtube.com/watch?v=O3gLgN517JA
  [Jelte Fennema-Nio]: https://www.citusdata.com/posette/speakers/jelte-fennema-nio/
  [PgBouncer]: https://www.pgbouncer.org "Lightweight connection pooler for PostgreSQL"
  [LISTEN]: https://www.postgresql.org/docs/current/sql-listen.html
    "Postgres Docs: LISTEN"
  [NOTIFY]: https://www.postgresql.org/docs/current/sql-notify.html
    "Postgres Docs: NOTIFY"
  [PGXN Bot]: https://botsin.space/@pgxn
  [pgmq]: https://pgxn.org/dist/pgmq/
    "A lightweight message queue like AWS SQS or RSMQ, but on Postgres"
  [How to work with other people]: https://www.youtube.com/watch?v=Z77AjEitFMA
  [Jimmy Angelakos]: https://www.citusdata.com/posette/speakers/jimmy-angelakos/
  [Floor Drees]: https://www.citusdata.com/posette/speakers/floor-drees/
  [Even JSONB In Postgres Needs Schemas]: https://www.youtube.com/watch?v=F6X60ln2VNc
  [Chris Ellis]: https://www.citusdata.com/posette/speakers/chris-ellis/
  [check constraints]: https://www.postgresql.org/docs/current/ddl-constraints.html
    "Postgres Docs: Constraints"
  [JSON Schema]: https://json-schema.org
  [pg_jsonschema]: https://github.com/supabase/pg_jsonschema
    "PostgreSQL extension providing JSON Schema validation"
  [JSON Schema extension]: https://pgxn.org/dist/jsonschema/
    "PGXN: jsonschema --- JSON Schema validation functions for PostgreSQL"
  [gen]: https://nexteam.co.uk/pg-jsonschema-gen/v1/index.html
    "PostgreSQL JSON Validation Function Generator"
  [State of the Postgres Extension Ecosystem]: https://www.youtube.com/watch?v=-6thIB2jw6w
  [mini-Summit session]: {{% ref "/post/postgres/mini-summit-one" %}} "Mini Summit One"
