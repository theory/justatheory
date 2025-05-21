---
title: 2025 Postgres Extensions Mini Summit One
slug: mini-summit-one
date: 2025-03-24T20:46:58Z
lastMod: 2025-03-24T20:46:58Z
description: |
  A rough transcript of my talk "State of the Extension Ecosystem".
tags: [Postgres, PGXN, Extensions, PGConf, Summit, Transcript]
type: post
---

Back on March 12, we hosted the first in a series of [PostgreSQL Extensions
Mini Summits][mini-summit] leading up to the [Extension Ecosystem
Summit][summit] at PGConf.dev on May 13. I once again inaugurated the series
with a short talk on the State of the Extension Ecosystem. The talk was
followed by 15 minutes or so of discussion. Here are the relevant links:

*   [Video](https://www.youtube.com/watch?v=ebHpEDX9D2Y)
*   [OCI Demo][oci-demo]
*   [Slides]({{% link "/shared/extension-ecosystem-summit/state-of-the-ecosystem-mini-summit-2025.pdf" %}})

And now, with many thanks to [Floor Drees] for the effort, the transcript from
the session.

## Introduction

Floor Drees introduced the organizers:

*   [David Wheeler], Principal Architect at [Tembo], maintainer of [PGXN]
*   [Yurii Rashkovskii], [Omnigres]
*   [Keith Fiske], [Crunchy Data]
*   [Floor Drees], Principal Program Manager at [EDB], PostgreSQL CoCC member,
    PGDay Lowlands organizer

David presented a State of the Extension Ecosystem at this first event, and
shared some updates from PGXN land.

The stream and the closed captions available for the recording are supported
by PGConf.dev and their gold level [sponsors], Google, AWS, Huawei, Microsoft,
and EDB.

## State of the Extensions Ecosystem

So I wanted to give a brief update on the state of the Postgres extension
ecosystem, the past, present, and future. Let's give a brie history; it's
quite long, actually.

There were originally two approaches back in the day. You could use shared
preload libraries to have it preload dynamic shareable libraries into the main
process. And then you could do pure SQL stuff using, including procedural
languages like PL/Perl, PL/Tcl, and such.

And there were a few intrepid early adopters, including PostGIS, BioPostgres,
PL/R, PL/Proxy, and pgTAP, who all made it work. Beginning of Postgres 9.1
Dimitri Fontaine added support for explicit support for extensions in the
Postgres core itself. The key features included the ability to compile and
install extensions. This is again, pure SQL and shared libraries.

There are `CREATE`, `UPDATE`, and `DROP EXTENSION` commands in SQL that you
can use to add extensions to a database, upgrade them to new versions and to
remove them. And then `pg_dump` and `pg_restore` support so that extensions
could be considered a single bundle to be backed up and restored with all of
their individual objects being included as part of the backup.

Back then, a number of us, myself included, saw this as an opportunity to have
the extensibility of Postgres itself be a fundamental part of the community
and distribution. I was a long time user of Perl and used CPAN, and I thought
we had something like CPAN for Postgres. So, I proposed [PGXN], the
PostgreSQL Extension Network, back in 2010. The idea was to do distribution of
source code. You would register namespaces for your extensions.

There was discovery via a website for search, documentation published, tags to
help you find different kinds of objects, and to support installation through
a command line interface. The compile and install stuff that Postgres itself
provides, using PGXS and Configure.

This is what PGXN looks like today. It was launched in 2011. There's a command
line client, this website, an API an a registry you can upload your extensions
to. The most recent one was `pg_task` a day or so ago.

In the interim, since that came out in 2011/2012, the cloud providers have
come into their own with Postgres, but their support for extensions tends to
be rather limited. For non-core extension counts, as of yesterday, Azure
provides 38 extensions, GCP provides 44 extensions, and AWS 51. These are the
third party extensions that don't come with Postgres and its contrib itself.
Meanwhile, PGXN has 420 extensions available to download, compile, build, and
install.

A GitHub project that tracks random extensions on the internet,
([joelonsql/PostgreSQL-EXTENSIONs.md][gist]), which is pretty comprehensive,
has almost 1200 extensions listed. So the question is why is the support not
more broad? Why aren't there a thousand extensions available in every one of
these systems?

Rthis has been a fairly common question that's come up in the last couple
years. A number of new projects have tired to fill in the gaps. One is
[Trusted Language Extensions][pg_tle]. They wanted to make it easier to
distribute extensions without needing dynamic shared libraries by adding
additional features in the database itself.

The idea was to empower app developers to make it easy to install extensions
via SQL functions rather than having to access the file system of the database
server system itself. It can be portable, so there's no compilation required,
it hooks into the create extension command transparently, supports custom data
types, and there have been plans for foreign data wrappers and background
workers. I'm not sure how that's progressed in the past year. The [pg_tle]
extension itself was created by AWS and Supabase. 

Another recent entrant in tooling for extensions is [pgrx], which is native
Rust extensions in Postgres. You build dynamic shared libraries, but write
them in pure Rust. The API for pgrx provides full access to Postgres features,
and still provides the developer-friendly tooling that Rust developers are
used to. There's been a lot of community excitement the last couple of years
around pgrx, and it remains under active development --- version 0.13.0 just
came out a week or so ago. It's sponsored and run out of the PgCentral
Foundation.

There have also been a several new registries that have come up to try to fill
the gap and make extensions available. They have emphasized different things
than PGXN. One was ease of use. So, for example, here [pgxman] says it should
be really easy to install a client in a single command, and then it installs
something, and then it downloads and installs a binary version of your an
extension.

And then there was platform neutrality. They wanted to do binary distribution
and support multiple different platform, to know what binary∑ to install for a
given platform. They provide stats. PGXN doesn't provide any stats, but some
of them are list stats like how many downloads we had, how many in the last
180 days.

And curation. Trunk is another binary extension registry, from my employer,
Tembo. They do categorization of all the extensions on Trunk, which is at 237
now. Quite a few people have come forward to tells us that they don't
necessarily use Trunk to install extensions, but use them to find them,
because the categories are really helpful for people to figure out what sorts
of things are even available, and an option to use.

So here's the State of the Ecosystem as I see it today.

*   There have been some lost opportunities from the initial excitement around
    2010. Extensions remain difficult to find and discover. Some are on PGXN,
    some are on GitHub, some are on Trunk, some are on GitLab, etc. There's no
    like one place to go to find them all.

*   They remain under-documented and difficult to understand. It takes effort
    for developers to write documentation for their extensions, and a lot of
    them aren't able to. Some of them do write the documentation, but they
    might be in a format that something like PGXN doesn't understand.

*   The maturity of extensions can be difficult to gauge. If you look at that
    [list of 1200 extensions][gist] on GitHub, which ones are the good ones?
    Which ones do people care about? That page in particular show the number
    of stars for each extension, but that the only metric.

*   They're difficult to configure and install. This is something TLE really
    tried to solve, but the uptake on TLE has not been great so far, and it
    doesn't support all the use cases. There are a lot of use cases that need
    to be able to access the internal APIs of Postgres itself, which means
    compiling stuff into shared libraries, and writing them in C or Rust or a
    couple of other compiled languages.

    That makes them difficult to configure. You have ask questions lik: Which
    build system do I use? Do I install the tooling? How do I install it and
    configure it? What dependencies does it have? Et cetera.

*   There's no comprehensive binary packaging. The Postgres community's own
    packaging systems for Linux --- Apt, and YUM --- do a remarkably good job
    of packaging extensions. They probably have more extensions packaged for
    those platforms than any of the others. If they have the extension you
    need and you're using the PGDG repositories, then this stuff is there. But
    even those are still like a fraction of all the potential available
    extensions that are out there.

*   Dependency management can be pretty painful. It's difficult to know what
    you need to install. I was messing around  yesterday with the PgSQL HTTP
    extension, which is a great extension that depends on libcurl. I thought
    maybe I could build a package that includes libcurl as part of it. But
    then I realized that libcurl depends on other packages, other dynamic
    libraries. So I'd have to figure out what all those are to get them all
    together.
    
    A lot of that goes away if you use a system like apt or yum. But if you,
    if you don't, or you just want to install stuff on your Mac or Windows,
    it's much more difficult.
    
*   Centralized source distribution, we've found found, is insufficient. Even
    if all the extensions were available on PGXN, not everybody has the
    wherewithal or the expertise to find what they need, download it, compile
    it, and build it. Moreover, you don't want to have a compiler on your
    production system, so you don't want to be building stuff from source on
    your production system. So then you have to get to the business of
    building your own packages, which is a whole thing.

But in this state of the extension ecosystem we see new opportunities too. One
I've been working on for the past year, which we call "PGXN v2", is made
possible by my employer, Tembo. The idea was to consider the emerging patterns
--- new registries and new ways of building and releasing and developing
extensions --- and to figure out the deficiencies, and to engage deeply with
the community to work up potential solutions, and to design and implement a
new architecture. The idea is to serve the community for the next decade
really make a PGXN and its infrastructure the source of record for extensions
for Postgres.

In the past year, I did a bunch of design work on it. Here's a high level
architectural view. We'd have a root registry, which is still the source code
distribution stuff. There's a web UX over it that would evolve from the
current website. And there's a command line client that knows how to build
extensions from the registry.

But in addition to those three parts, which we have today, we would evolve a
couple of additional parts.

1.  One is "interactions", so that when somebody releases a new extension on
    PGXN, some notifications could go out through webhooks or some sort of
    queue so that downstream systems like the packaging systems could know
    something new has come out and maybe automate building and updating their
    packages.

2.  There could be "stats and reports", so we can provide data like how many
    downloads there are, what binary registries make them available, what
    kinds of reviews and quality metrics rate them. We can develop these stats
    and display those on the website.

3.  And, ideally, a "packaging registry" for PGXN to provide binary packages
    for all the major platforms of all the extensions we can, to simplify the
    installation of extensions for anybody who needs to use them. For
    extensions that aren't available through PGDG or if you're not using that
    system and you want to install extensions. Late last year, I was focused
    on figuring out how t build the packaging system.

Another change that went down in the past year was the Extension Ecosystem
Summit itself. This took place at PGConf.Dev last May. The idea was for a
community of people to come together to collaborate, examine ongoing work in
the extension distribution, examine challenges, identify questions, propose
solutions, and agree on directions for execution. Let's take a look at the
topics that we covered last year at the summit.

*   One was extension metadata, where the topics covered included packaging
    and discoverability, extension development, compatibility and taxonomies
    as being important to represent a metadata about extensions --- as well as
    versioning standards. One of the outcomes was [an RFC][meta-v2] for
    version two of the PGXN metadata that incorporates a lot of those needs
    into a new metadata format to describe extensions more broadly.

*   Another topic was the binary distribution format and what it should look
    like, if we were to have major, distribution format. We talked about being
    able to support multiple versions of an extension at one time. There was
    some talk about the Python Wheel format as a potential precedent for
    binary distribution of code.

    There's also an idea to distribute extensions through Docker containers,
    also known as the [Open Container Initiative][OCI]. Versioning came up
    here, as well. One of the outcomes from this session was another PGXN [RFC
    for binary distribution], which was inspired by Python Wheel among other
    stuff.

    I wanted to give [a brief demo][oci-demo] build on that format. I hacked
    some changes into the PGXS `Makefile` to add a new target, `trunk` that
    builds a binary package called a "trunk" and uploads it to an OCI registry
    for distribution. [Here's what it looks like][oci-demo].
    
    *   On my Mac I was compiling my semver extension. Then I go into a Linux
        container and compile it again for Linux using the `make trunk`
        command. The result is two `.trunk` files, one for Postgres 16 on
        Darwin and one for Postgres 16 on Linux.

    *   There are also some JSON files that are annotations specifically for
        OCI. We have a command where we can push these images to an OCI
        registry.
        
    *   Then we can then use an install command that knows to download and
        install the version of the build appropriate for this platform
        (macOS). And then I go into Linux and do the same thing. It also
        knows, because of the OCI standard, what the platform is, and so it
        installs the appropriate binary.

*   Another topic was ABI and API compatibility. There was some talk at the
    Summit about what is the definition of an ABI and an API and how do we
    define internal APIs and their use? Maybe there's some way to categorize
    APIs in Postgres core for red, green, or in-between, something like that.
    There was desire to have more hooks available into different parts of the
    system.

    One of the outcomes of this session was that I worked with Peter
    Eisentraut on some stability guidance for the API and ABI that is now
    committed in the docs. You can [read them now] on in the developer docs,
    they'll be part of the Postgres 18 release. The idea is that minor version
    releases should be safe to use with other minor versions. If you compiled
    your extension against one minor version, it should be perfectly
    compatible with other minor versions of the same major release.

    Interestingly, there was a release earlier this year, like two weeks after
    Peter committed this, where there was an API break. It's the first time in
    like 10 years. Robert Treat and I spent quite a bit of time trying to look
    for a previous time that happened. I think there was one about 10 years
    ago, but then this one happened and, notably it broke the Timescale
    database. The Core Team decided to release a fix just a week later to
    restore the ABI compatibility.
    
    So it's clear that even though there's guidance, you should in general
    be able to rely on it, and it was a motivating factor for the a new
    release to fix an ABI break, there are no guarantees.

    Another thing that might happen is that I [proposed a Google Summer of
    Code project to build an ABI checker service][gsoc-idea]. Peter
    [embarrassing forgetfulness and misattributed national identity omitted]
    Geoghegan [POC'd an ABI checker] in 2023. The project is to take Peter's
    POC and build something that could potentially run on every commit or push
    to the back branches of the project. Maybe it could be integrated into the
    build farm so that, if there's a back-patch to an earlier branch and it
    turns red, they quickly the ABI was broken. This change could potentially
    provide a higher level of guarantee --- even if they don't end up using
    the word "guarantee" about the stability of the ABIs and APIs. I'm hoping
    this happens; a number of people have asked about it, and at least one
    person has written an application.
    
*   Another topic at the summit last year was including or excluding
    extensions in core. They've talked about when to add something to core,
    when to remove something from core,  whether items in contrib should
    actually be moved into core itself, and whether to move metadata about
    extensions into catalog. And once again, support for multiple versions
    came up; this is a perennial challenge! But I'm not aware of much work on
    these questions. I'm wondering if it's time for a revisit,
    
*   As a bonus item --- this wasn't a formal topic at the summit last year,
    but it came up many times in the mini-summits --- is the challenge of
    packaging and lookup. There's only one path to extensions in `SHAREDIR`.
    This creates a number of difficulties. Christoph Berg has a patch for a
    PGDG and Debian that adds a second directory. This allowed the PGDG stuff
    to actually run tests against extensions without changing the core
    installation of the Postgres service itself. Another one is [Cloud Native
    Postgres][CNPG] immutability. If that directory is part of the image, for
    your CloudNative Postgres, you can't install extensions into it.
    
    It's a similar issue, for [Postgres.app] immutability. Postgres.app is a
    Mac app, and it's signed by a  certificate provided by Apple. But that
    means that if you install an extension in its `SHAREDIR`, it changes the
    signature of the application and it won't start. They work around this
    issue through a number of symlink shenanigans, but these issues could be
    solved by allowing extension to be installed in multiple locations.
    
    Starting with Christoph's search path patch and a number of discussions we
    had at PGConf last year, [Peter Eisentraut] has been working on a search
    path patch to the core that would work similar to shared preload
    libraries, but it's for finding extension control files. This would allow
    you to have them in multiple directories and it will find them in path.

    Another interesting development in this line has been, the
    [CloudNativePG][CNPG] project has been using that extension search path
    patch to prototype a new feature coming to Kubernetes that allows one to
    mount a volume that's actually another Docker image. If you have your
    extension distributed as an OCI image, you can specify that it be mounted
    and installed via your CNPG cluster configuration. That means when CNPG
    spins up, it puts the extension in the right place. It updates the search
    path variables and stuff just works.

    A lot of the thought about the stuff went into a [less formal RFC] I wrote
    up in my blog, rather than on PGXN. The idea is to take these improvements
    and try to more formally specify the organization of extensions separate
    from how Postgres organizes shared libraries and shared files.

I said, we're bringing the Extension Summit back! There will be another
Extension Summit hosted our team of organizers, myself, Floor, Keith Fiske
from Crunchy Data, and Yurii from Omnigres. That will be on May 13th in the
morning at [PGConf.dev]; we appreciate their support.

The idea of these Mini Summits is to bring up a number of topics of interest.
Have somebody come and do a 20 or 40 minute talk about it, and then we can
have discussion about implications.

Floor mentioned the schedule, but briefly:

*   March 12: [David Wheeler], PGXN: "State of the Extension Ecosystem”
*   March 24: [Peter Eisentraut], Core Team: "Implementing an Extension Search Path" 
*   April 9: [Christoph Berg], Debian: "Apt Extension Packaging"
*   April 23: 
*   May 7: [Gabriele Bartolini], CNPG "Extension Management in CloudNativePG"

So, what are your interests in extensions and how they can be improved. There
are a lot of potential topics to talk about at the Summit or at these Mini
Summits: development tools, canonical registry, how easy it is to publish,
continuous delivery, yada, yada, yada, security scanning --- all sorts of
stuff that could go into conceiving, designing, developing, distributing
extensions for Postgres. 

I hoe you all will participate. I appreciate you taking the time to listen to
me for half an hour. So I'd like to turn it over to, discussion, if people
would like to join in, talk about implications of stuff. Also, we can get to
any questions here. 

## Questions, comments, shout-outs

*Floor*: David, at one point you talked about, metadata taxonomy. If you can
elaborate on that a little bit, that's Peter's question.

*David*: So one that people told me that they found useful was one provided by
[Trunk]. So it has these limited number of categories, so if you're interested
in machine learning stuff, you could go to the [machine learning] stuff and it
shows you what extensions are potentially available. They have 237 extensions
on Trunk now.

PGXN itself allows arbitrary tagging of stuff. It builds [this little tag
cloud]. But if I look at this one here, you can see [this one] has a bunch of
tags. These are arbitrary tags that are applied by the author. The current
metadata looks [like this]. It's just plain JSON, and it has a list of tags.
The [PGXN Meta v2 RFC][meta-v2] has a bunch of examples. It's an evolution of
that `META.json`, so the idea is to have a classifications that includes tags
as before, but also adds categories, which are a limited list that would be
controlled by the core [he means "root"] registry:

```json
{
  "classifications": {
    "tags": [
      "testing",
      "pair",
      "parameter"
    ],
    "categories": [
      "Machine Learning"
    ]
  }
}
```

## Announcements

Yurii made a number of announcements, summarizing:

*   There is a new library that they've been developing at Omnigres that
    allows you to develop Postgres extensions in C++. For people who are
    interested in developing extensions in C++ and gaining the benefits of
    that and not having to do all the tedious things that we have to do with C
    extensions: look for [Cppgres]. Yurii thinks that within a couple of
    months it will reach parity with pgrx.

    *David*: So it sounds like it would work more closely to the way PGXS and
    C works. Whereas pgrx has all these additional Rust crates you have to
    load and like slow compile times and all these dependencies.

    *Yurii*: This is just like a layer over the C stuff, an evolution of that.
    It's essentially a header only library, so it's a very common thing in the
    C++ world. So you don't have to build anything and you just include a
    file. And in fact the way I use it, I amalgamate all the header files that
    we have into one. Whenever I include it in the project, I just copy the
    amalgamation and it's just one file. You don't have any other build chain
    associated yet. It is C++ 20, which some people consider new, but by the
    time it's mature it's already five years old and most compilers support
    it. They have decent support of C++ 20 with a few exclusions, but those
    are relatively minor. So for that reason, it's not C++ 23, for example,
    because it's not very well supported across compilers, but C++ 20 is.

*   Yurii is giving a talk about [PostgresPM] at the Postgres Conference in
    Orlando. He'll share the slides and recording with this group. The idea
    behind PostgresPM is that it takes a lot of heuristics, takes the URLs of
    packages and of extensions and creates packages for different outputs like
    for Red Hat, for Debian, perhaps for some other formats in the future. It
    focuses on the idea that a lot of things can be figured out.
    
    For example: do we have a new version? Well, we can look at list of tags
    in the Git repo. Very commonly that works for say 80 percent of
    extensions. Do we need a C compiler? We can see whether we have C files.
    We can figure out a lot of stuff without packagers having to specify that
    manually every time they have a new extension. And they don't have to
    repackage every time there is a new release, because we can detect new
    releases and try to build.

*   Yurii is also running an event that, while not affiliated with PGConf.dev,
    is strategically scheduled to happen one day before PGConf.dev: [Postgres
    Extensions Day]. The Call for Speakers is open until April 1st. There's
    also an option for people who cannot or would not come to Montréal this
    year to submit a prerecorded talk. The point of the event is not just to
    bring people together, but also ti surface content that can be interesting
    to other people. The event itself is free.

Make sure to join our [Meetup group][mini-summit] and join us live, March 26,
when [Peter Eisentraut] joins us to talk about implementing an extension search
path.  

  [mini-summit]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/
    "Postgres Extension Ecosystem Mini-Summit on Meetup"
  [summit]: https://www.pgevents.ca/events/pgconfdev2025/schedule/session/241/
    "PGConf.dev: Extensions Ecosystem Summit"
  [oci-demo]: {{% ref "/post/postgres/trunk-oci-poc" %}}#demo
    "POC: Distributing Trunk Binaries via OCI (Demo)"
  [David Wheeler]: {{% ref "/" %}}
  [Tembo]: https://tembo.io/
  [PGXN]: https://pgxn.org/
  [Yurii Rashkovskii]: https://ca.linkedin.com/in/yrashk
  [Omnigres]: https://omnigres.com/
  [Keith Fiske]: https://pgxn.org/user/keithf4/
  [Crunchy Data]: https://www.crunchydata.com/
  [Floor Drees]: https://dev.to/@floord
  [EDB]: https://enterprisedb.com "EnterpriseDB"
  [PGConf.dev]: https://2025.pgconf.dev "PostgreSQL Development Conference 2025"
  [sponsors]: https://2025.pgconf.dev/sponsors.html
  [gist]: https://gist.github.com/joelonsql/e5aa27f8cc9bd22b8999b7de8aee9d47
  [pg_tle]: https://github.com/aws/pg_tle
    "pg_tle: Framework for building trusted language extensions for PostgreSQL"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [pgxman]: https://pgxman.com/ "npm for PostgreSQL"
  [meta-v2]: https://github.com/pgxn/rfcs/pull/3 "RFC: Meta Spec v2"
  [OCI]: https://opencontainers.org
  [RFC for binary distribution]: https://github.com/pgxn/rfcs/pull/2
    "RFC: Binary Distribution Format"
  [read them now]: https://www.postgresql.org/docs/devel/xfunc-c.html#XFUNC-API-ABI-STABILITY-GUIDANCE
    "Postgres Docs: Server API and ABI Stability Guidance"
  [gsoc-idea]: https://wiki.postgresql.org/wiki/GSoC_2025#ABI_Compliance_Checker
    "PostgreSQL Wiki/GSoC 2025: ABI Compliance Checker"
  [POC'd an ABI checker]: https://postgr.es/m/CAH2-Wzm-W6hSn71sUkz0Rem=qDEU7TnFmc7_jG2DjrLFef_WKQ@mail.gmail.com
  [CNPG]: https://cloudnative-pg.io "Run PostgreSQL. The Kubernetes way."
  [Postgres.app]: https://postgresapp.com
  [less formal RFC]: {{% ref "/post/postgres/rfc-extension-packaging-lookup" %}}
    "RFC: Extension Packaging & Lookup"
  [Trunk]: https://pgt.dev
  [Peter Eisentraut]: https://peter.eisentraut.org
  [Christoph Berg]: https://www.df7cb.de
  [Gabriele Bartolini]: https://www.gabrielebartolini.it
  [machine learning]: https://pgt.dev/?cat=machine_learning
    "Trunk Categories: Machine Learning"
  [this little tag cloud]: https://pgxn.org/tags "PGXN: Release Tags"
  [this one]: https://pgxn.org/dist/uint128/1.0.1/ "PGXN: uint128 v1.0.1"
  [like this]: https://api.pgxn.org/src/uint128/uint128-1.0.1/META.json
    "PGXN: uint128 v1.0.1 META.json"
  [Cppgres]: https://cppgres.org
  [PostgresPM]: https://github.com/postgres-pm/pgpm
  [Postgres Extensions Day]: https://pgext.day
