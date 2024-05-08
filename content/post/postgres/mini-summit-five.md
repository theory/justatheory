---
title: Mini Summit Five
slug: mini-summit-five
date: 2024-05-07T22:12:04Z
lastMod: 2024-05-07T22:12:04Z
description: |
  Links, notes, and commentary from Yurri Rashkovskii's presentation,
  "Universally Buildable Extensions: Dev to Prod," at the fifth Postgres
  Extension Ecosystem Mini-Summit on May 1, 2024.
tags: [Postgres, Yurri Rashkovskii, PGXN, Extensions, PGConf, Summit]
type: post
---

The video for Yurri Rashkovskii's presentation at the fifth Postgres
Extension Ecosystem Mini-Summit last week is up. Links:

*   [Video](https://youtu.be/R5ijx8IJyaM)
*   [PDF Slides]({{% link "/shared/extension-ecosystem-summit/omni-universally-buildable-extensions.pdf" %}})

Here's my interpolation of YouTube's auto-generated transcript, interspersed
with chat activity.

## Introduction

*   I opened the meeting and introduced [Omnigres]'s [Yurri Rashkovskii].

## Presentation

*   Yurri: Today I'm going to be talking about universally buildable
    extensions. This is going to be a shorter presentation, but the point of
    it is to create some ideas, perhaps some takeaways, and actually provoke a
    conversation during the call. It would be really amazing to explore what
    others think, so without further ado...

*   I'm with Omnigres, where we're building a lot of extensions. Often  they
    push the envelope of what extensions are supposed to do. For example, one
    of our first extensions is an HTTP server that embeds a web server inside
    of Postgres. We had to do a lot of unconventional things. We have other
    extensions uniquely positioned to work both on developer machines and
    production machines --- because we serve the the developers and devops
    market.

*   The point of Omnigres is turning Postgres into an application runtime ---
    or an application server --- so we really care how extensions get adopted.
    When we think about application developers, they need to be able to use
    extensions while they're developing, not just in production or on some
    remote server. They need extensions to work on their machine.

*   The thing is, not everybody is using Linux Other people use macOS and
    Windows and we have to account for that. There are many interesting
    problems associated with things like dependencies.

*   So there's a very common approach used by those who who try to orchestrate
    such setups and by some package managers: operating out of container. The
    idea is that with a can create a stable environment where you bring all
    the dependencies that your extension would need, and you don't have to
    deal with the physical reality of the host machine. Whether it's a
    developer machine, CI machine, production machine, you always have the
    same environment. That's definitely a very nice property.

*   However, there are some interesting concerns that we have to be aware when
    we operate out of a container. One is specifically mapping resources. When
    you have a container you have to map how many cores are going there,
    memory, how do we map our volumes (especially on Docker Desktop), how we
    connect networking, how we pass environment variables.

*   That means whenever you're running your application --- especially
    locally, especially in development --- you're always interacting with that
    environment and you have to set it up. This is particularly problematic
    with Docker Desktop on macOS and Windows because these are not the same
    machines. You're operating out of a virtual machine machine instead of
    your host machine, and obviously containers are Linux-specific, so it's
    always Linux.

*   What we found is that often times it really makes a lot of sense to test
    extensions, especially those written in C, on multiple platforms. Because
    in certain cases bugs, especially critical memory-related bugs, don't show
    up on one platform but show up on another. That's a good way to catch
    pretty severe bugs.

*   There are also other interesting, more rare concerns. For example, you
    cannot access the host GPU through Docker Desktop on macOS or through
    Colima. If you're building something that could have use the host GPU that
    would work on that machine it's just not accessible. If you're working
    something ML-related, that can be an impediment

*   This also makes me wonder: what are other reasons why we're using
    containers. One reason that struck out very prominently was that Postgres
    always has paths embedded during compile time. That makes it very
    difficult to ship extensions universally across different installations,
    different distributions. I wonder if that is one of the bigger reasons why
    we want to ship Postgres as a Docker container: so that we always have the
    same path regardless of where where it's running.

*   Any questions so far about Docker containers? Also if there's anybody who
    is operating a Docker container setup --- especially in their development
    environment --- if you have any thoughts, anything to share: what are the
    primary reasons for you to use a Docker container in your development
    environment?

    *   *Jeremy S* in chat: When you say it’s important to test on multiple
        platforms, do you mean in containers on multiple platforms, or
        directly on them?

    *   *Jeremy S* in chat: That is - I’m curious if you’ve found issues, for
        example, with a container on Mac/windows that you wouldn’t have found
        with just container on linux

*   Daniele: Probably similarity with the production deployment environments.
    That's one. Being free from whatever is installed on your laptop, because
    maybe I don't feel like upgrading the system Python version and
    potentially breaking the entire Ubuntu, whereas in a Docker container you
    can have whatever version of Python, whatever version of NodeJS or
    whatever other invasive type of service. I guess these are these are good
    reasons. These were the motivation that brought me to start developing
    directly in Docker instead of using the desktop.

*   Yurri: Especially when you go all the way to to production, do you find
    container isolation useful to you?

*   Daniele: Yeah I would say so; I think the problem is more to break
    isolation when you're are developing. So just use your editor on your
    desktop, reload the code, and have a direct feedback in the container. So
    I guess you have to break one barrier or two to get there. At least from
    the privilege points of having a Linux on desktop there is a smoother
    path, because it's not so radically different being in the container.
    Maybe for Windows and macOS developers it would be a different experience

*   Yurri: Yeah, I actually wanted to drill down a little bit on this In my
    experience, I build a lot on macOS where you have to break through the
    isolation layers with the container itself and obviously the VM. I've
    found there are often subtle problems that make the experience way less
    straightforward.

*   One example I found it that, in certain cases, you're trying to map a
    certain port into the container and you already have something running [on
    that port] on your host machine. Depending on how you map the port ---
    whether you specify or don't specify the address to bind on --- you might
    not get Docker to complain that this port is actually overridden.

*   So it can be very frustrating to find the port, I'm trying to connect to
    it but it's not connecting to to the right port. There's just very small
    intricate details like this, and sometimes I've experienced problems like
    files not perfectly synchronizing into the VM --- although that has gotten
    a little better in the past 2--3 years --- but there there were definitely
    some issues. That's particularly important for the workflows that we're
    doing at Omnigres, where you're running this entire system --- not just
    the database but your back end. To be able to connect to what's running
    inside of the container is paramount to the experience.

*   Daniele: Can I ask a question about the setup you describe? When you go
    towards production, are those containers designed to be orchestrated by
    Kubernetes? Or is there a different environments where you have your
    Docker containers in a local network, I assume, so different Dockers
    microservices talking to each other. Are you agnostic from what you run in
    it, or do you run it on Kubernetes or on Docker Compose or some other form
    of glue that you you set up yourself, or your company has set up?

    *   *Steven Miller* in chat: … container on Mac/windows [versus linux]
    *   *Steven Miller* in chat: Have seen with chip specific optimizations
        like avx512

*   Yurri: Some of our users are using Docker Compose to run everything
    together. However, I personally don't use Docker containers. This is part
    of the reason why the topic of this presentation is about universally
    buildable extensions. I try to make sure that all the extensions are
    easily compilable and easily distributable on any given supported
    platform. But users do use Docker Compose, it's quite common.

*   Does anyone else here have a preference for how to move Docker containers
    into production or a CI environment?

*   Nobody?  I'll move on then.

    *   *Steven Miller* in chat: Since in docker will run under emulation, but
        on linux will run with real hardware, so the environment has different
        instruction set support even though the docker —platform config is the
        same

    *   *Jeremy S* in chat: That makes sense

*   Yurri: I wanted to show just a little bit of a proof of concept tool that
    we've been working on, on and off for the last year---

*   David Wheeler (he/him): Yurri, there are a couple comments and questions
    in chat, I don't know if saw that

*   Yurri: I didn't see that sorry.

*   Jeremy is saying, "when you say it's important to test on
    multiple platforms do you mean in containers on multiple platforms or
    directly on them?" In that particular instance I meant on multiple
    platforms, directly.

*   The other message from Jeremy was, "I'm curious if you found issues for
    example with a container on Mac or Windows that you wouldn't have found
    with just container on Linux?" Yeah I did see some issues depending on the
    type of memory-related bug. Depending on the system allocator, I was
    either hitting a problem or not. I was not hitting it on Linux, I believe
    and it was hidden macOS. I don't remember the details right now,
    unfortunately, but that difference was indicative of a bug.

*   Steven wrote, trying to connect this… "Have * seen chip-specific
    optimizations for containers?" And, "Docker will run under emulation but
    on Linux will run with real Hardware." Yeah that's an interesting one
    about ax512. I suppose this relates to the commentary about  about GPU
    support, but this is obviously the other part of supporting specific
    hardware, chip-specific optimizations That's an interesting thing to
    learn; I was not aware of that! Thank you Steven.

*   Let's move on. postgres.pm is a pro of concept that I was working on for
    some time. The idea behind it was both ambitious but also kind of simple:
    Can we try describing Postgres extensions in such a way that they will be
    almost magically built on any supported platform?

*   The idea was to build an expert system of how to build things from a
    higher level definition. Here's an example for pgvector:

    ``` prolog
    :- package(vector(Version), imports([git_tagged_revision_package(Version)])).
    git_repo("https://github.com/pgvector/pgvector").
    :- end_package.
    ```

    It's really tiny! There are only two important things there: the Git
    tagged revision package and Git repo. There's nothing else to describe the
    package.

*   The way this works is by inferring as much information as possible from
    what's available. Because it's specified as a Git-tagged revision package,
    it knows that it can download the list of version-shaped revisions --- the
    versions --- and it can checkout the code and do further inferences. It
    infers metadata from `META.json` if it's available, so it will know the
    name of the package, the description, authors, license, and everything
    else included there.

    *   *David G. Johnston* in chat: PG itself has install-check to verify
        that an installed instance is functioning. What are the
        conventions/methods that extension authors are using so that a
        deployed container can be tested at a low level of operation for the
        installed extensions prior to releasing the image to production?

*   It automatically infers the build system. For example for C extensions, if
    it sees that there's a `Makefile` and C files, it infers that you need
    `make` and a C compiler and it tries to find those on the system: it will
    try to find `cc`, `gcc`, Clang ---  basically all kinds of things.

    *David Wheeler (he/him)() in chat: Feel free to raise hands with questions

*   Here's a slightly more involved example for `pg_curl`. Ah, there was a
    question from David Johnson. David says, "PG has install-check to verify
    that installed instance is functioning. What are the conventions methods
    that extension authors are using so the deployed container can be tested
    at a low level of operation for the installed extension prior to releasing
    the image to production?"

*   I guess the question is about general conventions for how extension
    authors ensure that the extensions work, but I suppose maybe part of this
    question is whether that's also testable in a production environment.
    David, are you talking about the development environment alone or both?

*   David G. Johnston: Basically, the pre-release to production. You go in
    there in development and you cut up an extension and source and then you
    build your image where you compile it --- you compile PG, you compile it,
    or you deploy packages. But now you have an image, but you've never
    actually tested that image. I can run `installcheck` on an installed
    instance of Postgres and know that it's functioning, but it won't test my
    extension. So if I install PostGIS, how do I test that it has been
    properly installed into my database prior to releasing that image into
    production?

    *   *Tobias Bussmann* in chat: shouldn't have the extension a make
        installcheck as well?

*   Yurri: To my knowledge there's no absolutely universal method. Of course
    the PGXS methods are the most standard ones --- like `installcheck` --- to
    to run the tests. In our [Omnigres's] case, we replaced `pg_regress` with
    `pg_yregress`, another tool that we've developed. It allows for more
    structural tests and tests that test certain things that `pg_regress`
    cannot test because of the way it operates.

    *   *David Wheeler (he/him)* in chat:
        https://docs.omnigres.org/pg_yregress/intro/

*   I can share more about this later if that's of interest to anybody. So we
    basically always run `pg_yregress` on our extensions; it creates a new
    instance of Postgres --- unless told to use a pre-existing instance ---
    and it runs all the tests there as a client. It basically deploys the the
    extension and runs the set of tests on it.

*   David G. Johnston: Okay.

    Yurri: I guess you know it depends on how you ship it. For example, if you
    look at the pgrx camp, they have their own tooling for that, as well. I've
    also seen open-source extensions where they could be written in, say,
    Rust, but still using `pg_regress` tests to test their behavior. That
    would often depend on how their build system is integrated in those tests.
    I guess the really short answer is there's probably no absolutely
    Universal method.

*   David thank you for pasting the link to `pg_yregress`. If there are ny
    questions about it, feel free to ask me. Any other thoughts or questions
    before I finish this slide? Alright will carry on then.

    ``` prolog
    :- package(pg_curl(Version), imports(git_explicit_revision_package(Version))).
    :- inherit(requires/1).
    git_repo("https://github.com/RekGRpth/pg_curl").
    git_revisions([
            '502217c': '2.1.1',
            % ... older versions omitted for now ...
        ]).
    requires(when(D := external_dependency(libcurl), version::match(D, '^7'))).
    :- end_package.
    ```

*   The difference between this example and the previous one is that here it
    specifies that there will be an explicit revision map because that project
    does not happen to have version tags, so they have to be done manually.
    You can see that in the Git revision specification. But what's more
    interesting about this is that it specifies what kind of dependency it
    needs. In this particular instance it's `libcurl`, and the version has to
    match version 7 --- any version 7.

*   These kinds of requirements, as well as compiler dependencies, `make`
    dependencies, and others are always solved by pluggable satisfiers. They
    look at what's available depending on the platform --- Linux, a particular
    flavor of Linux, macOS, etc --- and picks the right tools to see what's
    available. In the future there's a plan to add features like building
    these dependencies automatically, but right now it depends on the host
    system, but in a multi-platform way.

    *   *David Wheeler (he/him)* in chat: How does it detect that libcurl is
        required?

*   The general idea behind this proof of concept is that we want to specify
    high level requirements and not how exactly to satisfy them. If you
    compare this to a Docker file, the Docker file generally tells you exactly
    what to do step by step: let's install this package and that
    package, let copy files, etc. so it becomes a very specific set of
    instructions.

    *   *Jeremy S* in chat: And how does it handle something with different
        names in different places?

*   There was a question: "how does it detect that `libcurl` is required?"
    There there is this line at the bottom says "requires external dependency
    `libcurl`, so that was the definition."

*   The other question was "how does it handle something with different names
    in different places?" I'm not sure I understand this question.

*   Jeremy S: I can be more spe specific. A dependency like `libc` is called
    `libc` on Debian platforms and it's called `glibc` on Enterprise Linux.
    You talked about available satisfiers like Homebrew, Apt and package
    config, but what if it has a different name in Homebrew than in Apt or
    something like? Does it handle that or is that just something you haven't
    tackled yet?

*   Yurri: It doesn't tackle this right now, but it's part of the division
    where it should go. For certain known libraries there's an easy way to add
    a mapping that will kick in for a distribution, and otherwise it will be a
    satisfier for another one. They're completely pluggable, small satisfiers
    looking at all the predicates that describe the system underneath.

    *   *David G. Johnston* in chat: How is the upcoming move to meson in core
        influencing or impacting this?

*   Just for point of reference, this is built on top of Prolog, so it's like
    a knowledge base and rules for how to apply on this knowledge to
    particular requirements.

    *   *Tobias Bussmann* in chat: Prolog 👍

    *   *Shaun Thomas* in chat: What if there _are_ no satisfiers for the
        install? If something isn't in your distro's repo, how do you know
        where to find the dependency? And how is precedence handled? If two
        satisfiers will fulfill a requirement, will the highest version win?

*   Jeremy S: I remember Devrim talking about, if you read through the [RPM]
    spec files, what find is all this spaghetti code with `#ifdefs` and  logic
    branches and in his case is just dealing with differences between Redhat
    and SUSE. If this is something that we manually put in, we kind of end up
    in a similar position where it's on us to create those mappings, it's on
    us to *maintain* those mappings over time --- we kind of own it --- versus
    being able to automate some kind of automatic resolution. I don't know if
    there is a good automatic way to do it. David had found something that he
    posted, which I looked at a little bit, but Devrim talked about how much
    of maintenance overhead it becomes in the long run to constantly have to
    maintain this which seemed less than ideal.

*   Yurri: It is less than ideal. For now, I do think that would have to be
    manual, which is less than ideal. But it could be addressed at least on on
    a case-by-case basis. Because we don't really have thousands of extensions
    yet --- in the ecosystem maybe a thousand total --- I think David Wheeler
    would would know best from his observations, and I think he mentioned some
    numbers in his presentation couple of weeks ago. But basically handling
    this on on a case-by-case basis where we need this dependency and
    apparently it's a different one on a different platform, so let's address
    that. But if there can be a method that can at least get us to a certain
    level of unambiguous resolution automatically or semi-automatically, that
    would be really great.

    *   *Samay Sharma* in chat: +1 on the meson question.

*   Jeremy S: I think there's a few more questions in the chat.

*   Yurri: I'm just looking at them now. "how is the upcoming move to meson
    and core influencing or impacting this?" I don't think it's influencing
    this particular part in any way that I can think of right now. David, do
    you have thoughts how it can? I would love to learn.

*   David G. Johnston: No, I literally just started up a new machine yesterday
    and decided to build it from meson instead of `make` and the syntax of the
    meson file seems similar to this. I just curious if there are any influences
    there or if it's just happenstance.

*   Yurri: Well from from what I can think right now, there's just general
    reliance on either implicitly found PG config or explicitly specified PG
    config. That's just how you discover Postgres itself. There's no relation
    to how Postgres itself was built. The packaging system does not handle say
    building Postgres itself or providing it so it's external to this proof of
    concept.

*   David G. Johnston: That's a good separation of concerns, but there's also
    the idea that, if core is doing something, we're going to build extensions
    against PostgresSQL, if we're doing things similar to how core is doing
    them, there's less of a learning curve and less of everyone doing their
    own thing and you have 500 different ways of doing testing.

*   Yurri: That's a good point. That's something definitely to reflect on.

*   I'll move on to the next question from Sean. "What if there are no
    satisfiers for the install? If something isn't in your distro how do you
    know where to find the dependency?" And "if two satisfiers will fulfill a
    requirement, will the highest version win?" If there are no satisfiers
    right now it will just say it's not solvable. So we fail to do anything.
    You would have to go and figure that out. It is a proof of concept, it's
    not meant to be absolutely feature complete but rather an exploration of
    how we can describe the the packages and their requirements.

*   David Wheeler (he/him): I assume the
    idea is that, as you come upon these you would add more satisfiers.

*   Yurri: Right, you basically just learn. We learn about this particular
    need in a particular extension and develop a satisfier for it. The same
    applies to precedence: it's a question of further evolution. Right now it
    just finds whatever is available within the specified range.

*   If there are no more pressing questions I'll move to the next slide. I was
    just mentioning the problem of highly specific recipes versus high-level
    requirements. Now I want to shift attention to another topic that has been
    coming up in different conversations: whether to build and ship your
    extension against minor versions of Postgres.

*   Different people have different stances in this, and even package managers
    take different stands on it. Some say, just build against the latest major
    version of Postgres and others say build extensions against every single
    minor version. I wanted to research and see what the real answer should
    be: should we build  against minor versions or not?

*   I've done a little bit of experimentation and my answer is "perhaps", and
    maybe even "test against different minor versions." In my exploration of
    version 16 (and also 15 bu Id didn't include it) there there are multiple
    changes between minor versions that can potentially be dangerous. One
    great example is when you have a new field inserted in the middle of a
    structure that is available through a header file. That definitely changes
    the layout of the structure.

    ``` diff
     typedef struct BTScanOpaqueData
     {
    -    /* these fields are set by _bt_preprocess_keys(): */
    +    /* all fields (except arrayStarted) are set by _bt_preprocess_keys(): */
         bool            qual_ok;                /* false if qual can never be satisfied */
    +    bool            arrayStarted;     /* Started array keys, but have yet to "reach
    +                                                               * past the end" of all arrays? */
         int                     numberOfKeys    /* number of preprocessed scan keys */
     }
    ```

*   In this particular case, for example, will not get number of keys if
    you're intending to. I think that change was from 16.0 to 16.1. If you
    build against 16.0 and then try to run on 16.1, it might not be great.

    The other concern that I found is there are new apis appearing in header
    files between different versions. Some of them are implemented in header
    files, either as macros or static and line functions. When you're building
    against that particular version, you'll get the particular implementation
    embedded.

*   Others are exports of symbols, like in this case, try index open
    and contain mutable functions after planning, if you're using any of this.
    But this means that these symbols are not available on some minor versions
    and they're available later on, or vice versa: they may
    theoretically disappear.

*   There are also changes in inline behavior. There was a change between 16.0
    and 16.1 or 16.2 where an algorithm was changed. Instead of just `> 0`
    there's now `>= 0`, and that means that particular behavior will be
    completely different between these implementations. This is important
    because it's coming from a header file, not a source file, so you're
    embedding this into your extension.

   *   *David Wheeler (he/him)* in chat: That looks like a bug fix

*   Yeah it is a bug fix. But what I'm saying is, if you build your extension
    against say 16.0m which did not have this bug fix, and then you deploy it
    on 16.1, then you still have the bug because it's coming from the header
    file.

*   *David Wheeler (he/him): Presumably they suggest that you build from the
    latest minor release and that's Backward compatible to the earlier
    releases.

*   Yurri: Right and that's a good middle ground for this particular case. But
    but of course sometimes when you do a minor upgrade you have to remember
    that you have to rebuild your extensions against that minor version so you
    can just easily transfer them yeah.

    *   *Jeremy S* in chat: The struct change in a minor is very interesting

*   *David Wheeler (he/him)Jeremy points out that struct change is pretty
    interesting.

 *  Yurri: Yeah, it's interesting because it's super dangerous! Like if
    somebody is expecting a different versioned structure, then  it can be
    pretty nasty.

    *   *Shaun Thomas* in chat: Yeah. It's a huge no-no to insert components
        into the middle of a struct.

*   Jeremy S: Is that common? I'm really surprised to see that in a minor
    version. On the other hand, I don't know that Postgres makes promises
    about --- some of this seems to come down to, when you're coding in C and
    you're coding directly against structures in Postgres, that's really
    interesting. That's --- I'm surprised to see that still.

    *   *Steven Miller* in chat: In the case of trunk, we would have built
        against minor versions in the past then upgrade the minor version of
        postgres without reinstalling the binary source of the extension, so
        this is an issue

    *   *David G. Johnston* in chat: Yeah, either that isn't a public
        structure and someone is violating visibility (in which case yes, you
        should be tracking minor builds)

    *   *Shaun Thomas* in chat: I'm extremely shocked that showed up in 16.2.

*   Yurri: Yeah, I didn't expect that either, because that's just a great way
    to have absolutely undefined behavior. Like if somebody forgot to rebuild
    their extension against a new minor, then this can be pretty terrible.

*   But my general answer to all of this unless you're going really deep into
    the guts of Postgres, unless you're doing something very deep in terms
    query planning, query execution, you're probably okay? But who knows.

    *   *Jason Petersen* in chat: yeah it feels like there’s no stated ABI
        guarantee across minor updates

    *   *Jason Petersen* in chat: other than “maybe we assume people know not
        to do this"

    *   *David Christensen* in chat: yeah ABI break in minor versions seems
        nasty

*   Jeremy S: But it's not just remembering to rebuild your extension. Let's
    let's suppose somebody is just downloading their extensions from the PGDG
    repo, because there's a bunch of them there. They're not compiling
    anything! They're they're downloading an RPM and the extension might be in
    a different RPM from Postgres and the extension RPMs --- I don't know that
    there have been any cases with any of the extensions in PGDG, so far,
    where a particular extension RPM had to have compatibility information at
    the level of minors.

    *   *Shaun Thomas* in chat: There was actually a huge uproar about this a
        couple year ago because they broke the replication ABI by doing this.

    *   *David G. Johnston* in chat: I see many discussions about ABI
        stability on -hackers so it is a goal.

    *   *Steven Miller* in chat: PGDG is the same binaries for each minor
        version because the postgres package is only major version, right?

*   Yurri: Yeah, that's definitely a concern, especially when it comes to the
    scenario when you rebuild your extensions but just get pre-built packages.
    It's starting to leak out of the scope of this presentation, but I thought
    it was a very interesting topic to bring to everybody's attention.

    *   *Jason Petersen* in chat: “it’s discussed on hackers” isn’t quite the
        same as “there’s a COMPATIBILITY file in the repo that states a
        guarantee”

    *   *Jason Petersen* in chat: (sorry)

*   My last item. Going back to how we ship extensions and why do we need
    complex build systems and packaging. Oftentimes you want your extensions
    to depend on some library, say OpenSSL or SQLite or whatever, and the
    default is to bring the shared dependency that would come from different
    packages on different systems.

*   What we have found at Omnigres is that it is increasingly simpler to
    either statically link with your dependencies --- and pay the price of
    larger libraries --- but then you have no questions about where it comes
    from --- what what package, which version -- you know exactly what which
    version it is and how it's getting built. But of course you also have a
    problem where, if you want to change the version of the dependency it's
    harder because it's statically linked. The question is whether you should
    be doing that or not, depending on the authors of the extension and their
    promises for compatibility with particular versions of their dependencies.
    This one is kind of naive and simple, as in just use static. Sometimes
    it's not possible or very difficult to do so, some some libraries don't
    have build systems amenable to static library production.

*   What we found that works pretty nicely is using `rpath` in your dynamic
    libraries. You can use special variables --- `$ORIGIN` or `@loader_path`
    on Linux or macOS, respectively, to specify that your dependency is
    literally in the same folder or directory where your extension is. So you
    can ship your extension with the dependencies alongside, and it will not
    try to load them immediately from your system but from the same directory.
    We find this pretty pretty useful.

*   That's pretty much it. Just to recap I talked about the multi-platform
    experience, the pros and cons of containers, inferencing how you build and
    how you can build extensions with dependencies, static and `rpath`
    dependencies, and the problems with PG minor version differences. If
    anybody has thoughts, questions, or comments I think that would be a
    great. Thank you.

## Discussion

*   David Wheeler (he/him): Thank you, Yurri, already some good discussion.
    What else do you all have?

*   David G. Johnston: PG doesn't use semantic versioning. They we have a
    major version and a minor version. The minor versions are new releases,
    they do change behaviors. There are goals from the hackers to not break
    things to the extent possible. But they don't guarantee that this will not
    change between dot-three and dot-four. When you're releasing once a year
    that's not practical if things are broken, you can't wait nine months to
    fix something. Some things you need to fix them in the next update and
    back-patch.

    *   *Steven Miller* in chat: Thank you, this is very useful info

    *   *Jeremy S* in chat: Dependency management is hard 🙂 it’s been a topic
        here for awhile

*   David G. Johnston: So we don't have a compatibility file, but we do have
    goals and if they get broken there's either a reason for it or someone
    just missed it. From an extension standpoint, if you want to be absolutely
    safe but absolutely cost intensive, you want to update every minor
    release: compile, test, etc. Depending on what your extension is, you can
    trade off some of that risk for cost savings. That's just going to be a
    personal call. The systems that we build should make it easy enough to do
    releases every "dot" and back-patching. Then the real cost is do you spend
    the time testing and coding against it to make sure that the stuff works.
    So our tool should assume releasing extensions on every minor release, not
    every major release, because that's the ideal.

    *   *Shaun Thomas* in chat: It's good we're doing all of this though. It
        would suck to do so much work and just become another pip spaghetti.

*   Yurri: That's exactly what I wanted to bring to everybody's attention,
    because there's still a lot of conversations about this and there was not
    enough clarity. So that helps a lot.

*   Jeremy S: Did you say *release* or did you say *build* with every Miner?
    I think I would use the word "build".

*   David G. Johnston: Every minor release, the ones that go out to the
    public. I mean every commit you could update your extension if you wanted.
    but really the ones that matter are the ones that go public. So, 16.3 or
    16.4 comes out, automation would ideally would build your extension
    against it run your test and see if anything broke. And then deploy the
    new [???] of your extension against version 16.3. Plus that would be your
    your release.

*   Jeremy S: I think there are two things there: There's rebuilding it ---
    because you can rebuild the same version of the extension and that would
    pick up if they they added a field in the middle of a struct which is what
    happened between 16.0 and 16.1, rebuild the same version. Versus: the
    extension author ... what would they be doing? If they they could tag a
    new version but they're not actually changing any code I don't think it is
    a new release of the extension, because you're not even changing anything
    in the extension, you're just running a new build. It's just a rebuild.

    *   *David Wheeler (he/him)* in chat: It’d be a new binary release of the
        same version. In RPM it goes from v1.0.1-1 to v1.0.1-2

    It reminds me of what Alvaro did in his his OCI blog post, where he said
    you really have to ... Many of us don't understand how tightly coupled the
    extensions need to be to the database. And these C extensions that we're
    we're building have risks when we separate them don't just build
    everything together.

*   David G. Johnston: The change there would be metadata. Version four of my
    extension, I know it works on 16.0 to 16.1. 16.2 broke it, so that's where
    it ends and my version 4.1 is known to work on 16.2.

*   Jeremy S: But there is no difference between version 4 and version 4.1.
    There's a difference in the build artifact that your build farm spit out,
    but there's no difference in the extension, right?

    *   *Keith Fiske* in chat: Still confusing if you don't bump the release
        version even with only a library change

    *   *Keith Fiske* in chat: How are people supposed to know what library
        version is running?

*   David G. Johnston: Right. If the extension still works, then` your
    metadata would just say, "not only do I work through version 16.2, I now
    work through 16.3.

*   Jeremy S: But it goes back to the question: is the version referring to a
    build artifact, or is the version referring to a version of the code? I
    typically think of versions as a user of something: a version is *the
    thing.* It would be the code of the extension. Now we're getting all meta;
    I guess there are arguments to be made both ways on that.

    *   *Jason Petersen* in chat: (it’s system-specific)

    *   *Jason Petersen* in chat: no one talks in full version numbers, look
        at an actual debian apt-cache output

*   David Wheeler (he/him): Other questions? Anybody familiar with the `rpath`
    stuff? That seems pretty interesting to me as a potential solution for
    bundling all the parts of an extension in a single directory --- as
    opposed to what we have now, where it's scattered around four different
    directories.

*   Jason Petersen: I've played around with this. I think I was trying to do
    fault injection, but it was some dynamically loaded library at a different
    point on the `rpath`. I'm kind of familiar with the
    mechanics of it.

    I just wanted to ask: In a bigger picture, this talks about building
    extensions that sort of work everywhere. But the problems being solved are
    just the duplication across the spec files, the Debian files, etc. You
    still have to build a different artifact for even the same extension on
    the same version of Postgres on two different versions of Ubuntu, Right?
    Am I missing something? It is not an extension that runs everywhere.

*   Yurri: No, you still have to build against the set of attributes that
    constitute your target, whether that's architecture, operating system,
    flavor. It's not yet something you can build and just have one binary. I
    would love to have that, actually! I've been pondering a lot about this.
    There's an interesting project, not really related to plugins, but if
    you've seen A.P.E. and Cosmopolitan libc, they do portable executables.
    It's a very interesting hack that allows you to run binaries on any
    operating system.

*   Jason Petersen: I expected that to be kind of "pie in the
    sky."

*   Yurri: It's more of a work of art.

*   Jason Petersen: Do you know of other prior art for the `rpath`?  Someone
    on Mastodon the other day was talking about Ruby --- I can't remember the
    library, maybe it was ssh --- and they were asking, "Do I still have to
    install this dynamic library?" And they said, "No, we vendor that now;
    whenever you install this it gets installed within the Ruby structure."
    I'm not sure what they're doing; maybe it's just a static linking. But I
    was curious if you were aware of any prior art or other packaging systems
    where system manages its own dynamic libraries, and use `rpath` to
    override the loading of them so we don't use the system ones and don't
    have to conflict with them. Because I think that's a really good idea! I
    just was wondering if there's any sort of prior art.

*   Daniele: There is an example: Python Wheels binaries us `rpath`. A wheel
    is a ZIP file with the C extension and all the depending libraries the
    with the path modified so that they can refer to each other in the the
    environment where they're bundled. There is a tool chain to obtain this
    packaging --- this vendoring --- of the system libraries. There are three,
    actually: one for Unix, one for macOS, one for Windows. But they all more
    or less achieve the same goal of having libraries where they can find each
    other in the same directory or in a known directory. So you could take a
    look at the wheel specification for Python and the implementation.
    That could be a guideline.

*   Jason Petersen: Cool.

*   Yurri: That's an excellent reference, thank you.

*   David Wheeler (he/him): More questions?

*   Jeremy S: Yeah, I have one more. Yurri, the build inferencing was *really*
    interesting. A couple things stood out to me. One that you mentioned was
    that you look for The `META.json` file. That's kind of neat, just that
    it's acknowledged a useful thing; and a lot of extensions have it and we
    want to make use of it. I think everybody knows part of the background of
    this whole series of meetings is --- one of the things we're asking is,
    how can we improve what's the next generation of `META.json` to make all
    of this better? Maybe I missed this, but what was your high-level takeaway
    from that whole experience of trying to infer the stuff that wasn't there,
    or infer enough information to build something if there isn't a
    `META.json` at all? Do you feel like it worked, that it was successful?
    That it was an interesting experiment but not really viable long term? How
    many different extensions did you try and did it work for? Once you put it
    together, were you ever able to point it at a brand new extension you'd
    never seen before and actually have it work? Or was it still where you'd
    try a new extension and have to add a little bit of extra logic to handle
    that new extension? What's your takeaway from that experience?

*   Yurri: The building part is largely unrelated to `META.json`, that was
    just primarily the metadata itself. I haven't used in a lot of extensions
    because I was looking for different cases --- extensions that exhibit
    slightly different patterns --- not a whole ton of them yet. I would say
    that, so far, this is more of a case-by-case scenario to see for a
    particular type of or shape of extension what we need to do. But
    generally, what I found so far that it works pretty nicely for C
    extensions: it just picks up where all the stuff is, downloads all the
    necessary versions, allows to discover the new versions --- for example
    you don't need to update the specification for a package if you have a new
    release, it will just automatically pick that up rom the list of tags.
    These these were the current findings. I think overall the direction is
    promising, just need to continue adjusting the results and see how much
    further it can be taken and how much more benefit it can bring.

*   Jeremy S: Thank you.

*   Yurri: Any other comments or thoughts?

*   David Wheeler (he/him): Any more questions for Yurri?

*   David Wheeler (he/him): I think this is a an interesting space for some
    research between Devrim's presentation talking about how much effort it is
    to manually maintain all the extensions in the Yum repository. I've been
    doing some experiments trying to build everything from PGXN, and the
    success rate is much lower than I'd like. I think there are some
    interesting challenges to automatically figuring out how things work
    versus convincing authors to specify in advance.

*   Jeremy S: Yep. Or taking on that maintenance. Kind of like what a spec
    file maintainer or a Debian package maintainer is doing.

*   Yurri: Yeah, precisely.

## Wrap Up

*   David Wheeler (he/him): Thanks, Yurri, for that. I wanted to remind
    everyone that we have our final Mini-Summit before PGConf on May 15th.
    That's two weeks from today at noon Eastern or 4 pm UTC. We're going to
    talk about organizing the topics for the Summit itself. I posted a long
    list of stuff that I've extracted from my own brain and lots more topics
    that I've learned in these presentations in the Slack. Please join the
    [community Slack] to participate.

    The idea is to winnow down the list to a reasonable size. We already are
    full with about 45 attendees, and we we can maybe have a few more with
    standing room and some hallway track stuff. We'll figure that out, but
    it's a pretty good size, so I think we'll be able to take on a good six or
    *maybe* eight topics. I'm going to go over them all and we'll talk about
    them and try to make some decisions in advance, so when we get there we
    don't have to spend the first hour figuring out what we want to, we can
    just dive in.

    And that's it. Thank you everybody for coming, I really appreciate. We'll
    see you next time

    *   *Tobias Bussmann* in chat: Thanks for the insights and discussion!

    *   Jeremy S: Thank you!

  [Omnigres]: https://omnigres.com
  [Yurri Rashkovskii]: https://yrashk.com
  [community Slack]: https://pgtreats.info/slack-invite "Join the Postgres Slack"
