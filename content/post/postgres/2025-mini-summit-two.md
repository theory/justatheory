---
title: 2025 Postgres Extensions Mini Summit Two
slug: mini-summit-two
date: 2025-04-01T19:32:52Z
lastMod: 2025-04-01T19:32:52Z
description: |
  A transcript of from the second PostgreSQL Extension Mini Summit,
  "Implementing an Extension Search Path", by Peter Eisentraut.
tags: [Postgres, Extensions, PGConf, Summit, Peter Eisentraut, Transcript]
type: post
image:
image:
  src: /shared/extension-ecosystem-summit/search-path-card.jpeg
  link: https://www.youtube.com/watch?v=xtnt06zhONk
  title: "PostgresSQL Extension Mini Summit: Implementing an Extension Search Patch"
  alt: |
    Orange card with large black text reading "Implementing an Extension Search
    Patch". Smaller text below reads "Peter Eisentraut, EDB" and "03.26.2025". A
    photo of Peter speaking into a mic at a conference appears on the right.
---

Last Wednesday, March 26, we hosted the second of five virtual [Extension
Mini-Summits][mini-summit] in the lead up to [*the big one*][summit] at the
Postgres Development Conference ([PGConf.dev]) on May 13 in Montréal, Canada.
[Peter Eisentraut] gave a very nice presentation on the history, design
decisions, and problems solved by "Implementing an Extension Search Path".
That talk, plus another 10-15m of discussion, is now available for your
viewing pleasure:

*   [Video](https://www.youtube.com/watch?v=xtnt06zhONk)
*   [Slides]({{% link "/shared/extension-ecosystem-summit/implementing-an-extension-search-path.pdf" %}})

If you'd like to attend any of the next three Mini-Summits, join [the
Meetup][mini-summit]!

Once again, with many thanks again to [Floor Drees] for the effort, here's the
transcript from the session.

## Introduction

Floor Drees introduced the organizers:

*   [David Wheeler], Principal Architect at [Tembo], maintainer of [PGXN]
*   [Yurii Rashkovskii], [Omnigres]
*   [Keith Fiske], [Crunchy Data]
*   [Floor Drees], Principal Program Manager at [EDB], PostgreSQL CoCC member,
    PGDay Lowlands organizer

[Peter Eisentraut], contributor to PostgreSQL development since 1999, talked
about implementing an extension search path.

The stream and the closed captions available for the recording are supported
by PGConf.dev and their gold level [sponsors], Google, AWS, Huawei, Microsoft,
and EDB.

## Implementing an extension search path

Peter: Thank you for having me!

I'm gonna talk about a current project by me and a couple of people I have
worked with, and that will hopefully ship with Postgres 18 in a few months.

So, what do I know about extensions? I'm a Postgres core developer, but I've
developed a few extensions in my time, here's a list of extensions that I've
built over the years.

*   [plsh](https://github.com/petere/plsh)
*   [pguint](https://github.com/petere/pguint)
*   [pgpcre](https://github.com/petere/pgpcre)
*   [pguri](https://github.com/petere/pguri)
*   [plxslt](https://github.com/petere/plxslt)
*   [pgemailaddr](https://github.com/petere/pgemailaddr)
*   [pgtrashcan](https://github.com/petere/pgtrashcan)

Some of those are experiments, or sort of one-offs. Some of those are actually
used in production.

I've also contributed to well-known extensions: [orafce]; and back in the day,
[pglogical], [BDR], and [pg_failover_slots], at [EDB], and previously
2ndQuadrant. Those are obviously used widely and in important production
environments.

I also wrote an extension installation manager called [pex] at one point. The
point of pex was to do it in one shell script, so you don't have any
dependencies. It's just a shell script, and you can say `pex install orafce`
and it installs it. This was a proof of concept, in a sense, but was actually
quite useful sometimes for development, when you just need an extension and
you don't know where to get it.

And then I wrote, even more experimental, a follow-on project called
[autopex], which is a plugin module that you load into Postgres that
automatically installs an extension if you need it. If you call `CREATE
EXTENSION orafce`, for example, and you don't have it installed, autopex
downloads and installs it. Obviously highly insecure and dubious in terms of
modern software distribution practice, but  it does work: you can just run
`CREATE EXTENSION`, and it just installs it if you don't have it. That kind of
works.

So anyways, so I've worked on these various aspects of these over time. If
you're interested in any of these projects, they're all under my [GitHub
account].

In the context of this presentation...this was essentially not my idea. People
came to me and asked me to work on this, and as it worked out, multiple people
came to me with their problems or questions, and then it turned out it was all
the same question. These are the problems I was approached about.

The first one is *extension management in the Kubernetes environment.* we'll
hear about this in a [future talk] in this series. [Gabriele Bartolini] from
the [CloudNativePG] project approached me and said that the issue in a
Kubernetes environment is that if you launch a Postgres service, you don't
install packages, you have a pre-baked disk image that contains the software
that you need. There's a Postgres server and maybe some backup software in
that image, and if you want to install an extension, and the extension is not
in that image, you need to rebuild the image with the extension. That's very
inconvenient.

The ideal scenario would be that you have additional disk images for the
extensions and you just somehow attach them. I'm hand waving through the
Kubernetes terminology, and again, there will be [a presentation][future talk]
about that in more detail. But I think the idea is clear: you want to have
these immutable disk images that contain your pieces of software, and if you
want to install more of them, you just wanna have these disk images augment
'em together, and that doesn't work at the moment.

Problem number two is: I was approached by a maintainer of the [Postgres.app]
project, a Mac binary distribution for Postgres. It's a nice, user-friendly
binary distribution for Postgres. This is sort of a similar problem: on macOS
you have these `.app` files to distribute software. They're this sort of weird
hybrid between a zip file with files in it and a directory you can look into,
so it's kind of weird. But it's basically an archive with software in it. And
in this case it has Postgres in it and it integrates nicely into your system.
But again, if you want to install an extension, that doesn't work as easily,
because you would need to open up that archive and stick the extension in
there somehow, or overwrite files.

And there's also a tie in with the way these packages are signed by Apple, and
if you, mess with the files in the package, then the signature becomes
invalid. It's the way it's been explained to me. I hope this was approximately
accurate, but you already get the idea, right? There's the same problem where
you have this base bundle of software that is immutable or that you want to
keep immutable and you want to add things to it, which doesn't work.

And then the third problem I was asked to solve came from the Debian package
maintainer, who will also [speak later] in this presentation series. What he
wanted to do was to run the tests of an extension while the package is being
built. That makes sense. You wanna run the tests of the software that you're
building the package for in general. But in order to do that, you have to
install the extension into the the normal file system location, right? That
seems bad. You don't want to install the software while you're into the main
system while you're building it. He actually wrote a custom patch to be able
to do that, which then my work was inspired by.

Those are the problems I was approached about.

I had some problems I wanted to solve myself based on my experience working
with extensions. While I was working on these various extensions over the
years, one thing that never worked is that you could never run `make check`.
It wasn't supported by the PGXS build system. Again, it's the same issue.

It's essentially a subset of the Debian problem: you want to run a test of the
software before you install it, but Postgres can only load an extension from a
fixed location, and so this doesn't work. It's very annoying because it makes
the software development cycle much more complicated. You always have to then,
then run `make all`, `make install`, make sure you have a server running,
`make installcheck`. And then you would want to test it against various
different server versions. Usually they have to run this in some weird loop.
I've written custom scripts and stuff all around this, but it's was never
satisfactory. It should just work.

That's the problem I definitely wanted to solve. The next problem  --- and
these are are all subsets of each other --- that if you have Postgres
installed from a package, like an RPM package for example, and then you build
the extension locally, you have to install the extension into the directory
locations that are controlled by your operating system. If you have Postgres
under `/usr`, then the extensions also have to be installed under `/usr`,
whereas you probably want to install them under `/usr/local` or somewhere
else. You want to keep those locally built things separately, but that's not
possible.

And finally --- this is a bit more complicated to explain --- I'm mainly using
macOS at the moment, and the [Homebrew] package manager is widely used there.
But it doesn't support extensions very well at all. It's really weird because
the way it works is that each package is essentially installed into a separate
subdirectory, and then it's all symlinked together. And that works just fine.
You have a bunch of `bin` directories, and it's just a bunch of symlinks to
different subdirectories and that works, because then you can just swap these
things out and upgrade packages quite easily. That's just a design choice and
it's fine.

But again, if you wanna install an extension, the extension would be its own
package --- PostGIS, for example --- and it would go into its own directory.
But that's not the directory where Postgres would look for it. You would have
to install it into the directory structure that belongs to the other package.
And that just doesn't work. It's just does not fit with that system at all.
There are weird hacks at the moment, but it's not satisfactory. Doesn't work
at all.

It turned out, all of these things have sort of came up over the years and
some of these, people have approached me about them, and I realized these are
essentially all the same problem. The extension file location is hard-coded to
be inside the Postgres installation tree. Here as an example: it's usually
under something like `/usr/share/postgresql/extension/`, and you can't install
extensions anywhere else. If you want to  keep this location managed by the
operating system or managed by your package management or in some kind of
immutable disk image, you can't. And so these are essentially all versions of
the same problem. So that's why I got engaged and tried to find a solution
that addresses all of 'em.

I had worked on this already before, a long time ago, and then someone broke
it along the way. And now I'm fixing it again. If you go way, way back, before
extensions as such existed in Postgres in 9.1, when you wanted to install a
piece of software that consists of a shared library object and some SQL, you
had to install the shared library object into a predetermined location just
like you do now. In addition, you had to run that SQL file by hand, basically,
like you run `psql -f install_orafce.sql` or something like that. Extensions
made that a little nicer, but it's the same idea underneath.

In 2001, I realized this problem already and implemented a configuration
setting called `dynamic_library_path`, which allows you to set a different
location for your shared library. Then you can say

``` ini
dynamic_library_path = '/usr/local/my-stuff/something'
```

And then Postgres would look there. The SQL file just knows where is
because you run it manually. You would then run

```sh
psql -f /usr/local/my-stuff/something/something.sql
```

That fixed that problem at the time. And when extensions were implemented, I
was essentially not paying attention or, you know, nobody was paying
attention. Extension support were a really super nice feature, of course, but
it broke this previously-available feature: then you couldn't install your
extensions anywhere you wanted to; you were tied to this specific file system,
location, `dynamic_library_path` still existed: you could still set it
somewhere, but you couldn't really make much use of it. I mean, you could make
use of it for things that are not extensions. If you have some kind of plugin
module or modules that install hooks, you could still do that. But not for an
extension that consist of a set of SQL scripts and a control file and
`dynamic_library_path`.

As I was being approached about these things, I realized that was just the
problem and we should just now fix that. The recent history went as follows.

In April, 2024, just about a year ago now, David Wheeler started [a hackers
thread] suggesting [Christoph Berg]'s Debian patch as a starting point for
discussions. Like, "here's this thing, shouldn't we do something about this?"

There was, a fair amount of discussion. I was not really involved at the time.
This was just after feature freeze,and so I wasn't paying much attention to
it. But the discussion was quite lively and a lot of people pitched in and
had their ideas and thoughts about it. And so a lot of important, filtering
work was done at that time.

Later, in September, [Gabriele][Gabriele Bartolini], my colleague from EDB who
works on [CloudNativePG], approached me about this issue and said like: "hey,
this is important, we need this to make extensions useful in the Kubernetes
environment." And he said, "can you work, can you work on this?"

I said, "yeah, sure, in a couple months I might have time." [Laughs]. But it
sort of turns out that, at [PGConf.EU] we had a big brain trust meeting of
various people who basically all came and said, "hey, I heard you're working
on `extension_control_path`, I also need that!"

[Gabriele][Gabriele Bartolini] was there, and [Tobias Bussmann] from
[Postgres.app] was there ,and [Christoph][Christoph Berg], and I was like,
yeah, I really need this `extension_control_path` to make this work. So I made
sure to talk to everybody there and, and make sure that, if we did this, would
it work for you? And then we kind of had a good idea of how it should work.

In November the first patch was posted and last week it was [committed][the commit]. I
think there's still a little bit of discussion of some details and, we
certainly still have some time before the release to fine tune it, but the
main work is hopefully done.

This is [the commit] I made last week. The fact that this presentation was
scheduled gave me additional motivation to get it done. I wanna give some
credits to people who reviewed it. Obviously David did a lot of reviews and
feedback in general. My colleague Matheus, who I think I saw him earlier, he
was also here on the call, did help me quite a bit with sort of finishing the
patch. And then Gabriele, Marco and Nicolò, who work on [CloudNativePG], did a
large amount of testing.

They set up a whole sort of sandbox environment making test images for
extensions and, simulating the entire process of attaching these to the main
image. Again, I'm butchering the terminology, but I'm just trying to explain
it in general terms. They did the whole end-to-end testing of what that would
then look like with [CloudNativePG]. And again, that will, I assume, be
discussed when Gabriele [presents][future talk] in a few weeks.

These are the stats from the patch

```
commit 4f7f7b03758

doc/src/sgml/config.sgml                                     |  68 +++++
doc/src/sgml/extend.sgml                                     |  19 +-
doc/src/sgml/ref/create_extension.sgml                       |   6 +-
src/Makefile.global.in                                       |  19 +-
src/backend/commands/extension.c                             | 403 +++++++++++++++++----------
src/backend/utils/fmgr/dfmgr.c                               |  77 +++--
src/backend/utils/misc/guc_tables.c                          |  13 +
src/backend/utils/misc/postgresql.conf.sample                |   1 +
src/include/commands/extension.h                             |   2 +
src/include/fmgr.h                                           |   3 +
src/test/modules/test_extensions/Makefile                    |   1 +
src/test/modules/test_extensions/meson.build                 |   5 +
.../modules/test_extensions/t/001_extension_control_path.pl  |  80 ++++++
```

the reason I show this is that, it's not big! What I did is use the same
infrastructure and mechanisms that already existed for the
`dynamic_library_path`. That's the code in that's in `dfmgr` there in the
middle. That's where this little path search is implemented9. And then of
course, in `extension..c` there's some code that's basically just a bunch of
utility functions, like to list all the extensions and list all the versions
of all the extensions. Those utility functions exist and they needed to be
updated to do the path search. Everything else is pretty straightforward.
There's just a few configuration settings added to the documentation and the
sample files and so on. It's not that much really.

One thing we also did was add tests for this, Down there in `test_extensions`.
We wrote some tests to make sure this works. Well, it's one thing to make sure
it works, but the other thing is if we wanna make changes or we find problems
with it, or we wanna develop this further in the future, we have a record of
how it works, which is why you write tests. I just wanted to point that out
because we didn't really have that before and it was quite helpful to build
confidence that we know how this works.

So how does it work? Let's say you have your Postgres installation in a
standard Linux file system package controlled location. None of the actual
packages look like this, I believe, but it's a good example. You have your
stuff under the `/usr/bin/`, you have the shared libraries in the
`/usr/lib/something`, you have the extension control files and SQL files in
the `/usr/share/` or something. That's your base installation. And then you
wanna install your extension into some other place to keep these things
separate. So you have `/usr/local/mystuff/`, for example.

Another thing that this patch implemented is that you can now also do this:
when you build an extension, you can write `make install prefix=something`.
Before you couldn't do that, but there was also no point because if you
installed it somewhere else, you couldn't do anything with it there. Now you
can load it from somewhere else, but you can also install it there --- which
obviously are the two important sides of that.

And then you set these two settings: `dynamic_library_path` is an existing
configuration setting, yYou set that to where your lib directory is, and then
the `extension_control_path` is a new setting. The titular setting of this
talk, where you tell it where your extension control files are.

There's these placeholders, `$libdir` and `$system` which mean the system
location, and then the other locations are your other locations, and it's
separated by colon (and semi-colon on Windows). We had some arguments about
what exactly the `extension_control_path` placeholder should be called and,
people continue to have different opinions. What it does is it looks in the
list directories for the control file, and then where it finds the control
file from there, it loads all the other files.

And there's a fairly complicated mechanism. There's obviously the actual SQL
files, but there's also these auxiliary control files, which I didn't even
know that existed. So you can have version specific control files. It's a
fairly complicated system, so we wanted to be clear  that what is happening is
the, the main control file  is searched for in these directories, and then
wherever it's found, that's where it looks for the other things. You can't
have the control file in one path and then the SQL files in another part of
the path; that's not how it works.

That solves problem number five. Let's see what problem number five was. I
forgot [Chuckles]. This is the basic problem, that you no longer have to
install the extensions in the directories that are ostensibly controlled by
the operating system or your package manager.

So then how would Debian packaging use this? I got this information from
[Christoph][Christoph Berg]. He figured out how to do this. He just said, "Oh,
I did this, and that's how it works." During packaging, the packaging scripts
that built it up in packages that you just pass these:

```sh
PKGARGS="--pgoption extension_control_path=$PWD/debian/$PACKAGE/usr/share/postgresql/$v/extension:\$system
--pgoption dynamic_library_path=$PWD/debian/$PACKAGE/usr/lib/postgresql/$v/lib:/usr/lib/postgresql/$v/lib"
```

These options set the control path and the `dynamic_library_path` and these
versions and then it works. This was confirmed that this addresses his
problem. He no longer has to carry his custom patch. This solves problem
number three.

The question people ask is, "why do we have two?" Or maybe you've asked
yourself that. Why do we need two settings. We have the
`dynamic_library_path`, we have the `extension_control_path`. Isn't that kind
of the same thing? Kind of, yes! But in general, it is not guaranteed that
these two things are in a in a fixed relative location.

Let's go back to our fake example. We have the libraries in
`/usr/lib/postgresql` and the SQL and control files in
`/usr/share/postgresql`, for example. Now you could say, why don't we just set
it to `/usr`? Or, for example, why don't we just set the path to
`/usr/local/mystuff` and it should figure out the sub directories. That would
be nice, but it doesn't quite work in general because it's not guaranteed that
those are the subdirectories. There could be, for example. `lib64`, for
example, right? Or some other so architecture-specific subdirectory names. Or
people can just name them whatever they want. So, this may be marginal, but it
is possible. You need to keep in mind that the subdirectory structure is not
necessarily fixed.

So we need two settings. The way I thought about this, if you compile C code,
you also have two settings. And if you think about it, it's exactly the same
thing. When you compile C code, you always have to do `-I` and `-L`: `I` for
the include files, `L` for the  lib files. This is basically the same thing.
The include file is also the text file that describes the interfaces and the
libraries are the libraries. Again, you need two options, because you can't
just tell the compiler, oh, look for it in `/usr/local` because the
subdirectories could be different. There could be architecture specific lib
directories. That's a common case. You need those two settings. Usually they
go in parallel. If somebody has a plan on how to do it simpler, follow up
patches are welcome.

But the main point of why this approach was taken is also to get it done in a
few months. I started thinking about this, or I was contacted about this in
September and I started thinking about it seriously in the October/November
timeframe. That's quite late in the development cycle to start a feature like
this, which I thought would be more controversial! People haven't really
complained that this breaks the security of extensions or anything like that.
I was a little bit afraid of that.

So I wanted to really base it on an existing facility that we already had, and
that's why I wanted to make sure it works exactly in parallel to the other
path that we already have, and that has existed for a long time, and was
designed for this exact purpose. That was also the reason why we chose this
path of least resistance, perhaps.

This is the solution progress for the six problems that I described initially.
The [CloudNativePG] folks obviously have accompanied this project actively and
have already prototyped the integration solution. And, and presumably we will
hear about some of that at the [meeting on May 7th][future talk], where
Gabriele will talk about this.

[Postgres.app] I haven't been in touch with, but one of the maintainers is
here, maybe you can give feedback later. Debian is done as I described, and
they will also be at [the next meeting][speak later], maybe there will be some
comment on that.

One thing that's not fully implemented is the the `make check` issue. I did
send a follow-up patch about that, which was a really quick prototype hack,
and people really liked it. I'm slightly tempted to give it a push and try to
get it into Postgres 18. This is a work in progress, but it's, there's sort of
a way forward. The local install problem I said is done.

[Homebrew], I haven't looked into. It's more complicated, and I'm also not
very closely involved in the development of that. I'll just be an outsider
maybe sending patches or suggestions at some point, maybe when the release is
closer and, and we've settled everything.

I have some random other thoughts here. I'm not actively working on these
right now, but I have worked on it in the past and I plan to work on it again.
Basically the conversion of all the building to [Meson] is on my mind, and
other people's mind.

Right now we have two build systems: the `make` build system and the [Meson]
build system, and all the production packages, as far as I know, are built
with `make`. Eventually we wanna move all of that over to Meson, but we want
to test all the extensions and if it still works. As far as I know, it does
work; there's nothing that really needs to be implemented, but we need to go
through all the extensions and test them.

Secondly --- this is optional; I'm not saying this is a requirement --- but
you may wish to also build your own extensions with Meson. But that's in my
mind, not a requirement. You can also use `cmake` or do whatever you want. But
there's been some prototypes of that. Solutions exist if you're interested.

And to facilitate the second point, there's been the proposal --- which I
think was well received, but it just needs to be fully implemented --- to
provide a `pkg-config` file to build against the server, and `cmake` and Meson
would work very well with that. Then you can just say  here's a `pkg-config`
file to build against the server. It's much easier than setting all the
directories yourself or extracting them from [`pg_config`]. Maybe that's
something coming for the next release cycle.

That's what I had. So `extension_control_path` is coming in Postgres 18. What
you can do is test and validate that against your use cases and and help
integration into the downstream users. Again, if you're sort of a package or
anything like that, you know, you can make use of that. That is all for me.

Thank you!

## Questions, comments

-   Reading the comments where several audience members suggested Peter
    follows Conference Driven Development he confirmed that that's definitely
    a thing.

-   Someone asked for the "requirements gathering document". Peter said that
    that's just a big word for "just some notes I have". "It's not like an
    actual document. I called it the requirements gathering. That sounds very
    formal, but it's just chatting to various people and someone at the next
    table overheard us talking and it's like, 'Hey! I need that too!'"

-   Christoph: I tried to get this fixed or implemented or something at least
    once over the last 10 something-ish years, and was basically shot down on
    grounds of security issues if people mess up their system. And what
    happens if you set the extension path to something, install an extension,
    and then set the path to something else and then you can't upgrade. And
    all sorts of weird things that people can do with their system in order to
    break them. Thanks for ignoring all that bullshit and just getting it
    done! It's an administrator-level setting and people can do whatever they
    want with it.

    So what I then did is just to implement that patch and, admittedly I never
    got around to even try to put it upstream. So thanks David for pushing
    that ahead. It was clear that the Debian version of the patch wasn't
    acceptable because it was too limited. It made some assumptions about the
    direct restructure of Debian packages. So it always included the prefix in
    the path. The feature that Peter implemented solves my problem. It does
    solve a lot of more problems, so thanks for that.

-   Peter: Testing all extensions. What we've talked about is doing this
    through the Debian packaging system because the idea was to maybe make a
    separate branch or a separate sub-repository of some sort, switch it to
    build Meson, and rebuild all the extension packages and see what happens.
    I guess that's how far we've come. I doesn't actually mean they all work,
    but I guess that most of them has tests, so we just wanted to test, see
    if it works.

    There are some really subtle problems. Well, the ones I know of have been
    fixed, but there's some things that certain compilation options are not
    substituted into the `Makefile`s correctly, so then all your extensions
    are built without any optimizations, for example, without any `-O`
    options. I'm not really sure how to detect those automatically, but at
    least, just rebuild everything once might be an option. Or just do it
    manually. There are not thousands of extensions. There are not even
    hundreds that are relevant. There are several dozens, and I think that's
    good coverage.

-   Christoph: I realize that doing it on the packaging side makes sense
    because we all have these tests running. So I was looking into it. The
    first time I tried, I stopped once I realized that Meson doesn't support
    LLVM yet; and the second time I tried, I just `diff`-ed the generated
    `Makefile`s to see if there's any difference that looks suspicious. At
    thus point I should just continue and do compilation run and see what the
    tests are doing and and stuff.

    So my hope would be that I could run `diff` on the results; the problem is
    compiling with Postgres with Autoconf once and then with Meson the second
    time, then see if it has an impact on the extensions compiled. But my idea
    was that if I'm just running `diff` on the two compilations and there's no
    difference, there's no point in testing because they're identical anyway.

-   Peter Oooh, you want the actual compilation, for the `Makefile` output to
    be the same.

-   Christoph: Yeah. I don't have to run that test, But the `diff` was a bit
    too big to be readable. There was lots of white space noise in there. But
    there were also some actual changes. Some were not really bad, like9 in
    some points variables were using a fully qualified path for the `make`
    directory or something, and then some points not; but, maybe we can just
    work on making that difference smaller and then arguing about correctness
    is easier.

-   Peter: Yeah, that sounds like a good approach.

-   Jakob: Maybe I can give some feedback from [Postgres.app]. So, thank you
    very much. I think this solves a lot of problems that we have had with
    extensions over the years, especially because it allows us to separate the
    extensions and the main Postgres distribution. For Postgres.app we
    basically have to decide which extensions to include and we can't offer
    additional extensions when people ask for them without shipping them for
    everyone. So that's a big win.

    One question I am wondering about is the use case of people building their
    own extensions. As far as I understand, you have to provide the prefix/
    And one thing I'm wondering whether there is there some way to give a
    default value for the prefix. Like in [`pg_config`] or in something like
    that, so people who just type `make install` automatically get some path.

-   Peter: That might be an interesting follow on. I'm making a note of it.
    I'm not sure how you'd...

-   Jakob: I'm just thinking because a big problem is that a lot of people who
    try things don't follow the instructions for the specific Postgres. So for
    example, if we write documentation how to build extensions and people on a
    completely different system --- like people Google stuff and they get
    instruction --- they'll just try random paths. Right now, if you just
    type `make install`, it works on most systems because it just builds into
    the standard directories.

-   Peter: Yeah, David puts it like, "should there be a different default
    extension location?" I think that's probably not an unreasonable
    direction. I think that's something we should maybe think about, once this
    is stabilized. I think for your [Postgres.app] use case, it, I think you
    could probably even implement that yourself with a one or two line patch
    so that at least, if you install Postgres.app, then somebody tries to
    build an extension, they get a reasonable location.

-   David: If I could jump in there, Jakob, my assumption was that
    [Postgres.app] would do something like designate the `Application Support`
    directory and `Preferences` in `~/Library` as where extensions should be
    installed. And yeah, there could be some patch to PGXS to put stuff there
    by default.

-   Jakob: Yeah, that would be nice!

-   Peter: Robert asked a big question here. What do we think the security
    consequences of this patch? Well, one of the premises is that we already
    have `dynamic_library_path`, which works exactly the same way, and there
    haven't been any concerns about that. Well, maybe there have been
    concerns, but nothing that was acted on. If you set the path to somewhere
    where anybody can write stuff, then yeah, that's not so good. But that's
    the same as anything. Certainly there were concerns as I read through the
    discussion.

    I assumed *somebody* would hav security questions, so I really wanted to
    base it on this existing mechanism and not invent something completely
    new. So far nobody has objected to it [Chuckles]. But yeah, of course you
    can make a mess of it if you go into that `extension_control_path = /tmp`!
    That's probably not good. But don't do that.

-   David: That's I think in part the [xz exploit] kind of made people more
    receptive to this patch because we want to reduce the number of patches
    that packaging maintainers have to maintain.

-   Peter: Obviously this is something people do. Better we have one solution
    that people then can use and that we at least we understand, as opposed to
    everybody going out and figuring out their own complicated solutions.

-   David: Peter, I think there are still some issues with the behavior of
    `MODULEDIR` from PGXS and `directory` in the control file that this
    doesn't quite work with this extension. Do you have some thoughts on how
    to address those issues?

-   Peter: For those who are not following: there's an existing, I guess,
    rarely used feature that, in the control file, you can specify directory
    options, which then specifies where other files are located. And this
    doesn't work the way you think it should maybe it's not clear what that
    should do if you find it in a path somewhere. I guess it's so rarely used
    that we might maybe just get rid of it; that was one of the options.

    In my mental model of how the C compiler works, it sets an [`rpath`] on
    something. If you set an absolute `rpath` somewhere and you know it's not
    gonna work if you move the thing to a different place in the path. I'm not
    sure if that's a good analogy, but it sort of has similar consequences. If
    you hard-code absolute path, then path search is not gonna work. But yeah,
    that's on the list I need to look into.

-   David: For what it's worth, I discovered last week that the part of this
    patch where you're stripping out `$libdir` and the extension make file that
    was in modules, I think? That also needs to be done when you use `rpath`
    to install an extension and point to extensions today with Postgres 17.
    Happy to see that one go.

-   Christoph: Thanks for fixing that part. I was always wondering why this
    was broken. The way it was broken. It looked very weird and it turned out
    it was just broken and not me not understanding it.

-   David: I think it might have been a documentation oversight back when
    extensions were added at 9.1 to say this is how you list the modules.

    Anyway, this is great! Im super excited for this patch and where it's
    going and the promise for stuff in the future. Just from your list of the
    **six issues** it addresses, it's obviously something that covers a
    variety of pain points. I appreciate you doing that.

-   Peter: Thank you!

Many thanks and congratulations wrap up this call.

The next Mini-Summit is on [April 9][speak later], [Christoph Berg] (Debian,
and also Cybertec) will join us to talk about Apt Extension Packaging.

  [mini-summit]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/
    "Postgres Extension Ecosystem Mini-Summit on Meetup"
  [summit]: https://www.pgevents.ca/events/pgconfdev2025/schedule/session/241/
    "PGConf.dev: Extensions Ecosystem Summit"
  [PGConf.dev]: https://2025.pgconf.dev "PostgreSQL Development Conference 2025"
  [Peter Eisentraut]: https://peter.eisentraut.org
  [David Wheeler]: {{% ref "/" %}}
  [Tembo]: https://tembo.io/
  [PGXN]: https://pgxn.org/
  [Yurii Rashkovskii]: https://ca.linkedin.com/in/yrashk
  [Omnigres]: https://omnigres.com/
  [Keith Fiske]: https://pgxn.org/user/keithf4/
  [Crunchy Data]: https://www.crunchydata.com/
  [Floor Drees]: https://dev.to/@floord
  [EDB]: https://enterprisedb.com "EnterpriseDB"
  [sponsors]: https://2025.pgconf.dev/sponsors.html
  [orafce]: https://pgxn.org/dist/orafce/
  [pglogical]: https://github.com/2ndQuadrant/pglogical
  [BDR]: https://www.enterprisedb.com/docs/pgd/4/bdr/
  [pg_failover_slots]: https://github.com/EnterpriseDB/pg_failover_slots
  [pex]: https://github.com/petere/pex
  [autopex]: https://github.com/petere/autopex
  [GitHub account]: https://github.com/petere/
  [future talk]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/events/306551747/
    "PostgreSQL Extension Mini Summit: Extension Management in CNPG"
  [CloudNativePG]: https://cloudnative-pg.io
  [Gabriele Bartolini]: https://www.gabrielebartolini.it
  [Postgres.app]:https://postgresapp.com
  [speak later]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/events/306682786/
    "PostgreSQL Extension Mini Summit: Apt Extension Packaging"
  [Homebrew]: https://brew.sh "The Missing Package Manager for macOS (or Linux)"
  [a hackers thread]: https://postgr.es/m/E7C7BFFB-8857-48D4-A71F-88B359FADCFD@justatheory.com
  [Christoph Berg]: https://www.cybertec-postgresql.com/en/author/christoph_berg/
  [PGConf.EU]: https://pgconf.eu
  [Tobias Bussmann]: https://github.com/tbussmann
  [the commit]: https://github.com/postgres/postgres/commit/4f7f7b0
  [Meson]: https://www.postgresql.org/docs/current/install-meson.html
  [`pg_config`]: https://www.postgresql.org/docs/current/app-pgconfig.html
  [xz exploit]: https://en.wikipedia.org/wiki/XZ_Utils_backdoor
  [`rpath`]: https://en.wikipedia.org/wiki/Rpath
