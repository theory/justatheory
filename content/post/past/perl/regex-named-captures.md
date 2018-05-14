--- 
date: 2006-10-16T19:17:09Z
slug: regex-named-captures
title: How to Use Regex Named Captures in Perl 5
aliases: [/computers/programming/perl/regex_named_captures.html]
tags: [Perl, Regular Expressions]
type: post
---

<p>I ran some Perl 5 regular expression syntax that I'd never seen the other
day. It used two features I'd never seen before:</p>

<ul>
  <li><code>(?{ })</code>, a zero-width, non-capturing assertion that executes
    arbitrary Perl code.</li>
  <li><code>$^N</code>, a variable for getting the contents of the most recent
    capture in a regular expression.</li>
</ul>

<p>The cool thing is that, used in combination, these two features can be used
to hack named captures into Perl regular expressions. Here's an example:</p>

<pre>
use warnings;
use strict;
use Data::Dumper;

my $string = &#x0027;The quick brown fox jumps over the lazy dog&#x0027;;

my %found;

my @captures = $string =~ /
    (?: (quick|slow) \s+    (?{ $found{speed}  = $^N  }) )
    (?: (brown|blue) \s+    (?{ $found{color}  = $^N  }) )
    (?: (sloth|fox)  \s+    (?{ $found{animal} = $^N  }) )
    (?: (eats|jumps)        (?{ $found{action} = $^N  }) )
/xms;

print Dumper \@captures;
print Dumper \%found;
</pre>

<p>The output of running this program is:</p>

<pre>
$VAR1 = [
          &#x0027;quick&#x0027;,
          &#x0027;brown&#x0027;,
          &#x0027;fox&#x0027;,
          &#x0027;jumps&#x0027;
        ];
$VAR1 = {
          &#x0027;color&#x0027; =&gt; &#x0027;brown&#x0027;,
          &#x0027;speed&#x0027; =&gt; &#x0027;quick&#x0027;,
          &#x0027;action&#x0027; =&gt; &#x0027;jumps&#x0027;,
          &#x0027;animal&#x0027; =&gt; &#x0027;fox&#x0027;
        };
</pre>

<p>So the positional captures are still returned, <em>and</em> we've assigned
them to keys in a hash. This can be very convenient for complex regular
expressions.</p>

<p>This is a cool feature, but there are a few caveats. First, according to
the Perl regular expression
<a href="http://search.cpan.org/perldoc/perlre#(?{_code_})" title="Read about (?{ }) on CPAN">documentation</a>, <code>(?{ })</code> is a highly
experimental feature that could go away at any time. But more importantly, if
you're relying on this feature you should be aware of the side effects. What I
mean by that is that, if a regular expression match fails, but there are some
successful matches during execution, then the code in the <code>(?{ })</code>
assertions could still execute. For example, if you changed the
word <q>jumps</q> to <q>poops</q> in the above example, the output becomes:</p>

<pre>
$VAR1 = [];
$VAR1 = {
          &#x0027;color&#x0027; =&gt; &#x0027;brown&#x0027;,
          &#x0027;speed&#x0027; =&gt; &#x0027;quick&#x0027;,
          &#x0027;animal&#x0027; =&gt; &#x0027;fox&#x0027;
        };
</pre>

<p>Which means that the match failed, but there were still assignments to our
hash, because some of the captures succeeded before the overall match failed.
The upshot is that you should always check the return value from the match
before relying on whatever the code inside the <code>(?{ })</code> assertions
did.</p>

<p>The problem becomes even more subtle if your regular expressions trigger
backtracking. In that case, you might have an optional group match and its
value assigned to the hash, and then the next required group fail. Perl will
then backtrack to throw out the successful group match and then see if the
next required match succeeds. If so, you can have a successful match and
potentially invalid data in your hash. Here's an example:</p>

<pre>
my @captures = $string =~ /
    (?: (quick|slow) \s+    (?{ $found{speed}  = $^N  }) )
    (?: (brown|blue) \s+    (?{ $found{color}  = $^N  }) )?
    (?: (brown\s+fox)       (?{ $found{animal} = $^N  }) )
/xms;

print Dumper \@captures;
print Dumper \%found;
</pre>

<p>And the output is:</p>

<pre>
$VAR1 = [
          &#x0027;quick&#x0027;,
          undef,
          &#x0027;brown fox&#x0027;
        ];
$VAR1 = {
          &#x0027;color&#x0027; =&gt; &#x0027;brown&#x0027;,
          &#x0027;speed&#x0027; =&gt; &#x0027;quick&#x0027;,
          &#x0027;animal&#x0027; =&gt; &#x0027;brown fox&#x0027;
        };
</pre>

<p>So while the second group returned <code>undef</code> for the color
capture, the <code>%found</code>hash still had the color key in it. This may
or may not be what you want.</p>

<p>Of course, all this seems cool, but since it's a truly evil hack, you have
to be careful. If you can wait, though, perhaps we'll
see <a
href="http://www.nntp.perl.org/group/perl.perl5.porters/;msgid=9b18b3110610051158h43c58810ted1017129929a539[at]mail.gmail.com" title="Perl 5 Porters: &#x201c;[PATCH] Initial attempt at named captures for
perls regexp engine&#x201d;">named captures in Perl 5.10</a>.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/regex_named_captures.html">old layout</a>.</small></p>


