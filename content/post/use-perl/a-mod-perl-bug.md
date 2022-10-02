---
date: 2002-02-05T04:14:32Z
description: The Location directive appears to be broken in `<Perl>` sections.
lastMod: 2022-10-02T22:39:29Z
slug: a-mod-perl-bug
tags:
  - use Perl
  - Perl
title: A mod_perl Bug?
---

I think I've found a bug in the `<Perl>` sections of mod_perl. More information
can be found [here]. The upshot is that the `Location` directive, when used in
`<Perl>` sections, seems to be used internally as a `LocationMatch` directive
instead.

I ran into this because I was simplifying Bricolage's Apache configuration. I
moved the whole complex Apache configuration into a Bricolage module, so that
it's much simpler to configure Apache to run Bricolage --- and much easier to
use virtual hosts. (This is all in Bricolage's CVS, BTW --- it's not yet
released). I got around the problem by specifying all of my `Location`
directives with a caret (`^`) prepended to them so that they behave like a regex
version of `Location` (i.e., `LocationMatch`), but I'm kinda annoyed to have to
do that. Am I right in thinking that the `LocationMatch` directives add a bit
more overhead to every request?

*Originally published [on use Perl;]*

  [here]: http://mathforum.org/epigone/modperl/rorphaltwin/1012618588.7040.34.camel@mercury.kineticode.com
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/2658/
    "use.perl.org journal of Theory: “A mod_perl Bug?”"
