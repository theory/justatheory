---
title: Mini Summit Three
slug: mini-summit-three
date: 2024-04-10T20:27:15Z
lastMod: 2024-04-10T20:27:15Z
description: |
  A rough transcript of my Devrim Gündüz's talk, "Overview of
  {yum,zypp}.postgresql.org, and the challenges around RPMifying extensions",
  along with interspersed chat comments.
tags: [Postgres, PGXN, Extensions, PGConf, Summit, Yum, ZYpp]
type: post
---

Terrific presentation and discussion at last week's [Postgres Extension
Ecosystem Mini-Summit][mini-summit]. In fact, I later learned that some
people couldn't make it because the Eventbrite event page showed it as
sold out!

This is a limitation of the free level at Eventbrite, which caps tickets at
25. But this is a fully-remote event and we can host more people than that. We
had over 30 last week! So if you'd like to attend one of the remaining three
events and Eventbrite shows it as sold out, have a look at the bookmarks for
the [#extensions] channel on the [Postgres Slack], or email the username
`david` at this domain and I will send you the link!

Okay, back to business. Last week, [Devrim Gündüz] kindly gave a super
thorough presentation in his capacity as the maintainer of the Postgres
community [Yum] and [ZYpp] repositories. This topic sparked lots of
interesting discussion and commentary, which I detail below. But why read when
you can look?

*   [Video](https://www.youtube.com/watch?v=6hk4bvXj0QE)
*   [PDF Slides](https://www.gunduz.org/seminer/pg/DevrimGunduz-Overview_of_yum.postgresql.org_and_extensions-Extension_Ecosystem_Mini_Summit_2024-01.pdf)

Still reading? Okay then, here we go!

## Introduction

*   I opened the meeting and introduced Devrim Gündüz.

## Presentation

*   Thank you for the introduction. Going to talk about Yum and ZYpp dot
    postgresql.org, these are the challenge for us, and the challenge of
    making RPMs from extensions.

*   Work for [EDB] as Postgres expert, Postgres Major contributor responsible
    for the Postgres Yum repo. If you're using RPMs, I'm building them. I also
    contribute to Rocky, SUSE, and Fedora Linux, proud Postgres community
    member, live in London, and I'm also doing some DJing, so if I get fired I
    have an extra job to do.

*   Agenda: Last year at PGConf.eu in Prague, I had 60 slides for 5 minutes,
    so expect huge number of slides for today. I want to leave some time for
    discussion discussion and questions.
    
*   I'm going to start with how it started back in the 2000s, talk about the
    contents of the repos, which distributions we t because that's another
    challenge um how do we do the extension packaging how to RPM how to build
    RPMs of an extension and how to update an extension RPM.
    
*   Then the horror story um when what happens when there's a new Postgres
    beta is out,  which is due in the next next month or so for Postgres 17.
 
*   Then we are going to speak about the extension maintainers,  problem for
    us, and then the problems about relying on the external repos.
    
*   So if you have any questions please ask as soon as you can. I may not be
    able to follow the chat during the presentation, but I'll try as much as I
    can.

*   So let's talk about how it started. When I started using Linux in 1996 um
    and Postgres in 1998, we always had Tom Lane and we had we had Lamar for
    for who build built RPMs for RedHta Upstream. So they were just building
    the distribution packages, nothing community. It was only specific to
    RedHat --- not RedHat Enterprise Linux but RedHat 3-4-5 --- not the
    non-enterprise version of RedHat back then, but it was called it Fedora
    core back then, the first version was released in November
    2003, which was another challenge for packaging
    
*   One of the problems with the distribution packaging was that it was
    slightly behind the minor Postgres releases, sometimes major post releases

*   So that was one single Postgres version available for a given distro, say
    Postgres 6.4 or something, 7.0, and multiple versions were not
    available back then, and the minor version was slightly behind.
    
*   I started building packages for my laptop because I wanted to use Postgres
    and not all versions wer available back then. So I started building
    packages for my laptop and my server. They were based on the packaging of
    Tom Lane and Lamar.
    
*   Then I uploaded them to my personal server and emailed the PG mailing
    lists lists and said, "I'm running on own packages, use at your own risk.
    This is just a rebuild of the upstream packages on the RedHat version that
    I'm using or the Fedora version that I'm using. Up to you! This is a personal
    project, nothing serious."
    
*   So then then people started downloading them, and using them. There was no
    signature, nothing official back then. Then Lamar said he didn't have
    enough time for the RPMs. He sent an email to the mailing lists and I said
    Devrim is stepping up to the plate, and I did it. So that was I think in
    2004, about which is about 20 years ago.

*   So 19 years ago we had the first domain, `postgresql.rpm.org`, and then we
    had more packages. In 2007 we had the first repository RPM and then we had
    yum.postgresql.org. This means that, starting 2007, this began to be the
    official RPM repo of the community, which which was a good thing because
    we could control everything under the Community.
    
*   I was living in Canada back then. We had the first RPM build farm ---
    instead of using my laptop and my VMs --- we had the actual machine
    back then.

*   In 2010 we had what was then called multiple postmaster support, which
    means the parallel installation of the Postgres RPMs. That was a that was
    a revolution because even still, the current Fedora or RedHat RPMs cannot
    be installed in parallel. So if you want to install post 13, 14, 15, 16,
    and 17 or whatever, it is available in the community repo. This is a great
    feature because you may want to test or do something else. This is how
    we how we started, 14 years ago we had this feature in the community repo.
    
*   Then next year we moved the repo to the community servers and unified the
    spec files. Our builds are extremely simple --- like you can start your
    own builds in less than 10 minutes: five minutes for pulling the git repo
    and then a few minutes for for a package. Extremely simple builds, and now
    we are in 2024

*   Let's talk about the contents, because we have four different contents for
    the repo. The first one is the "common" repo. We call it "common" in the
    repository config file. It has the RPMs that work across all Postgres
    major releases. Let's say pg_badger, or the ODBC driver, JDBC driver, or
    GDAL for PostGIS. There's  lots of stuff: Python packages, which are not
    extensions but we like Patroni, which actually works for all Postgres
    releases.

*   This was an effort to get rid of duplicates in the Postgres repo. I think we
    shaved lots of gigabytes back then, and we still save a lot
    
*   Then, to address one of the topics of today's talks, we have the
    "non-common" RPMs. (These are the name of the directories, by the way.)
    They are the RPMs which are Postgres version-specific, basically they are
    extensions. Say `plpgsql_check` 15 or whatever. Lots of extensions are
    there.
    
*   Then we have extras. They are not actually Postgres packages, they
    shouldn't be included in our repo by default, but many people actually
    look for these packages because they they want to use Patroni and they
    don't have the supporting RPMs or supporting RTM RPMs, or they're not
    up-to-date.
    
*   I'm building a console, console-template, ETCD, HAProxy keepalived and
    vip-manager. They are all open source, some of them are Go packages ---
    which, actually, I don't build them, I just distribute the precompiled
    binaries via the repo. So that makes easier for people to deploy the
    packages.

*   And then we have the "non-free" repo. These are the packages that depend
    on closed-source software like Oracle libraries, or that have license
    restrictions. For example, ora2pg depends on Perl DBD::Oracle, oracle_fdw
    depends on Oracle, pg_storm depends on Cuda Nvidia stuff, timescaledb-tsl
    actually is Timescale DB with the TSL license, informix_fdw and db2_ftw.

*   So we have some non-free packages which actually depend on non-free stuff
    as well. *All of them* are well-maintained: I'm trying to keep everything
    up to date --- like real up-to-date! That brings some problems but we
    will get there.
    
*   We support RedHat Enterprise Linux and of course Rocky Linux. This year we
    started supporting Alma Linux as well. Of course they are more or less
    identical, but we test them, install, and support to verify the packages
    in these three distributions.
    
*   We have x86_64 aarchm64, ppc64le, and RedHat 9, 8, and 7. We have
    also RedHat 6 for Postgres 12, but it's going to be killed by the end of
    this year. We have Fedora, but only two major releases, which matches the
    Fedora lifecycle. And SUSE ---  my pain in the neck --- um I'll get there.

*   Since you all are here for extension packaging, let's get there: what
    happens for extension packaging.

*   First of all, we have the first extension, which is the in-core
    extensions. They are delivered with the contrib sub-package, which matches
    the directory name in The Postgres tarball. There are separate packages
    for each major version, so p`ostgres15-contrib`, `postgres13-contrib`,
    etc. These are the installation directories for each extension. We are
    going to use those directories for the other [non-cre] extensions as well.
    
*   When we add a new extension to the repo, it's going to use these
    directories if they have a binary or if they an extension config file, if
    the library or the mem files --- all are going are all installed under
    these directories. This magic is done by PGXS, which has been there
    forever. We just provide initial stuff and then the rest is done by the
    the PGXS magic. This is the base for a lot of the core extensions.
    
*   So what happens when we do non-common and non-free package? First of all,
    they are distributed separately for each Postgres major version. Let's go
    back to the one of the extensions, say `plpgsql_check`. We have a separate
    package for Postgres 14, a separate package for Postgres 15, 16, 13, and
    12. If they build against all the supported Postgres versions, we have
    separate packages for each.

*   Of course from time to time --- as far as I remember Timescale DB does
    this ---- Timescale DB only supports Postgres 15 and 16 nowadays. So we
    drop support for the older versions in the Git repo. But they are separate
    packages; they are all installed in these directories along with the main
    contrib package.

*   This is the naming convention that I use: `$extensionName_PGMajorVersion`.
    Four or six years ago, some of the packages didn't have an underscore
    before the PG major version. It was a problem, so someone complained in
    the hackers mailing list, and then I made the changes.
    
*   Currently all the previous and all the new packages have this naming
    convention except a few packages like PostGIS --- because in PostGIS we
    have multiple versions of the same extension. let's say we have PostGIS
    3.3, 3.2, 3.4, 3.1, 3.0. We have combinations of each --- I think we have
    PostGIS 3.0 in some of the distributions but mostly PostGIS 3.1, 3.2, 3.3,
    and 3.4, and then all the Postgres versions they support --- A lot of
    builds! So there are some exceptions where we have the extension name and
    extension major version before the Postgres major version.

    *   *Jeremy S* in chat: question: curious if you have thoughts about
        relocatable rpm packages. ever tried? just best to avoid?

*   I have a question from Jeremy. This is a very basic question to answer.
    This is actually forbidden by the packaging rules. The RPM packaging rules
    forbid you to distribute or create relocatable RPM packages. We we stick
    to the packaging guidelines, so this this cannot be done.

    *   *Jeremy S* in chat: Thanks! (Didn’t realize packaging guidelines
        forbid this)

*   Let's talk about how we build extensions. Often our develop package is
    enough: many of our packages just just rely on on Postgres itself. But of
    course packages like PostGIS may depend on some other packages, like GDAL,
    which requires lots of lots of extra dependencies as well. The most
    problematic one is the GIS Stack: they need EPEL on RHEL and
    RHEL and its derivatives.

*   There there has been a discussion in the past about whether should require
    EPEL by default. The answer is "no," because not all not all of our users
    are installing, for example, the GIS stack or other packages. Most of our
    users --- not the majority of our users ---- rely on the um rely on just
    our repo.

*   On the other hand, in order to provide completeness for our users, I added
    lots of python packages in the past to support Patroni --- because the
    upstream packages (I'm sorry not maybe upstream packages) were not enough.
    The version wasn't enough or maybe too low. So From some time to time I
    add non Postgres-related packages to the repo just to support the Postgres
    package. In the past it was PGAdmin, but now it's not in our repo so it's
    not a problem: their upstream is building their own RPMs, which is a good
    thing for us. We are building extra packages mostly for Patroni.
    
*   However, this is a potential problem for some enterprise users because
    large companies don't even want to use the EPEL repo because they feel
    like it's like it's not a community repo, but a community repo controlled
    by Fedora and RedHat. That's why from time to time I
    try to add some of the packages to our repo.
    
*   If it's a problem for enterprise users, does it mean we should we maintain
    tons of extra packages in the EPEL repo for the GIS stack? The answer is
    "no, definitely no". Not just because of the human power that we need to
    maintain those those packages ---  I mean rebuilding them is easy: I just
    get the source RPM, commit the spec files into our repo, and rebuild them.
    But maintaining them is something else.

*   We will have a similar problem when we release our own ICU package in the
    next few years. Because, now that we have the in core collation --- but
    just for C Locale  ----  and people are trying to get rid of glibc, maybe
    we should have an ICU package. But maintaining an ICU Library across a
    single Postgres major version is a real big challenge that I don't know
    how to solve for now, at least.
    
*   And then SLES --- my pain in the neck --- the GIS stack requires lots of
    repos on SLES 15. They are they are well documented on on our website.

*   Fedora is safe because Fedora is Fedora, everything is there, it's easy to
    get a package there.

    *   *Jeremy S* in chat: "Building them is easy. Maintaining them is
        something else."

*   Yeah that's that's the problem, Jeremy.

*   So how do you RPMify an extension?

*   The first thing is to know that the extension exists. This is one of the
    big problems between developers and users. The developer creates a useful
    extension and then they don't create a tarball, they don't release
    anything. They expect people to install Git on their production databases
    and `git pull`, install `make`, `gcc`, all the development
    libraries and build a binary, blah, blah blah.
    
*   I'm sorry that'ss not going to work. It also doesn't work for pip --- pip
    is not a package manager, it just destroys your server. It downloads
    things to random places and then everything's gone. That's why I added
    lots of Python packages to support Patroni, because most of the users use
    the packaging package manager to install Postgres and other packages to
    their servers. It's the same for Debian, Ubuntu, for RPMs, for Windows,
    for macOS.

*   So first of all we know have to know that the extension exists and we have
    to have a tallbal. If I see an extension that seems good enough I'll get
    there. PGXN is a good place, because when I go to pgxn.org a few times per
    day and see if there is a new version of an extension or if there's new
    extension, it's a good piece. But there's a problem: we have hundreds of
    extensions --- maybe thousands --- but not all of them are on PGXN. They
    should be!

    *   *David Wheeler (he/him)* in chat: You should follow
        [@pgxn@botsin.space] for new releases :-)

    *   *nils* in chat: pg_xz incoming

*   I don't know how to solve this problem, but we should expect every
    extension to announce their extensions on PGXN. I'm not just talking about
    installing everything through PGXN, but at least have an entry that
    there's a new extension, this is repo, the website, the readme and the is
    a tarball. It doesn't have to be on PGXN, as long as we have *something*.

*   And then I check the version. If there is an extension that will kill your
    database and the version is 0.001, that's not going to be added to the
    repo, because we don't want to distribute an experimental feature.
    
    *   *David Wheeler (he/him)* in chat: LOL, all my extensions start at
        0.0.1

    *   *David G. Johnston* in chat: If it isn't on PGXN it doesn't exist.
    
*   Another problem is that  lots of people write extensions but some of them
    are just garbage. I'm sorry but that's the truth. I mean they just release
    a version and then do nothing.

    *   *David Wheeler (he/him)* in chat: LOLOLOL

*   From the chat, "pgxn_xz is coming": that's right! We have [blackhole_fdw],
    which was written by Andrew Dunstan. When you create blackhole_fdw, it throws all
    of your data into black hole, so everything is gone.
    
*   Yeah, "if it's not on PGXN it doesn't exist," that's what I hope we
    achieve achieve in the next year or so.

    *   *Jimmy Angelakos* in chat, replying to "If it isn't on PGXN ...": I
        would correct that to "If it isn't on PGXN it isn't maintained."
        Sometimes even ON PGXN...

*   Yeah Jimmy, that's one of the big problems that we have: maintenance.
    
*   We create the spec file, just copy one of the existing ones and start
    editing. It's easy but sometimes we have to add patches. We used to carry
    patches for each Postgres major version to change the `Makefile`s for the
    specific Postgres major version. But I realized that it was [not a great
    pattern]. Now we just export the path, which fixes the problem.

    *   *David G. Johnston* in chat: As a policy though, someone who cares and
        wants responsibility needs to apply to be part of the RPM community.

 *  Then I initiate a scratch build for any missing requirements. If there are
    any missing build requirements it fails to build. I only do it on Fedora
    latest, not for every package because it doesn't always help because some
    distros may not have the missing dependency

    *   *Alvaro Hernandez* in chat: Hi everybody!

    *   *David G. Johnston* in chat: Delegated to PGXN for that directory.
    
*   Let's say we rely on some really good feature that comes with a latest
    version of something, but that latest version may not appear in RedHat 7
    or 8. So some dist dros may have it, but the version may be lower than
    required. Or some distros may have the dependency under different name.
    Now in the spec file we have "if SUSE then this" and "if RedHat then this"
    "if Fedora then", "if RedHat nine then this", etc. That's okay, it's
    expected. As long as we have the package, I don't care.

*   Then I push it to the Git repo, which I use not just for the spec files
    and patches, but also for carrying the spec files and pitches to the build
    instances.
    
    *   *Jorge* in chat: How to handle extension versioning properly? I mean,
        in the control file the version could be anything, like for ex. citus
        default_version = '12.2-1' where the "published version" is v12.1.2,
        then the "default version" could remain there forever.

        Also have seen in the wild extensions that the control file have a
        version 0.1 (forever) and the "released" version is 1.5

*   If something fails I go back to the drawing board. GCC may fail (gcc 14
    has been released on Fedora 40 and is causing lots of issues for for
    packaging nowadays), it could be `cmake` --- too recent or too old. It
    could be LLVM --- LLVM18 is a problem for Postgres nowadays. I either try
    to fix it ping upstream. I often ping upstream because the issue must be
    fixed anyway
    
*   If everything is okay, just push the packages to the repo.

    *   *Ruohang Feng (Vonng)* in chat: question: how about adding some good
        extensions written in Rust/pgrx to the repo? like pgml,  pg_bm25,
        pg_analytics, pg_graphql....

*   One issues is that there is no proper announcement. Maybe I have an
    awesome extension available in the Postgres repo that people crave and, we
    build the extensions, it took a lot of time (thank you Jimmy, he helped me
    a lot) and then I didn't actually announce it that much. On the other
    hand, people just can use PG stat base [?] to install and start using it
    in a few seconds. This is something that we should improve.

    *   *Steven Miller* in chat: How to handle system dependencies like libc
        versions being updated on the target system? Do extensions need to be
        complied against exactly a specific libc version?    

    *   *From Nevzat* in chat: how can we make sure bugfix or extension is
        safe before installing it

    *   *vrmiguel* in chat: Interesting approach to identify build/runtime
        requirements
    
        Over at Tembo we have a project called trunk-packager which attempts
        to automatically create .deb packages given the extension's shared
        object.
        
        We try to identify the dynamic libs the extension requires by parsing
        its ELF and then trying to map the required .so to the Debian package
        that provides it, saving this info in the .deb's control file
    
*   From the chat: How to handle extension versions properly? That's a good
    thing but, extension version and the release version don't have to match.
    Thr extension version isn't the same thing as the release version. It's
    the version of the SQL file or the functions or the tables, the views,
    sort procedures, or whatever. If it's 0.1 it means it's 0.1 it means
    nothing nothing has changed in this specific regarding the control file.
    They they may bump up the package version because they may add new
    features, but if they don't add new features to the SQL file, then they
    don't update the extensions. I hope that answers your question George

*   I have another question from Ruohang. Yaaaaay! I was afraid that someone
    would ask that one. We have no extensions written in Rust in repo so far.
    It's not like Go; there is a ban against Go because we don't want to
    download the world, all the internet just to build an extension. If I
    recall correctly they're rewriting pg_anonymizer in Rust. They will let me
    know when they release it or they're ready to release it, and then I'll
    build it. It's not something I don't like, it just hasn't happened.
    
    *   *Keith Fiske* in chat: I still update the control file with my
        extensions even if it's only a library change. Makes it easier to know
        what version is installed from within the database, not just looking
        at the package version (which may not be accessible)

    *   *Ruohang Feng (Vonng)* inchat: question: How to handle RPM and
        extension name conflicts, e.g., Hydra's `columnar` and Citus's
        `columnar`.

    *   *David Wheeler (he/him) in chat, replying to "I still update the c..."
        Yeah I’ve been shifting to this pattern, it’s too confusing otherwise

*   If you think there are good extensions like these, just create a ticket on
    [redmine.postgresql.org]. I'm happy to take a look as long as I know them.
    That's one of the problems: I have never heard about pg_analytics or pgml,
    because they're not on PGXN. Or maybe they are. This is something that we
    should improve in the next few months.

    *   *Jimmy Angelakos* in chat: Go is a pretty terrible ecosystem. It has
        its own package manager in the language, so it's kinda incompatible
        with distro packages

    *   *Jason Petersen* in chat: (but that means a build is safe within a
        single release, it doesn’t mean you can move a built extension from
        one Fedora version to another, right?)

    *   *David Wheeler (he/him)* in chat, replying to "How to handle
        system...": Libc is stable in each major version of the OS, and there
        are separate RPMs for each.

*   Another question from Steven: how to handle system dependencies like libc
    version updates. The answer is no. It's mostly because they don't update
    the libc major version  across the across across the lifetime of the of
    the release. So we don't need to rebuild the extension against libc.

    *   *Steven Miller* in chat, replying to "How to handle system...": Ok I
        see, TY

    *   *Jason Petersen* in chat, replying to "How to handle system...": Is
        that how we deploy in trunk, though?

    *   *David Wheeler (he/him)* in chat, replying to "Go is a pretty
        terri...": Huh? You can build binaries in a sandbox and then you just
        need the binary in your package.

*   [Addressing Nevzat's question]: That's a great question. It's up to you!
    It's no different than installing Postges or any other thing. I just build
    RPMs. If you're reading the hackers mailing list nowadays, people rely on
    me an Christoph and others, so that we don't inject any code into the RPMs
    or Debian packages. You just need to trust us not to add extra code to the
    packages. But if there's a feature problem or any bug then you should
    complain upstream, not to us. so you should just test.

    *   *Jimmy Angelakos* in chat, replying to "Go is a pretty terri...": Find
        me one person that does this.

    *   *Steven Miller* in chat, replying to "How to handle system...": We
        don’t have OS version as one of the dimensions of version packaging
        but should

*   [Addressing vrmiguel's comment]: Yeah, that could be done but like I don't
    like complex things, that's why I'm an RPM packager.

    *   *Jason Petersen* in chat, replying to "Go is a pretty terri...":
        (doesn’t go statically link binaries, or did they drop that
        philosophy?)

    *   *vrmiguel* in chat: I think citus has changed it to citus_columnar

    *   *David Wheeler (he/him)* in chat, replying to "Go is a pretty
        terri...": Hugo:
        https://github.com/hugomods/docker/tree/main/docker/hugo

    *   *David Wheeler (he/him)* in chat, replying to "Go is a pretty
        terri...": Jason: Static except for libc, yes
    
*   Another question from Ruohang: uh how to handle RPM and extension name
    conflicts. I think Citus came first, so you should complain to Hydra and
    ask them to change the name. They shouldn't be identical. We have
    something similar with Pgpool: they they are conflicting with the PCP
    Library ,which has been in the Linux for the last 25 years. I think Pgpool
    has to change their name.

    *   *Jeremy S* in chat, replying to "I still update the c...": So you
        think people will run the “alter extension upgrade” eh?

*   [Addressing Keith Fiske's comment]: I'm not saying I don't agree with you,
    but it means every time I have to update my extension version in my
    running database --- it's some extra work but that's okay. It's the user
    problem, not my problem.

*   Question from Jason [on moving an extension from one Fedora to another]:
    Right, it may not be safe because the GCC version may be different and
    other stuff may be different. One distro to another is not safe, Jason;
    sorry about that.
    
*   [Back to Steven's question]: Yes, David's answer is right.

*   [Addressing vrmiguel's comment about citus_columnar]: You are right.

*   Jimmy I'm not going to read your comment about go because I
    don't think think you can swear enough here.
    
    *   *vrmiguel* in chat, replying to "Go is a pretty terri...": Are there
        known Postgres extensions written in Go? Not sure how Go is relevant
        here

    *   *Jason Petersen* in chat: you said “gcc” and not “libc” there, are you
        implying that things like compiler versions and flags need to be
        identical between postgres and extensions

    *    *Keith Fiske* in chat, replying to "I still update the c...": I think
         they should ...

    *   *David Wheeler (he/him)* in chat, replying to "Go is a pretty
        terri...": Were some experiments a few years ago.
        https://pkg.go.dev/github.com/microo8/plgo

*   Let me continue now. First you have to know the extension exists, and then
    the you also need to know that the extension has an update. Unfortunately
    the same problem: the extension exists or has an update and they just
    don't let us know.
    
    *   *Jimmy Angelakos* in chat, replying to "Go is a pretty terri...":
        @vrmiguel now you know why :D

*   This is a big challenge Fedora has in house solution.When you add a new
    package to Fedora, I think they crawl their repo once a day and if there's
    new release they create a ticket in their bug tracker automatically, so
    that the maintainer knows there's a new version. This can be done, but
    would need a volunteer to do it. Orr maybe the easiest thing is just add
    everything to the to PGXN,
    
*   When we update an extension we, have to make sure it doesn't break
    anything. It requires some testing. As I said earlier, building is one
    thing, maintaining the extension is a bigger thing. If you want to raise a
    baby, you are responsible until until the end of your life. Consider this
    like your baby: either just let us know if you can't maintain an extension
    anymore or please respond to the tickets that I open.

    *   *Steven Miller* in chat: One other detail about compatibility
        dimensions. We have noticed some extensions can be complied with
        chip-specific instructions like AVX512, for example vector does this
        which optimizes performance in some cases

    *   *Alvaro Hernandez* in chat, replying to "you said “gcc” and n...": I'd
        reverse the question: do we have strong guarantees that there are no
        risks if versions and/or flags may differ?

        I believe extensions are already risky in several ways, and we should
        diminish any other risks, like packaging ones.

        So I'd say absolutely yes, compile extensions and Postgres in exactly
        the same way, versions and environments.    

*   Sometimes a new minor version of an extension breaks a previous Postgres
    release. For example, an extension drops support for Postgres 12 even
    though Postgres 12 is still supported. Or they didn't do the upgrade path
    work. I have to make sure everything is safe.

    *   *nils* in chat, rReplying to "I think citus has ch...": It was never
        changed, the extension has always either been embedded in Citus or
        later moved to a separate extension called citus_columner.

        I think the name conflict comes from the access method being called
        `columnar`, which Citus claimed first. (Hydra’s started actually as a
        fork from Citus’ codebase).

        (disclaimer; I work on Citus and its ecosystem)
    
    *   *Jason Petersen* in chat, replying to "I think citus has ch...": hi
        nils

*   Next month a new beta comes out. Everyone is happy, let's start testing
    new features. For the packagers that means it's time to start building
    extensions against beta-1. So a build might fail, we fix it, and then it
    may fail against beta-2. I understand if extension authors may want to
    wait until rc-1. That's acceptable as long as they let us know. Many of
    them fail, and then Christoph and I create tickets against them and
    display them [on wiki.postgresql.org]. It's a Hall of Shame!

    *   *Eric* in chat: When you decide to package a new extension do you
        coordinate with upstream to make that decision?

    *   *David Wheeler (he/him)* in chat, replying to "When you decide to
        p...": I learned I had extensions in the yum repo only after the fact

    *   *Eric* in chat, replying to "When you decide to p...": I see

    *   *vrmiguel* in chat: @Devrim Gündüz I'm curious about how RPM deals with
        extensions that depend on other Pg extensions

    *   *David Wheeler (he/him)* in chat: You can test Postgres 17 in the
        pgxn-tools docker image today. Example:
        https://github.com/theory/pgtap/actions/runs/8502825052

*   This list pisses off the extension authors because they don't respond to
    ticket. So what do we do next? It happens again and again and again,
    because they just don't respond to us. On Monday uh I got a response from
    an extension maintainer. He said "you are talking like you are my boss!" I
    said, "I'm talking like I'm your user, I'm sorry. I just asked for a very
    specific thing."

    *   *nils* in chat: I love Devrim’s issues against our repo’s! They are
        like clockwork, every year 😄

    *   *David Wheeler (he/him)* in chat, replying to "You can test
        Postgre...": It relies on the community apt repo

    *   *Eric* in chat, replying to "When you decide to p…": Related: ever had
        upstream request you stop packaging an extension?
    
    *   Steven Miller* in chat, replying to "One other detail abo...": Even if
        compiled inside a container, on a specific chip it can get
        chip-specific instructions inside the binary. For example building
        vector on linux/amd64 inside docker on a chip with AVX512, the
        container image will not work on another linux/amd64 system that does
        not have AVX512

    *   *David Wheeler (he/him)* in chat: :boss:

*   Unresponsive maintainers are a challenge: they don't respond to tickets,
    or emails, or they don't update the extensions for recent Postgres
    versions.
    
*   Don't get me wrong even the big companies also do this, or they don't
    update the extensions for the new GCC versions. I don't expect them to
    test everything against all all the GCC versions; that's that's my
    problem. But just respond please.
    
*   What's the responsibility of the packager in this case? Should we fork if
    they don't respond at all? No we are not forking it! VBut going to
    conferences helps, because  if the extension author is there I can talk to
    them in person in a quiet place, in a good way, just "please update the
    package tomorrow or you're going to die". Of course not this but you see
    what I mean.

*   [Looking at chat]: I'm going to skip any word about containers; sorry
    about that.
    
*   [Addressing Eric's question]: That's a good so so the question! No,
    actually they support us a lot, because that's the way that people use
    their extensions. And do we coordinate with upstream? No, I coordinate
    with myself and try to build it. Of course upstream just can just create a
    ticket, send me email, or find me at a conference. They can say, "hey, we
    have an extension, could you package an RPM?" Sure, why not." I don't
    coordinate with Upstream as long as uh there is no problem with the builds.

    *   *Eric* in chat, replying to "When you decide to p…": So you haven’t
        run into a situation where upstream did not want/appreciate you
        packaging for them?

*   [Respondinding to nils's comment]: Thank you, thanks for responding!

*   [Responding to vrmiguel's question about depending on other extensions]:
    We actually add dependency to that one. That's bit of uh work, like PG
    rotting depends on PostGIS. In order to provide a seamless installation
    the PostGIS package, in the PostGIS spec file, I add an extra line that
    says it provides PostGiS without the version as part of the name. Then
    when we install pg rotting, it looks for any PostGIS package --- which is
    fine because it can run against any PostGIS version. So I add the
    dependency to other extensions if we need them.

    *   *David G. Johnston* in chat: The tooling ideally would report, say to
        PGXN or whatever the directory location for the initial application
        is, the issues and remind them that if the build system cannot build
        their extension it will not be included in the final RPM. You are an
        unpaid service provider for them and if they don't meet their
        obligations their don't get the benefit of the service.

*   [Responding to Eric's upstream follow-up question]: I haven't seen
    anything in any upstream  where a person didn't want me to package. But I
    haven't seen many appreciations, either; I mean they don't appreciate you.
    I'm being appreciated by EDB --- money, money, money, must be funny ---
    thanks EDB! But I haven't had any rejections so far. Good question!

    *   *Eric* in chat, replying to "When you decide to p…": Fair. Cool.
        Thanks

*   Relying on external repos is a big problem for SUSE. Some of the
    maintainers just discontinue their repo. One problem with SUSE is they
    don't have an EPEL-like repo. EPEL is a great thing. The barrier to add a
    package to EPEL is not low but not high, either. If you if you're an
    advanced packager you can add a package quick enough. Of course it
    requires review from others. But this a big problem for SUSE.

*   Lack of maintenance is a problem. We have a repo but they don't update it;
    so I have to go find another repo from build.opensuse.org, change it,
    update the website, change our build instance, etc. That's a big problem.

    *   *David Wheeler (he/him)* in chat, replying to "The tooling ideally
        ...": I want to add build and test success/fail matrices to extension
        pages on PGXN

    *   *Florents Tselai* in chat: How do you handle Pl/Python-based
        extensions + pip dependencies? Especially with virtualenv-based
        installations. i.e. Pl/Python usually relies on a /usr/bin/python3,
        but people shouldn't install dependencies there.

*   And then there's costs! What's the cost of RPMifying an extension? Hosting
    a build server?  We have a *very beefy* bare metal build server hosted by
    Enterprise DB, just because I'm working for them and they have a spare
    machine. Hosting a build server is a cost.
    
*   I have to use some external resources for architecture reasons, like some
    of our build instances, like PPC 64 ,is hosted somewhere else. There are
    some admin tasks to keep everything and running, like EDB's IT team
    actually helped me to fix an issue today in both of our PPC instances.
    
    *   *Jason Petersen* in chat, replying to "How do you handle Pl...":  I
        think early on he said he makes the extensions rely on RPMs that
        provide those Python dependencies
    
    *    *David Wheeler (he/him)* in chat, replying to "How do you handle
         Pl...": I have used this pattern for RPMifying Perl tools

*   Then, maintaining build instances requires keeping them up-to-date, and
    also that each update doesn't break anything. It's not like "dnf update
    and build a package". No. It may be a problem with Fedora because Fedora
    may can update anything any time they want. But it's a less problem for
    SUSE and RedHat, but we have to take care that the updates don't break
    anything.
    
*   Redhat, the company, actually follows our release schedule. We release
    every three months. Unless something bad happens, we know the next release
    is in May, on a Thursday. So every Wednesday, one day before our minor release,
    RedHat releases their new maintenance releases. RedHat is going
    to release 9.4 on Wednesday before our minor release. What does that mean
    for us as an RPM packager for RedHat?
    
*   *RedHat releases a new version with a new LLVM, for example, and then it
    means we have to rebuild the packages against the new LLVM so that people
    can use it. That means I have to work until Thursday morning to build the
    packages. That's fine but another problem is for Rocky and Alma Linux
    users, because they're are not going to have the updated LLVM package, or
    any any updated package, like GCC. It's not like the old RedHat days; they
    change everything uh in minor versions.

*   So I have to rebuild GCC and LLVM on our instances, add them to our
    special repo "sysupdates", which is in the config file, and this takes
    many hours because building GCC and LLVM is a big thing.
    
*   In the last two years I have not been able to build the from GCC Source
    RPM. I had to edit everything and not edit the spec files blah blah to be
    able to build it. I have no idea how how they can break in Source RPM.
    
*   So that's another cost: in May I'm going to spend lots of cycles to  keep
    up with the latest RedHat release, and also make the make the Rocky Linux
    and Alma Linux users happier. Maintaining build systems is not as easy as
    running Yup or Zypper update. It requires employing the packager ---
    because I have the bills pay I have the beers to drink.
    
*   [Addressing Florents's PL/Python question]: I don't know what the
    PL/Python based extensions are, but I tried to get rid of everything
    related to pip. I'm not a developer, a DBA isn't a developer, a Sysadmin
    isn't a developer. They're not suposed to use pip; they are supposed to
    use the package manager to keep up with everything. My point is if someone
    needs pip then *I* should fix it. That's what I did for Patroni. I added
    lots of packages to our Git repo just to be able to support Patroni.

    *   *Ian Stanton* in chag: Need to drop, thank you Devrim!

    *   *Jeremy S* in chat, replying to "How do you handle Pl...": A lot of
        larger companies have inventory management and risk control processes
        that heavily leverage package management

    *   *Alvaro Hernandez* in chat: Need to go, ttyl!

    *   *vrmiguel in chat, replying to "you said “gcc” and n...": Do you think
        there are no guarantees at all? For instance, Postgres loads up the
        extension with `dlopen`, which could fail with `version mismatch`. If
        that doesn't occur and the extension loads 'fine', how likely do you
        think an issue could be?
        
        Also I'm curious how often you've seen problems arise from libc itself
        (rather than any of the many things that could cause UB in a C
        program) and how these problems have manifested
    
    *   *Ahmet Melih Başbuğ* in chat: Thank you

## Conclusion

I thanked Devrim and all the discussion, and pitched the next [mini-summit],
where I *think* Jonathan Katz will talk about the TLE vision and specifics.

Thank you all for coming!

  [mini-summit]: https://www.eventbrite.com/e/851125899477/
    "Postgres Extension Ecosystem Mini-Summit"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [Devrim Gündüz]: https://github.com/devrimgunduz
  [Yum]: https://yum.postgresql.org "PostgreSQL Yum Repository"
  [ZYpp]: https://zypp.postgresql.org "PostgreSQL Zypper Repository"
  [EDB]: https://www.enterprisedb.com
    "EDB: Open-Source, Enterprise Postgres Database Management"
  [@pgxn@botsin.space]: https://botsin.space/@pgxn
  [blackhole_fdw]: https://bitbucket.org/adunstan/blackhole_fdw/src
  [redmine.postgresql.org]: https://redmine.postgresql.org
  [on wiki.postgresql.org]: https://wiki.postgresql.org/wiki/PostgreSQL_16_Extension_Bugs