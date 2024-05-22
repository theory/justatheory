---
title: Mini Summit Six
slug: mini-summit-six
date: 2024-05-22T21:56:50Z
lastMod: 2024-05-22T21:56:50Z
description: |
  A rough transcript of the sixth and final Extension Ecosystem Mini-Summit,
  in which we review potential topics for the in-person summit at PGConf.dev
  and discuss how to organize it.
tags: [Postgres, PGXN, Extensions, PGConf, Summit]
type: post

---

Last week, a few members of the community got together for for the sixth and
final [Postgres Extension Ecosystem Mini-Summit][mini-summit]. Follow these
links for the video and slides:

*   [Video](https://www.youtube.com/watch?v=6o1N1-Eq-Do)
*   [Keynote]({{% link "/shared/extension-ecosystem-summit/organizing-topics.key" %}})
*   [PDF Slides]({{% link "/shared/extension-ecosystem-summit/organizing-topics.pdf" %}})

Or suffer through my interpolation of YouTube's auto-generated transcript,
interspersed with chat activity, if you are so inclined.

## Introduction

*   I opened the meeting, welcomed everyone, and introduced myself as host. I
    explained that today I'd give a brief presentation on the list of issues I
    I've dreamed up and jotted down over the last couple mini-summits as
    possible potential topics to take on at [the Summit] in Vancouver on May
    28th.

## Presentation

*   These are things that I've written down as I've been thinking through the
    whole architecture myself, but also that come up in these Summits. I'm
    thinking that we could get some sense of the topics that we want to
    actually cover at the summit. There is room for about 45 people, and I
    assume we'll break up "unconference style" into four or five working
    groups. People an move to corners, hallways, or outdoors to discuss
    specific topics.
    
*   Recall the [first mini-summit] I showed a list of things that of potential
    topics that might come up as we think through what's issues in the
    ecosystem. I left off with the prompt "What's important to you?" We hope
    to surface the most important issues to address at the summit and create a
    hierarchy. To that end, I've created this Canva board[^canva-link]
    following [Open Space Technology][][^oops] to set things up, with the
    rules and an explanation for how it workjs.

*   I expect one of us (organizers) to give a brief introduction at the
    start of the summit to outline the principles of [Open Space Technology],
    which are similar to unconferences.

*   [Open Space Technology] principles are:
    *   Whoever comes are the right people
    *   Whatever happens is the only thing that could happen
    *   Whenever it starts at the right time (but we start at 2 p.m. and we
        have only three hours so we'll try to make the best of it)
    *   When it's over it's over
    *   And whatever happens is the right place 

*   There is also a "Law of Mobility". If you start out interested in one
    topic and attending a session or discussion about one topic, and you
    decide you want to do something else, you can wander over to another
    session . Open Space Technology calls these people "bumblebees" who
    cross-pollinate between topics. "Butterflies" are the people who hover
    around a particular topic to make it happen.
    
*   And "Come to be Surprised" about what will come up.

*   I've split potential topics into topics in Post-its. we might have four or
    five spaces. Pick a space, pick a session; we have two two-hour-long
    sessions. I assume we'll have 15-30 minutes to open the Summit, do intros,
    and split up the sessions; then have people do an hour on one topic and an
    hour on a second topic. At the end, we'll do the readout in which we talk
    about decisions we came to.

*   If you're interested in facilitating any of these topics, simply drag it
    in and stick your name on it.

*   First I thought I'd briefly go over the list of topics as I've imagined
    them. I posted the list on Slack a couple weeks ago and added to it as
    things have come up in the discussions. But I want to give a high level
    view of what these brief descriptions mean.

*   This is ad-hoc; I don't have anything super planned. Please feel free to
    jump in at any time! I think I've turned on "talking permitted" for
    everybody, or stick your hand up and we'll be glad to figure out other
    stuff, especially if you're thinking of other topics or related things, or
    if you think things should be merged.
    
*   Any questions or thoughts or comments?

*   I put the topics in broad categories. There's some crossover, but the the
    first one I think of is metadata. I've thought about metadata a fair bit,
    and drafted an RFC for the kinds of things to put in an updated metadata
    standard, like:

    *   How do you specify third-party dependencies? For example, PostGIS
        depends on additional libraries; how can those be specified in an
        ideally platform neutral way within the metadata?

    *   How to specify the different types of extensions there are? Stephen
        wrote a blog post last year about this: you have `CREATE EXTENSION`
        extensions, `LOAD` command extensions, background workers,
        applications, and more. You have things that need
        `shared_preload_libraries` and things that don't. How do we describe
        those things about an extension within a distribution package?

    *   Taxonomies have come up a few times. PGXN currently allows extension
        authors to put an arbitrary number of tags into their `META.json`
        file. Maybe in part because of the precedent of the stuff that that I
        released early on, people mostly put stuff in there to describe it,
        like "fdw", or "function" or "JSON". Some of the newer uh binary
        distribution packaging systems, in particular Trunk, have a curated
        list of categories that they assign. so there might be different ways
        we want to classify stuff.

        Another approach is crates.io, which has a canonical list of
        categories (or "slugs"), that authors can assign. These are handy they
        group things together in a more useful way, like "these are related to
        data analytics" or "these are related to Vector search" --- as opposed
        to the descriptive tags PGXN has now. So, what ought that to look
        like? What kind of controls should we have? And who might want to use
        it?

    *   How would we specify system requirements. For example "this package
        requires only a subset of OSes", or the version of an OS, or the
        version of postgres, or CPU features. Steven's mentioned vector-based
        ones a few times, but there's also things like encryption instructions
        provided by most chips. Or the CPU architecture, like "this supports
        aarch64 but not amd64." How should we specify that?

    *   I covered  categorization under taxonomies
    
    *   Versioning. I blogged about this a couple months ago. I'm reasonably
        sure we should just stick to SemVer, but it's worth bringing up.

*   Thoughts on metadata, or stuff I've left out? This is in addition to the
    stuff that's in the [`META.json` spec][PGXN Meta spec]. It leaves room for
    overlap with core stuff. How do we create one sort of metadata for
    everything, that might subsume the control file as well as the metadata
    spec or `trunk.toml`?
    
    *   *Jeremy S* in chat: So far this is seeming like a good recap of
        ground that’s been covered, questions & topics that have been
        raised. Great to see how broad it’s been

*   The next category is the source registry. This is thinking through
    how we should evolve the PGXN root registry for distributing
    extension source code. There are questions like identity, namespacing,
    and uniqueness.
    
    *   These are broad categories but identity is how do you identify
        yourself to the system and claim ownership over something.
    
    *   What sort of namespacing should we use? Most systems, including PGXN,
        just use an arbitrary string and you own a string from [first
        release]. But other registries, like Go, allow you to use domain-based
        namespacing for packages. This is really nice because it allows a lot
        more flexibility, such as the ability to switch between different
        versions or forks.
        
    *   Then there's the level of uniqueness of the namespacing. This is kind
        of an open question. Another another approach I thought of is that,
        rather than string that names your extension distribution being
        unique, it could be your username *and* the string. That makes it
        easier when somebody abandoned something and somebody else forks it
        and has a new username. Then maybe people can switch more easily. To
        be able to account for and handle that sort of evolution in a way that
        single string uniqueness makes trickier.
        
    *   Distributed versus centralized publishing. I've written about this a
        couple times. I am quite attracted to the Go model where packages are
        not centrally distributed but are in three or four supported Version
        Control Systems, and as long as they use SemVers and appropriate tags,
        anybody can use them. The centralized index just indexes a package
        release the first time it's pulled. This is where host names come into
        play as part of the namespacing. It allows the system to be much more
        distributed. Now Go caches all of them in a number of different
        regions, so when you download stuff it goes through the Go stuff. When
        you say "give me the XYZ package," it'll generally give you the cached
        version, but will fall back on the repositories as well. So there's
        still the centralized stuff.

        I think there's a a lot to that and it goes along with the namespacing
        issue. But there are other ideas at play as well. For example, almost
        all the other source code distribution systems just use a centralized
        system: crates.io, CPAN, npm, and all the rest.

        And maybe there are other questions to consider, like is there some
        sort of protocol we should adopt as an abstraction, such as Docker,
        where Docker is not a centralized repository other than
        hub.docker.com. Anyone can create a new Docker repository, give it a
        host name, and then it becomes something that anybody can pull from.
        It's much more distributed. So there are a number of ideas to think
        through.
        
    *   Binary packaging and distribution patterns. I have a separate slide
        that goes into more detail, but there are implications for source code
        distribution, particularly with the metadata but perhaps other things.
        We also might want to think through how it might vary from source
        distribution.
        
    *   Federated distribution gets at the Docker idea, or the [OCI idea] that
        Alvaro proposed a few weeks ago. Stuff like that.
        
    *   What services and tools to improve or build. This goes to the
        fundamental question of why we've had all these new packaging systems
        pop up in the last year or so. People were saying "there are problems
        that aren't solved by PGXN." How do we as a community collectively
        decide what are the important bits and what we should build and
        provide. Features include developer tools, command line clients,
        search & browse, and discovery.
    
    *   Stats, reports, and badging. This is another fundamental problem that
        some of the emerging registries have tried to to address: How do you
        *find* something? How do you know if it's any good? How do you know
        who's responsible for it? How do you know whether there's some
        consensus across the community to use it? The topic, then, is what
        sort of additional metadata could we provide at the registry level to
        include some hint about these issues. For example, a system to
        regularly fetch stars and statistical analysis of a GitHub or a
        Bitbucket project. Or people wanted review sites or the ability to
        comment on on systems.
        
        There's also badging, in particular for build and test matrices for
        extensions that will not only encourage people to better support broad
        arrays of versions of Postgres and platforms. There could be badges
        for that. so you can see how well an extension supports various
        platforms. And any other sort of badging, like quality badging. The
        idea is a brainstorming of what sorts of things might be useful there,
        and what what might be best to build first, might be the the low
        hanging fruit.

*   Any questions, comments,m thoughts, additional suggestions on the root
    registry?

### Interlude

*   Steven Miller: So the idea is there are topics on the left and then they
    get lined up into the schedule? So there are five five different rooms, so
    horizontally aligned it4ms are at the same time?
    
*   David Wheeler (he/him): Correct. These are session one and these are
    session two.

*   Jeremy S: I was kind of waiting to jump to that. It seemed like you were
    just doing a review of all the topics we've covered, but I was waiting
    until till you got through everything to bring that up.
    
*   Steven Miller: Oh yeah, good call, good call.

*   Jeremy S: I have the same kind of question/concern. This is a great list
    of topics, now what do we want to do with the time in Vancouver? David, do
    you think we need to go through everything on the list? How do you want to
    spend the time today?

*   David Wheeler (he/him): I was trying to do a quick review just so people
    knew what these words mean. If you all feel like you have a good idea, or
    you want to add topics of your own, please do!
    
*   Jeremy S: Like I commented in the chat, it's amazing to see how much
    ground we've covered, and it's good to have a a quick recap. It's 9:22
    right now Pacific time --- 22 after the hour wherever you are --- I just
    want to make sure we don't run out of time going through everything.

*   David Wheeler (he/him): I agree, I'll make it work. I can speed up a
    little. I know I can be verbose about some of this stuff.

*   David G. Johnson: Unless the ones from India, in which case they have half
    hour time zone.

*   David Wheeler (he/him): I was gonna say! [Laughs]

### Presentation Continues

*   Binary packaging. This is the problem that PGXMan and trunk have tried to
    solve with varying degrees of success. I think it'd be worthwhile for us
    to think through as a community what, ideally, should a community-provided
    binary packaging system look like?
    
    *   And what's the format? Do we want to do tarballs, do OCI like Alvaro
        proposed? Do we want something like RPM or Apt or Python wheels?
        That's a that's actually something I'm super interested to get into.
        There was a question that came up two weeks ago in Yurri's
        presentation. I think Daniele suggested that the Python wheel package
        format allows you to put dynamic libs into the wheel. That's pretty
        interesting and worth looking into as well.
    
    *   How we go about building a community-based binary packaging registry?
        How do we do the build farming, what platforms and architectures and
        OSes would it support, and what sort of security, trust, and
        verification? And the centralization: who runs it, who's responsible
        for it, how should it work at a high level?
        
    *   *Philippe Noël* in chat: Phil from ParadeDB here (pg_search,
        pg_analytics, pg_lakehouse) — First minisummit I can attend, glad
        to be here

*   Thank for coming, Philippe! Again, interrupt me anytime.
        
*   The next topic is developer tooling. Developer tooling today is kind of
    all over the place. There a PGXN client, there's the PGXN utils client
    (which doesn't compile anymore, as far as I can tell), there's pgrx stuff,
    and maybe a few other things. What sorts of tools would be useful for
    developers who actually develop and build extensions?
    
    *   CLIs and APIs can do metadata management, or scaffolding your source
        code and adding new features through some sort of templating system.
        
    *   The packaging and Publishing system based on how we uh ultimately
        elect to distribute source code, and how we ultimately elect to
        distribute binary code. How does that get packaged up with the
        namespacing and all the decisions we made, to be as easy as possible
        for the developer?
    
    *   What build pipelines do we support? today PGXS and pgrx are perhaps
        the most common, but I've seen GNU autoconf configure stuff and stuff
        that uses Rust or Go or Python-based builds. Do we want to support
        those? And how do we integrate them with our binary packaging format
        and where Postgres expects to put stuff?
        
        I think this is an important topic. One of the things I've been
        dealing with as I've talked to the people behind Apache Age and a
        couple other projects is how they put put stuff in `/usr/local` by
        default. I suggest that it'd be better if it went where `pg_config`
        wants to put it. How do we want to go about integrating those things?
        
    *   Tooling for CI/CD workflows to make it as easy
        as possible to test across a variety of platforms, Postgres versions, and
        those pipelines.
        
*   Kind of a broad Community topic here. This gets to where things are
    hosted. There's a Postgres identity service that does Oauth 2; is that
    something we want to plug into? Is there a desire for the community to
    provide the infrastructure for the systems or for at least the core
    systems of PGXN v2? Who would support it? The people who work on the
    development ideally would also handle the devops, but should work closely
    with whoever provides the infrastructure to make sure it's all copacetic.
    And that there's a a plan for when something happens. People exit the
    community for whatever reason; how will systems continue to be maintained?
    I don't think there's a plan today for PGXN.

*   Another topic is documentation. How do we help engineers figure out how to
    build extensions; tutorials and references for all the things and all the
    various details. Do we end up writing a book, or do we just have very
    specifically-focused tutorials like, "So you want to build a foreign data
    wrapper; here's a guide for that." Or you just need to write a background
    worker, here's an example repository to clone. What should those things
    look like?

    *   `CREATE EXTENSION`
    *    Hooks
    *    Background workers
    *    CLI apps/services
    *    Web apps
    *    Native apps
    
    This also kind of covers the variety of different kinds of extensions we
    might want to package and distribute.
    
*   Then there's all the stuff that I filed under "core," because I think it
    impacts the core Postgres project and how it may need to evolve or we
    might want it to evolve over time. One is the second extension directory;
    there's [a patch] pending now, but it'll probably be deferred until until
    Postgres 17 ships; it's on hold while we're in the freeze. This is a patch
    that Christoph Berg wrote for the Debian distribution; it allows you to
    have a second destination directory for your extensions where Postgres
    knows to find stuff, including shared object libraries. This would make it
    easier for projects like Postgres.app and for immutable Docker containers
    to mount a new directory and have all the stuff be there.
    
*   I would love to see some sort of more coherent idea of what an extension
    pack package looks like, where like if I install pgTAP, all of its files
    are in a single subdirectory that Postgres can access. Right now it's in
    package config, and the sharedir and the libder and the docdir --- it's
    kind spread all over.
    
*   Should there be a documentation standard, in the way you have JavaDoc and
    rustdoc and Godoc, where docs are integrated into the source code, so it's
    easy to use, and there's tooling to build effective documentation. Today,
    people mostly just write short READMEs and leave it at that, which is not
    really sufficient for a lot of projects.
    
*   There's the longstanding idea of inline extensions that Dimitri proposed
    back as far as 2013, something they called "units". Oracle calls them
    "packages" or "modules". Trusted Language Extensions start making a stab
    at the problem, trying to make something like inline extensions with the
    tooling we have today. How should that evolve? What sorts of ideas do we
    want to adapt to make it so that you don't have to have physical access to
    the file system to manage your extensions? Where you could do it all over
    SQL or libpq.
    
*   How can we minimize restarts? A lot of extensions require loading DSOs in
    the `shared_preload_libraries` config, which requires a cluster restart.
    How can we minimize that need? There are ways to minimize restarts; it's
    just a broad category I threw in.
    
*   What Namespacing is there? I touched on this topic when I wrote about Go
    Namespacing a while ago. My current assumption is, if we decided to
    support `user/extension_string` or `hostname/user/extension_string`
    namespacing for package and source distribution, Postgres itself still has
    to stick to a single string. How would we like to see that evolve in the
    future?

*   What kind of sandboxing, code signing, security and trust could be built
    into the system? Part of the reason they've resisted having a second
    extension directory up to now is to have one place where everything was,
    where the DBA knows where things are, and it's a lot it's easier to manage
    there. But it's also because otherwise people will put junk in there. Are
    there ideas we can borrow from other projects or technologies where
    anything in some directory is sandboxed, And how is it sandboxed? Is it
    just for a single database or a single user? Do we have some sort of code
    signing we can build into the system so that Postgres verifies an
    extension when you install it? What other kinds of security and trust
    could implement?
    
    This is a high level, future-looking topic that occurred to me, but it
    comes up especially when I talk to the big cloud vendors.
    
*   An idea I had is dynamic module loading. It came up during Jonathan's
    talk, where there was a question about how one could use Rust crates in
    PL/Rust, a trusted language. Well, a DBA has to approve a pre-installed
    list of crates that's on the file system where PL/Rust can load them. But
    what if there was a hook where, in PL/Perl for example, you `use Thing`
    and a hook in the Perl `use` command knows to look in a table that the DBA
    manages and can load it from there. Just a funky idea I had, a way to get
    away from the file system and more easily let people, through permissions,
    be able to load modules in a safe way.
    
*   A topic that came up during Yurri's talk was binary compatibility of minor
    releases, or some sort of ABI stability. I'd be curious what to bring up
    with hackers on formalizing something there. Although it has seemed mostly
    pretty stable over time to me, that doesn't mean it's been fully stable.
    I'd be curious to hear about the exceptions.
    
So! That's my quick review. I did the remainder of them in 11 minutes!

## Discussion

*   Jeremy S: Well done.

*   David Wheeler (he/him): What I'd like to do is send an email to all the
    people who are registered to come to The Summit in two weeks, as well as
    all of you, to be able to access this board and put stars or icons or
    something --- stickers which you can access ---

*   Jeremy S: I do feel like there's something missing from the board. I don't
    know that it's something we would have wanted to put on sooner, but I kind
    of feel like one of the next steps is just getting down into the trenches
    and looking at actual extensions, and seeing how a lot of these topics are
    going to apply once we start looking like at the list. I was looking
    around a bit.
    
    It's funny; I see a mailing list thread from a year or two ago where,
    right after Joel made his big list of 1,000 extensions, he jumped on the
    hackers list and said, "hey could we stick this somewhere like on the
    wiki?" And it looks like nobody quite got around to doing anything like
    tha. But that's where I was thinking about poking around, maybe maybe
    starting to work on something like that.
    
    But I think once we start to look at some of the actual extensions, it'll
    help us with a lot of these topics, kind of figure out what we're talking
    about. Like when you're when you're trying to figure out dependencies,
    once you start to figure out some of the actual extensions where this is a
    problem and other ones where it's not, it might help us to have be a lot
    more specific about the problem that we're trying to solve. Or whether
    it's versioning, which platform something is going to build on, all that
    kind of stuff. That's where I was thinking a topic --- or maybe a next
    step or a topic that's missing, or you were talking about how many
    extensions even build today. If you go through the extensions on PGXN
    right now, how many of them even work, at all. So starting to work down
    that list.
    
*   David Wheeler (he/him): So, two thoughts on that. One is: create a sticky
    with the topic you want and stick it in a place that's appropriate, or
    create another category if you think that's relevant.
    
*   Jeremy S: It's kind of weird, because what I would envision is what I want
    to do on the wiki --- I'll see if I can start this off today, I have
    rights to make a Postgres Wiki page --- is I want to make a list of
    extensions, like a table, where down the left is the extensions and across
    the top is where that extension is distributed today. So just extensions
    that are already distributed like in multiple places. I'm not talking
    about the stuff that's on core, because that's a given that it's
    everywhere. But something like pg_cron or PGAudit, anybody who has
    extensions probably has them. That gives some sense of the extensions that
    everybody already packages. Those are obviously really important
    extensions, because everybody is including them.
    
    And then the next thing I wanted to do was the same thing with the list of
    those extensions on the left but a column for each of the categories you
    have here. For, say, PGAudit, for stuff across the top --- metadata,
    registry packaging, developer stuff --- for PGAudit are their packaging
    concerns? For PGAudit, go down the list of registry topics like identity,
    where's the where is the source for PGAudit, is the definitive upstream
    GitLab, isit GitHub, is it git.postgresql.org? I could go right down the
    list of each of these topics for PGAudit. and then go down the list of all
    of your topics for pg_hint_plan. That's another big one; pg_hint_plan is
    all over the place. Each of your topics I could take and apply to each of
    the top 10 extensions and there might be different things that rise to the
    surface for pg_hint_plan than there are for, like, pgvector.

*   David Wheeler (he/him): That sounds like a worthwhile project to me, and
    it could be a useful reference for any of these topics. Also a lot of
    work!

*   Jeremy S: Well, in another way to like think about Vancouver might be,
    instead of like splitting people up by these topics --- I'm spitballing
    here, this this might be a terrible idea --- but you could take a list of
    like 20 or 30 important extensions split people up into groups and say,
    "here's five extensions for you, now cover all these topics for your five
    extensions." You might have one group that's looking at like pg_hint_plan
    and pgvector and PGAudit, and then a different group that has pg_cron and
    whatever else we come up with. That's just another way you could slice it
    up.
    
*   David Wheeler (he/him): Yeah, I think that you're thinking about it the
    inverse the way I've been thinking of it. I guess mine is perhaps a little
    more centralized and top down, and that comes from having worked on PGXN
    in the past and thinking about what we'd like to build in the future. But
    there's no reason it couldn't be bottom up from those things. I will say,
    when I was working on the metadata RFC, I did work through an example of
    some actually really fussy extension --- I don't remember which one it was
    --- or no, I think it was the ML extension.[^pgml] I think that could be a
    really useful exercise.
    
    But the idea the Open Technology Space is that you can create a sticky,
    make a pitch for it, and have people vote by putting a star or something
    on them. I'm hoping that, a. we can try to figure out which ones we feel
    are the most important, but ultimately anybody can grab one of these and
    say "I want to own this, I'm putting it in session session one, and put
    your put your name on it. They ca be anything, for the most part.

*   Jeremy S: Sure. I think I don't totally grok the Canva
    board and how that all maps out, but at the end of the day whatever you
    say we're doing in Vancouver I'm behind it 100%.
    
*   David Wheeler (he/him): I'm trying to make it as open as possible. If
    there's something you want to talk about, make a sticky.
    
*   Jeremy S: I'll add a little box. I'm not sure how this maps to what you
    want to do with the time in Vancouver.

*   David Wheeler (he/him): Hopefully this will answer the question. First
    we'll do an intro and welcome and talk about the topics, give people time
    to look at them, I want to send it in advance so people can have a sense
    of it in advance. I know the way they do the the Postgres unconference
    that's been the last day of PGCon for years, they have people come and put
    a sticky or star or some sort of sticker on the topics they like, and then
    they pick the ones that have the most and and those are the ones they line
    up in here [the agenda]. But the idea of the Open Technology stuff is a
    person can decide on whatever topic they want, they can create their sticky,
    they can put it in the set slot they want and whatever space they want,
    and ---

*   Jeremy S: Ooooh, I think I get it now. Okay, I didn't realize that's what
    you were doing with the Canva board. Now I get it.
    
*   David Wheeler (he/him): Yeah, I was trying to more or less do an
    unconference thing, but because we only have three hours try to have a
    solid idea of the topics we want to address are before we get there.

*   Jeremy S: I don't know though. Are you hoping a whole bunch of people are
    going to come in here and like put it --- Okay, it took me five or ten
    minutes to to even realize what you were doing, and I don't have high
    hopes that we'll get 20 people to come in and vote on the Post-it notes in
    the next seven days.
    
*   David Wheeler (he/him): Yeah, maybe we need to...  These instructions here
    are meant to help people understand that and if that needs to be
    tweaked, let's do it.
    
    *   *David G. Johnston* in chat: How many people are going to in this
        summit in Vancouver?
    *   *David G. Johnston* in chat: Is the output of a session just
        discussions or are action items desired?

*   Steven Miller: I have another question. Are people invited to
    present at the Summit if they're not physically present at the Summit? And then
    same question for viewership
    
*   David Wheeler (he/him): I don't think they are providing remote stuff at
    the Summit
    
*   Steven Miller: okay 

*   David Wheeler (he/him): David, last I heard there were 42 people
    registered. I think we have space for 45. We can maybe get up to 50 with
    some standing room, and there's a surprisingly large number of people
    (laughs).

    *   *David G. Johnston* in chat: So average of 10 in each space?

*   Jeremy S: Have you gone down the list of names and started to figure out
    who all these people? Cuz that's another thing. There might be people who
    have very little background and just thought "this sounds like an
    interesting topic." How those people would contribute and participate
    would be very different from someone who's been working with extensions
    for a long time.

*   David Wheeler (he/him): David, yeah, and we can add more spaces or
    whatever if it makes sense, or people can just arbitrarily go to a corner.
    Because it's an unconference they can elect to do whatever interests them.
    I'm just hoping to have like the top six things we think are most
    important to get to ahead of time.
    
    Jeremy, Melanie sent me the list of participants, and I recognized perhaps
    a quarter of the names were people who're pretty involved in the
    community, and the rest I don't know at all. so I think it's going to be
    all over the map.

*   Steven Miller: So would it work if somebody wanted to do a presentation,
    they can. They grab stickies from the left and then you could also
    duplicate stickies because maybe there'd be some overlap, and then you put
    them in a session. But there's basically supposed to be only one name per
    field, and that's who's presenting.
    
*   David Wheeler (he/him): You can put however many names on it as you want.
    Open technology usually says there's one person who's facilitating and
    another person should take notes.
    
*   Steven Miller: Okay.    

*   David Wheeler (he/him): But whatever works! The way I'm imagining it is,
    people say, "Okay I want to talk to other people about make some decisions
    about, I don't know, documentation standards." So they go off to a corner
    and they talk about it for an hour. There are some notes. And the final
    half hour we'll have readouts from those, from whatever was talked about
    there.
    
*   Steven Miller: These are small working sessions really,it's not like
    a conference presentation. Okay, got it
    
 *  David Wheeler (he/him): Yeah. I mean, somebody might come prepared with a
    brief presentation if they want to set the context. [Laughs] Which is what
    I was trying to do for the overall thing here. But the idea is these are
    working sessions, like "here's the thing we want to look at" and we want
    to have some recommend commendations, or figure out the parameters, or you
    have a plan --- maybe --- at the end of it. My ideal, personally, is that
    at the at the end of this we have a good idea of what are the most
    important topics to address earlier on in the process of building out the
    ecosystem of the future, so we can start planning for how to execute on
    that from those proposals and decisions. That's how I'm thinking about it
    
*   Steven Miller: Okay, yeah I see.

*   Jeremy S: This sounds a lot like the CoffeeOps meetups that I've been to.
    They have a similar process where you use physical Post-it notes and vote
    on topics and then everybody drops off into groups based on what they're
    interested in.

*   David Wheeler (he/him): Yeah it's probably the same thing, the Open
    Technology stuff.

*   Steven Miller: Maybe we should do one field so we kind of get an idea?
    
*   David Wheeler (he/him): Sure. Let's say somebody comes along and there are
    a bunch of stickers on this one [drops stickers on the sticky labeled
    "Identity, namespacing, and uniqueness"]. So so we know that it's
    something people really want to talk about. So if somebody will take
    ownership of it, they can control click, select "add your name", find a
    slot that makes sense (and we may not use all of these) and drag it there.
    So "I'm going to take the first session to talk about this." Then people
    can put the stickies on it over here [pasties stickers onto the topic
    sticky in the agenda], so you have some sense of how many people are
    interested in attending and talking about that topic. But there are no
    hard and fast rules.

    Whether or not they do that, say, "David wants to talk about identity name
    spacing uniqueness in the core registry," we're going to do that in the
    first session. We'll be in the northeast corner of the room --- I'm going
    to try to get access to the room earlier in the day so I can have some
    idea of how it breaks up, and I'll tweak the the Canva to to add stuff as
    appropriate.

    *   *David G. Johnston* in chat: Same thing multiple times so people don't
        miss out on joining their #2 option?
    *   *David G. Johnston* in chat: How about #1, #2, #3 as labels instead of
        just one per person?

*   Jeremy S: Are you wanting us to put Post-it notes on the agenda now,
    before we know what's been voted for?
    
*   David Wheeler (he/him): Yep! Especially if there's some idea you had
    Jeremy. If there's stuff you feel is missing or would be a different
    approach, stick it in here. It may well be not that many people interested
    in what I've come up with but they want to talk about
    those five extensions.
    
*   David Wheeler (he/him): (Reading comment from David Johnson): "One two and
    three as labels instead of just one per person?" David I'm sorry I don't
    follow.

*   David G. Johnston: So basically like rank choice. If you're gonna do I
    core one time and binary packaging one time, and they're running at the
    same time, well I want to do both. I want to do core --- that's my first
    choice --- I want to do binary packaging --- that's my second choice. If I
    had to choose, I'd go to number one. But if you have enough people saying
    I want to see this, that's my number two option, you run binary packaging
    twice, not conflicting with core so you can get more people.
    
*   David Wheeler (he/him): I see, have people stick numbers on the topics
    that most interest in them. Let's see here... [pokes around the Canva UX,
    finds stickers with numbers.] There we go. I'll stick those somewhere
    that's reasonable so people can rank them if they want, their top
    choices.
    
    This is all going to be super arbitrary and unscientific. The way I've
    seen it happen before is people just drop stars on stuff and say, okay
    this one has four and this one has eight so we definitely want to talk
    about that one, who's going to own it, that sort of thing. I think what
    makes sense is to send this email to all the participants in advance;
    hopefully people will take a look, have some sense of it, and maybe put a
    few things on. Then, those of us who are organizing it and will be
    facilitating on the day, we should meet like a day or two before, go over
    it, and make some decisions about what we definitely think should be
    covered, what things are open, and get a little more sense of how we want
    to run things. Does that make sense?
    
*   Jeremy S: Yeah, I think chatting ahead of time would be a good idea. It'll
    be interesting to see how the Canva thing goes and what happens with it.
    
*   David Wheeler (he/him): It might be a mess! Whatever! But the answer is
    that whatever happens this is the right place. Whenever it starts is the
    right time. Whatever happens could only happen here. It's super arbitrary
    and free, and we can adapt as much as we want as it goes.

*   David Wheeler (he/him): I think that's it. Do you all feels like you have
    some sense of what we want to do?
    
*   Jeremy S: Well not really, but that's okay! [Laughs]

*   Steven Miller: Okay, so here's what we are supposed to do. Are we supposed
    to go find people who might be interested to present --- they will already
    be in the list of people who are going to Vancouver. Then we talk to them
    about these Post-its and we say, "would you like to have a small
    discussion about one of these things. If you are, then put a sticky note
    on it." And then we put the sticky notes in the fields, we have a list of
    names associated with the sticky notes. Like, maybe Yurri is interested in
    binary distribution, and then maybe David is also interested in that. So
    there's like three or four people in each section, and we're trying to
    make sure that if you're interested multiple sections you get to go to
    everything?
    
*   David Wheeler (he/him): Yeah you can float and try to organize things. I
    put sessions in here assuming people would want to spend an hour, but
    maybe a topic only takes 15 minutes.
    
*   David G. Johnston: Staying on my earlier thought on what people want to
    *see,* people who are willing to present and can present on multiple
    things, if we have a gold star for who's willing to actually present on
    this topic. So here's a topic, I got eight people who want to see it but
    only one possible presenter. Or I got five possible presenters and three
    possible viewers. But you have that dynamic of ranked choice for both "I'll
    present stuff" or "I'm only a viewer.
    
*   David Wheeler (he/him): I think that typically these things are
    self-organizing. Somebody says, "I want to do this, I will facilitate, and
    I need a note taker." But they negotiate amongst themselves about how they
    want to go about doing it. I don't think it necessarily has to be formal
    presentation, and usually these things are not. Usually it's like somebody
    saying, "here's what this means, this is the topic, we're going to try to
    cover, these are the decisions we want to make, Go!"
    
*   Jeremy S: You're describing the the the unconference component of PGCon
    that has been down in the past.

*   David Wheeler (he/him): More or less, yes

*   Jeremy S: So should we just come out and say this is a unconference? Then
    everybody knows what you're talking about really fast, right?
    
*   David Wheeler (he/him): Sure, sure, yeah. I mean ---

*   Jeremy S: We're just we're doing the same thing as -- yeah.

*   David Wheeler (he/him): Yeah, I try to capture that here but we can use
    the word "unconference" *for sure.* [Edits the Canva to add "an
    unconference session" to the title.] There we go.

*   Steven Miller: I imagine there are people who might be interested to
    present but they just aren't in this meeting right now. So maybe we need
    to go out and advertise this to people.
    
*   David Wheeler (he/him): Yeah, I want to draft an email to send to all the
    attendees. Melanie told me we can send an email to everybody who's registered.

*   Jeremy S: And to be clear it's full, right? Nobody new can register at
    this point?

*   David Wheeler (he/him): As far as I know, but I'm not sure how hard and
    fast the rules are. I don't think any more people can register, but it
    doesn't mean other people won't wander in. People might have registered
    and then not not come because they'rein the patch the patch session or
    something.
    
    So I volunteer to draft that email today or by tomorrow and share it with
    the Slack channel for feedback. Especially if you're giving me notes to
    clarify what things mean, because it seems like there are
    more questions and confusions about how it works than I anticipated --- in
    part because it's kind of unorganized by design [chuckles].
    
    *   *Jeremy S* in chat: https://wiki.postgresql.org/wiki/PgConUnconferenceFAQ
    
*   David Wheeler (he/him): Oh that's a good thing to include Jeremy. that's a
    good call. But to also try to maximize participation of the people who're
    planning to be there. It may be that they say, "Oh this sounds
    interesting," or whatever, so and I'll add some different stickers to this
    for some different meanings, like "I'm interested" or "I want to take
    ownership of this" or "this is my first, second, third, or fourth choice".
    Sound good?

*   Steven Miller: Yes, it sounds good to me!

*   David Wheeler (he/him): Thanks Steven.

*   Jeremy S: Sounds good, yeah.
 
*   David Wheeler (he/him): All right, great! Thanks everybody for coming!

  [^canva-link]: Hit the [#extensions] channel on the [Postgres Slack] for the link!
  [^oops]: In the meeting I kept saying "open technology" but meant [Open
    Space Technology] 🤦🏻‍♂️.
  [^pgml]: But now I can look it up. It was [pgml], for which I [mocked up a
    `META.json`].

  [mini-summit]: https://www.eventbrite.com/e/851125899477/
    "Postgres Extension Ecosystem Mini-Summit"
  [the Summit]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/191/
    "PGConf.dev: Extensions Ecosystem Summit: Enabling comprehensive indexing, discovery, and binary distribution"
  [first mini-summit]: {{% ref "/post/postgres/mini-summit-one" %}}
    "Mini Summit One"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [Open Space Technology]: https://en.wikipedia.org/wiki/Open_space_technology
    "wikipedia: “Open space technology”"
  [PGXN Meta spec]: https://pgxn.org/spec/
  [OCI idea]: https://www.ongres.com/blog/why-postgres-extensions-should-be-distributed-and-packaged-as-oci-images/
    "Why Postgres Extensions should be packaged and distributed as OCI images"
  [a patch]: https://commitfest.postgresql.org/48/4913/
    "PostgreSQL CommitFest: Add extension_destdir GUC"
  [pgml]: https://github.com/postgresml/postgresml
    "The GPU-powered AI application database."
  [mocked up a `META.json`]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}#example-pgml-extension 
    "RFC: PGXN Metadata Sketch --- Example: PGML Extension"
