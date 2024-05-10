---
title: PGXN Language Poll Result
slug: pgxn-language-poll-result
date: 2024-05-10T18:13:44Z
lastMod: 2024-05-10T18:13:44Z
description: Results of the Postgres community poll for building PGXN v2 in Go, Rust, or both.
tags: [Postgres, PGXN, Go, Rust, Perl]
type: post
---

Back on March 28, I [asked] the Postgres community whether new services for
[PGXN v2][project] should be written in [Go], [Rust], or "some of each". I
went so far as to create a [poll], which ran through April 12. A month later
you might reasonably be wondering what became of it. Has David been refusing
to face reality and accept the results?

The answer is "no". Or at least I don't think so. Who among us really knows
ourselves. Since it closed, the [poll] has provided the results since it
closed, but I suspect few have looked. So here they are:

| Candidate          | Votes | % All Votes |
|:-------------------|------:|------------:|
| 🦀 Rust	         |   102 |       60.4% |
| 🐿️ Go               |    53 |       31.4% |
| 🐿️ + 🦀 Some of each |    13 |        7.7% |

**🦀 Rust is the clear winner.**

I don't know whether some Rust brigade descended upon the poll, but the truth
is that the outcome was blindingly apparent within a day of posting the poll.
So much so that I decided to get ahead of things and try writing a [pgrx]
extension. I released [jsonschema] on PGXN on April 30. Turned out to be kind
of fun, and the pgrx developers kindly answered all my questions and even made
a new release to simplify integration testing, now included in the
[`pgrx-build-test`] utility in the [pgxn-tools] Docker image.

But I digress. As a result of this poll and chatting with various holders of
stakes at [work] and haunting the [#extensions] Slack channel, I plan to use
Rust for all new PGXN projects --- unless there is an overwhelmingly
compelling reason to use something else for a specific use case.

Want to help? Rustaceans welcome! Check out the [project plan][project]
plan or join us in the [#extensions] channel on the [Postgres Slack].

  [asked]: {{% ref "/post/postgres/pgxn-language-choices" %}}
    "PGXN v2: Go or Rust?"
  [project]: https://github.com/orgs/pgxn/projects/1/views/1 "PGXN v2 Project"
  [Go]: https://go.dev "The Go Programming Language"
  [Rust]: https://www.rust-lang.org "Rust Programming Language"
  [poll]: https://dev.star.vote/tqkv3v/results
    "Poll: What language should PGXN v2 tools and services be written in?"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [jsonschema]: https://pgxn.org/dist/jsonschema/
    "The jsonschema Postgres Extension on PGXN"
  [`pgrx-build-test`]: https://github.com/pgxn/docker-pgxn-tools?tab=readme-ov-file#pgrx-build-test
    "pgrx-build-test: Build and test a pgrx extension"
  [pgxn-tools]: https://hub.docker.com/r/pgxn/pgxn-tools
  [work]: https://tembo.io "Tembo: Goodbye Database Sprawl, Hello Postgres"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
