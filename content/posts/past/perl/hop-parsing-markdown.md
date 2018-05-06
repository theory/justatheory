--- 
date: 2009-04-08T21:21:48Z
slug: hop-parsing-markdown
title: Issues Parsing Markdown with HOP::Parser
aliases: [/computers/programming/perl/hop-parsing-markdown.html]
tags: [Perl, parsing, HOP, Higher-Order Perl, HOP::Parser, Mark Jason Dominus]
---

<p>Since I had <a href="/computers/markup/modest-markdown-proposal.html" title="A Modest Proposal for Markdown Definition
Lists">some</a> <a href="/computers/markup/markdown-table-rfc.html" title="RFC: A Simple Markdown Table Format">ideas</a> for features to add on
to <a href="http://daringfireball.net/projects/markdown/">Markdown</a>, and
since I have been wanting to learn more about parsing, I picked up my copy
of <a href="http://hop.perl.plover.com/">Higher-Order Perl</a> with the aim of
writing a proper parser for Markdown. I've made a decent start, with support
for simple paragraphs, code spans, escapes, and a few other things. Then I
took on emphasis spans and ran smack into the limits of the current implementation of
<a href="http://search.cpan.org/perldoc?HOP::Parser" title="HOP::Parser on CPAN">HOP::Parser</a>.</p>

<p>It started out simply enough. I added this tokens to my lexer:</p>

<pre>
        [ EMOP =&gt; qr/[_]{1,2}|[*]{1,2}/ ],
</pre>

<p>The <a href="http://daringfireball.net/projects/markdown/syntax/">Markdown syntax</a> calls for emphasized text to be bracketed one star or underscore,
and strong text to be bracketed by two stars or underscores. With this simple
“emphasis operator” token, I was able to write an emphasis parser like
this:</p>

<pre>
my $joiner  = sub { join &#x0027;&#x0027;, @_ };
my $sstar   = absorb match EMOP =&gt; &#x0027;*&#x0027;;
my $suscore = absorb match EMOP =&gt; &#x0027;_&#x0027;;
my $not_em;
my $Not_em = parser { $not_em-&gt;(@_) };

my $emphasis = T(
    alternate(
        concatenate( $sstar,   $Not_em, $sstar   ),
        concatenate( $suscore, $Not_em, $suscore ),
    ),
    sub { &quot;&lt;em&gt;$_[0]&lt;/em&gt;&quot; }
);

# omitted: definition of $strong;

$not_em = T(plus( T( alternate(
    $text, $code, $strong
), $joiner, ) ), $joiner);
</pre>

<p>(The <code>plus()</code> parser is
in <a href="http://github.com/theory/hop/tree/master">my fork of HOP::Parser on GitHub</a>.) The parser for <code>&lt;strong&gt;</code> is similar. And it
works reasonably well for simple examples such as:</p>

<ul>
  <li>*this*</li>
  <li>_this_</li>
  <li>un*frigging*believable</li>
  <li>un_frigging_believable</li>
  <li>*this* and *that*</li>
  <li>*this* and _that_</li>
</ul>

<p>It even works when strong and emphasis are mixed:</p>

<ul>
  <li>“***this***” yields <code>&lt;strong&gt;&lt;em&gt;this&lt;/em&gt;&lt;/strong&gt;</code></li>
  <li>“___this___” yields <code>&lt;strong&gt;&lt;em&gt;this&lt;/em&gt;&lt;/strong&gt;</code></li>
  <li>“*this **and** that*” yields <code>&lt;em&gt;this &lt;strong&gt;and&lt;/strong&gt; that&lt;/em&gt;</code></li>
  <li>“*this __and__ that*” yields <code>&lt;em&gt;this &lt;strong&gt;and&lt;/strong&gt; that&lt;/em&gt;</code></li>
</ul>

<p>But then came the need to support properly parsing non-emphasizing instances of the emphasis characters. For example, each of these should yield no emphasis:</p>

<ul>
  <li>* not em *</li>
  <li>_ not em _</li>
</ul>

<p>Instead, they should be parsed as literal stars and underscores. This is
because opening emphasis operators must be followed by a non-space character,
and closing ones must be preceded by a non-space character. So my first
thought was to use lookahead and lookbehind in the parser to find left and
right emphasis operators, like so:</p>

<pre>
        [ EMLOP =&gt; qr/(?&lt;=[^\s_])[_]{1,2}|(?&lt;=[^\s*])[*]{1,2}/ ],
        [ EMROP =&gt; qr/[_]{1,2}(?=[^\s_])|[*]{1,2}(?=[^\s*])/ ],
</pre>

<p>And then I changed the parser to this:</p>

<pre>
my $lstar  = absorb match EMLOP =&gt; &#x0027;*&#x0027;;
my $rstar  = absorb match EMROP =&gt; &#x0027;*&#x0027;;
my $lscore = absorb match EMLOP =&gt; &#x0027;_&#x0027;;
my $rscore = absorb match EMROP =&gt; &#x0027;_&#x0027;;

my $emphasis = T(
    alternate(
        concatenate( $lstar,  $Not_em, $rstar  ),
        concatenate( $lscore, $Not_em, $rscore ),
    ),
    sub { &quot;&lt;em&gt;$_[0]&lt;/em&gt;&quot; }
);
</pre>

<p>Again, this works with the simple examples, but now I'm getting different
issues. For example, whereas “__*word*__” should be lexed as</p>

<pre>
[
  [&#x0027;EMLOP,   &#x0027;__&#x0027;  ],
  [&#x0027;EMLOP&#x0027;,  &#x0027;*&#x0027;   ],
  [&#x0027;STRING&#x0027;, &#x0027;this&#x0027;],
  [&#x0027;EMROP&#x0027;,  &#x0027;*&#x0027;   ],
  [&#x0027;EMROP,   &#x0027;__&#x0027;  ],
]
</pre>

<p>But instead comes out as:</p>

<pre>
[
  [&#x0027;STRING&#x0027;, &#x0027;__&#x0027;  ],
  [&#x0027;EMROP&#x0027;,  &#x0027;*&#x0027;   ],
  [&#x0027;STRING&#x0027;, &#x0027;this&#x0027;],
  [&#x0027;EMROP&#x0027;,  &#x0027;*&#x0027;   ],
  [&#x0027;STRING&#x0027;, &#x0027;__&#x0027;  ],
]
</pre>

<p>Note that it's not finding any left operators there! There are a number of
examples where the lexed tokens are just inadequate, leading to parse
failures.</p>

<p>The whole problem with identifying the left and right emphasis operators is
where they are relative to whitespace or line boundaries. Even trickier,
however, is the mid-word emphasis, such as in “un*frigging*believable,” where,
to know whether an operator is left or right, you have to actually be tracking
whether or not a left one has been found. For example, if you find a star,
it's a rightop if a previously-found leftop star was found; otherwise it's a
leftop. So the issue is state, which of course the Lexer cannot track (once
you capture a token, it's gone; you can't do a lookbehind).</p>

<p>So I thought that the solution would be to start generating whitespace
tokens. It's likely I'd have to do this anyway, to deal with code blocks and
lists, though I had hoped to avoid it even then, since it means a <em>lot</em>
more tokens and a lot more work for the lexer. But I decided to give it a try.
I changed the relevant bits of the lexer to:</p>

<pre>
        [ SPACE =&gt; qr/[\t ]+/ ],
        [ EMOP  =&gt; qr/[_]{1,2}|[*]{1,2}/ ],
</pre>

<p>(I'm ignoring newlines because they're already handled elsewhere in the
lexer.) This at least makes the lexing much simpler, and there are no
unexpected tokens. With that, I went about trying to coerce the parser to
properly deal with those tokens:</p>

<pre>
my $space     = match &#x0027;SPACE&#x0027;;
my $neg_space = neg_lookahead $space;
my $sstar     = absorb match EMOP =&gt; &#x0027;*&#x0027;;
my $suscore   = absorb match EMOP =&gt; &#x0027;_&#x0027;;
my $not_em;
my $Not_em = parser { $not_em-&gt;(@_) };

my $emphasis = T(
    alternate(
        concatenate( $sstar,   $neg_space, $Not_em, $sstar   ),
        concatenate( $suscore, $neg_space, $Not_em, $suscore ),
    ),
    sub { &quot;&lt;em&gt;$_[0]&lt;/em&gt;&quot; }
);
</pre>

<p>That <code>neg_lookahead()</code> parser-builder was my attempt to
implement a negative lookahead assertion. This is so that the left emphasis
operator is only identified as such if it is <em>not</em> followed by
a space. It looks like this:</p>

<pre>
sub neg_lookahead {
    my $p = ref $_[0] eq &#x0027;CODE&#x0027; ? shift : lookfor @_;
    parser {
        my $input = shift or return;
        my @ret = eval { $p-&gt;($input) };
        return @ret ? () : (undef, $input);
    },
}
</pre>

<p>I also had to change my <code>$text</code> parser, which is included
in <code>$not_em</code>, to recognize EMOP tokens and stringify them, since
they can now sometimes be ignored by the emphasis parser. Still, this doesn't
quite get me where I want to be. For example, “*this*” is not interpreted as
having any emphasis at all. The reason? because the <code>$not_em</code>
parser now recognizes EMOP tokens, and it's a greedy parser. So while the
parser does fine the first star and the intervening text, it fails to find the
second star, because the <code>$not_em</code> parser has already eaten it!</p>

<p>At this point, I'm pretty frustrated. I really want to get this right, but
I'm at the limits of both what I understand about parsing and, I think, the
current implementation of HOP::Parser (which has no way to turn off
greediness, as far as I know). At first I thought that adding backtracking as
described in section 8.8
of <a href="http://hop.perl.plover.com/book/mod/chap08.mod" title="HOP Chapter 8: Parsing">Chapter 8</a> might help, but I couldn't figure out how to add it
to HOP::Parser without fundamentally changing how the parser works. But then I
realized that it wouldn't be able to backtrack to find the last token eaten by
the <code>$text</code> parser anyway, so the issue is moot.</p>

<p>What I really need is some help better understanding how to think about
parsing stuff like this. It took me years to really understand regular
expressions, so I don't doubt that it will take me a long time to train my
mind to think like a parser, but hints and suggestions would be greatly
appreciated!</p>

<p>If you're curious enough, the code, in progress,
is <a href="https://svn.kineticode.com/Text-Markover/trunk/" title="Text::Markover Repository">here</a>.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/hop-parsing-markdown.html">old layout</a>.</small></p>


