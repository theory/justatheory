--- 
date: 2005-08-31T18:48:00Z
slug: perl-closest-word-algorithm
title: Efficient Closest Word Algorithm
aliases: [/computers/programming/perl/closet_word_algorithm.html]
tags: [Perl, grep, Levenshtein, Perl Best Practices]
type: post
image:
  src: pbp-cover.jpeg
  alt: “Perl Best Practices” cover
  title: Buy “Perl Best Practices” on Amazon.com
  class: left frame
  link: https://www.amazon.com/dp/0596001738/justatheory-20
---

I've been reading [Perl Best Practices] and have been making use of [List::Util]
and [List::MoreUtils] as a result. I'm amazed that I never knew about these
modules before. I mean, I kinda knew there were there, but hadn't paid much
attention before or bothered to find out how useful they are!

Anyway, a problem I'm currently working on is finding a word in a list of words
that's the closest match to another word. [Text::Levenshtein] appears to be a
good method to determine relative closeness, but try as I might, I couldn't make
it work using `first` or `min` or `apply` or any of the utility list methods. I
finally settled on this subroutine:

``` perl
  use Text::LevenshteinXS qw(distance);
  sub _find_closest_word {
      my ($word, $closest) = (shift, shift);
      my $score = distance($word, $closest);
      for my $try_word (@_) {
          my $new_score = distance($word, $try_word);
          ($closest, $score) = ($try_word, $new_score)
              if $new_score < $score;
      }
      return $closest;
  }
```

Am I missing something, or is this really the most obvious and efficient way to
do it?

  [Perl Best Practices]: https://www.amazon.com/exec/obidos/ASIN/0596001738/justatheory-20
    "Buy “Perl Best Practices” on Amazon.com"
  [List::Util]: http://search.cpan.org/dist/List-Util/ "List::Util on CPAN"
  [List::MoreUtils]: http://search.cpan.org/dist/List-MoreUtils/
    "List::MoreUtils on CPAN"
  [Text::Levenshtein]: http://search.cpan.org/dist/Text-Levenshtein/
    "Text::Levenshtein on CPAN"
