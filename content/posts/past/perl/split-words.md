--- 
date: 2005-09-07T19:40:34Z
slug: split-words
title: Splitting Words in Perl
aliases: [/computers/programming/perl/split_words.html]
tags: [Perl, Unicode, Regular Expressions, pattern matching]
---

<p>I've created a new module, <a href="http://search.cpan.org/dist/Text-WordDiff/" title="Text::WordDiff on CPAN">Text::WordDiff</a>, now on its way to CPAN, to show the differences between two documents using words as tokens, rather than lines as <a href="http://search.cpan.org/dist/Text-Diff/" title="Text::Diff on CPAN">Text::Diff</a> does. I plan to use it in Bricolage to give people a change tracking-type view (as seen in word processors) comparing two versions of a document. Fortunately, <a href="http://search.cpan.org/dist/Algorithm-Diff/" title="Algorithm::Diff on CPAN">Algorithm::Diff</a> makes this extremely easy to do. My only real problem was figuring out how to tokenize a string into words</p>

<p>After looking at discussions in <a href="https://www.amazon.com/exec/obidos/ASIN/0596003137/justatheory-20" title="Buy &#x201c;The Perl Cookbook&#x201d; on Amazon.com"><cite>The Perl Cookbook</cite></a> and <a href="https://www.amazon.com/exec/obidos/ASIN/0596002890/justatheory-20" title="Buy &#x201c;Mastering Regular Expressions&#x201d; on Amazon.com"><cite>Mastering Regular Expressions</cite></a>, I settled on using Friedl's pattern for identifying the starting boundary of words, which is <code>qr/(?&lt;!\w)(?=\w)/msx</code>. This pattern will turn the string, <q>this is O&#x0027;Reilly&#x0027;s string</q> into the following tokens:</p>

<pre>
[
    q{this },
    q{is },
    q{O&#x0027;},
    q{Reilly&#x0027;},
    q{s },
    q{string},
];
</pre>

<p>So it's imperfect, but it works well enough for me. I'm thinking of using the Unicode character class for words, instead, at least for more recent versions of Perl that understand them (5.8.0 and later?). That would be <code>/(?&lt;!\p{IsWord})(?=\p{IsWord})/msx</code>. The results using that regular expression are the same.</p>

<p>But otherwise, I'm not sure whether or not this is the best approach. I think that it's good enough for the general cases I have, and the matching of words in and of themselves is not that important. What I mean is that, as long as most tokens are words, it's okay with me if some, such as <q>O&#x0027;</q>, <q>Reilly&#x0027;</q>, and <q>s </q> in the above example, are not words. What I don't know is how well it'll work for non-Roman glyphs, such as in Japanese or Korean text. I tried a test on a Korean string I have lying around (borrowed from the Encode.pm test suite), but it didn't split it up at all (with <code>use utf8;</code>).</p>

<p>So what do you think? Does <a href="http://search.cpan.org/dist/Text-WordDiff/" title="Text::WordDiff on CPAN">Text::WordDiff</a> work for your text? Is there a better and more general solution for tokenizing the words in a string?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/split_words.html">old layout</a>.</small></p>


