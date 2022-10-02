---
date: 2003-05-06T02:28:39Z
description: "No, I'm not kidding."
lastMod: 2022-10-02T22:39:29Z
slug: all-rdmses-suck
tags:
  - use Perl
  - Perl
  - RDBMS
  - Databases
title: All RDMSes Suck
---

I use relational databases in my work every day. Bricolage of course
runs on PostgreSQL, and I've done some work on DBD::Pg. But after using
various RDBMSs over the years (Access, MS SQL Server, DB2, MySQL,
Oracle, PostgreSQL), I've come to one inevitable conclusion: RDBMSs are
all just total crap.

Don't get me wrong, I think that they have their place. I just don't know what
that place is. But no decently designed object system that I've worked on (let
alone a poorly designed system) has found an elegant way to interact with
databases. Sure, DBI makes things easy for Perlers in that it provides a pretty
standard, uniform interface for accessing databases of all kinds. But if you're
designing even a moderately sophisticated application, you still run up against
the complete incompatibility of object-oriented design and relational storage.
They're just completely orthogonal to one another.

Many have tried to address this problem. CPAN is full of object/relational and
relational/object mapping modules. Hell, I've given a lot of thought to writing
one myself. But this adds an extra layer of complexity to systems that may well
already be complex, and is no friend to performance. Bricolage 2.0 will likely
have some kind of mapper built in, but there's one thing I'm sure of: No matter
how well designed it may be, it will still suck. Mapping are just an ugly
solution, and should be, in my opinion, totally unnecessary.

So why are we all still using RDBMSs? I mean, I know that some of them have
object-oriented features (Oracle, PostgreSQL), but they have their weaknesses.
In PostgreSQL, for example, if table A has a primary key index, and table B
inherits from that table, a query against table B can't use the primary key
index in table A. It has to do a table scan, instead! And how many people are
really taking advantage of Oracle's OO features, anyway? Not many, I would
guess.

Why not push for something better? Why not start working on or with systems that
are designed to perform and interact well with well-designed object systems?
Where are the ANSI OODBMS standards, and who's using them? What's next in this
space, and will the Oracle marketing department ever let it see the light of
day?

As for me, I've got on my long list of To Dos to check out [Caché] at some
point. A "post-relational database" is exactly what I'd like to do, and Caché,
if InterSystems' hype is to be believed, sounds very promising. Sure it's a
commercial system, but there's a Perl interface, and I'd love to see if
InterSystems really is revolutionizing databases.

One can only hope.

*Originally published [on use Perl;]*

  [Caché]: http://www.intersystems.com/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/12028/
    "use.perl.org journal of Theory: “All RDMSs Suck”"
