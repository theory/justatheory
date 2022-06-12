--- 
date: 2008-09-20T00:37:06Z
lastMod: 2022-05-22T21:36:50Z
description: The new version features compatibility back as far as PostgreSQL 8.0 and lots of cool functions for testing database schemas. The site's cool, too.
slug: pgtap-site
title: pgTAP 0.10 Released, Web Site Launched
aliases: [/computers/databases/postgresql/pgtap_site.html]
tags: [Postgres, Test Anything Protocol, pgTAP, Perl, PpFoundry, YAPC, Module::Build, Python, PHP]
type: post
---

Two major announcements this week with regard to pgTAP:

First, I've release [pgTAP 0.10]. The two major categories of changes are
compatibility as far back as PostgreSQL 8.0 and new functions for testing
database schemas. Here's a quick example:

``` postgres
BEGIN;
SELECT plan(7);

SELECT has_table( 'users' );
SELECT has_pk('users');
SELECT col_is_fk( 'users', ARRAY[ 'family_name', 'given_name' ]);

SELECT has_table( 'widgets' );
SELECT has_pk( 'widgets' );
SLEECT col_is_pk( 'widgets', 'id' );
SELECT fk_ok(
    'widgets',
    ARRAY[ 'user_family_name', 'user_given_name' ],
    'users',
    ARRAY[ 'family_name', 'given_name' ],
);

SELECT * FROM finish();
ROLLBACK;
```

Pretty cool, right? Check [the documentation] for all the details.

Speaking of the documentation, that link goes to the new [pgTAP Web site]. Not
only does it include the complete documentation for pgTAP, but also instructions
for [integrating pgTAP] into your application's preferred test environment.
Right now it includes detailed instructions for Perl + Module::Build and for
PostgreSQL, but has only placeholders for PHP and Python. Send me the details on
those languages or any others into which you integrate pgTAP tests and I'll
update the page.

Oh, and it has a beer. [Enjoy].

I think I'll take a little time off from pgTAP next week to give [Bricolage]
some much-needed love. But as I'll be given another talk on pgTAP at [PostgreSQL
Conference West] next month, worry not! I'll be doing a lot more with pgTAP in
the coming weeks.

Oh, and one more thing: I'm looking for consulting work. Give me a shout (david
- at - justatheory.com) if you have some PostgreSQL, Perl, Ruby, MySQL, or
JavaScript hacking you'd like me to do. I'm free through November.

That is all.

  [pgTAP 0.10]: https://github.com/theory/pgtap/releases/tag/rel-0.10 "Download pgTAP"
  [the documentation]: https://pgtap.org/documentation.html
    "The complete pgTAP Documentation"
  [pgTAP Web site]: https://pgtap.org "pgTAP Home"
  [integrating pgTAP]: https://pgtap.org/integration.html
    "Integrate pgTAP"
  [Enjoy]: https://pgtap.org "pgTAP"
  [Bricolage]: https://bricolagecms.org/ "Bricolage"
  [PostgreSQL Conference West]:
    https://web.archive.org/web/20081120015713/http://www.postgresqlconference.org/west08/talks/
    "Talks at PostgreSQL Conference West 2008"
