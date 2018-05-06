--- 
date: 2006-07-04T00:33:22Z
slug: stepped-series
title: Stepped Series of Numbers in Perl
aliases: [/computers/programming/perl/stepped_series.html]
tags: [Perl, grep]
---

<p>In working on a Perl validation function for GTINs
(recipe <a href="http://www.gs1.org/productssolutions/idkeys/support/check_digit_calculator.html#how" title="GTIN/EAN/UPC validation tables">here</a>), I found a need to generate a
series of numbers with a step of two. For example, I in the series 1-10, I
first want 1, 3, 5, 7, and 9. And then later I want 2, 4, 6, 8, 10. Here's how
I went about creating those series in my GTIN function to create hash
slices:</p>

<pre>
sub isa_gtin {
    my @nums = reverse split q{}, shift;
    (
        sum( @nums[ grep {   $_ % 2  } 0..$#nums ] ) * 3
      + sum( @nums[ grep { !($_ % 2) } 0..$#nums ] )
    ) % 10 == 0;
}
</pre>

<p>But it seems wasteful to generate the series of numbers twice and to
calculate whether they're odd or even twice. Surely there's a more efficient
way to do this in Perl, perhaps even more expressive? Python seems to have a
useful syntax for creating array slices that step. In Python, I'd do something
like this:</p>

<pre>
  sum( nums[1:10:2] ) * 3 + sum( nums[2:10:2])
</pre>

<p>But barring such a slice feature in Perl is there some cleaner way than the
ugly <code>grep</code> approach I created to generate a stepped series in
Perl?</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/stepped_series.html">old layout</a>.</small></p>


