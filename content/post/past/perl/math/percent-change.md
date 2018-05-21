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

``` perl
#!/usr/local/bin/perl -w

use strict;

print "\nUsage: $0 from to\n" unless @ARGV == 2;

my ($from, $to) = @ARGV;
my $diff = (($to - $from) / $from) * 100;
my $label = $diff < 0 ? 'greater' : 'less';
printf "$from is %.2f%% $label than $to\n", abs $diff;
```

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

> Your algorithm is incorrect. 5 is not 40% smaller than 7. It is 28.57% smaller
> than 7. And 7 is not 28.57% larger than 5; it is 40% larger than 5.
> 
> I will try to make sense of this. The first thing to notice is that the
> algorithm is not symmetric. When you're calculating percent differences, the
> percentage is always reckoned relative to the FROM value, never the “to” value.
> 40 is one-THIRD larger than 30, not one-fourth larger. And 30 is one-FOURTH
> smaller than 40, not one-third smaller. (If someone gives you a 50% discount on
> a computer that has been marked up from the wholesale price by 50%, say from
> $1000 to $1500, you are not getting it at the wholesale price, right? That is
> the asymmetry at work.)
> 
> Now let's go back to basics. What number is (say) 10% larger than 70? To find
> this, you take 70 and add 10% of it. To do the calculation, you need to know
> what “of” means. In mathematics, “of” always means multiplication. So when you
> say that 1/3 \*of\* 75 is 25, you just mean that 1/3 \* 75 is 25. (Similarly, if
> rutubagas cost 50c a pound, then twelve pounds OF rutubagas cost 12 MULTIPLIED
> BY 50c = $6.)
> 
> So when we ask about 10% of 70, we mean 10% \* 70. What kind of number is 10%?
> “%” is also simple; it means “multiply by 1/100”, so that 10% is just 10 \*
> 1/100, or 1/10, and 37% is 37 \* 1/100. Thus 10% of 70 is 10 \* 1/100 \* 70 = 7,
> as you would hope and expect. And 100% of 70 is 100 \* 1/100 \* 70 = 70.
> 
> Now, what's 10% larger than 70? You take 70, and add 10% of 70:
> 
>     70 + 10%        of 70 =
>     70 + 10%         * 70 = 
>     70 + 10  * 1/100 * 70 = 
>     70 + 700 * 1/100      =
>     70 + 7                =
>     77
> 
> What's 10% larger than 70? 77 is. OK so far, I hope.
> 
> Now let's use algebra to work it backwards. Suppose we want to know how much
> larger than 70 is 84. So we want to solve the equation
> 
>     84 is X% larger than 70
> 
> and to work out “X% larger than 70” we do the same as we did just before: Take
> 70 and add X% of 70:
> 
>     70  + X%   of 70 = 84
>     70  + X%    * 70 = 84
>     70  + X/100 * 70 = 84
>     70  + 7X/10      = 84
>     700 + 7X         = 840
>           7X         = 140
>            X         = 20
> 
> So X is 20, and 84 is thus 20% larger than 70.
> 
> Now let's do it in general. Suppose we're given F (“from”) and T (“to”), as this
> program is, and we want to know how much larger T is than F. We set it up the
> same way:
> 
>         F + X%   of F = T
>         F + X%    * F = T
>         F + X/100 * F = T
>         T - F         = X/100 * F
>        (T - F) / F    = X/100
>    100*(T - F) / F    = X
> 
> So T is now X% larger than F, where X is as above.
> 
> For example, when T is 20 and F is 10, we get that X is 100 \* (20-10) / 10 =
> 100% larger than F, which is just right.
> 
> When about when T is actually smaller than F? Say, T is 5 and F is 10? Then X is
> 100 \* (5-10)/10 = -50, so T is -50% larger than F. And then we usually say that
> T is 50% smaller than F.
> 
> So when X, the percent difference, is positive, it's because T is larger than F
> and when X is negative, it means that T is smaller than F. Which is what you
> would expect.
> 
> What's wrong with your program? Two things. The formula itself is exactly
> correct. The problem is later.
> 
> You have the “greater” and “lesser” reversed---you say that one is “greater”
> when X is negative; it should be the other way around.
> 
> Why didn't you notice this? Because your final print statement also has F and T
> backwards. It says that F is X% larger/smaller than T, but it should be saying
> that T is X% larger/smaller than F. So your program got the greater-lesser thing
> backwards, and then reverse the from and to values to match. For some kinds of
> calculations, this would not be a problem. But as we noticed way back at the
> beginning, the algorithm is not symmetric between from and to, so we can't do
> that here.
> 
> So here is the corrected version:
>
``` perl
#!/usr/local/bin/perl -w

use strict;

print "\nUsage: $0 from to\n" unless @ARGV == 2;

my ($from, $to) = @ARGV;
my $diff = (($to - $from) / $from) * 100;
my $label = $diff > 0 ? 'greater' : 'less';
printf "$to is %.2f%% $label than $from\n", abs $diff;
```
>
> And it now produces outputs:
> 
>     % ./pd 7 5
>     5 is 28.57% less than 7
>     % ./pd 5 7
>     7 is 40.00% greater than 5
> 
> These are correct.
> 
>     % ./pd 13.67 40.73
>     40.73 is 197.95% greater than 13.67
>     % ./pd 40.73 13.67
>     13.67 is 66.44% less than 40.73
> 
> And now your thing about fitting three 13.67's into 40.73 comes out in the
> numbers. 40.73 is as big as three 13.67's, so it is about 200% larger, and this
> is what the program says. (If it were as big as one 13.67, it would be 0%
> larger, and if it were as big as two 13.67's, it would be 100% larger.)
> 
> And going the other way, 13.67 is about one-third as big as 40.73, so it is
> about 2/3 smaller; 2/3 is 66.67%, which is what the program says.
> 
> I hope this was helpful and not excessively verbose.
