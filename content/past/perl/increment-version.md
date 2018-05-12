--- 
date: 2004-12-14T22:03:00Z
slug: increment-version
title: How I Increment Module Version Numbers
aliases: [/computers/programming/perl/increment_version.html]
tags: [Perl, Versions, CPAN, shipping]
type: post
---

<p>Here's how I quickly increment version numbers in my modules. I call this script
<em>reversion</em>:</p>

<pre>#!/usr/bin/perl -w

use strict;

unless (@ARGV) {
    print &quot;  Usage: $0 version\n\n&quot;;
    exit;
}

my $old = shift;
my $new = $old + .01;
my $dir = shift || &#x0027;.&#x0027;;

system qq{grep -lr &#x0027;\Q$old\E&#x0027; $dir }
  . &#x0027;| grep -v \\.svn &#x0027;
  . &#x0027;| grep -v Changes &#x0027;
  . &#x0027;| grep -v META\\.yml &#x0027;
  . &quot;| xargs $^X -i -pe \&quot;&quot;
  . qq{print STDERR \\\$ARGV[0], \\\$/ unless \\\$::seen{\\\$ARGV[0]}++;}
  . qq{s/(\\\$VERSION\\s*=?\\s*&#x0027;?)\Q$old\E(&#x0027;?)/\\\${1}$new\\\$2/g&quot;};

__END__
</pre>

<p>Enjoy!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/increment_version.html">old layout</a>.</small></p>


