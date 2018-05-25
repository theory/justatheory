--- 
date: 2009-04-13T17:42:42Z
slug: hop-markdown-followup
title: HOP Markdown Followup
aliases: [/computers/programming/perl/hop-markdown-followup.html]
tags: [Perl, Parsing, HOP, Higher-Order Perl, HOP::Parser, Mark Jason Dominus]
type: post
---

Just to follow up on [my post] from last week, in which I was banging my head on
parsing, I had an insight over the weekend that helped me to solve the problem.
All I can say is, thank god I’ve written a lot of huge regular expressions in
the past, as that experience really helped me to thinking more like a parser. I
wanted to share that insight here.

The issue I had came down to an inability to parse both standalone emphasis
characters — that is, `_` or `*` with whitespace on both sides — and doubled-up
emphasis characters, such as `***`, `___`, `**_`, or `_**`, among a few others.
It seemed that I could handle one or the other issue, but not both.

The insight was that I could add more tokens to match doubled emphasis
characters before single emphasis characters. Then I could just process them
separately. So whereas I previously had

``` perl
    [ EMLOP => qr/(?<=[^\s_])[_]{1,2}|(?<=[^\s*])[*]{1,2}/ ],
    [ EMROP => qr/[_]{1,2}(?=[^\s_])|[*]{1,2}(?=[^\s*])/ ],
```

I now have a regular expression to match doubled-up emphasis operators:

``` perl
my $stem_re = qr{
        (?:[*]{2}|[_]{2})[*_]
    | [*_](?:[*]{2}|[_]{2})
}x;
```

And I use it like so:

``` perl
    [ STEMLOP => qr/$stem_re(?=[^\s_*])/ ],
    [ STEMROP => qr/(?<=[^\s_*])$stem_re/ ],

    [ EMLOP => qr/[_]{1,2}(?=[^\s*_])|[*]{1,2}(?=[^\s*_])/ ],
    [ EMROP => qr/(?<=[^\s*_])[_]{1,2}|(?<=[^\s*_])[*]{1,2}/ ],
```

Yes, I’m now also matching “middle” emphasis operators — that is, those with
non-whitespace on *both* sides. But now I’m able to get pretty much exactly what
I need with a rule like this:

``` perl
my $lstar = match EMLOP => '*';
my $rstar = match EMROP => '*';
my $lline = match EMLOP => '_';
my $rline = match EMROP => '_';
my $not_em;
my $Not_em = parser { $not_em->(@_) };

my $emphasis = T(
    alternate(
        concatenate( $lstar,  $Not_em, $rstar  ),
        concatenate( $lline,  $Not_em, $rline  ),
    ),
    sub { "<em>$_[1]</em>" }
);
```

Pretty much the same as before. But now I also have this rule, to deal with the
combined strong and emphasis tokens:

``` perl
my $lstem = match 'STEMLOP';
my $rstem = match 'STEMROP';
my $mstem = match 'STEMMOP';
my $not_stem;
my $Not_stem = parser { $not_stem->(@_) };

my $stem = T(
    concatenate(
        alternate($lstem, $mstem),
        $Not_stem,
        alternate($rstem, $mstem)
    ),
    sub {
        my @c = split //, shift;
        return $c[0] eq $c[1]
            ? "<strong><em>$_[1]</em></strong>"
            : "<em><strong>$_[1]</strong></em>";
    },
);
```

In truth, I ended up with something much more complicated than this, as it
needed to make sure that the operators were balanced (e.g., you can’t do it
`***like this___`), but the overall idea is the same. The emphasis, strong, and
strong/em parsers also handle mid-word markers, such as in
`un*frigging*believable`, that I’m not showing here. But the overall approach is
fundamentally the same: I was having a problem with two patterns getting in the
way of my parser, so I simply wrote a separate parser to handle one of those
patterns. Ultimately, all I had to do was break the problem down into smaller
parts and solve each part individually. It works pretty well.

As a side note, at one point I had the a lexer that used this code ref:

``` perl
my $stem_split = sub {
    my $l = shift;
    my @c = split //, shift;
    my $pos = substr($l, 4);
    return $c[0] eq $c[1]
        ? ( [ $l => "$c[0]$c[1]"], [ $l => $c[2]]         )
        : ( [ $l => $c[0] ],       [ $l => "$c[1]$c[2]" ] );
};
```

Those STEMOP rules then looked like so:

``` perl
    [ EMMOP => qr/(?<=[^\s_*])$stem_re(?=[^\s_*])/, $stem_split ],
    [ EMROP => qr/(?<=[^\s_*])$stem_re/, $stem_split ],
```

The cool thing about this was that I didn’t need a separate strong/emphasis
parser; these lexer rules were just returning the appropriate emphasis tokens,
and then I was able to just let the emphasis and strong parsers do their things.

But I ran into issues when I realized that it the left and right versions were
coming out the same, so for `***foo***`, rather than getting
`<strong><em>foo</em></strong>`, I was getting `<strong><em>foo</strong></em>`.
Oops. I could solve this by using different splitters for left and right, but
once I added the middle token, wherein there are no whitespace characters on
either side, it’s impossible to tell which token to return first. So I went back
to the separate strong/emphasis operators.

Another path I started down was separate tokens for strong and emphasis markers.
It looked something like this:

``` perl
    [ STLOP => qr/[_]{2}(?=[_]?\S)|[*]{2}(?=[*]?\S)/ ],
    [ STROP => qr/(?<=\S)[_]{2}|(?<=\S)[*]{2}/ ],
    [ EMLOP => qr/[_*](?=\S)/ ],
    [ EMROP => qr/(?<=\S)[_*]/ ],
```

With this approach, I thought I could match the strong and emphasis operators
separately in the lexer. But as I [described] on the HOP-discuss mail list, this
runs up to limitations of the lexer. For example, for these rules, the string
`_*foo*__` yields the proper tokens:

``` perl
[['STLOP','_'],['EMLOP','*'],'foo,['EMROP','*'],['STROP','_']];
```
But `*__foo__*` does not:

``` perl
['*',['STLOP','_'],'foo,['STLOP','_'],'*'];
```

The problem is that the lexer splits the string up into tokens and leftovers
after each rule is parsed. So after STLOP and STROP are parsed, the stream looks
like this:

``` perl
['*',['STLOP','_'],'foo,['STLOP','_'],'*'];
```

In other words, exactly the same. When EMLOP and EMROP are applied to ‘\*’,
there is no non-space character before or after it, so it’s left alone. But
clearly this is an invalid lexing.

So I had to once again go back to the more complicated solution of a separate
parser for combined span operators. For now. I’m hoping someone can come up with
a solution to make this lex better, because I’m going to be adding more span
operators, such as for code, deleted text, and added text, and it will very
quickly get complicated parsing for those combinations of characters. It’d be
much better if the lexer could see something like

    +**_`test *markdown*`_**+

And correctly give me:

``` perl
[
    [ ADDLOP => '+'                 ],
    [ STLOP  => '**'                ],
    [ EMLOP  => '_'                 ],
    [ CODE   => '`test *markdown*`' ],
    [ EMROP  => '_'                 ],
    [ STROP  => '**'                ],
    [ ADDROP => '+'                 ],
]
```

And then the parsing would be quite straight-forward. Because otherwise my
parser is just going to get more complex and harder to maintain.

  [my post]: /computers/programming/perl/hop-parsing-markdown.html
    "Issues Parsing Markdown with HOP::Parser"
  [described]: http://www.nabble.com/Limitation-of-the-Lexer-or-my-Brain-tt23024740.html
    "HOP-Discuss: “Limitation of the Lexer or my Brain?”"
