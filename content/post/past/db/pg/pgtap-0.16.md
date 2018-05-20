--- 
date: 2009-02-03T18:19:38Z
slug: pgtap-0.16
title: pgTAP 0.16 in the Wild
aliases: [/computers/databases/postgresql/pgtap-0.16.html]
tags: [Postgres, PL/pgSQL, TAP, pgTAP, SQL, testing]
type: post
---

I've been writing a lot tests for a client in [pgTAP] lately. It's given me a
lot to think about in terms of features I need and best practices in writing
tests. I'm pleased to say that, overall, it has been absolutely invaluable. I'm
doing a *lot* of database refactoring, and having the safety of solid test
coverage has been an absolute godsend. pgTAP has done a lot to free me from
worry about the effects of my changes, as it ensures that everything about the
databases continue to just work.

Of course, that's not to say that I don't scew up. There are times when my
refactorings have introduced new bugs or incompatibilities; after all, the tests
I write of existing functionality extend only so far as I can understand that
functionality. But as such issues come up, I just add regression tests, fix the
issues, and move on, confident in the knowledge that, as long as the tests
continue to be run regularly, those bugs will never come up again. Ever.

As a result, I'll likely be posting a bit on best practices I've found while
writing pgTAP tests. As I've been writing them, I've started to find the cow
paths that help me to keep things sane. Most helpful is the large number of
assertion functions that pgTAP offers, of course, but there are a number of
techniques I've been developing as I've worked. Some are better than others, and
still others suggest that I need to find other ways to do things (you know, when
I'm cut-and-pasting a lot, there must be another way, though I've always done a
lot of cut-and-pasting in tests).

In the meantime, I'm happy to announce the release of pgTAP 0.16. This version
includes a number of improvements to the installer (including detection of Perl
and [TAP::Harness], which are required to use the included `pg_prove` test
harness app. The installer also has an important bug fix that greatly increases
the chances that the `os_name()` function will actually know the name of your
operating system. And of course, there are new test functions:

-   `has_schema()` and `hasnt_schema()`, which test for the presence of absence
    of a schema
-   `has_type()` and `hasnt_type()`, which test for the presence and absence of
    a data type, domain, or enum
-   `has_domain()` and `hasnt_domain()`, which test for the presence and absence
    of a data domain
-   `has_enum()` and `hasnt_enum()`, which test for the presence and absence of
    an enum
-   `enum_has_lables()` which tests that an enum has an expected list of labels

As usual, you can [download] the latest release from pgFoundry. Visit the [pgTAP
site][pgTAP] for more information and for documentation.

  [pgTAP]: http://pgtap.projects.postgresql.org/
    "pgTAP: Unit Testing for PostgreSQL"
  [TAP::Harness]: http://search.cpan.org/dist/Test-Harness/
    "TAP::Harness on CPAN"
  [download]: http://pgfoundry.org/frs/?group_id=1000389 "Download pgTAP"
