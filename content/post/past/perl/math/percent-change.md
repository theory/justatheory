--- 
date: 2006-04-15T00:53:36Z
slug: percent-change
title: How To Calculate Percentage Change Between Two Values
aliases: [/learn/math/percent_change.html]
tags: [Math, percentage, Perl]
type: post
---

So I'm a total math n00b, but I wanted to know how much of a change there was
between some benchmarking numbers, in percentages. I thought that this was
really basic, but I was wrong. So I Googled and found [an article] describing
how to calculate the percentage change between two values. I wrote this Perl
script so that I'd just have it in my toolbox:

    #!/usr/local/bin/perl -w

    use strict;

    print "\nUsage: $0 from to\n" unless @ARGV == 2;

    my ($from, $to) = @ARGV;
    my $diff = (($to - $from) / $from) * 100;
    my $label = $diff < 0 ? 'greater' : 'less';
    printf "$from is %.2f%% $label than $to\n", abs $diff;

When I run this script, I get values that agree with Dr Math's answers:

    % percent_diff 7 5
    7 is 28.57% larger than 5
    % percent_diff 5 7
    5 is 40.00% smaller than 7

So far so good. But then when I ran it on my benchmark numbers, I got different
numbers than I would intuitively expect:

    % percent_diff 13.67 40.73
    13.67 is 197.95% smaller than 40.73
    % percent_diff 40.73 13.67
    40.73 is 66.44% greater than 13.67

Now, to me, it seems like you can fit roughly three 13.67s in 40.73. So then why
isn't it 300% smaller?

Pardon my total ignorance, but if anyone knows the answer to this question, I'd
greatly appreciate a simple explanation. Thanks!

**Update:**[Mark Jason Dominus] was kind enough to respond very lucidly to an
email linking to this blog entry. With his permission, I've pasted his comments
below. All is now clear.

  [an article]: http://mathforum.org/library/drmath/view/58083.html
    "Ask Dr. Math: Percent Change, Increase, Difference"
  [Mark Jason Dominus]: http://www.plover.com/blog/ "Mark Jason Dominus"
