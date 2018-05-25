--- 
date: 2004-09-10T02:54:00Z
slug: mod_perl-escape-html-utf8
title: Apache::Util::escape_html() Doesn't Like Perl UTF-8 Strings
aliases: [/computers/programming/perl/mod_perl/escape_html_utf8.html]
tags: [mod_perl, Perl, UTF-8, Encode, Testing]
type: post
---

I got bit by a bug with [Apache::Util]'s `escape_html()` function in mod\_perl
1. It seems that it doesn't like Perl's Unicode encoded strings! This patch
demonstrates the issue (be sure that your editor understands utf-8):

    --- modperl/t/net/perl/util.pl.~1.18.~  Sun May 25 03:54:08 2003+++ modperl/t/net/perl/util.pl  Thu Sep  9 19:38:40 2004@@ -74,6 +74,25 @@  #print $esc_2; test ++$i, $esc eq $esc_2;++# Make sure that escape_html() understands multibyte characters.+my $utf8 = '<專輯>';+my $esc_utf8 = '<專輯>';+my $test_esc_utf8 = Apache::Util::escape_html($utf8);+test ++$i, $test_esc_utf8 eq $esc_utf8;+#print STDERR "Compare '$test_esc_utf8'\n     to '$esc_utf8'\n";++eval { require Encode };+unless ($@) {+    # Make sure escape_html() properly handles strings with Perl's+    # Unicode encoding.+    $utf8 = Encode::decode_utf8($utf8);+    $esc_utf8 = Encode::decode_utf8($esc_utf8);+    $test_esc_utf8 = Apache::Util::escape_html($utf8);+    test ++$i, $test_esc_utf8 eq $esc_utf8;+    #print STDERR "Compare '$test_esc_utf8'\n     to '$esc_utf8'\n";+}+ use Benchmark;  =pod

If I enable the print statements and look at the log, I see this:

    Compare '<專輯>'
         to '<專輯>'
    Compare '<å°è¼¯>'
         to '<專輯>'

The first escape appears to work correctly, but when I decode the string to
Perl's Unicode representation, you can see how badly `escape_html()` munges the
text!

Curiously, both tests fail, although the first conversion appears to be correct.
This could be due to the behavior of `eq`, though I'm not sure why. But it's the
second test that's the more interesting, since it really screws things up.

  [Apache::Util]: http://search.cpan.org/dist/mod_perl-1.29/Util/Util.pm
    "Apache::Util on CPAN"
