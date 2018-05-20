--- 
date: 2006-04-18T18:32:14Z
slug: subclass-in-shell
title: "Hack: Force DBI::Shell to use a DBI Subclass"
aliases: [/computers/programming/perl/dbi/subclass_in_shell.html]
tags: [Perl, DBI, DBI::Shell]
type: post
---

So I just had a need to use DBI::Shell with a subclass of the DBI. It doesn't
support subclasses directly (it'd be nice to be able to specify one on the
command-line or something), but I was able to hack it into using one anyway by
doing this:

    use My::DBI;
    BEGIN {
        sub DBI::Shell::Base::DBI () { 'My::DBI' };
    }
    use DBI::Shell;

Yes, it's extremely sneaky. DBI::Shell::Base uses the string constant `DBI`, as
in `DBI->connect(...)`, so by shoving a constant into DBI::Shell::Base before
loading DBI::Shell, I convince it to use my subclass, instead.
