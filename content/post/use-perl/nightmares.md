---
date: 2002-11-22T05:20:11Z
description: Dreaming in C considered hazardous.
lastMod: 2022-10-02T22:39:29Z
slug: nightmares
tags:
  - use Perl
  - Perl
  - C Programming
title: Nightmares
---

So last week, I decided it was finally time to put an end to my years-long
mental block and learn some C. Because I'm a crazy bastard, I decided to do so
by writing a new DBI driver for PostgreSQL. The existing PostgreSQL driver,
DBD::Pg, is a mess, and since it would be harder for me to just jump in and
start patching, I decided to follow the instructions in [DBI::DBD] and start
cutting and pasting a brand new driver.

It's been a great experience for me so far, mostly because of the [tremendous
support] I've received from the denizens of the dbi-dev mail list. If it wasn't
for the great answers that so many of them have taken the time to write, I would
be getting more sleep at night, but wouldn't be learning half as much, either!

Speaking of not sleeping, I was in Florida for a business meeting for one night
on Tuesday, and I sat up late with Comedy Central on, studying the sources for
DBD::ODBC, DBD::mysql, and DBD::Oracle, trying to wrap my brain around the
peculiarities of C and XS programming. I was completely absorbed in what I was
doing, and thinking a lot about how to parse SQL strings in C. I finally went to
bed around 3 am (it was only midnight my time, after all), but lay awake for
another hour, parsing SQL character arrays, moving pointers around, trying to
identify comments and literals. When I did sleep, I dreamed in C.

*What a nightmare.*

Now, when I was first *really* learning Perl, and working very intently in it
for hours and days at a time, trying to grok what I was seeing, it was a
wondrous path of discovery. Perl is such a rewarding language to learn; it
thinks like I think. I even had a few dreams in Perl. Its expressiveness was
enjoyable in my dreams. I could communicate in Perl.

Not so with C. In my C dreams, things were rigid and structured, and didn't
always seem so consistent. I was just parsing, parsing, parsing character arrays
all night, and desperately needing a good regex to do the job for me. Needless
to say, I didn't sleep well.

I'm going to continue working on my new PostgreSQL driver. I want to make it a
top-notch DBI driver implementation. It's going to take me a few months, but I
look forward to the rewards. But, I think, I shan't be working on it quite so
intensely just before turning in late at night any more, especially on those
nights when I have to get up in only three hours.

*Originally published [on use Perl;]*

  [DBI::DBD]: http://search.cpan.org/author/TIMB/DBI/lib/DBI/DBD.pm
  [tremendous support]: http://archive.develooper.com/dbi-dev@perl.org/msg01731.html
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/9074/
    "use.perl.org journal of Theory: “Nightmares”"
