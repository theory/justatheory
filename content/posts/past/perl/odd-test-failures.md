--- 
date: 2006-10-02T20:58:56Z
slug: odd-test-failures
title: What's With These CPAN-Testers Failures?
aliases: [/computers/programming/perl/odd_test_failures.html]
tags: [Perl, CPAN, testing, mod_perl]
---

<p>So I just learned about and subscribed to
the <a href="http://testers.cpan.org/author/DWHEELER.rss" title="My CPAN-Testers Feed">CPAN-Testers feed for my modules</a>. There appear to be a
number of odd failures.
Take <a href="http://nntp.x.perl.org/group/perl.cpan.testers/249132" title="FAIL Text-Diff-HTML-0.04 5.8.5 on freebsd 5.4-stable (i386-freebsd)">this one</a>. It says, <q>Can't locate Algorithm/Diff.pm,</q>
despite the fact that I have properly specified the requirement
for <code>Text::Diff</code>, which itself properly
requires <code>Algorithm::Diff.</code>. Is this an instance
of <code>CPAN.pm</code> or <code>CPANPLUS</code> not following all
prerequisites, or what?</p>

<p>Or take <a href="http://www.nntp.perl.org/group/perl.cpan.testers/240189" title="FAIL Apache-Dir-0.04 5.8.5 on solaris 2.9 (sun4-solaris-thread-multi)">this failure</a>. It says, <q>[CP_ERROR] [Mon Sep
5 09:32:08 2005] No such module 'mod_perl' found on CPAN</q>.
Yet <a href="http://search.cpan.org/~gozer/mod_perl-1.29/mod_perl.pod" title="mod_perl on CPAN">here it is</a>. Maybe the <code>CPANPLUS</code>
indexer has a bug? Or are people's configurations just horked? Or am I just
doing something braindead?</p>

<p>Opinions welcomed.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/odd_test_failures.html">old layout</a>.</small></p>


