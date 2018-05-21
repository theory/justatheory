--- 
date: 2005-08-25T02:03:17Z
slug: perl-time-override-help
title: How Does DateTime Ignore CORE::GLOBAL::time?
aliases: [/computers/programming/perl/time_override_help.html]
tags: [Perl, testing, hacks]
type: post
---

For the life of me, I can't figure out why this test fails. `time` returns my
overridden time, and DateTime just calls `scalar time`, so I would expect it to
work. But DateTime appears to be somehow getting the time for `CORE::time`,
instead.

``` perl
#!/usr/bin/perl -w

use strict;
use DateTime;
use Test::More tests => 1;

BEGIN {
    *CORE::GLOBAL::time = sub () { CORE::time() };
}

my $epoch = time;
sleep 1;
try();

sub try {
    no warnings qw(redefine);
    local *CORE::GLOBAL::time = sub () { $epoch };
    is( DateTime->now->epoch, time );
}
```

Anyone got any bright ideas? This is a [reasonably well-known technique], so I'm
sure that I must be overlooking something obvious.

  [reasonably well-known technique]: http://use.perl.org/~geoff/journal/20660
