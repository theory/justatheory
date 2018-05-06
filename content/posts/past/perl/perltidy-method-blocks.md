--- 
date: 2006-01-12T19:29:07Z
slug: perltidy-method-blocks
title: How Do I Tweak Perltidy Method/Funtion-call blocks?
aliases: [/computers/programming/perl/perltidy_method_blocks.html]
tags: [Perl, Perltidy]
---

<p>Say I have some icky code like this:</p>

<pre>
my $process = Background->new($^X, &quot;-I$lib&quot;,
                              &quot;-MMyLong:Namespace::Bar::Bat&quot;,
                              &quot;-e 1&quot;, &quot;other&quot;, &quot;arguments&quot;, &quot;here&quot;);
</pre>

<p>Perltidy will turn it into this:</p>

<pre>
my $process = Background->new( $^X, &quot;-I$lib&quot;, &quot;-MMyLong:Namespace::Bar::Bat&quot;,
    &quot;-e 1&quot;, &quot;other&quot;, &quot;arguments&quot;, &quot;here&quot; );
</pre>

<p>That's a little better, but I'd much rather that it made it look like this:</p>

<pre>
my $process = Background->new(
    $^X,    &quot;-I$lib&quot;, &quot;-MMyLong:Namespace::Bar::Bat&quot;,
    &quot;-e 1&quot;, &quot;other&quot;,  &quot;arguments&quot;, &quot;here&quot;,
);
</pre>

<p>Or even this:</p>

<pre>
my $process = Background->new(
    $^X,
    &quot;-I$lib&quot;,
    &quot;-MMyLong:Namespace::Bar::Bat&quot;,
    &quot;-e 1&quot;,
    &quot;other&quot;,
    &quot;arguments&quot;,
    &quot;here&quot;,
);
</pre>

<p>Anyone know how to get it to do that? If so, please leave a comment!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/perltidy_method_blocks.html">old layout</a>.</small></p>


