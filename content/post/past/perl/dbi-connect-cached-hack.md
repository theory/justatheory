--- 
date: 2009-09-13T09:31:48Z
slug: dbi-connect-cached-hack
title: Keep DBI's connect_cached From Horking Transactions
aliases: [/computers/programming/perl/dbi-connect-cached-hack.html]
tags: [Perl, DBI, database, caching]
type: post
---

<p>I've been on a bit of a Perl hacking tear lately. In addition to knocking out
<a href="http://search.cpan.org/perldoc?Test::XPath" title="Test::XPath on CPAN">Test::XPath</a> last week, I've been experimenting with
<a href="http://search.cpan.org/perldoc?TAP::Harness" title="TAP::Harness on CPAN">TAP::Harness</a> sources,
<a href="http://search.cpan.org/perldoc?Template::Declare" title="Template::Declare on CPAN">Template::Declare</a>, Catalyst views, a new
Module::Build <a href="http://github.com/theory/module-build-db/" title="Module::Build::DB on GitHub">subclass</a> for building database-backed
applications, and, last but not least, an
<a href="http://github.com/theory/circle/" title="Circle on GitHub">IRC logging bot</a>. Oh, and that application I'm working on
for <a href="http://www.pgexperts.com/" title="PostgreSQL Experts, Inc.">PGX</a> with <a href="http://www.pgexperts.com/Quinn.Weaver.html">Quinn Weaver</a>. So much is crowding my mind these days that I'm having trouble
sleeping. Tonight I'm up late hacking to try to get some of this stuff out of
my head.</p>

<p>But before I crash, I wanted to share a useful DBI hack. I use
<a href="http://search.cpan.org/perldoc?DBI#connect_cached" title="DBI: connect_cached">connect_cached</a> in a lot of my applications, because it's a
nice way to reuse database handles without having to figure out my own caching
algorithm. The code I have to use it looks like this:</p>

<pre>
sub dbh {
    my $self = shift;
    DBI-&gt;connect_cached( @{ $self-&gt;_dbi }{qw(dsn username password)}, {
        PrintError     =&gt; 0,
        RaiseError     =&gt; 0,
        HandleError    =&gt; Exception::Class::DBI-&gt;handler,
        AutoCommit     =&gt; 1,
    });
}
</pre>

<p>Very simple. I just call the <code>dbh()</code> method whenever I need to
talk to the database, and I'm set. Except for one problem: transactions.</p>

<p>Say I have a method that grabs the handle, starts a transaction with
the <code>begin_work</code> method, and then inserts a row. Then another
method grabs the handle from <code>dbh()</code> on the assumption that it's in
the same transaction, and does its own work. Only, it's not the same
transaction, because, unfortunately, DBI sets the attributes passed
to <code>connect_cached</code> <em>every single time it's called!</em>. So
even though that second method may think it's in the middle of a transaction,
it's really not, because when <code>connect_cached</code>
sets <code>AutoCommit</code> back to 1, the transaction gets committed.</p>

<p>Oops.</p>

<p>This really fucks with my tests, where I'm often fetching the database
handle to start a transaction, running some tests, and then wanting to
rollback the transaction when I'm done. It's irritating as all hell to
discover that data has been inserted into the database. And the DBI, alas,
just gives me this warning:</p>

<pre>
rollback ineffective with AutoCommit enabled at t/botinst.t line 67.
</pre>

<p>I'm likely not to notice until I get a duplicate key error the next time I
run the tests.</p>

<p>As I was dealing with this today, my memory started poking at me, telling
me that I've dealt with this before. And sure enough, a quick Google shows
that <a href="http://blog.timbunce.org/" title="Not this…">Tim Bunce</a> and I
had an <a href="http://markmail.org/thread/de3jzc2unm55egn7" title="DBI-Dev: “AutoCommit and connect_cached()”">extensive conversation</a>
on this very topic -- <em>over four years ago.</em> If you're patient enough
to dig through that thread, you'll note that this issue is due to some
architectural difficulties in the DBI, to be worked out in DBI 2.</p>

<p>Over the last four years, I've implemented a couple of solutions to this
problem, all involving my code tracking the transaction state and modifying
the <code>AutoCommit</code> attribute in the appropriate places. It's all
rather fragile. But as I dug through the thread, I discovered a much cleaner
fix, using a little-known and so-far undocumented feature of the DBI:
<strong>callbacks</strong>. This is actually I feature I half-way implemented
in the DBI years ago, getting it just far enough that Tim was willing to
finish it. And it's just sitting there, waiting to be used.</p>

<p>So here's the trick: Specify a callback for
the <code>connect_cached()</code> method that's used only when an existing
file handle is retrieved from the cache. A bunch of stuff is passed to the
callback, but the important one is the fifth argument, the attributes. All it
has to do is delete the <code>AutoCommit</code> attribute. Since this callback
is called before the DBI looks at the attributes to set them on the handle,
the callback effectively prevents the DBI from horking up your
transactions.</p>

<p>Here's the modified code:</p>

<pre>
my $cb = {
    'connect_cached.reused' =&gt; sub { delete $_[4]-&gt;{AutoCommit} },
};

sub dbh {
    my $self = shift;
    DBI-&gt;connect_cached( @{ $self-&gt;_dbi }{qw(dsn username password)}, {
        PrintError     =&gt; 0,
        RaiseError     =&gt; 0,
        HandleError    =&gt; Exception::Class::DBI-&gt;handler,
        AutoCommit     =&gt; 1,
        Callbacks      =&gt; $cb,
    });
}
</pre>

<p>Callbacks are passed as a hash reference, with the keys being the names of
the DBI methods that should trigger the callbacks, such as <code>ping</code>,
<code>data_sources</code>, or <code>connect_cached</code>. The values are, of
course, code references. When the DBI calls the code callbacks, it passes in
stuff relevant to the method.</p>

<p>In the case of <code>connect_cached</code>, there are two additional
special-case callbacks, <code>connect_cached.new</code> and
<code>connect_cached.reused</code>, so that you can have different callbacks
execute depending on whether <code>connect_cached</code> used a cached
database handle or had to create a new one. Here, I've
used <code>connect_cached.reused</code>, of course, and all I do is kill off
the <code>AutoCommit</code> attribute before the DBI gets its greedy hands on
it. Et voilà, problem solved!</p>

<p>And before you ask, no, you can't simply omit <code>AutoCommit</code>
from the attributes passed to <code>connect_cached</code>, because the DBI
helpfully adds it for you.</p>

<p>So now this is here so I can find it again when it bites me next year, and
I hope it helps you, too. Meanwhile, perhaps someone could take it upon
themselves to document DBI's callbacks? At this point, the closest thing to
documentation is in the
<a href="http://cpansearch.perl.org/src/TIMB/DBI-1.609/t/70callbacks.t"title="DBI test 70callbacks.t">tests</a>. (Hrm. I think I might have had a hand in
writing them.) Check 'em out.</p>
