--- 
date: 2005-03-28T22:55:29Z
slug: perl-pack-vs-regex
title: Regular Expressions are Faster than Unpacking
aliases: [/computers/programming/perl/pack_vs_regex.html]
tags: [Perl, Regular Expressions, DateTime]
type: post
---

Bricolage has always used `unpack()` to parse ISO-8601 date strings into their
component parts. A few months back, I added support for subsecond precision
using the [DateTime], and couldn't figure out how to parse out the optional
subsecond part of the date (If it's 0, PostgreSQL doesn't include the decimal
part of the seconds). So I switched to parsing with the regular expression
`/(\d\d\d\d).(\d\d).(\d\d).(\d\d).(\d\d).(\d\d)(\.\d*)?/`. This worked well, but
I lamented the loss of performance of `unpack()`. I mean, surely it's faster to
tell a parser where, exactly, to find each characters, than it is to use a
pattern, right?

Well, last week I finally figured out how to unpack the decimal place using
`unpack()` whether it's there or not (the secret is the `*` modifier, which
somehow I'd never noticed before). So I ran a benchmark to see how much of a
performance gain I would get:

``` perl
#!/usr/bin/perl -w
use strict;
use Benchmark;

my $date = '2005-03-23T19:30:05.1234';
my $ISO_TEMPLATE =  'a4 x a2 x a2 x a2 x a2 x a2 a*';

sub with_pack {
    my %args;
    @args{qw(year month day hour minute second nanosecond)}
        = unpack $ISO_TEMPLATE, $date;
    {
        no warnings;
        $args{nanosecond} *= 1.0E9;
    }
}

sub with_regex {
    $date =~ m/(\d\d\d\d).(\d\d).(\d\d).(\d\d).(\d\d).(\d\d)(\.\d*)?/;
    my %args = (
        year       => $1,
        month      => $2,
        day        => $3,
        hour       => $4,
        minute     => $5,
        second     => $6,
        nanosecond => $7 ? $7 * 1.0E9 : 0
    );
}

timethese(100000, {
    pack => \&with_pack,
    regex => \&with_regex
});

__END__
```

I quickly got my answer (all hail [Benchmark]!). This script outputs:

      Benchmark: timing 100000 iterations of pack, regex...
            pack:  3 wallclock secs ( 2.14 usr +  0.00 sys =  2.14 CPU) @ 46728.97/s (n=100000)
           regex:  3 wallclock secs ( 2.11 usr +  0.01 sys =  2.12 CPU) @ 47169.81/s (n=100000)

I sure didn't expect them to be so close, let alone to see the regular
expression approach nose out the `unpack()` solution. Clearly the Perl regex
engine is highly optimized. And perhaps `pack()/unpack()` is not.

Live and learn, I guess.

  [DateTime]: http://search.cpan.org/dist/DateTime/
    "Download DateTime and read its docs on CPAN"
  [Benchmark]: http://search.cpan.org/dist/Benchmark/
    "Download Benchmark and read its docs on CPAN"
