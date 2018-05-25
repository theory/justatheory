--- 
date: 2010-12-17T18:52:09Z
slug: serious-dbix-connector-bug-fixed
title: Serious Exception-Handling Bug Fixed in DBIx::Connector 0.42
aliases: [/computers/programming/perl/serious-dbix-connector-bug-fixed.html]
tags: [Perl, DBIx::Connector, DBI, Exception Handling]
type: post
---

I’ve just released [DBIx::Connector] 0.42 to CPAN. This release fixes a serious
bug with `catch` blocks. In short, if you threw an exception from inside a catch
block, it would not be detectable from outside. For example, given this code:

``` perl
eval {
    $conn->run(sub { die 'WTF' }, catch => sub { die 'OMG!' });
};
if (my $err = $@) {
    say "We got an error: $@\n";
}
```

With DBIx::Connector 0.41 and lower, the `if` block would never be called,
because even though the catch block threw an exception, `$@` was not set. In
other words, the exception would not be propagated to its caller. This could be
terribly annoying, as you can imagine. I was being a bit too clever about
localizing `$@`, with the scope much too broad. 0.42 uses a much tighter scope
to localize `$@`, so now it should propagate properly everywhere.

So if you’re using DBIx::Connector `catch` blocks, please upgrade ASAP. Sorry
for the hassle.

  [DBIx::Connector]: http://search.cpan.org/dist/DBIx-Connector "DBIx::Connector on CPAN"
