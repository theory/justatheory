--- 
date: 2006-10-02T20:58:56Z
slug: odd-test-failures
title: What's With These CPAN-Testers Failures?
aliases: [/computers/programming/perl/odd_test_failures.html]
tags: [Perl, CPAN, testing, mod_perl]
type: post
---

So I just learned about and subscribed to the [CPAN-Testers feed for my
modules]. There appear to be a number of odd failures. Take [this one]. It says,
“Can't locate Algorithm/Diff.pm,” despite the fact that I have properly
specified the requirement for `Text::Diff`, which itself properly requires
`Algorithm::Diff.`. Is this an instance of `CPAN.pm` or `CPANPLUS` not following
all prerequisites, or what?

Or take [this failure]. It says, “\[CP\_ERROR\] \[Mon Sep 5 09:32:08 2005\] No
such module 'mod\_perl' found on CPAN”. Yet [here it is]. Maybe the `CPANPLUS`
indexer has a bug? Or are people's configurations just horked? Or am I just
doing something braindead?

Opinions welcomed.

  [CPAN-Testers feed for my modules]: http://testers.cpan.org/author/DWHEELER.rss
    "My CPAN-Testers Feed"
  [this one]: http://nntp.x.perl.org/group/perl.cpan.testers/249132
    "FAIL Text-Diff-HTML-0.04 5.8.5 on freebsd 5.4-stable (i386-freebsd)"
  [this failure]: http://www.nntp.perl.org/group/perl.cpan.testers/240189
    "FAIL Apache-Dir-0.04 5.8.5 on solaris 2.9 (sun4-solaris-thread-multi)"
  [here it is]: http://search.cpan.org/~gozer/mod_perl-1.29/mod_perl.pod
    "mod_perl on CPAN"
