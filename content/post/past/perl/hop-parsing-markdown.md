--- 
date: 2009-04-08T21:21:48Z
slug: hop-parsing-markdown
title: Issues Parsing Markdown with HOP::Parser
aliases: [/computers/programming/perl/hop-parsing-markdown.html]
tags: [Perl, parsing, HOP, Higher-Order Perl, HOP::Parser, Mark Jason Dominus]
type: post
---

Since I had [some][] [ideas] for features to add on to [Markdown], and since I
have been wanting to learn more about parsing, I picked up my copy of
[Higher-Order Perl] with the aim of writing a proper parser for Markdown. I've
made a decent start, with support for simple paragraphs, code spans, escapes,
and a few other things. Then I took on emphasis spans and ran smack into the
limits of the current implementation of [HOP::Parser].

It started out simply enough. I added this tokens to my lexer:

            [ EMOP => qr/[_]{1,2}|[*]{1,2}/ ],

The [Markdown syntax] calls for emphasized text to be bracketed one star or
underscore, and strong text to be bracketed by two stars or underscores. With
this simple “emphasis operator” token, I was able to write an emphasis parser
like this:

    my $joiner  = sub { join '', @_ };
    my $sstar   = absorb match EMOP => '*';
    my $suscore = absorb match EMOP => '_';
    my $not_em;
    my $Not_em = parser { $not_em->(@_) };

    my $emphasis = T(
        alternate(
            concatenate( $sstar,   $Not_em, $sstar   ),
            concatenate( $suscore, $Not_em, $suscore ),
        ),
        sub { "<em>$_[0]</em>" }
    );

    # omitted: definition of $strong;

    $not_em = T(plus( T( alternate(
        $text, $code, $strong
    ), $joiner, ) ), $joiner);

(The `plus()` parser is in [my fork of HOP::Parser on GitHub].) The parser for
`<strong>` is similar. And it works reasonably well for simple examples such as:

-   \*this\*
-   \_this\_
-   un\*frigging\*believable
-   un\_frigging\_believable
-   \*this\* and \*that\*
-   \*this\* and \_that\_

It even works when strong and emphasis are mixed:

-   “\*\*\*this\*\*\*” yields `<strong><em>this</em></strong>`
-   “\_\_\_this\_\_\_” yields `<strong><em>this</em></strong>`
-   “\*this \*\*and\*\* that\*” yields `<em>this <strong>and</strong> that</em>`
-   “\*this \_\_and\_\_ that\*” yields `<em>this <strong>and</strong> that</em>`

But then came the need to support properly parsing non-emphasizing instances of
the emphasis characters. For example, each of these should yield no emphasis:

-   \* not em \*
-   \_ not em \_

Instead, they should be parsed as literal stars and underscores. This is because
opening emphasis operators must be followed by a non-space character, and
closing ones must be preceded by a non-space character. So my first thought was
to use lookahead and lookbehind in the parser to find left and right emphasis
operators, like so:

            [ EMLOP => qr/(?<=[^\s_])[_]{1,2}|(?<=[^\s*])[*]{1,2}/ ],
            [ EMROP => qr/[_]{1,2}(?=[^\s_])|[*]{1,2}(?=[^\s*])/ ],

And then I changed the parser to this:

    my $lstar  = absorb match EMLOP => '*';
    my $rstar  = absorb match EMROP => '*';
    my $lscore = absorb match EMLOP => '_';
    my $rscore = absorb match EMROP => '_';

    my $emphasis = T(
        alternate(
            concatenate( $lstar,  $Not_em, $rstar  ),
            concatenate( $lscore, $Not_em, $rscore ),
        ),
        sub { "<em>$_[0]</em>" }
    );

Again, this works with the simple examples, but now I'm getting different
issues. For example, whereas “\_\_\*word\*\_\_” should be lexed as

    [
      ['EMLOP,   '__'  ],
      ['EMLOP',  '*'   ],
      ['STRING', 'this'],
      ['EMROP',  '*'   ],
      ['EMROP,   '__'  ],
    ]

But instead comes out as:

    [
      ['STRING', '__'  ],
      ['EMROP',  '*'   ],
      ['STRING', 'this'],
      ['EMROP',  '*'   ],
      ['STRING', '__'  ],
    ]

Note that it's not finding any left operators there! There are a number of
examples where the lexed tokens are just inadequate, leading to parse failures.

The whole problem with identifying the left and right emphasis operators is
where they are relative to whitespace or line boundaries. Even trickier,
however, is the mid-word emphasis, such as in “un\*frigging\*believable,” where,
to know whether an operator is left or right, you have to actually be tracking
whether or not a left one has been found. For example, if you find a star, it's
a rightop if a previously-found leftop star was found; otherwise it's a leftop.
So the issue is state, which of course the Lexer cannot track (once you capture
a token, it's gone; you can't do a lookbehind).

So I thought that the solution would be to start generating whitespace tokens.
It's likely I'd have to do this anyway, to deal with code blocks and lists,
though I had hoped to avoid it even then, since it means a *lot* more tokens and
a lot more work for the lexer. But I decided to give it a try. I changed the
relevant bits of the lexer to:

            [ SPACE => qr/[\t ]+/ ],
            [ EMOP  => qr/[_]{1,2}|[*]{1,2}/ ],

(I'm ignoring newlines because they're already handled elsewhere in the lexer.)
This at least makes the lexing much simpler, and there are no unexpected tokens.
With that, I went about trying to coerce the parser to properly deal with those
tokens:

    my $space     = match 'SPACE';
    my $neg_space = neg_lookahead $space;
    my $sstar     = absorb match EMOP => '*';
    my $suscore   = absorb match EMOP => '_';
    my $not_em;
    my $Not_em = parser { $not_em->(@_) };

    my $emphasis = T(
        alternate(
            concatenate( $sstar,   $neg_space, $Not_em, $sstar   ),
            concatenate( $suscore, $neg_space, $Not_em, $suscore ),
        ),
        sub { "<em>$_[0]</em>" }
    );

That `neg_lookahead()` parser-builder was my attempt to implement a negative
lookahead assertion. This is so that the left emphasis operator is only
identified as such if it is *not* followed by a space. It looks like this:

    sub neg_lookahead {
        my $p = ref $_[0] eq 'CODE' ? shift : lookfor @_;
        parser {
            my $input = shift or return;
            my @ret = eval { $p->($input) };
            return @ret ? () : (undef, $input);
        },
    }

I also had to change my `$text` parser, which is included in `$not_em`, to
recognize EMOP tokens and stringify them, since they can now sometimes be
ignored by the emphasis parser. Still, this doesn't quite get me where I want to
be. For example, “\*this\*” is not interpreted as having any emphasis at all.
The reason? because the `$not_em` parser now recognizes EMOP tokens, and it's a
greedy parser. So while the parser does fine the first star and the intervening
text, it fails to find the second star, because the `$not_em` parser has already
eaten it!

At this point, I'm pretty frustrated. I really want to get this right, but I'm
at the limits of both what I understand about parsing and, I think, the current
implementation of HOP::Parser (which has no way to turn off greediness, as far
as I know). At first I thought that adding backtracking as described in section
8.8 of [Chapter 8] might help, but I couldn't figure out how to add it to
HOP::Parser without fundamentally changing how the parser works. But then I
realized that it wouldn't be able to backtrack to find the last token eaten by
the `$text` parser anyway, so the issue is moot.

What I really need is some help better understanding how to think about parsing
stuff like this. It took me years to really understand regular expressions, so I
don't doubt that it will take me a long time to train my mind to think like a
parser, but hints and suggestions would be greatly appreciated!

If you're curious enough, the code, in progress, is [here].

  [some]: /computers/markup/modest-markdown-proposal.html
    "A Modest Proposal for Markdown Definition
    Lists"
  [ideas]: /computers/markup/markdown-table-rfc.html
    "RFC: A Simple Markdown Table Format"
  [Markdown]: http://daringfireball.net/projects/markdown/
  [Higher-Order Perl]: http://hop.perl.plover.com/
  [HOP::Parser]: http://search.cpan.org/perldoc?HOP::Parser
    "HOP::Parser on CPAN"
  [Markdown syntax]: http://daringfireball.net/projects/markdown/syntax/
  [my fork of HOP::Parser on GitHub]: http://github.com/theory/hop/tree/master
  [Chapter 8]: http://hop.perl.plover.com/book/mod/chap08.mod
    "HOP Chapter 8: Parsing"
  [here]: https://svn.kineticode.com/Text-Markover/trunk/
    "Text::Markover Repository"
