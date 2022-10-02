---
date: 2002-06-06T04:34:13Z
description: Now with improved error handling.
lastMod: 2022-10-02T22:39:29Z
slug: more-app-info
tags:
  - use Perl
  - Perl
  - App::Info
title: More App::Info
---

Yes, I put out a new version of [App::Info] today. Well, a couple of versions,
actually.

First of all, all the problems with the unit tests should be fixed. They
actually aren't all that comprehensive, but since the values returned form the
various methods can vary, it didn't make sense for them to be super precise. I
have internal unit tests that are more precise, and they don't execute when
folks download App::Info from the CPAN.

But the major change in version 0.10 is the addition of error levels. Now when
you construct an App::Info object, you can specify an error level that
corresponds to a Carp function. Subclass writers (currently just your truly)
then just have to use the `error()` method to record errors (although serious
problems should probably just `croak`. Client code can specify how it wants to
handle errors. The default is "carp", but the CPAN unit tests, for example, use
"silent".

This functionality makes App::Info much more customizable for creating
installation utilities, as the problems the subclasses run into -- such as not
being able to find a files they need, or not being able to parse a value from a
file -- can be set to be as verbose as necessary.

Next up, [Matt Seargent] suggests that I borrow from the AxKit `Makefile.PL ` to
make interrogating libiconv much more robust. Maybe in a couple of weeks. I've
been back-burnering work that I really need to get done in order to work on
this!

*Originally published [on use Perl;]*

  [App::Info]: http://search.cpan.org/search?dist=App-Info
  [Matt Seargent]: http://use.perl.org/user/matts/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/5453/
    "use.perl.org journal of Theory: “More App::Info”"
