--- 
date: 2014-09-05T17:46:00Z
title: Sqitch Goes Vertical
url: /2014/09/05/sqitch-goes-vertical/

categories: []
---

I released [Sqitch] v0.996 today. Despite the minor version increase, this is
a pretty big release. I'm busy knocking out all the stuff I want to get done
for 1.0, but the version space is running out, so just a minor version jump
from v0.995 to v0.996. But a lot changed. A couple the biggies:

### Goodbye Mouse and Moose, Hello Moo ###

If you're not a Perl programmer, you probably aren't familiar with [Moose] or
its derivatives [Mouse] and [Moo]. Briefly, it's an object system. Great
interface and features, but freaking *huge*—and *slow*. Mouse is a lighter
version, and when we (mostly) switched to it [last year], it yielded a 20-30% speed
improvement.

Still wasn't great, though. So on a day off recently, I switched
to Moo, which implements most of Moose but without a lot of the baggage. At
first, there wasn't much difference in performance, but as I profiled it
([Devel::NYTProf] is indispensable for profiling Perl apps, BTW), I was able
to root out all trace of Moose or Mouse, including in CPAN modules Sqitch
depends on. The result is around a 40% speedup over what we had before.
Honestly, it feels like a new app, it's so fast. I'm really happy with how it
turned out, and to have shed some of the baggage from the code base.

The downside is that package maintainers will need to do some work to get the
new dependencies built. Have a look at [the RPM spec changes] I made to get
our internal Sqitch RPMs to build v0.996.

### MySQL Password Handling ###

The handling of MySQL passwords has also been improved. Sqitch now uses the
`$MYSQL_PWD` environment variable if a password is provided in a target. This
should simplify authentication when running MySQL change scripts through the
`mysql` client client.

Furthermore, if [MySQL::Config] is installed, Sqitch will look for passwords
in the `client` and `mysql` sections of your MySQL configuration files
(`~/.my.cnf`, `/etc/my.cnf`). This should already happen automatically when
executing scripts, but Sqitch now tries to replicate that behavior when
connecting to the database via [DBI].

Spotting the `$MYSQL_PWD` commit, Ștefan Suciu updated the Firebird engine to
use the `$ISC_PASSWORD` when running scripts. Awesome.

### Vertically Integrated ###

And finally, another big change: I added support for [Vertica], a very nice
commercial column-store database that features partitioning and sharding,
among other OLAP-style functionality. It was originally forked from
[PostgreSQL], so it was fairly straight-forward to port, though I did have to
borrow a bit from the Oracle and SQLite engines, too. This port was essential
for [work], as we're starting to use Vertical more and more, and need ways to
manage changes.

If you're using Vertica, peruse [the tutorial] to get a feel for what it's
all about. If you want to install it, you can get it from CPAN:

    cpan install App::Sqitch BDD::ODBC

Or, if you're on Homebrew:

    brew tap theory/sqitch
    brew install sqitch_vertica

Be warned that there's a minor bug in v0.996, though. Apply this diff to fix
it:

    @@ -16,7 +16,7 @@ our $VERSION = '0.996';
 
     sub key    { 'vertica' }
     sub name   { 'Vertica' }
    -sub driver { 'DBD::Pg 2.0' }
    +sub driver { 'DBD::ODBC 1.43' }
     sub default_client { 'vsql' }
 
     has '+destination' => (

That fix will be in the next release, of course, as will [support for Vertica 6].

### What Next? ###

I need to focus on some other work stuff for a few weeks, but then I expect
to come back to Sqitch again. I'd like to get 1.0 shipped before the end of
the year. To that end, next up I will be [rationalizing configuration hierarchies]
to make engine selection and deploy-time configuration more sensible. I hope
to get that done by early October.

[Sqitch]: http://sqitch.org/
[Moose]: https://metacpan.org/module/Moose
[Mouse]: https://metacpan.org/module/Mouse
[Moo]: https://metacpan.org/module/Moo
[last year]: https://github.com/theory/sqitch/pull/73
[Devel::NYTProf]: https://metacpan.org/module/Devel::NYTProf
[the RPM spec changes]: https://github.com/theory/sqitch/compare/v0.995...v0.996#diff-4
[MySQL::Config]: https://metacpan.org/module/MySQL::Config
[DBI]: https://metacpan.org/module/DBI
[Vertica]: https://my.vertica.com/
[PostgreSQL]: http://www.postgresql.org/
[work]: http://www.iovation.com/
[rationalizing configuration hierarchies]: https://github.com/theory/sqitch/issues/153
[the tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial-vertica.pod
[support for Vertica 6]: https://github.com/theory/sqitch/commit/4f8dbaa236a04f6dd1ec762250ffd8481078691a


