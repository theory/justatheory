--- 
date: 2005-03-28T22:55:29Z
slug: pack-vs-regex
title: Regular Expressions are Faster than Unpacking
aliases: [/computers/programming/perl/pack_vs_regex.html]
tags: [Perl, Regular Expressions, DateTime]
---

<p>Bricolage has always used <code>unpack()</code> to parse ISO-8601 date strings into their component parts. A few months back, I added support for subsecond precision using the <a href="http://search.cpan.org/dist/DateTime/" title="Download DateTime and read its docs on CPAN">DateTime</a>, and couldn't figure out how to parse out the optional subsecond part of the date (If it's 0, PostgreSQL doesn't include the decimal part of the seconds). So I switched to parsing with the regular expression <code>/(\d\d\d\d).(\d\d).(\d\d).(\d\d).(\d\d).(\d\d)(\.\d*)?/</code>. This worked well, but I lamented the loss of performance of <code>unpack()</code>. I mean, surely it's faster to tell a parser where, exactly, to find each characters, than it is to use a pattern, right?</p>

<p>Well, last week I finally figured out how to unpack the decimal place using <code>unpack()</code> whether it's there or not (the secret is the <code>*</code> modifier, which somehow I'd never noticed before). So I ran a benchmark to see how much of a performance gain I would get:</p>

<pre>
#!/usr/bin/perl -w
use strict;
use Benchmark;

my $date = &#x0027;2005-03-23T19:30:05.1234&#x0027;;
my $ISO_TEMPLATE =  &#x0027;a4 x a2 x a2 x a2 x a2 x a2 a*&#x0027;;

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
        year       =&gt; $1,
        month      =&gt; $2,
        day        =&gt; $3,
        hour       =&gt; $4,
        minute     =&gt; $5,
        second     =&gt; $6,
        nanosecond =&gt; $7 ? $7 * 1.0E9 : 0
    );
}

timethese(100000, {
    pack =&gt; \&amp;with_pack,
    regex =&gt; \&amp;with_regex
});

__END__
</pre>

<p>I quickly got my answer (all hail <a href="http://search.cpan.org/dist/Benchmark/" title="Download Benchmark and read its docs on CPAN">Benchmark</a>!). This script outputs:</p>

<pre>
  Benchmark: timing 100000 iterations of pack, regex...
        pack:  3 wallclock secs ( 2.14 usr +  0.00 sys =  2.14 CPU) @ 46728.97/s (n=100000)
       regex:  3 wallclock secs ( 2.11 usr +  0.01 sys =  2.12 CPU) @ 47169.81/s (n=100000)
</pre>

<p>I sure didn't expect them to be so close, let alone to see the regular expression approach nose out the <code>unpack()</code> solution. Clearly the Perl regex engine is highly optimized. And perhaps  <code>pack()/unpack()</code> is not.</p>

<p>Live and learn, I guess.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/pack_vs_regex.html">old layout</a>.</small></p>


