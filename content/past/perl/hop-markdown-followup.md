--- 
date: 2009-04-13T17:42:42Z
slug: hop-markdown-followup
title: HOP Markdown Followup
aliases: [/computers/programming/perl/hop-markdown-followup.html]
tags: [Perl, parsing, HOP, Higher-Order Perl, HOP::Parser, Mark Jason Dominus]
type: post
---

<p>Just to follow up on <a href="/computers/programming/perl/hop-parsing-markdown.html" title="Issues Parsing Markdown with HOP::Parser">my post</a> from last week, in which I was banging my
head on parsing, I had an insight over the weekend that helped me to solve the
problem. All I can say is, thank god I’ve written a lot of huge regular
expressions in the past, as that experience really helped me to thinking more
like a parser. I wanted to share that insight here.</p>

<p>The issue I had came down to an inability to parse both standalone emphasis
characters — that is, <code>_</code> or <code>*</code> with whitespace on both sides — and
doubled-up emphasis characters, such as <code>***</code>, <code>___</code>, <code>**_</code>, or <code>_**</code>, among a
few others. It seemed that I could handle one or the other issue, but not
both.</p>

<p>The insight was that I could add more tokens to match doubled emphasis
characters before single emphasis characters. Then I could just process them
separately. So whereas I previously had</p>

<pre><code>    [ EMLOP =&gt; qr/(?&lt;=[^\s_])[_]{1,2}|(?&lt;=[^\s*])[*]{1,2}/ ],
    [ EMROP =&gt; qr/[_]{1,2}(?=[^\s_])|[*]{1,2}(?=[^\s*])/ ],
</code></pre>

<p>I now have a regular expression to match doubled-up emphasis operators:</p>

<pre><code>my $stem_re = qr{
      (?:[*]{2}|[_]{2})[*_]
    | [*_](?:[*]{2}|[_]{2})
}x;
</code></pre>

<p>And I use it like so:</p>

<pre><code>    [ STEMLOP =&gt; qr/$stem_re(?=[^\s_*])/ ],
    [ STEMROP =&gt; qr/(?&lt;=[^\s_*])$stem_re/ ],

    [ EMLOP =&gt; qr/[_]{1,2}(?=[^\s*_])|[*]{1,2}(?=[^\s*_])/ ],
    [ EMROP =&gt; qr/(?&lt;=[^\s*_])[_]{1,2}|(?&lt;=[^\s*_])[*]{1,2}/ ],
</code></pre>

<p>Yes, I’m now also matching “middle” emphasis operators — that is, those with
non-whitespace on <em>both</em> sides. But now I’m able to get pretty much exactly
what I need with a rule like this:</p>

<pre><code>my $lstar = match EMLOP =&gt; &#x0027;*&#x0027;;
my $rstar = match EMROP =&gt; &#x0027;*&#x0027;;
my $lline = match EMLOP =&gt; &#x0027;_&#x0027;;
my $rline = match EMROP =&gt; &#x0027;_&#x0027;;
my $not_em;
my $Not_em = parser { $not_em-&gt;(@_) };

my $emphasis = T(
    alternate(
        concatenate( $lstar,  $Not_em, $rstar  ),
        concatenate( $lline,  $Not_em, $rline  ),
    ),
    sub { &quot;&lt;em&gt;$_[1]&lt;/em&gt;&quot; }
);
</code></pre>

<p>Pretty much the same as before. But now I also have this rule, to deal with
the combined strong and emphasis tokens:</p>

<pre><code>my $lstem = match &#x0027;STEMLOP&#x0027;;
my $rstem = match &#x0027;STEMROP&#x0027;;
my $mstem = match &#x0027;STEMMOP&#x0027;;
my $not_stem;
my $Not_stem = parser { $not_stem-&gt;(@_) };

my $stem = T(
    concatenate(
        alternate($lstem, $mstem),
        $Not_stem,
        alternate($rstem, $mstem)
    ),
    sub {
        my @c = split //, shift;
        return $c[0] eq $c[1]
            ? &quot;&lt;strong&gt;&lt;em&gt;$_[1]&lt;/em&gt;&lt;/strong&gt;&quot;
            : &quot;&lt;em&gt;&lt;strong&gt;$_[1]&lt;/strong&gt;&lt;/em&gt;&quot;;
    },
);
</code></pre>

<p>In truth, I ended up with something much more complicated than this, as it
needed to make sure that the operators were balanced (e.g., you can’t do it
<code>***like this___</code>), but the overall idea is the same. The emphasis, strong,
and strong/em parsers also handle mid-word markers, such as in
<code>un*frigging*believable</code>, that I’m not showing here. But the overall approach
is fundamentally the same: I was having a problem with two patterns getting in
the way of my parser, so I simply wrote a separate parser to handle one of
those patterns. Ultimately, all I had to do was break the problem down into
smaller parts and solve each part individually. It works pretty well.</p>

<p>As a side note, at one point I had the a lexer that used this code ref:</p>

<pre><code>my $stem_split = sub {
    my $l = shift;
    my @c = split //, shift;
    my $pos = substr($l, 4);
    return $c[0] eq $c[1]
        ? ( [ $l =&gt; &quot;$c[0]$c[1]&quot;], [ $l =&gt; $c[2]]         )
        : ( [ $l =&gt; $c[0] ],       [ $l =&gt; &quot;$c[1]$c[2]&quot; ] );
};
</code></pre>

<p>Those STEMOP rules then looked like so:</p>

<pre><code>    [ EMMOP =&gt; qr/(?&lt;=[^\s_*])$stem_re(?=[^\s_*])/, $stem_split ],
    [ EMROP =&gt; qr/(?&lt;=[^\s_*])$stem_re/, $stem_split ],
</code></pre>

<p>The cool thing about this was that I didn’t need a separate strong/emphasis
parser; these lexer rules were just returning the appropriate emphasis tokens,
and then I was able to just let the emphasis and strong parsers do their
things.</p>

<p>But I ran into issues when I realized that it the left and right versions were
coming out the same, so for <code>***foo***</code>, rather than getting
<code>&lt;strong&gt;&lt;em&gt;foo&lt;/em&gt;&lt;/strong&gt;</code>, I was getting <code>&lt;strong&gt;&lt;em&gt;foo&lt;/strong&gt;&lt;/em&gt;</code>.
Oops. I could solve this by using different splitters for left and right, but
once I added the middle token, wherein there are no whitespace characters on
either side, it’s impossible to tell which token to return first. So I went
back to the separate strong/emphasis operators.</p>

<p>Another path I started down was separate tokens for strong and emphasis
markers. It looked something like this:</p>

<pre><code>    [ STLOP =&gt; qr/[_]{2}(?=[_]?\S)|[*]{2}(?=[*]?\S)/ ],
    [ STROP =&gt; qr/(?&lt;=\S)[_]{2}|(?&lt;=\S)[*]{2}/ ],
    [ EMLOP =&gt; qr/[_*](?=\S)/ ],
    [ EMROP =&gt; qr/(?&lt;=\S)[_*]/ ],
</code></pre>

<p>With this approach, I thought I could match the strong and emphasis operators
separately in the lexer. But as I <a href="http://www.nabble.com/Limitation-of-the-Lexer-or-my-Brain-tt23024740.html" title="HOP-Discuss: “Limitation of the Lexer or my Brain?”">described</a> on the HOP-discuss mail list,
this runs up to limitations of the lexer. For example, for these rules, the
string <code>_*foo*__</code> yields the proper tokens:</p>

<pre><code>[[&#x0027;STLOP&#x0027;,&#x0027;_&#x0027;],[&#x0027;EMLOP&#x0027;,&#x0027;*&#x0027;],&#x0027;foo,[&#x0027;EMROP&#x0027;,&#x0027;*&#x0027;],[&#x0027;STROP&#x0027;,&#x0027;_&#x0027;]];
</code></pre>

<p>But <code>*__foo__*</code> does not:</p>

<pre><code>[&#x0027;*&#x0027;,[&#x0027;STLOP&#x0027;,&#x0027;_&#x0027;],&#x0027;foo,[&#x0027;STLOP&#x0027;,&#x0027;_&#x0027;],&#x0027;*&#x0027;];
</code></pre>

<p>The problem is that the lexer splits the string up into tokens and leftovers
after each rule is parsed. So after STLOP and STROP are parsed, the stream
looks like this:</p>

<pre><code> [&#x0027;*&#x0027;,[&#x0027;STLOP&#x0027;,&#x0027;_&#x0027;],&#x0027;foo,[&#x0027;STLOP&#x0027;,&#x0027;_&#x0027;],&#x0027;*&#x0027;];
</code></pre>

<p>In other words, exactly the same. When EMLOP and EMROP are applied to &lsquo;*’,
there is no non-space character before or after it, so it’s left alone. But
clearly this is an invalid lexing.</p>

<p>So I had to once again go back to the more complicated solution of a separate
parser for combined span operators. For now. I’m hoping someone can come up
with a solution to make this lex better, because I’m going to be adding more
span operators, such as for code, deleted text, and added text, and it will
very quickly get complicated parsing for those combinations of characters.
It’d be much better if the lexer could see something like</p>

<pre><code>+**_`test *markdown*`_**+
</code></pre>

<p>And correctly give me:</p>

<pre><code>[
    [ ADDLOP =&gt; &#x0027;+&#x0027;                 ],
    [ STLOP  =&gt; &#x0027;**&#x0027;                ],
    [ EMLOP  =&gt; &#x0027;_&#x0027;                 ],
    [ CODE   =&gt; &#x0027;`test *markdown*`&#x0027; ],
    [ EMROP  =&gt; &#x0027;_&#x0027;                 ],
    [ STROP  =&gt; &#x0027;**&#x0027;                ],
    [ ADDROP =&gt; &#x0027;+&#x0027;                 ],
]
</code></pre>

<p>And then the parsing would be quite straight-forward. Because otherwise my
parser is just going to get more complex and harder to maintain.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/hop-markdown-followup.html">old layout</a>.</small></p>


