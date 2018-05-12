--- 
date: 2004-09-10T02:54:00Z
slug: escape-html-utf8
title: Apache::Util::escape_html() Doesn't Like Perl UTF-8 Strings
aliases: [/computers/programming/perl/mod_perl/escape_html_utf8.html]
tags: [mod_perl, Perl, UTF-8, Encode, testing]
type: post
---

<p>I got bit by a bug with <a href="http://search.cpan.org/dist/mod_perl-1.29/Util/Util.pm" title="Apache::Util on CPAN">Apache::Util</a>'s <code>escape_html()</code> function in mod_perl 1. It seems that it doesn't like Perl's Unicode encoded strings! This patch demonstrates the issue (be sure that your editor understands utf-8):</p>

<pre>
--- modperl/t/net/perl/util.pl.~1.18.~	Sun May 25 03:54:08 2003+++ modperl/t/net/perl/util.pl	Thu Sep  9 19:38:40 2004@@ -74,6 +74,25 @@  #print $esc_2; test ++$i, $esc eq $esc_2;++# Make sure that escape_html() understands multibyte characters.+my $utf8 = &#x0027;&lt;專輯&gt;&#x0027;;+my $esc_utf8 = &#x0027;&lt;專輯&gt;&#x0027;;+my $test_esc_utf8 = Apache::Util::escape_html($utf8);+test ++$i, $test_esc_utf8 eq $esc_utf8;+#print STDERR "Compare &#x0027;$test_esc_utf8&#x0027;\n     to &#x0027;$esc_utf8&#x0027;\n";++eval { require Encode };+unless ($@) {+    # Make sure escape_html() properly handles strings with Perl&#x0027;s+    # Unicode encoding.+    $utf8 = Encode::decode_utf8($utf8);+    $esc_utf8 = Encode::decode_utf8($esc_utf8);+    $test_esc_utf8 = Apache::Util::escape_html($utf8);+    test ++$i, $test_esc_utf8 eq $esc_utf8;+    #print STDERR "Compare &#x0027;$test_esc_utf8&#x0027;\n     to &#x0027;$esc_utf8&#x0027;\n";+}+ use Benchmark;  =pod
</pre>

<p>If I enable the print statements and look at the log, I see this:</p>

<pre>
Compare '&lt;專輯&gt;'
     to '&lt;專輯&gt;'
Compare '&lt;å°è¼¯&gt;'
     to '&lt;專輯&gt;'
</pre>

<p>The first escape appears to work correctly, but when I decode the string to Perl's Unicode representation, you can see how badly <code>escape_html()</code> munges the text!</p>

<p>Curiously, both tests fail, although the first conversion appears to be correct. This could be due to the behavior of <code>eq</code>, though I'm not sure why. But it's the second test that's the more interesting, since it really screws things up.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/mod_perl/escape_html_utf8.html">old layout</a>.</small></p>


