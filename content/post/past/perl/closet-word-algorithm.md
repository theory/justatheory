--- 
date: 2005-08-31T18:48:00Z
slug: closet-word-algorithm
title: Efficient Closest Word Algorithm
aliases: [/computers/programming/perl/closet_word_algorithm.html]
tags: [Perl, grep, Levenshtein, Perl Best Practices]
type: post
---

<figure class="left"><a href="https://www.amazon.com/exec/obidos/ASIN/0596001738/justatheory-20" title="Buy &#x201c;Perl Best Practices&#x201d; on Amazon.com"><img src="https://images-na.ssl-images-amazon.com/images/I/81Rh6gbV-ZL.jpg" alt="&#x201c;Perl Best Practices&#x201d; cover" /></a></figure>

<p>I've been reading <a href="https://www.amazon.com/exec/obidos/ASIN/0596001738/justatheory-20" title="Buy &#x201c;Perl Best Practices&#x201d; on Amazon.com">Perl Best Practices</a> and have been making use of <a href="http://search.cpan.org/dist/List-Util/" title="List::Util on CPAN">List::Util</a> and <a href="http://search.cpan.org/dist/List-MoreUtils/" title="List::MoreUtils on CPAN">List::MoreUtils</a> as a result. I'm amazed that I never knew about these modules before. I mean, I kinda knew there were there, but hadn't paid much attention before or bothered to find out how useful they are!</p>

<p>Anyway, a problem I'm currently working on is finding a word in a list of words that's the closest match to another word. <a href="http://search.cpan.org/dist/Text-Levenshtein/" title="Text::Levenshtein on CPAN">Text::Levenshtein</a> appears to be a good method to determine relative closeness, but try as I might, I couldn't make it work using <code>first</code> or <code>min</code> or <code>apply</code> or any of the utility list methods. I finally settled on this subroutine:</p>

<pre>
use Text::LevenshteinXS qw(distance);
sub _find_closest_word {
    my ($word, $closest) = (shift, shift);
    my $score = distance($word, $closest);
    for my $try_word (@_) {
        my $new_score = distance($word, $try_word);
        ($closest, $score) = ($try_word, $new_score)
            if $new_score &lt; $score;
    }
    return $closest;
}
</pre>

<p>Am I missing something, or is this really the most obvious and efficient way to do it?</p>
