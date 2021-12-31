--- 
date: 2009-12-15T23:06:27Z
slug: make-the-perl-pragmas-stop
title: Make the Pragmas Stop!
aliases: [/computers/programming/perl/make-the-pragmas-stop.html]
tags: [Perl, Unicode, Perl 5 Porters]
type: post
---

I've been following the development of a few things in the Perl community
lately, and it’s leaving me very frustrated. For years now, I've written modules
that start with the same incantation:

``` perl
package My::Module;

use strict;
our $VERSION = '0.01';
```

Pretty simple: declare the module name and version, and turn on strictures to
make sure I'm not doing anything stupid. More recently I've added
`use warnings;` as a [best practice]. And even more recently, I've started
adding `use utf8;`, too, because I like to write my code in UTF-8. And I like to
turn on all of the Perl 5.10 features. It’s mildly annoying to have the same
incantation at the start of every module, but I could deal with it:

``` perl
package My::Module;

use strict;
use warnings;
use feature ':5.10';
use utf8;

our $VERSION = '0.01';
```

Until now that is. Last year, [chromatic] started something with his
[Modern::Perl] module. It was a decent idea for newbies to help them get started
with Perl by having to have only one declaration at the tops of their modules:

``` perl
package My::Module;

use Modern::Perl;
our $VERSION = '0.01';
```

Alas, it wasn’t really designed for me, but for more casual users of Perl, so
that they don’t have to think about the pragmas they need to use. The fact that
it doesn’t include the `utf8` pragma also made it a non-starter for me. Or did
it? Someone recently suggested that the `utf8` pragma has problems (I can’t find
the Perl Monks thread at the moment). Others report that the [encoding pragma]
has issues, too. So what’s the right thing to do with regard to assuming
everything is UTF8 in my program and its inputs (unless I say otherwise)? I'm
not at all sure.

Not only that, but Modern::Perl has lead to an explosion of other pragma-like
modules on CPAN that promise best pragma practices. There’s [common::sense],
which loads `utf8` but only some of of the features of `strict`, `warnings`, and
`feature`. [uni::perl] looks almost exactly the same. There’s also Damian
Conwayâ€™s [Toolkit], which allows you to write your own pragma-like loader
module. There’s even [Acme::Very::Modern::Perl], which is meant to be a joke,
but is it really?

If I want to simplify the incantation at the top of every file, what do I use?

And now it’s getting worse. In addition to `feature`, Perl 5.11 introduces the
`legacy` pragma, which allows one to get back behaviors from older Perls. For
example, to get back the old Unicode semantics, you'd
`use legacy 'unicode8bit';`. I mean, WTF?

I've had it. Please make the pragma explosion stop! Make it so that the best
practices known at the time of the release of any given version of Perl can
automatically imported if I just write:

``` perl
package My::Module '0.01';
use 5.12;
```

That’s it. Nothing more. Whatever has been deemed the best practice at the time
5.12 is released will simply be used. If the best practices change in 5.14, I
can switch to `use 5.14;` and get them, or just leave it at `use 5.12` and keep
what was the best practices in 5.12 (yay future-proofing!).

What should the best practices be? My list would include:

-   `strict`
-   `warnings`
-   `features` — all of them
-   `UTF-8` — all input and output to the scope, as well as the source code

Maybe you disagree with that list. Maybe I'd disagree with what Perl 5 Porters
settles on. But then you can I can read what’s included and just add or removed
pragmas as necessary. But surely there’s a core list of likely candidates that
should be included the vast majority of the time, including for all novices.

In personal communication, chromatic tells me, with regard to Modern::Perl,
â€œExperienced Perl programmers know the right incantations to get the behavior
they want. Novices don’t, and I think we can provide them much better defaults
without several lines of incantations.â€? I'm fine with the second assertion,
but disagree with the first. I've been hacking Perl for almost 15 years, and I
no longer have any fucking idea what incantation is best to use in my modules.
Do help the novices, and make the power tools available to experienced hackers,
but please make life easier for the experienced hackers, too.

I think that declaring the semantics of a particular version of Perl is where
the Perl 5 Porters are headed. I just hope that includes handling all of the
likely pragmas too, so that I don’t have to.

  [best practice]: http://oreilly.com/catalog/9780596001735
    "“Perl Best Practices” by Master Damian Conway, Esq."
  [chromatic]: http://www.modernperlbooks.com/ "Modern Perl Books"
  [Modern::Perl]: https://metacpan.org/pod/Modern::Perl
    "Modern::Perl on CPAN"
  [encoding pragma]: https://metacpan.org/pod/encoding
    "encoding pragma on CPAN"
  [common::sense]: https://metacpan.org/pod/common::sense
    "common::sense on CPAN"
  [uni::perl]: https://metacpan.org/pod/uni::perl "uni::perl on CPAN"
  [Toolkit]: https://metacpan.org/pod/Toolkit "Toolkit on CPAN"
  [Acme::Very::Modern::Perl]: https://metacpan.org/pod/Acme::Very::Modern::Perl
    "Acme::Very::Modern::Perl on CPAN"
