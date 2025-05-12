---
title: "Mini Summit 3 Transcript: Apt Extension Packaging"
slug: mini-summit-three
date: 2025-04-14T22:48:22Z
lastMod: 2025-04-14T22:48:22Z
description: |
  Last week Christoph Berg, who maintains PostgreSQL's APT packaging system,
  gave a very nice talk on that system. Herein lie the transcript and links to
  the slides and video.
tags: [Postgres, Extensions, PGConf, Summit, Debian, APT, Christoph Berg, Transcript]
type: post
image:
  src: /shared/extension-ecosystem-summit/apt-packaging-card.jpeg
  title: "PostgresSQL Extension Mini Summit: Implementing an Extension Search Patch"
  alt: |
    Orange card with large black text reading "APT Extension Packaging". Smaller
    text below reads "Christoph Berg, Debian/Cybertec" and "04.09.2025". A photo
    of Christoph looking cooly at the camera appears on the right.
---

Last week [Christoph Berg], who maintains PostgreSQL's APT packaging system,
gave a very nice talk on that system at the third PostgreSQL [Extension
Mini-Summit][mini-summit]. We're hosting five of these virtual sessions in the
lead-up to the main [Extension Summit][summit] at [PGConf.dev] on May 13 in Montréal,
Canada. Check out Christoph's session on April 9:

*   [Video](https://www.youtube.com/watch?v=35a7YCEfaRY)
*   [Slides]({{% link "/shared/extension-ecosystem-summit/apt-extension-packaging.pdf" %}})

There are two more Mini-Summits coming up:

*   April 23: [The User POV]. Join our panelist of extension users for a
    lively discussion on tool choice, due diligence, and their experience
    running extensions.
*   May 7: [Extension Management in CloudNativePG"]. [CNPG] maintainer
    [Gabriele Bartolini] will talk about recent developments in extension
    management in this official [CNCF project].

Join [the Meetup][mini-summit] to attend!

And now, without further ado, thanks to the efforts of [Floor Drees], the
thing you've all been waiting for: the transcript!

## Introduction

David Wheeler introduced the organizers:

*   [David Wheeler], Principal Architect at [Tembo], maintainer of [PGXN]
*   [Yurii Rashkovskii], [Omnigres]
*   [Keith Fiske], [Crunchy Data]
*   [Floor Drees], Principal Program Manager at [EDB], PostgreSQL CoCC member,
    PGDay Lowlands organizer

[Christoph Berg], [PostgreSQL APT] developer and maintainer par excellence,
talked through the technical underpinnings of developing and maintaining
PostgresSQL and extension packages.

The stream and the closed captions available for the recording are supported
by [PGConf.dev] and its gold level [sponsors]: Google, AWS, Huawei, Microsoft,
and EDB.

## APT Extension Packaging

Speaker: [Christoph Berg]

Hello everyone. So what is this about? It's about packaging things for
PostgresSQL for Debian distributions. We have PostgreSQL server packages,
extension packages, application packages and other things. The general
workflow is that we are uploading packages to Debian unstable first. This is
sort of the master copy, and from there things eventually get to Debian
testing. Once they're being released, they end up in Debian stable.

Perhaps more importantly for the view today is that the same package is then
also rebuilt for [apt.postgresql.org] for greater coverage of Postgres major
versions. And eventually the package will also end up in an Ubuntu release
because, Ubuntu is copying Debian unstable, or Debian testing, every six
months and then doing their release from there. But I don't have any stakes in
that.

For an overview of what we are doing in this Postgres team, I can just briefly
show you [this overview page]. That's basically the view of packages we are
maintaining. Currently it's 138, mostly Postgres extensions, a few other
applications, and whatever comes up in the Postgres ecosystem.

To get a bit more technical let's look at how the Debian packages look from
the inside.

We have two sorts of packages. We have source packages, which are the source
of things that are built. The way it works is that we have a directory inside
that source tree called Debian, which has the configuration bits about how the
packages created should look like. And from this the actual binary packages,
the `.deb` files are built.

Over the past years, I've got a few questions about, "how do I get my
application, my extension, and so on packaged?" And I wrote that down as [a
document]. Hopefully to answer most of the questions. And I kind of think that
since I wrote this down last year, the questions somehow stopped. If you use
that document and like it, please tell me because no one has ever given me any
feedback about that. The talk today is kind of loosely based on this document.

I'm not going to assume that you know a whole lot of Debian packaging, but I
can't cover all the details here, so I'll keep the generic bits a bit
superficial and dive a bit more into the Postgres-specific parts.

Generally, the most important file in the Debian package is this Debian
control file, which describes the source and the binary packages. This is
where the dependencies are declared. This is where the package description
goes, and so on. In the Postgres context, we have the first problem that, we
don't want to encode any specific PG major versions inside that control file,
so we don't have to change it each year once a new Postgres version comes out.

This is why, instead of a Debian control file, we actually have a
`debian/control.in` file, and then there's a tool called `pg_buildext`,
originally written by [Dimitri Fontaine], one or two decades ago, and then
maintained by me and the other Postgres maintainers since then. That tool is,
among other things, responsible for rewriting that `control.in` file to the
actual `control` file.

I just picked one random extension that I happen to have on the system here.
This postgresql-semver extension, the upstream author is actually David here.
In [this control file] we say the name of the package, the name of the
Debian maintainer --- in this case the group --- there's a few uploaders, there's
build dependencies and other things that are omitted here because, the slide
was already full. And then we have, next to this source section, we have a
package section and here we have this placeholder:
`postgresql-PGVERSION-semver`.

Once we feed this `control.in` file through this `pg_buildext` tool, it'll
generate the control file, which expands this `PGVERSION` placeholder to
actually a list of packages. This is just a mechanical translation; we have
`postgresql-15-semver`, 16, 17 and whatever other version is supported at that
point.

Once a new PostgreSQL version is released, PostgreSQL 18 comes out, we don't
have to touch anything in this `control.in` file. We just rerun this
`pg_buildext` update control command, and it'll automatically add the new
package.

There's about half a dozen layers talking to each other when building a
package On the lowest level, no one actually touches it at at that level. But
Debian packages are actually `ar` archives, the one from library fame, was yet
another, archive inside control called `control.tar.xz` or something. But. No
one actually touches it at that level anymore.

We have `dpkg` on top of that, which provides some building blocks for
creating actual Debian packages. So you would call `dpkg-builddeb` and other
`dpkg` helpers to actually create a package from that. But because this is
complicated, there's yet another level on top of that, called `debhelper`.
This is the actual standard for building Debian package nowadays. So instead
of invoking all the `dpkg` tools directly, everyone uses the step helper tools
which provide some wrappers for the most common build steps that are executed.
I will show an example in a second.

Next to these wrappers for calling "create me a package", "copy all files",
and so on, there's also this program called `dh`, it's called a sequencer
because it'll invoke all the other tools in the correct order. So let me show
you an example before it gets too confusing. The top level command to actually
build a Debian package --- to create the binary packages from the source
package --- is called `dpkg-buildpackage`. It will invoke this `debian/rules`
file. The `debian/rules` file is where all the commands go that are used to
build a package. For historical reasons it's a Makefile. In the shortest
incantation it just says, "for anything that is called invoke this `dh`
sequencer with some arguments."

Let me skip ahead one more slide and if we're actually running it like that,
it kind of looks like this. I'm invoking `dpkg-buildpackage`,
`dpkg-buildpackage` invokes `debian/rules` with target name `debian/rules`,
invokes `dh` and `dh` then calls all the helper steps that are required for
getting the package to run. The first one would be
`dh_update_autotools_config`, so if any ancient auto conf things are used,
it'll be updated. The package will be reconfigured, and then it would it will
be built and so on.

This was the generic Debian part. Postgres actually adds more automation on
top of that. This is this "`dh` with `pgxs` step." Let me go back two slides.
We have this `pgxs` plugin for `debhelper` which adds more build steps that
actually call out this tool called `pg_buildext`, which interfaces with the
`pgxs` build system in your extension package. Basically `debhelper` calls
this `pgxs` plugin, and this `pgxs` plugin called `pg_buildext`, and this one
finally invokes the `make` command, including any `PG_CONFIG` or whatever
settings that are required for compiling this extension.

If we go back to the output here, we can see that one of the steps here is
actually invoking this `pg_buildext` tool and `pg_buildext` will then continue to
actually compile this extension.

This means in the normal case for extensions that don't do anything special,
you will actually get away with a very short `debian/rules` file. Most of the
time it's just a few lines. In this case I added more configuration for two of
the helpers. In this step, I told `dh_installchangelogs` that, in this
package, the changelog has a file name that `dh_installchangelogs` doesn't
automatically recognize. Usually if you have a file called `changelog`, it
will be automatically picked up. But in this case I told it to use this file.
Then I'm telling it that some documentation file should be included in all
packages. Everything else is standard and will be picked up by the default
Debian tool chain.

Another thing specific for the Postgres bits is that we like to run the
package tests at build time. One of the build steps that gets executed is this
`dh_pgxs` test wrapper, which in turn invokes `pg_buildext install check`.
That will create a new Postgres cluster and proceed to invoke `pg_regress` on
that package. This is actually the place where this patch that [Peter was
talking about two weeks ago][extension-search-path] is coming into play.

The actual call chain of events is that `dh_pgxs` starts
`pg_buildext installcheck`, `pg_buildext` starts `pg_virtualenv`, which is a
small wrapper shipped with Debian --- but not very specific to Debian --- that
just creates a new Postgres environment and then executes any command in that
environment. This is actually very handy to create test instances. I'm using
that all day. So if anyone is asking me, "can you try this on Postgres 15?" or
something, I'm using `pg_virtualenv -v 15` to fire up a temporary Postgres
instance. I can then play with it, break it or something, and, as soon as I
exit the shell that `pg_virtualenv` opens, the cluster will be deleted again.

In the context of `pg_buildext`, what `pg_virtualenv` is doing here is that
it's calling `pg_createcluster` to actually fire up that instance and it's
passing an option to set this `extension_control_path` to the temporary
directory that the extension was installed to during the build process. While
we are compiling the package, the actual install command is invoked, but it
does not write to `/usr/share/postgresql` or something, but it writes to a
subdirectory of the package build directory. So it's writing to
`debian/$PACKAGE/$THE_ORIGINAL_PATH`.

And that's why before we had this in Postgres 18, the Debian packages had a
patch that does the same thing as this `extension_control_path` setting. It
was called `extension_destdir`. It was basically doing the same thing except
that it was always assuming that you had this structure of some prefix and
then the original path. The new patch is more flexible that: it can be an
arbitrary directory. The old `extension_destdir` patch assumes that it's
always `/$something/usr/share/postgres/$something`. I'm glad that that patch
finally went in and we can still run the test at build time.

So far we've only seen how to build things for one Postgres version. The
reason why this `pg_buildext` layer is there is that this tool is the one that
does the building for each version in turn. So `pg_buildext` will execute any
command pass to it for all the versions that are currently supported by that
package. What's happening here is that we have one source package for
extension covered. And that one source package then builds a separate binary
for each of the major versions covered. But it does this from a single build
run.

In contrast to what [Devrim] is doing with the [RPM packages], he's actually
in invoking the builds several times separately for each version. We could
also have done this, it's just a design choice that, we've done it one way
round and he's doing it the other way round.

To tell `pg_buildext` which versions are supported by the package, there's a
file called `debian/pgversions` which usually just contains a single line
where you can either say, "all versions are supported", or you can say that
"anything, starting 9.1" or "starting PostgreSQL 15 and later" is supported.
In this example here, 9.1+ is actually copied from the semver package because
the requirement there was that it needs to support extensions and that's when
9.1 was introduced. We don't care about these old versions anymore, but the
file was never changed since it was written.

We know how to build several Postgres major versions from a source package.
Now the next axis is supporting multiple architectures. The build is invoked
separately for each architecture. This single source package is compiled
several times for each architecture. On [apt.postgresql.org], we're currently
supporting amd64, arm64 and ppc64el. We used to have s390x support, but I
killed that recently because IBM is not supporting any build machine anymore
that actually works. Inside Debian there are a lot more architecture
supported.

There's also something called Debian ports, which are not official
architectures, but either new architectures that are being introduced like
this loong64 thing, or it's sometimes it's old architectures that are not
official anymore, but are still being kept around like the Sparc one. There's
also some experimental things like hurd-amd64, hurd-i386. Isn't even Linux.
This is a hurd kernel, but still running everything Debian on top of it, and
some time ago it even started to support Postgres. The packages are even
passing the tests there, which is kind of surprising for something that hasn't
ever seen any production.

For Postgres 17, [it looks like this]. The architectures in the upper half of
that table are the official ones, and the gray area on the bottom are the
unofficial ones that are, let's say, less supported. If anything breaks in the
upper half, maintainers are supposed to fix it. If anything breaks in the
lower half, people might care or might not care.

I like to keep it working because if Postgres breaks, all the other software
that needs it --- like `libpq`, so it's not even extensions, but any software
that depends on `libpq` --- wouldn't work anymore if that's not being built
anymore. So I try to keep everything updated, but some architectures are very
weird and just don't work. But at the moment it looks quite good. We even got
Postgres 18 running recently. There were some problems with that until last
week, but I actually got that fixed on the [pg-hackers list].

So, we have several Postgres major versions. We have several architectures.
But we also have multiple distribution releases. For Debian this is currently
sid (or unstable), trixie, (currently testing), bookworm, bullseye, Ubuntu
plucky, oracular, noble, jammy, focal --- I get to know one funny adjective
each year, once Ubuntu releases something new. We're compiling things for each
of those and because compiling things yields a different result on each of
these distributions, we want things to have different version numbers so
people can actually tell apart where the package is coming from.

Also, if you are upgrading --- let's say from Debian bullseye to Debian
bookworm --- you want new Postgres packages compiled for bookworm. So things
in bookworm need to have higher version numbers than things in bullseye so you
actually get an upgrade if you are upgrading the operating system. This means
that packages have slightly different version numbers, and what I said before
--- that it's just one source package --- it's kind of not true because, once
we have new version numbers, we also get new source packages.

But these just differ in a new change log entry. It's basically the same
thing, they just get a new change log entry added, which is automatically
created. That includes this, plus version number part. Wwhat we're doing is
that the original version number gets uploaded to Debian, but packages that
show up on [apt.postgresql.org] have a marker inside the version number that
says "PGDG plus the distribution release number". So for the Ubuntu version,
it says `PGDG-24.0.4` or something and then Debian is, it's plus
120-something.

The original source package is tweaked a bit using [this shell script]. I'm
not going to show it now because it's quite long, but, you can look it up
there. This is mostly about creating these extra version numbers for these
special distributions. It applies a few other tweaks to get packages working
in older releases. Usually we can just take the original source or source
package and recompile it on the older Debians and older Ubuntus. But sometimes
build dependencies are not there, or have different names, or some feature
doesn't work. In that case, this `generate-pgdg-source` has some tweaks, which
basically invokes `set` commands on the source package to change some minor
bits. We try to keep that to minimum, but sometimes, things don't work out.

For example, when `set compression` support was new in Postgre, compiling the
newer Postgres versions for the older releases required some tweaks to disable
that on the older releases, because they didn't have the required libraries
yet.

If you're putting it all together, you get this combinatorial explosion. From
one project, `postgresql-semver`, we get this many builds and each of those
builds --- I can actually show you [the actual page] --- each of those builds
is actually several packages. If you look at the list of artifacts there, it's
creating one package for PostgreSQL 10, 11, 12, and so on. At the moment it's
still building for PostgreSQL 10 because I never disabled it. I'm not going to
complain if the support for the older versions is broken at some point. It's
just being done at the moment because it doesn't cost much.

And that means that, from one source package quite a lot of artifacts are
being produced. The current statistics are this:

*   63355 .deb files
*   2452 distinct package names
*   2928 source packages
*   210 distinct source package names
*   47 GB repository size

We have 63,000 `.deb` files. That's 2,400 distinct package names --- so
`package-$PGVERSION` mostly built from that many source packages. The actual
number of distinct source packages is 210. Let's say half of that is
extensions. Then there's of course separate source packages for Postgres 10,
11, 12, and so on, and there's a few application packages. Yeah, in total the
repository is 47 gigabytes at the moment.

This is current stuff. All the old distributions are moved to
[apt-archive.postgresql.org]. We are only keeping the latest built inside the
repository. So if you're looking for the second-latest version of something,
you can go to [apt-archive.postgresql.org]. I don't have statistics for that,
but that is much larger. If I had to guess, I would say probably something
like 400 gigabytes/ I could also be off by with guessing.

That was how to get from the source to the actual packages. What we're doing
on top of that is doing more testing. Next to the tests that we are running at
build time, we are also running tests at installation time, or once the
package is installed we can run tests. For many packages, that's actually the
same tests, just rerun on the actual binaries as installed, as opposed to
`debian/something`. Sometimes it's also different tests For some tests it's
just simple smoke tests. id everything get installed to the correct location
and does the service actually start, sometimes it's more complex things.

Many test suites are meant to be run at compilation time, but we want to run
them at install time. This is kind of `make check`, `make installcheck`, but
some projects are not really prepared to do that. They really want, before you
can run the test suite, you have to basically compile everything. I try to
avoid that because things that work at compilation time might not mean that
it's running at install time because we forgot to install some parts of the
build.

I try to get the test suite running with as few compilation steps as possible,
but sometimes it just doesn't work. Sometimes the `Makefile` assumes that
`configure` was run and that certain variables got substituted somewhere.
Sometimes you can get it running by calling `make` with more parameters, but
it tends to break easily if something changes upstream. If you're an extension
author, please think of someone not compiling your software but still wanting
to run the tests.

What we're doing there is to run these tests each month. On each day, each
month, a random set of tests is scheduled --- that's three or four per day or
something. It's not running everything each day because if something breaks, I
can't fix 50 things in parallel. You can see [test suite tab] there. At the
moment, actually everything worked. For example, we could check something...

With [this background worker rapid status] thing, that's an extension that
[Magnus] wrote sometime ago. Everything is running fine,  but something was
broken in January. Ah, there, the S390 machine was acting up. That was
probably a pretty boring failure. Probably something with network broken. Not
too interesting. This is actually why I shut down this architecture, because
the built machine was always having weird problems. This is how we keep the
system actually healthy and running.

One thing that's also catching problems is called [debcheck]. This is a static
installability analysis tool by Debian. You feed it a set of packages and it
will tell you if everything is installable. In this case, something was not
installable on Debian testing. And --- if we scroll down there --- it would
say that `postgresql-10-icu-ext` was not installable because this `lib-icu-72`
package was missing. What happened there is that project or library change
so-name, from time to time, and in this case, in Debian, ICU was moving from
72 to 76 and I just had to recompile this module to make it work.

Usually if something breaks, it's usually on the development suites --- sid,
trixie, unstable, and testing --- the others usually don't break. If the
others break, then I messed something up.

That was a short tour of how the packaging there works. For open issues or
pain pain points that there might be, there are packages that don't have any
tests. If we are looking at, what was the number, 63,000 packages, I'm not
going to test them by hand, so we really rely on everything being tested
automatically. Extensions are usually very well covered, so there's usually
not a problem.

Sometimes there's extensions that don't have tests, but they are kind of hard
to test. For example, modules that don't produce any SQL outputs like
[auto_explain] are kind of hard to test because the output goes somewhere
else. I mean, in the concrete case, auto_explain probably has tests, but it's
sometimes it's things that are not as easily testable as new data types.

Things that usually don't have tests by nature is GUI applications; any
program that opens a window is hard to test. But anything that produces text
output is usually something I like to cover. Problems with software that we
are shipping and that actually breaks in production is usually in the area
where the tests were not existing before.

One problem is that some upstream extensions only start supporting Postgres 18
after the release. People should really start doing that before, so we can
create the packages before the 18.0 release. Not sure when the actual best
point to start would be; maybe today because yesterday was feature freeze. But
sometime during the summer would be awesome. Otherwise [Devrim] and I will go
chasing people and telling them, "please fix that."

We have of course packages for Postgres 18, but we don't have extension
packages for Postgres 18 yet. I will start building that perhaps now, after
feature freeze. Let's see how, how much works and not. Usually more than half
of the packages just work. Some have trivial problems and some have hard
problems, and I don't know yet if Postgres 18 will be a release with more hard
problems or more trivial problems.

Another problem that we're running into sometimes is that upstream only cares
about 64bit Intel and nothing else. We recently stopped caring about 32 bits
for extensions completely. So Debian at postgresql.org is not building any
extension packages for any 32-bit architectures anymore. We killed i386, but
we also killed arm, and so on, on the Debian side.

The reason is that there are too many weird bugs that I have to fix, or at at
least find, and then chase upstreams about fixing their 32-bit problems. They
usually tell me "I don't have any 32-bit environment to test," and they don't
really care. In the end, there are no users of most extensions on 32-bit
anyway. So we decided that it just doesn't make sense to fix that. In order to
prevent the problems from appearing in the first place, we just disabled
everything 32-bit for the extensions.

The server is still being built. It behaves nicely. I did find a 32-bit
problem in Postgres 18 last week, but that was easy to fix and not that much
of a problem. But my life got a lot better once I started not caring about
32-bit anymore. Now the only problem left is big-endian s390x in Debian, but
that doesn't cause that many problems.

One thing where we are only covering a bit of stuff is if projects have
multiple active branches. There are some projects that do separate releases
per Postgres major version. For example, [pgaudit] has separate branches for
each of the Postgres versions, so we are tracking those separately, just to
make pgaudit available. [pg-hint-plan] is the same, and this Postgres graph
extension thing ([Apache Age]) is also the same. This is just to support all
the Postgres major versions. We have separate source packages for each of the
major versions, which is kind of a pain, but doesn't work otherwise.

Where we are not supporting several branches is if upstream is maintaining
several branches in parallel. For example, [PostGIS] is maintaining 3.5, 3.4,
3.3 and so on, and we are always only packaging the latest one. Same for
[Pgpool], and there's probably other projects that do that. We just don't do
that because it would be even more packages we have to take care of. So we are
just packaging the latest one, ad so far there were not that many complaints
about it.

Possibly next on the roadmap is looking at what to do with [Rust] extensions.
We don't have anything Rust yet, but that will probably be coming. It's
probably not very hard; the question is just how much of the build
dependencies of the average extension is already covered in Debian packages
and how much would we have to build or do we just go and render all the
dependencies or what's the best way forward?

There's actually a very small number of packages that are shipped on
[apt.postgresql.org] that are not in Debian for this reason. For example, the
[PL/Java] extension is not in Debian because too many of the build
dependencies are not packaged in Debian. I have not enough free time to
actually care about those Java things, and I can't talk Java anyway, so it
wouldn't make much sense anyway.

I hope that was not too much, in the too short time.

## Questions and comments

*   Pavlo Golub: When you show the `pg_virtualenv`, usage, do you use pre-built
    binaries or do you rebuild every time? Like for every new version you are
    using?

*   Christoph: No, no, that's using the prebuilt binaries. The way it works
    is, I have many Postgres versions installed on that machine, and then I
    can just go and say, `pg_virtualenv`, and I want, let's say, an 8.2
    server. It's calling `initdb` on the newer version, it's actually telling
    it to skip the `fsync` --- that's why 8.3 was taking a bit longer, because
    it doesn't have that option yet. And there it's setting `PGPORT`, `PGHOST`
    and so on, variables. So I can just connect and then play with this old
    server. The problem is that `psql` pro-compatibility at some point, but
    it's still working for sending normal commands to modern `psql`.

*   Pavlo: For modern `psql`, yeah. That's cool! Can you add not only vanilla
    Postgres, but any other flavors like by EDB or Cybertec or, ...?

*   Christoph: I've thought about supporting that; the problem there is that
    there's conflicting requirements. What we've done on the Cybertec side is
    that if the other Postgres distribution wants to be compatible to this
    one, it really has to place things in the same directories. So it's
    installing to exactly this location and if it's actually behaving like the
    original, it'll just work. If it's installing to `/opt/edb/something`, its
    not supported at the moment, but that's something we could easily add.
    What it's really doing is just invoking the existing tools with enough
    parameters to put the data directory into some temporary location.

*   Pavlo: And one more question. You had [Go] extensions mentioned on your last
    slide, but you didn't tell anything about those.

*   Christoph: Yeah, the story is the same as with Rust. We have not done
    anything with it yet and we need to explore it.

*   David Wheeler: Yurii was saying a bit about that in the chat. It seems
    like the problem is that, both of them expect to download most of their
    dependencies. And vendoring them swells up the size of the download and
    since they're not runtime dependencies, but compile-time dependencies, it
    seems kind of silly to make packages.

*   Christoph: Yeah. For Debian, the answer is that Debian wants to be
    self-contained, so downloading things from the internet at build time is
    prohibited. The ideal solution is to package everything; if it's things
    that are really used only by one package, then vendoring the modules might
    be an option. But people will look funny at you if you try to do that.

*   Yurii: I think part of the problem here is that in the Rust ecosystem in
    particular, it's very common to have *a lot* of dependencies, as in
    hundreds. When you start having one dependency and that dependency brings
    another dependency. The other part of the problem is that you might depend
    on a particular range of versions of particular dependencies and others
    depend on others. Packaging all of that as individual dependencies is
    becoming something that is really difficult to accomplish. So vendorizing
    and putting that as part of the source is something that we could do to
    avoid the problem.

*   Christoph: Yeah, of course, it's the easy solution. Some of the
    programming language ecosystems fit better into Debian than others. So I
    don't know how well Rust fits or not.

    What I know from the Java world is that they also like to version
    everything and put version restrictions on their dependencies. But what
    Debian Java packaging helpers are doing is just to nuke all those
    restrictions away and just use the latest version and usually that just
    works. So you're reducing the problem by one axis by having everything at
    the latest version. No idea how reasonable the Rust version ranges there
    are. So if you can just ignore them and things
    still work, or...

*   Yurii: Realistically, this is impossible. They do require particular
    versions and they will not compile oftentimes. The whole toolchain expects
    particular versions. This is not only dependency systems themselves, it's
    also Rust. A package or extension can have a particular demand
    for minimum supported Rust version. If that version is not available in
    particular distro, you just can't compile.

*   Christoph: Then the answer is we don't compile and you don't get it. I
    mean, Rust is possibly still very new and people depend on the latest
    features and then are possibly just out of luck if they want something on
    Debian bullseye. But at some point that problem should resolve itself and
    Rust get more stable so that problem is not as common anymore.

*   Yurii: It's an interesting take actually because if you think about, the
    languages that have been around for much longer should have solved this
    problem. But if you look at, I don't know, C, C++, so GCC and Clang,
    right? They keep evolving and changing all the time too. So there's a lot
    of code say in C++ that would not compile with a compiler that is older
    than say, three years. So yeah, but we see that in old languages.

*   Christoph: Yea, but Postgres knows about that problem and just doesn't use
    any features that are not available in all compilers. Postgres has
    solved the problem.

*   Yurii: Others not so much. Others can do whatever they
    want.

*   Christoph: If upstream doesn't care about their users, that's upstream's
    problem.

*   David: I think if there's there's a centralized place where the discussion
    of how to manage stuff, like Go and Rust do, on packaging systems is
    happening, I think it's reaching a point where there's so much stuff that
    we've gotta figure out how to work up a solution.

*   Christoph: We can do back ports of certain things in the repository and
    make certain toolchain bits available on the older distributions. But you
    have to stop at some point. I'm certainly not going to introduce GCC back
    ports, because I just can't manage that. So far we haven't done much of
    that. I think [Devrim] is actually backporting parts of the GIST tool
    chain, like GL and libproj or something. I've always been using what is
    available in the base distribution for that. There is some room for making
    it work, but it's always the question of how much extra work we want to
    put in, how much do we want to deviate from the base distribution, and
    ultimately also, support the security bits of that.

[David makes a pitch for the next two sessions and thanks everyone for coming].

  [Christoph Berg]: https://www.df7cb.de
  [mini-summit]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/
    "Postgres Extension Ecosystem Mini-Summit on Meetup"
  [summit]: https://www.pgevents.ca/events/pgconfdev2025/schedule/session/241/
    "PGConf.dev: Extensions Ecosystem Summit"
  [PGConf.dev]: https://2025.pgconf.dev "PostgreSQL Development Conference 2025"
  [The User POV]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/events/306682918/
  [Extension Management in CloudNativePG"]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/events/306551747/
  [CNPG]: https://cloudnative-pg.io "Run PostgreSQL. The Kubernetes way."
  [Gabriele Bartolini]: https://www.gabrielebartolini.it
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
  [CNCF project]: https://www.cncf.io/projects/cloudnativepg/
  [PostgreSQL APT]: https://wiki.postgresql.org/wiki/Apt
  [apt.postgresql.org]: https://apt.postgresql.org
  [this overview page]: https://qa.debian.org/developer.php?email=team%2bpostgresql%40tracker.debian.org
  [a document]: https://salsa.debian.org/postgresql/postgresql-common/blob/master/doc/postgresql-debian-packaging.md
  [Dimitri Fontaine]: https://tapoueh.org/about/
  [this control file]: https://salsa.debian.org/debian/postgresql-semver/-/blob/debian/master/debian/control.in?ref_type=heads
  [extension-search-path]: {{% ref "/post/postgres/2025-mini-summit-two" %}}
      "2025 Extension Mini Summit 2: Implementing an extension search path"
  [Devrim]: https://github.com/devrimgunduz "Devrim Gündüz"
  [RPM packages]: https://yum.postgresql.org
  [it looks like this]: https://buildd.debian.org/status/package.php?p=postgresql-17
  [pg-hackers list]: http://archives.postgresql.org/pgsql-hackers/
    "pgsql-hackers Archives"
  [this shell script]: https://salsa.debian.org/postgresql/apt.postgresql.org/-/blob/master/jenkins/generate-pgdg-source
  [the actual page]: https://jengus.postgresql.org/job/postgresql-semver-binaries/
  [apt-archive.postgresql.org]: https://apt-archive.postgresql.org
  [test suite tab]: https://jengus.postgresql.org/view/Testsuite/
  [this background worker rapid status]: https://jengus.postgresql.org/view/Testsuite/job/bgw-replstatus-autopkgtest/
  [Magnus]: https://www.hagander.net "Magnus Hagander"
  [debcheck]: https://jengus.postgresql.org/view/Testsuite/job/debcheck/
  [auto_explain]: https://www.postgresql.org/docs/current/auto-explain.html
  [pgaudit]: https://pgxn.org/dist/pgaudit/
  [pg-hint-plan]: https://pgxn.org/search?q=pg_hint_plan&in=dists
  [Apache Age]: https://pgxn.org/dist/apacheage/
  [PostGIS]: https://postgis.net "PostGIS"
  [Pgpool]: https://www.pgpool.net/
  [Rust]: https://www.rust-lang.org
  [PL/Java]: https://tada.github.io/pljava/
  [Go]: https://go.dev
