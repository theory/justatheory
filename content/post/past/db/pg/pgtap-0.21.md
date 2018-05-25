--- 
date: 2009-05-29T01:20:31Z
slug: pgtap-0.21
title: pgTAP 0.21 Drops
aliases: [/computers/databases/postgresql/pgtap-0.21.html]
tags: [Postgres, pgTAP, Testing, Unit Testing, TAP, PL/pgSQL, SQL]
type: post
---

[<img src="http://pgtap.org/ui/img/tap.jpg" alt="Mmmmm…pgTAP" class="right" />]

I just dropped a new version of
[pgTAP][<img src="http://pgtap.org/ui/img/tap.jpg" alt="Mmmmm…pgTAP" class="right" />],
following a few marathon hack sessions since [my talk at PGCon] ([movie here],
BTW). Actually, the new [`performs_ok()`] function came about as I wrote the
presentation, but all the rest came on the flight home and in the few days
since. Not sure when I'll hack on it this much again (it's getting a bit big at
5,758 lines of PL/pgSQL and SQL).

Overall I'm very happy with this release, as it adds a lot of new assertion
functions. In particular, I added a slew of functions that test that the objects
in a given schema (or visible in the search path, if you prefer) are exactly the
objects that *should* be there. This is useful for a couple of things. For one,
Norman Yamada, in [his PGCon talk], mentioned that his team was using pgTAP to
compare database objects between replicated databases. I like this because it's
a great example of using pgTAP for [system testing], rather than just [unit
testing] as I've been advocating. See, pgTAP can be used for any kind of
testing!

Another use for these functions is in a large organization where many different
people might be making changes to a schema. In this scenario, you might have
application developers adding new objects to the database (or dropping objects)
without necessarily informing the DBAs. Using, for example, [`tables_are()`] and
[`functions_are()`] and continuous testing, the DBAs can see when objects have
been modified by the developers. Even better, if the developers are running the
pgTAP tests themselves (as they should be!), they will be reminded to add new
tests for their changes when the existing tests notice that things have been
added or dropped and thus fail.

Beyond that, I added a bunch of new functions for [testing functions] and a
number of other goodies. Check out the [release notes] for all the details.

With these changes, I've finished nearly everything I've thought of for pgTAP.
There are only a few sequence-testing functions left on the To Do list, as well
as a [call to add a `throws_like()`] function, which I'll throw in soon if no
one else steps up. Beyond these changes, I have a few ideas of where to take it
next, but so far I'm kind of stumped. Mainly what I think should be done is to
add an interface that makes it easier to compare relations (or result sets, if
you prefer). [Epic] does this by allowing query strings to be passed to a
function, but I'd really like to keep queries in SQL rather than in SQL strings.
I'll be giving it some more thought and will post about it soon.

  [<img src="http://pgtap.org/ui/img/tap.jpg" alt="Mmmmm…pgTAP" class="right" />]:
    http://pgtap.org/ "pgTAP: Unit Testing for PostgreSQL"
  [my talk at PGCon]: https://www.pgcon.org/2009/schedule/events/165.en.html
    "PGCon: “Unit Test Your Database!”"
  [movie here]: http://hosting3.epresence.tv/fosslc/1/watch/129.aspx
    "Unit Test Your Database—The Movie"
  [`performs_ok()`]: http://pgtap.org/documentation.html#%60performs_ok+(+sql,+milliseconds,+description+)%60
    "pgTAP Documentation: `performs_ok()`"
  [his PGCon talk]: https://www.pgcon.org/2009/schedule/events/146.en.html
    "PGCon: “Reconciling and comparing databases”"
  [system testing]: https://en.wikipedia.org/wiki/System_testing
    "Wikipedia: “System testing”"
  [unit testing]: https://en.wikipedia.org/wiki/Unit_testing
    "Wikipedia: “Unit testing”"
  [`tables_are()`]: http://pgtap.org/documentation.html#%60tables_are(+schema,+tables,+description+)%60
    "pgTAP Documentation: `tables_are()`"
  [`functions_are()`]: http://pgtap.org/documentation.html#%60functions_are(+schema,+functions%5B%5D,+description+)%60
    "pgTAP Documentation: `functions_are()`"
  [testing functions]: http://pgtap.org/documentation.html#Feeling+Funky
    "pgTAP Documentation: Feeling Funky"
  [release notes]: http://pgfoundry.org/frs/shownotes.php?release_id=1389
    "pgTAP 0.21 Release Notes and Changes"
  [call to add a `throws_like()`]: http://archives.postgresql.org/pgsql-hackers/2009-05/msg01318.php
    "pgsql-hackers: Re: plperl error format vs plpgsql error format vs pgTAP"
  [Epic]: http://epictest.org/
    "Epic, more full of fail than any other testing tool"
