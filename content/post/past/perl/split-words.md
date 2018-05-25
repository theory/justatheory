--- 
date: 2005-09-07T19:40:34Z
slug: perl-split-words
title: Splitting Words in Perl
aliases: [/computers/programming/perl/split_words.html]
tags: [Perl, Unicode, Regular Expressions, Pattern Matching]
type: post
---

I've created a new module, [Text::WordDiff], now on its way to CPAN, to show the
differences between two documents using words as tokens, rather than lines as
[Text::Diff] does. I plan to use it in Bricolage to give people a change
tracking-type view (as seen in word processors) comparing two versions of a
document. Fortunately, [Algorithm::Diff] makes this extremely easy to do. My
only real problem was figuring out how to tokenize a string into words

After looking at discussions in [*The Perl Cookbook*] and [*Mastering Regular
Expressions*], I settled on using Friedl's pattern for identifying the starting
boundary of words, which is `qr/(?<!\w)(?=\w)/msx`. This pattern will turn the
string, “this is O'Reilly's string” into the following tokens:

``` perl
[
    q{this },
    q{is },
    q{O'},
    q{Reilly'},
    q{s },
    q{string},
];
```

So it's imperfect, but it works well enough for me. I'm thinking of using the
Unicode character class for words, instead, at least for more recent versions of
Perl that understand them (5.8.0 and later?). That would be
`/(?<!\p{IsWord})(?=\p{IsWord})/msx`. The results using that regular expression
are the same.

But otherwise, I'm not sure whether or not this is the best approach. I think
that it's good enough for the general cases I have, and the matching of words in
and of themselves is not that important. What I mean is that, as long as most
tokens are words, it's okay with me if some, such as “O'”, “Reilly'”, and “s” in
the above example, are not words. What I don't know is how well it'll work for
non-Roman glyphs, such as in Japanese or Korean text. I tried a test on a Korean
string I have lying around (borrowed from the Encode.pm test suite), but it
didn't split it up at all (with `use utf8;`).

So what do you think? Does [Text::WordDiff] work for your text? Is there a
better and more general solution for tokenizing the words in a string?

  [Text::WordDiff]: http://search.cpan.org/dist/Text-WordDiff/
    "Text::WordDiff on CPAN"
  [Text::Diff]: http://search.cpan.org/dist/Text-Diff/ "Text::Diff on CPAN"
  [Algorithm::Diff]: http://search.cpan.org/dist/Algorithm-Diff/
    "Algorithm::Diff on CPAN"
  [*The Perl Cookbook*]: https://www.amazon.com/exec/obidos/ASIN/0596003137/justatheory-20
    "Buy “The Perl Cookbook” on Amazon.com"
  [*Mastering Regular Expressions*]: https://www.amazon.com/exec/obidos/ASIN/0596002890/justatheory-20
    "Buy “Mastering Regular Expressions” on Amazon.com"
