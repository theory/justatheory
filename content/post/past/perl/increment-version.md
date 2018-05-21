--- 
date: 2004-12-14T22:03:00Z
slug: increment-perl-module-version
title: How I Increment Module Version Numbers
aliases: [/computers/programming/perl/increment_version.html]
tags: [Perl, Versions, CPAN, shipping]
type: post
---

Here's how I quickly increment version numbers in my modules. I call this script
*reversion*:

``` perl
#!/usr/bin/perl -w

use strict;

unless (@ARGV) {
    print "  Usage: $0 version\n\n";
    exit;
}

my $old = shift;
my $new = $old + .01;
my $dir = shift || '.';

system qq{grep -lr '\Q$old\E' $dir }
  . '| grep -v \\.svn '
  . '| grep -v Changes '
  . '| grep -v META\\.yml '
  . "| xargs $^X -i -pe \""
  . qq{print STDERR \\\$ARGV[0], \\\$/ unless \\\$::seen{\\\$ARGV[0]}++;}
  . qq{s/(\\\$VERSION\\s*=?\\s*'?)\Q$old\E('?)/\\\${1}$new\\\$2/g"};

__END__
```

Enjoy!
