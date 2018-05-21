--- 
date: 2006-10-16T19:17:09Z
slug: regex-named-captures
title: How to Use Regex Named Captures in Perl 5
aliases: [/computers/programming/perl/regex_named_captures.html]
tags: [Perl, Regular Expressions]
type: post
---

I ran some Perl 5 regular expression syntax that I'd never seen the other day.
It used two features I'd never seen before:

-   `(?{ })`, a zero-width, non-capturing assertion that executes arbitrary Perl
    code.
-   `$^N`, a variable for getting the contents of the most recent capture in a
    regular expression.

The cool thing is that, used in combination, these two features can be used to
hack named captures into Perl regular expressions. Here's an example:

``` perl
use warnings;
use strict;
use Data::Dumper;

my $string = 'The quick brown fox jumps over the lazy dog';

my %found;

my @captures = $string =~ /
    (?: (quick|slow) \s+    (?{ $found{speed}  = $^N  }) )
    (?: (brown|blue) \s+    (?{ $found{color}  = $^N  }) )
    (?: (sloth|fox)  \s+    (?{ $found{animal} = $^N  }) )
    (?: (eats|jumps)        (?{ $found{action} = $^N  }) )
/xms;

print Dumper \@captures;
print Dumper \%found;
```

The output of running this program is:

``` perl
$VAR1 = [
            'quick',
            'brown',
            'fox',
            'jumps'
        ];
$VAR1 = {
            'color' => 'brown',
            'speed' => 'quick',
            'action' => 'jumps',
            'animal' => 'fox'
        };
```

So the positional captures are still returned, *and* we've assigned them to keys
in a hash. This can be very convenient for complex regular expressions.

This is a cool feature, but there are a few caveats. First, according to the
Perl regular expression [documentation], `(?{ })` is a highly experimental
feature that could go away at any time. But more importantly, if you're relying
on this feature you should be aware of the side effects. What I mean by that is
that, if a regular expression match fails, but there are some successful matches
during execution, then the code in the `(?{ })` assertions could still execute.
For example, if you changed the word “jumps” to “poops” in the above example,
the output becomes:

``` perl
$VAR1 = [];
$VAR1 = {
            'color' => 'brown',
            'speed' => 'quick',
            'animal' => 'fox'
        };
```

Which means that the match failed, but there were still assignments to our hash,
because some of the captures succeeded before the overall match failed. The
upshot is that you should always check the return value from the match before
relying on whatever the code inside the `(?{ })` assertions did.

The problem becomes even more subtle if your regular expressions trigger
backtracking. In that case, you might have an optional group match and its value
assigned to the hash, and then the next required group fail. Perl will then
backtrack to throw out the successful group match and then see if the next
required match succeeds. If so, you can have a successful match and potentially
invalid data in your hash. Here's an example:

``` perl
my @captures = $string =~ /
    (?: (quick|slow) \s+    (?{ $found{speed}  = $^N  }) )
    (?: (brown|blue) \s+    (?{ $found{color}  = $^N  }) )?
    (?: (brown\s+fox)       (?{ $found{animal} = $^N  }) )
/xms;

print Dumper \@captures;
print Dumper \%found;
```

And the output is:

``` perl
$VAR1 = [
            'quick',
            undef,
            'brown fox'
        ];
$VAR1 = {
            'color' => 'brown',
            'speed' => 'quick',
            'animal' => 'brown fox'
        };
```

So while the second group returned `undef` for the color capture, the
`%found`hash still had the color key in it. This may or may not be what you
want.

Of course, all this seems cool, but since it's a truly evil hack, you have to be
careful. If you can wait, though, perhaps we'll see [named captures in Perl
5.10].

  [documentation]: http://search.cpan.org/perldoc/perlre#(?%7B_code_%7D)
    "Read about (?{ }) on CPAN"
  [named captures in Perl 5.10]: http://www.nntp.perl.org/group/perl.perl5.porters/;msgid=9b18b3110610051158h43c58810ted1017129929a539%5Bat%5Dmail.gmail.com
    "Perl 5 Porters: “[PATCH] Initial attempt at named captures for perls regexp engine”"
