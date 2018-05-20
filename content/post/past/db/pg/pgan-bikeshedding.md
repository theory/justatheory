--- 
date: 2010-05-24T19:15:55Z
description: Help me pick a good name for the PostgreSQL extension distribution network and site.
slug: pgan-bikeshedding
title: PGAN Bikeshedding
aliases: [/computers/databases/postgresql/pgan-bikeshedding.html]
tags: [Postgres, CPAN]
type: post
---

I’ve put together a [description of PGAN], the PostgreSQL extension distribution
system I plan to develop later this year based on the Comprehensive Archive Perl
Network or [CPAN]. Its primary features will be:

-   Extension distribution
-   Search site with extension documentation
-   Client for downloading, building, testing, and installing extensions.

I’ve never been thrilled with the name, though, so I’m asking for suggestions
for a better one. I’ve used the term "extension" here because it seems to be the
term that the PostgreSQL community has [settled on], but other terms might work,
since things other than extensions might be distributed.

What I’ve come up with so far is:

| Name   | Long Name                                         | Pronunciation         | Advantages                 | Disadvantages                                      |
|--------|---------------------------------------------------|-----------------------|----------------------------|----------------------------------------------------|
| PGAN   | PostgreSQL Add-on Network                         | pee-gan               | Short, similar to CPAN     | Ugly                                               |
| PGEX   | PostgreSQL Extensions                             | pee-gee-ex or pee-gex | Short, easier to pronounce | Too similar to [PGX])                              |
| PGCAN  | PostgreSQL Comprehensive Archive Network          | pee-gee-can           | Similar to CPAN            | Similar to CPAN                                    |
| PGDAN  | PostgreSQL Distribution Archive Network           | pee-gee-dan           | Short, easy to pronounce   | Who’s “Dan”? Doesn’t distribute PostgreSQL itself. |
| PGEDAN | PostgreSQL Extension Distribution Archive Network | pee-gee-ee-dan        | References extensions      | Long, sounds stupid                                |

Of these, I think I like “PGEX” best, but none are really great. So I’m opening
up the [bike shed] to all. What’s a better name? Or if you can’t think of one,
which of the above do you like best? Just leave a comment on this post. The only
requirements for suggestions are that a .org domain be available and that it
suck less than the alternatives.

Comments close in 2 weeks. Thanks!

  [description of PGAN]: http://wiki.postgresql.org/wiki/PGAN
  [CPAN]: http://search.cpan.org/
  [settled on]: http://wiki.postgresql.org/wiki/ExtensionPackaging
  [PGX]: http://pgexperts.com/
  [bike shed]: https://en.wikipedia.org/wiki/Parkinson's_Law_of_Triviality
