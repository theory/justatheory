--- 
date: 2009-09-13T09:31:48Z
slug: dbi-connect-cached-hack
title: Keep DBI's connect_cached From Horking Transactions
aliases: [/computers/programming/perl/dbi-connect-cached-hack.html]
tags: [Perl, DBI, Databases, Caching]
type: post
---

I've been on a bit of a Perl hacking tear lately. In addition to knocking out
[Test::XPath] last week, I've been experimenting with [TAP::Harness] sources,
[Template::Declare], Catalyst views, a new Module::Build [subclass] for building
database-backed applications, and, last but not least, an [IRC logging bot]. Oh,
and that application I'm working on for [PGX] with [Quinn Weaver]. So much is
crowding my mind these days that I'm having trouble sleeping. Tonight I'm up
late hacking to try to get some of this stuff out of my head.

But before I crash, I wanted to share a useful DBI hack. I use [connect\_cached]
in a lot of my applications, because it's a nice way to reuse database handles
without having to figure out my own caching algorithm. The code I have to use it
looks like this:

``` perl
sub dbh {
    my $self = shift;
    DBI->connect_cached( @{ $self->_dbi }{qw(dsn username password)}, {
        PrintError     => 0,
        RaiseError     => 0,
        HandleError    => Exception::Class::DBI->handler,
        AutoCommit     => 1,
    });
}
```

Very simple. I just call the `dbh()` method whenever I need to talk to the
database, and I'm set. Except for one problem: transactions.

Say I have a method that grabs the handle, starts a transaction with the
`begin_work` method, and then inserts a row. Then another method grabs the
handle from `dbh()` on the assumption that it's in the same transaction, and
does its own work. Only, it's not the same transaction, because, unfortunately,
DBI sets the attributes passed to `connect_cached` *every single time it's
called!*. So even though that second method may think it's in the middle of a
transaction, it's really not, because when `connect_cached` sets `AutoCommit`
back to 1, the transaction gets committed.

Oops.

This really fucks with my tests, where I'm often fetching the database handle to
start a transaction, running some tests, and then wanting to rollback the
transaction when I'm done. It's irritating as all hell to discover that data has
been inserted into the database. And the DBI, alas, just gives me this warning:

    rollback ineffective with AutoCommit enabled at t/botinst.t line 67.

I'm likely not to notice until I get a duplicate key error the next time I run
the tests.

As I was dealing with this today, my memory started poking at me, telling me
that I've dealt with this before. And sure enough, a quick Google shows that
[Tim Bunce] and I had an [extensive conversation] on this very topic -- *over
four years ago.* If you're patient enough to dig through that thread, you'll
note that this issue is due to some architectural difficulties in the DBI, to be
worked out in DBI 2.

Over the last four years, I've implemented a couple of solutions to this
problem, all involving my code tracking the transaction state and modifying the
`AutoCommit` attribute in the appropriate places. It's all rather fragile. But
as I dug through the thread, I discovered a much cleaner fix, using a
little-known and so-far undocumented feature of the DBI: **callbacks**. This is
actually I feature I half-way implemented in the DBI years ago, getting it just
far enough that Tim was willing to finish it. And it's just sitting there,
waiting to be used.

So here's the trick: Specify a callback for the `connect_cached()` method that's
used only when an existing file handle is retrieved from the cache. A bunch of
stuff is passed to the callback, but the important one is the fifth argument,
the attributes. All it has to do is delete the `AutoCommit` attribute. Since
this callback is called before the DBI looks at the attributes to set them on
the handle, the callback effectively prevents the DBI from horking up your
transactions.

Here's the modified code:

``` perl
my $cb = {
    'connect_cached.reused' => sub { delete $_[4]->{AutoCommit} },
};

sub dbh {
    my $self = shift;
    DBI->connect_cached( @{ $self->_dbi }{qw(dsn username password)}, {
        PrintError     => 0,
        RaiseError     => 0,
        HandleError    => Exception::Class::DBI->handler,
        AutoCommit     => 1,
        Callbacks      => $cb,
    });
}
```

Callbacks are passed as a hash reference, with the keys being the names of the
DBI methods that should trigger the callbacks, such as `ping`, `data_sources`,
or `connect_cached`. The values are, of course, code references. When the DBI
calls the code callbacks, it passes in stuff relevant to the method.

In the case of `connect_cached`, there are two additional special-case
callbacks, `connect_cached.new` and `connect_cached.reused`, so that you can
have different callbacks execute depending on whether `connect_cached` used a
cached database handle or had to create a new one. Here, I've used
`connect_cached.reused`, of course, and all I do is kill off the `AutoCommit`
attribute before the DBI gets its greedy hands on it. Et voilà, problem solved!

And before you ask, no, you can't simply omit `AutoCommit` from the attributes
passed to `connect_cached`, because the DBI helpfully adds it for you.

So now this is here so I can find it again when it bites me next year, and I
hope it helps you, too. Meanwhile, perhaps someone could take it upon themselves
to document DBI's callbacks? At this point, the closest thing to documentation
is in the [tests]. (Hrm. I think I might have had a hand in writing them.) Check
'em out.

  [Test::XPath]: https://metacpan.org/pod/Test::XPath
    "Test::XPath on CPAN"
  [TAP::Harness]: https://metacpan.org/pod/TAP::Harness
    "TAP::Harness on CPAN"
  [Template::Declare]: https://metacpan.org/pod/Template::Declare
    "Template::Declare on CPAN"
  [subclass]: http://github.com/theory/module-build-db/
    "Module::Build::DB on GitHub"
  [IRC logging bot]: https://github.com/theory/circle/ "Circle on GitHub"
  [PGX]: https://pgexperts.com/ "PostgreSQL Experts, Inc."
  [Quinn Weaver]: https://www.linkedin.com/in/quinnweaver/
  [connect\_cached]: https://metacpan.org/pod/DBI#connect_cached
    "DBI: connect_cached"
  [Tim Bunce]: https://blog.timbunce.org "Not this…"
  [extensive conversation]: https://markmail.org/thread/de3jzc2unm55egn7
    "DBI-Dev: “AutoCommit and connect_cached()”"
  [tests]: https://metacpan.org/release/TIMB/DBI-1.609/source/t/70callbacks.t
    "DBI test 70callbacks.t"
