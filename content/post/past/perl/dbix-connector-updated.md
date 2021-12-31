--- 
date: 2009-10-21T17:37:48Z
slug: dbix-connector-updated
title: DBIx::Connector Updated
aliases: [/computers/programming/perl/modules/dbix-connector-updated.html]
tags: [Perl, DBIx::Connector, DBI, Databases, Connectivity, Transactions]
type: post
---

After much gnashing of teeth, heated arguments with @robkinon and @mst, lots of
deep thesaurus spelunking, and three or four iterations, I finally came up with
an an improved API for [DBIx::Connector] that I believe is straight-forward and
easy to explain.

Following up on my [post] last week, I explored, oh I dunno, a hundred different
terms for the various methods? I've never spent so much time on [thesaurus.com]
in my life. Part of what added to the difficulty was that @mst seemed to think
that there should actually be three modes for each block method: one that pings,
one that doesn't, and one that tries again if a block dies and the connection is
down. So I went from six to nine methods with that assertion.

What I finally came up with was to name the three basic methods `run()`,
`txn_run()`, and `svp_run()`, and these would neither ping nor retry in the
event of failure. Then I added variations on these methods that would ping and
that would try to fix failures. I called these “ping runs” and “fixup runs,”
respectively. It was the latter term, “fixup,” that had been so hard for me to
nail down, as “retry” seemed to say that the method was a retry, while “fixup”
more accurately reflects that the method would try to fix up the connection in
the event of a failure.

Once I'd implemented this interface, I now had nine methods:

-   `run()`
-   `txn_run()`
-   `svp_run()`
-   `ping_run()`
-   `txn_ping_run()`
-   `svp_ping_run()`
-   `fixup_run()`
-   `txn_fixup_run()`
-   `svp_fixup_run()`

This worked great. Then I went about documenting it. Jesus Christ what a pain! I
realized that all these similarly-named methods would require a lot of
explanation. I duly wrote up said explanation, and just wasn't happy with it. It
just felt to me like all the explanation made it too difficult to decide what
methods to use and when. Such confusion would make the module less likely to be
used -- and certainly less likely to be used efficiently.

So I went back to the API drawing board and, reflecting on @robkinyon's
browbeating about decorating methods and @mst's coming to that conclusion as
well, I finally came up with just three methods:

-   `run()`
-   `txn()`
-   `svp()`

For any one of these, you can call it by passing a block, of course:

    $conn->txn( sub { $_->do('SELECT some_function()') } );

In addition, you can now have any one of them run in one of three modes: the
default (no ping), “ping”, or “fixup”:

    $conn->txn( fixup => sub { $_->do('SELECT some_function()') } );

It's *much* easier to explain the three methods in terms of how the block is
transactionally encapsulated, as that's the only difference between them. Once
that's understood, it's pretty easy to explain how to change the “connection
mode” of each by passing in a leading string. It even looks pretty nice. I'm
really happy with this

One thing that increased the difficulty in coming up with this API was that @mst
felt that by default the methods should neither ping nor try to fix up a
failure. I was resistant to this because it's not how [Apache::DBI] or
[`connect_cached()`] work: they always ping. It turns out that [DBIx::Class]
doesn't cache connections at all. I thought it had. Rather, it creates a
connection and simply hangs onto it as a scalar variable. It handles the
connection for as long as it's in scope, but includes no magic global caching.
This reduces the action-at-a-distance issues common with caching while
maintaining proper `fork`- and thread-safety.

At this point, I took a baseball bat to my desk.

Figuratively, anyway. I did at least unleash a mountain of curses upon @mst and
various family relations. Because it took me a few minutes to see it: It turns
out that DBIx::Class is right to do it this way. So I ripped out the global
caching from DBIx::Connector, and suddenly it made much more sense not to ping
by default -- just as you wouldn't ping if you created a DBI handle yourself.

DBIx::Connector is no longer a caching layer over the DBI. It's now a *proxy*
for a connection. That's it. There is no magic, no implicit behavior, so it's
easier to use. And because it ensures `fork`- and thread-safety, you can
instantiate a connector and hold onto it for whenever you need it, unlike using
the DBI itself.

And one more thing: I also added a new method, `with()`. For those who always
want to use the same connection mode, you can use this method to create a proxy
object that has a different default mode. (Yes, a proxy for a proxy for a
database handle. Whatever!) Use it like this:

    $conn->with('fixup')->run( sub { ... } );

And if you always want to use the same mode, hold onto the proxy instead of the
connection object:

    my $proxy = DBIx::Connector->(@args)->with('fixup');

    # later ...
    $proxy->txn( sub { ... } ); # always in fixup mode

So while fixup mode is no longer the default, as [Tim requested], but it can
optionally be made the default, as DBIx::Class requires. The `with()` method
will also be the place to add other global behavioral modifications, such as
DBIx::Class's `auto_savepoint` feature.

So for those of you who were interested in the first iteration of this module,
my apologies for changing things so dramatically in this release (ripping out
the global caching, deprecating methods, adding a new block method API, etc.).
But I think that, for all the pain I went through to come up with the new API --
all the arguing on IRC, all the thesaurus spelunking -- that this is a really
good API, easy to explain and understand, and easy to use. And I don't expect to
change it again. I might improve exceptions (use objects instead of strings?)
add block method exception handling (perhaps adding a `catch` keyword?), but the
basics are finally nailed down and here to stay.

Thanks to @mst, @robkinyon, and @ribasushi, in particular, for bearing with me
and continuing to hammer on me when I was being dense.

  [DBIx::Connector]: https://metacpan.org/pod/DBIx::Connector
    "DBIx::Connector on CPAN"
  [post]: {{% ref "/post/past/perl/dbix-connector-methods" %}}
    "Suggest Method Names for DBIx::Connector"
  [thesaurus.com]: https://www.thesaurus.com/
  [Apache::DBI]: https://metacpan.org/pod/Apache::DBI
    "Apache::DBI on CPAN"
  [`connect_cached()`]: https://metacpan.org/pod/DBI#connect_cached
    "DBI on CPAN"
  [DBIx::Class]: https://metacpan.org/pod/DBIx::Class
    "DBIx::Class on CPAN"
  [Tim requested]: https://rt.cpan.org/Ticket/Display.html?id=47005
    "RT #47005: txn_do should provide a way to disable retry"
