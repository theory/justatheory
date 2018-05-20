--- 
date: 2006-04-06T23:08:12Z
slug: svnnotify-2.57
title: SVN::Notify 2.57 Supports Windows
aliases: [/computers/programming/perl/modules/svnnotify-2.57.html]
tags: [Perl, Subversion, SVN::Notify, Windows]
type: post
---

So I finally got 'round to porting [SVN::Notify] to Windows. Version 2.57 is
making is way to CPAN right now. The solution turned out to be dead simple: I
just had to use a different form of piping `open()` on Windows, i.e.,
`open FH, "$cmd|"` instead of `open FH, "-|"; exec($cmd);`. It's silly, really,
but it works. It really makes me wonder why `-|` and `|-` haven't been emulated
on Windows. Whatever.

'Course the other thing I realized, after I made this change and all the tests
pass, was that there is no equivalent of *sendmail* on Windows. So I added the
`--smtp` option, so that now email can be sent to an SMTP server rather than to
a local *sendmail*. I tested it out, and it seems to work, but I'd be especially
interested to hear from folks using wide characters in their repositories: do
they get printed properly to Net::SMTP's connection?

The whole list of changes in 2.57 (the output remains the same as in [2.56]):

-   Finally ported to Win32. It was actually a simple matter of changing how
    command pipes are created.
-   Added `--smtp` option to enable sending messages to an SMTP server rather
    than to the local *sendmail* application. This is essential for Windows
    support.
-   Added `--io-layer` to the usage statement in *svnnotify*.
-   Fixed single-dash arguments in documentation so that they're all documented
    with a single dash in SVN::Notify.

Enjoy!

  [SVN::Notify]: http://search.cpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
  [2.56]: http://www.justatheory.com/computers/programming/perl/modules/svnnotify-2.56_colordiff_example.html
    "Example output from SVN::Notify 2.56"
