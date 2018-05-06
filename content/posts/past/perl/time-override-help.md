--- 
date: 2005-08-25T02:03:17Z
slug: time-override-help
title: How Does DateTime Ignore CORE::GLOBAL::time?
aliases: [/computers/programming/perl/time_override_help.html]
tags: [Perl, testing, hacks]
---

<p>For the life of me, I can't figure out why this test fails. <code>time</code> returns my overridden time, and DateTime just calls <code>scalar time</code>, so I would expect it to work. But DateTime appears to be somehow getting the time for <code>CORE::time</code>, instead.</p>

<pre>
#!/usr/bin/perl -w

use strict;
use DateTime;
use Test::More tests =&gt; 1;

BEGIN {
    *CORE::GLOBAL::time = sub () { CORE::time() };
}

my $epoch = time;
sleep 1;
try();

sub try {
    no warnings qw(redefine);
    local *CORE::GLOBAL::time = sub () { $epoch };
    is( DateTime-&gt;now-&gt;epoch, time );
}
</pre>

<p>Anyone got any bright ideas? This is a <a href="http://use.perl.org/~geoff/journal/20660" title="">reasonably well-known technique</a>, so I'm sure that I must be overlooking something obvious.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/time_override_help.html">old layout</a>.</small></p>


