--- 
date: 2006-04-15T00:53:36Z
slug: percent-change
title: How To Calculate Percentage Change Between Two Values
aliases: [/learn/math/percent_change.html]
tags: [Math, percentage, Perl]
---

<p>So I'm a total math n00b, but I wanted to know how much of a change there was between some benchmarking numbers, in percentages. I thought that this was really basic, but I was wrong. So I Googled and found <a href="http://mathforum.org/library/drmath/view/58083.html" title="Ask Dr. Math: Percent Change, Increase, Difference">an article</a> describing how to calculate the percentage change between two values. I wrote this Perl script so that I'd just have it in my toolbox:</p>

<pre>
#!/usr/local/bin/perl -w

use strict;

print &quot;\nUsage: $0 from to\n&quot; unless @ARGV == 2;

my ($from, $to) = @ARGV;
my $diff = (($to - $from) / $from) * 100;
my $label = $diff &lt; 0 ? &#x0027;greater&#x0027; : &#x0027;less&#x0027;;
printf &quot;$from is %.2f%% $label than $to\n&quot;, abs $diff;
</pre>

<p>When I run this script, I get values that agree with Dr Math's answers:</p>

<pre>
% percent_diff 7 5
7 is 28.57% larger than 5
% percent_diff 5 7
5 is 40.00% smaller than 7
</pre>

<p>So far so good. But then when I ran it on my benchmark numbers, I got different numbers than I would intuitively expect:</p>

<pre>
% percent_diff 13.67 40.73
13.67 is 197.95% smaller than 40.73
% percent_diff 40.73 13.67
40.73 is 66.44% greater than 13.67
</pre>

<p>Now, to me, it seems like you can fit roughly three 13.67s in 40.73. So then why isn't it 300% smaller?</p>

<p>Pardon my total ignorance, but if anyone knows the answer to this question, I'd greatly appreciate a simple explanation. Thanks!</p>

<p><strong>Update:</strong><a href="http://www.plover.com/blog/" title="Mark Jason Dominus">Mark Jason Dominus</a> was kind enough to respond very lucidly to an email linking to this blog entry. With his permission, I've pasted his comments below. All is now clear.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/learn/math/percent_change.html">old layout</a>.</small></p>


