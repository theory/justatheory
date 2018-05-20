--- 
date: 2006-01-12T19:29:07Z
slug: perltidy-method-blocks
title: How Do I Tweak Perltidy Method/Funtion-call blocks?
aliases: [/computers/programming/perl/perltidy_method_blocks.html]
tags: [Perl, Perltidy]
type: post
---

Say I have some icky code like this:

    my $process = Background->new($^X, "-I$lib",
                                  "-MMyLong:Namespace::Bar::Bat",
                                  "-e 1", "other", "arguments", "here");

Perltidy will turn it into this:

    my $process = Background->new( $^X, "-I$lib", "-MMyLong:Namespace::Bar::Bat",
        "-e 1", "other", "arguments", "here" );

That's a little better, but I'd much rather that it made it look like this:

    my $process = Background->new(
        $^X,    "-I$lib", "-MMyLong:Namespace::Bar::Bat",
        "-e 1", "other",  "arguments", "here",
    );

Or even this:

    my $process = Background->new(
        $^X,
        "-I$lib",
        "-MMyLong:Namespace::Bar::Bat",
        "-e 1",
        "other",
        "arguments",
        "here",
    );

Anyone know how to get it to do that? If so, please leave a comment!
