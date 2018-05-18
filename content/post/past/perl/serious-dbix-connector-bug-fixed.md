--- 
date: 2010-12-17T18:52:09Z
slug: serious-dbix-connector-bug-fixed
title: Serious Exception-Handling Bug Fixed in DBIx::Connector 0.42
aliases: [/computers/programming/perl/serious-dbix-connector-bug-fixed.html]
tags: [Perl, DBIx::Connector, DBI, exception handling]
type: post
---

<p>I’ve just released
<a href="http://search.cpan.org/dist/DBIx-Connector" title="DBIx::Connector
on CPAN">DBIx::Connector</a> 0.42 to CPAN. This release fixes a serious bug with <code>catch</code> blocks.
In short, if you threw an exception from inside a catch block, it would not be
detectable from outside. For example, given this code:</p>

<pre><code>eval {
    $conn-&gt;run(sub { die 'WTF' }, catch =&gt; sub { die 'OMG!' });
};
if (my $err = $@) {
    say "We got an error: $@\n";
}
</code></pre>

<p>With DBIx::Connector 0.41 and lower, the <code>if</code> block would never be called,
because even though the catch block threw an exception, <code>$@</code> was not set. In
other words, the exception would not be propagated to its caller. This could
be terribly annoying, as you can imagine. I was being a bit too clever about
localizing <code>$@</code>, with the scope much too broad. 0.42 uses a much tighter scope
to localize <code>$@</code>, so now it should propagate properly everywhere.</p>

<p>So if you’re using DBIx::Connector <code>catch</code> blocks, please upgrade ASAP. Sorry
for the hassle.</p>
