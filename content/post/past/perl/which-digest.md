--- 
date: 2005-12-24T01:35:11Z
slug: which-digest
title: Which Digest Should I Use?
aliases: [/computers/programming/perl/which_digest.html]
tags: [Perl, MD5, Whirpool, Haval256, passwords, hashing, algorithms]
type: post
---

With the recent [release of MD5 collision code], I'm reading that it's long
since time that MD5 was dropped from applications. But it seems that SHA-1 isn't
well-thought of anymore, either. So what should Perl programmers use now,
instead? [Digest::Whirlpool]? [Digest::SHA2]? [Digest::Tiger]?
[Digest::Haval256]? A combination of these? Something else? I mainly used MD5
for hashing passwords. What's the best choice for that use? For other uses?

  [release of MD5 collision code]: http://it.slashdot.org/article.pl?sid=05/11/15/2037232
  [Digest::Whirlpool]: http://search.cpan.org/dist/Digest-Whirlpool/
  [Digest::SHA2]: http://search.cpan.org/dist/Digest-SHA1/
  [Digest::Tiger]: http://search.cpan.org/dist/Digest-Tiger/
  [Digest::Haval256]: http://search.cpan.org/dist/Digest-Haval256/
