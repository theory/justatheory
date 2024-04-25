---
title: Mini Summit Four
slug: mini-summit-four
date: 2024-04-25T22:40:45Z
lastMod: 2024-04-25T22:40:45Z
description: |
  Links, notes, and commentary from Jonathan Katz's presentation at the fourth
  Postgres Extension Ecosystem Mini-Summit, "Trusted Language Extensions for
  PostgreSQL".
tags: [Postgres, TLEs, PGXN, Extensions, PGConf, Summit]
type: post
---

My thanks to [Jonathan Katz] for his presentation, "Trusted Language
Extensions for PostgreSQL", at last week's [Postgres Extension Ecosystem
Mini-Summit][mini-summit]. As usual I've collected the transcript here
interspersed with comments from the chat window. First, links!

*   [Video](https://youtu.be/fu_yDwofkTg)
*   PDF Slides [TBD]

And now, rivers of text!

## Introduction

*   I opened the meeting and introduced [Jonathan Katz].

## Presentation

*   Thank you for having me. I'm very excited to talk about this, and
    extensions in general. I see a lot of folks here I know and recognize and
    some new folks or folks I've not met in person yet.
    
*   Borrowed from the original presentation on TLEs from November of 2022, to
    level set on why we built it. I know this is a slightly more advanced
    audience, so some stuff that might seem relatively introductory to some of
    you, though there is some material on the internals of extensions.

*   The premise is why we decided to build TLEs, what were the problems we're
    trying to solve. Part of it is just understanding Postgres extensions. In
    general this group is very familiar with Extensions but there are two
    points I want to hit on.

*   One of the things that excites me most about Postgres is that, when you
    look back at Postgres as the Berkeley database project researching how to
    create an object relational database, an accidental or intentional
    features is not just that Postgres is an object-relational database, but
    that Postgres is an *extensible* database, built from the get-go to be
    able to add functionality without necessarily having to fork it.

*   Early on you'd have to Fork the database to add additional functionality,
    but the beauty of the Postgres design was the ability to keep adding
    functionality without forking.

*   It did require making changes to Postgres to further enhance that
    capability, which we'll discuss in a bit, but that's a *really powerful
    concept.*

*   The second point is that there is the large landscape of both open source
    and Commercial extensions. I think a lot of folks in this group are very
    familiar with the available open source extensions, but there are entire
    businesses built on, effectively, commercial extensions on top of
    Postgres. Again, that's a really powerful notion!
    
*   It's kind of like the Postgres economy: we created something that's so
    special that it's able to spawn all these different businesses whether
    it's building things on top of Postgres or using Postgres as the heart of
    their business. Extensions have a very large role to to to play in that.

*   Which gets us to the history of extensions. The Syntax for Postgres
    extensions has been around for over a decade, since Postgres 9.1. I know
    there's folks here well familiar with building extensions prior to that
    syntax! But we're very grateful for the extension syntax because, as a
    recovering application developer, I would say it made things a lot easier.

*   Instead of having to futz around the file system to figure out where to
    install everything (wink wink nudge nudge on the topic today), you had a
    very simple syntax. Once an extension is installed, I can `CREATE
    EXTENSION postgis` (or whatever extension) and there you go! I have
    PostGIS installed.

*   Again, that's really cool! Because anything we can do to make it simpler
    to install and use extensions further drives their adoption, and
    ultimately makes it even easier to develop and build applications with
    Postgres and  continues to drive that forward.
    
*   So what can you build with Postgres, what extensions are available? It's a
    whole range of things. For starters, there are extensions that I call "the
    ones that you take for granted". If you're using any monitoring tool
    you're likely running and you may not even realize
    it. `pg_stat_statements` helps to aggregate statistics as queries execute
    and bubbles it up to whatever monitoring tool you use. It's a great tool
    for performance tuning.
    
*   The example I like to give for my personal life was that, back when I was
    an application developer trying to manage my own databases, I had some
    query that was blocking my entire logical decoding system, so we weren't
    keeping up with transactions. Looking in `pg_stat_statements` I see a
    recursive query where I should have had a `UNION` with `SELECT DISTINCT`
    instead of a gigantic query that was amassing so many rows. Fixed it: I
    had a 100x speed up in the query. Thank you `pg_stat_statements`!

*   Side note: I got to say, "hey, I sped up this query by 100x," even though
    it was my fault it was slow to begin with.

*   There are utility functions to help with data types. UID OSSP is very
    widely used. Newer versions of Postgres have a random UUID function, but
    previously, anytime you needed a UUI you would `CREATE EXTENSION
    "uuid-ossp"`.
    
*   The other fun thing about this extension is that developers
    learned about SQL identifiers that require double quotes to
    install the extension.
    
*   I think I saw Keith on here today. pg_partman! What's really cool about
    pg_partman too is that a lot of it is PL/pgSQL. This PL/pgSQL code
    provides a way to manage partitions across all your tables in your entire
    database. Again, that's really powerful because Postgres has added
    declarative partitioning in version 10, but pg_partman is still incredibly
    useful because there are all sorts of aspects to partition management not
    supported in Postgres today. This is another example where Postgres
    provides the core functionality and you can use the extension to package
    additional functionality that makes it easier for use.
    
*   Foreign data wrappers.Postgres has a whole interface to interface with
    other databases. It could be other Postgres databases, other relational
    databases, non-relational databases, file systems, etc. Postgres has a
    C-level interface that allows you to design the calls to optimally use all
    these different databases. Again, packaged up as an extension, being able
    to add things as we go on.
    
*   I'll wait till the end to answer questions this will be a relatively short
    presentation, so we
    should have some time for discussion
    
*   Last but not least, a little bit on PostGIS. I think this is one of the
    most powerful aspects of Postgres. PostGIS itself is incredibly powerful
    because you have a geospatial database that happens to be Postgres
    underneath. A lot of heavy PostGIS users don't even realize they're using
    Postgres! They think they're using PostGIS. That is really the power of
    Postgres extensibility in a nutshell: It looks like you have like a brand
    new, domain-specific database -- and yet underneath it it's just boring
    old Postgres doing all the things you expect a database to do. That is
    also a very powerful notion/

    *   *Tobias Bussmann* in chat: Many PostGIS users don't know they are
        using PostgreSQL 🤣
    
    *   *nils* in chat: 🎉

*   To add a coda to it, you have pgRouting, an extension built on top of
    PostGIS, which is built on top of Postgres. So you have a cascading effect
    of extensions building on top of extensions building on top of Postgres.

*   So we're supposed to talk about trusted language extensions. To really to
    TLEs it's important to understand the anatomy of an extension. There are
    certain things that you need in order to have an extension: You need a
    control file, which is kind of like your packaging manifest. it tells you
    what's in the extension. It goes into a directory.

*   You have SQL files, which effectively map out the objects that you're
    going to have in your database. If you have functions that need to map to
    a C function or if you need to create a table access method in order to
    build your new your new storage layer, the SQL files are the building
    block.

*   If you have C- specific code, it goes in a library file or a shared object
    file that gets stored in a library directory.

*   It's a very simple layout. What's cool is if you go to create an
    extension, there's a particular pattern that it forms: You need to know
    that when you have an extension, the information in the control file goes
    into the Postgres catalog. Then, if there are any functions or objects or
    whatever in that extension, we need to install the object itself, but we
    also need to make sure that there's a dependency on the extension. That
    way, if we need to remove the extension or upgrade it, we know all the
    objects that we've collected.

*   So why this "extension building 101"? This gets at the heart of why we
    built TLes. Because the first thing to notice is that we install
    extensions directly on the file system. There are a lot of domains where
    that's restricted --- certainly managed service providers.
    
*   I worked a lot with containers previously, and a container is effectively
    an immutable file system: once you have things installed on it it's
    installed. You typically don't want to give your app developers access to
    your production systems, because your app developers are going to install
    everything under the sun on them, myself included. You certainly want to
    be able to restrict certain domains.
    
*   But we also don't want to inhibit what developers want to build. We want
    to make it as easy as possible for them to manage their code and be able
    to install in different environments. That gets to another point beyond
    restricting the file system. Some extensions may not be universally
    available, depending on where you're running them. You might be running an
    extension on an on-premise environment that might not work in a managed
    service provider. Or different managed service providers have different
    extensions available.
    
*   The final bit --- and something that I've definitely personally
    experienced --- is that, between major versions of Postgres, the API or
    the ABI will change. These are the interface points at the C layer. When
    they change it can break extensions. Ask any of the package managers how
    much they need to nag people to upgrade their extensions: they always want
    to make sure that they're keeping it up-to-date, and ensuring that it's
    compatible.

*   But this can also lead to other issues, because as the end user, this
    makes it challenging to perform major version upgrades --- particularly if
    I'm dependent on an extension that hasn't been updated to work with the
    latest version of Postgres. A subtle line of code change in Postgres could
    end up breaking an extension.

*   Quick story: that actually happened to me while I was managing pg_tle. I
    think it was a change in Postgres 15.1 actually broke something in the
    pg_tle extension. I had to to fix it. I think that's part of the point: if
    you're able to use a language that's *on top* of C, and you have the C
    layer abstracted away, in theory it could make it easier to perform major
    version upgrades.

*   That leads into TLE.

*   I think there were two Notions behind trusted language extensions, or
    TLEs, when they were initially designed. The first is giving power to app
    developers to be able to build extensions. It's actually one thing I
    noticed as I started making the journey from  app developer to quasi-DBA
    to, ultimately, product manager not writing code. Part of that Journey was
    the power of putting some of my business logic in the database.
    
*   There's always this tension between how much business logic to put in
    application code versus the database. But there are certain things that
    were just clear wins for me when they wer in the database. The first was a
    lot of search functions I wrote where filtering data down to a very small
    set in the database and returning to the application would save on network
    time, processing time on the app side, etc. There were some very clear
    wins by encapsulating them in functions.

*   But also solving things that were just much easier to solve in the
    database. Having specific data types that solve a particular problem ---
    geospatial extensions keep coming to mind, pgvector dealing with Vector
    data, and being able to store it in a database without having delegate it
    out into an application certainly is a is a clear win.

*   The other thing was installing extensions. I think the notion of
    portability is very powerful. If I
    have a way to manage my extensions from a SQL interface, it
    makes it much easier to move it between different systems.
    
*   Now, we do need to be careful as soon as we start saying "SQL interface".
    I don't want to suggest that we should have a SQL interface to ship C code
    everywhere We know there are some challenges with C code. C is highly
    performant, you can effectively build anything under the sun using C, but
    it's not memory-safe, and it's very easy if you're not familiar with what
    you're doing --- and even if you are familiar with what you're doing! ---
    you can easily make mistakes that could either lead to crashes or or
    possibly worse.
    
*   As we were thinking about all this with TLE, there's three things. First,
    we need an interface to be able to install and manage extension code
    effectively regardless of environment. We need a SQL interface to do that.
    We also need to make sure there's an appropriate trust boundary. Now, Postgres
    provides a trust boundary with the notion of a *trusted language.* But
    there are other things we need to
    build with trust, as well.
    
*   For example, you might not want everyone in your environment to be
    be able to install the a TLE, so we need to
    make sure there's appropriate access controls there.
    
*   Finally, we need a way to package it up --- which I
    think is what we're going to talk about at the Extension
    Summit.
    
*   If there are any takeaways from why we built TLE (I think this is the the
    slide that encapsulates it), it's that, by using by using Postgres's
    built-in trusted language interface it allows you to write extension code
    in languages that we know are going to respect Postgres security
    boundaries.

*   Postgres has this definition of a trusted language which, if you look at
    for it, you have to effectively dance around the documentation to find it.

*   But effectively I'd summarize as, if you allow an unprivileged user to
    write code in a trusted language, they can't do anything to escalate their
    privileges, access the file system directly, or do anything that would
    violate Postgres's security boundary.

*   It's a pretty good definition. Arguably, the easiest way to violate that
    definition is that you as the database administrator mark an untrusted
    language as trusted in the catalog. But I strongly advise to not do that!

*   What trusted languages are available. There's a great wiki page called the
    "PL Matrix" on the Postgres Wiki that shows the status of all all the
    known PLs in Postgres and whether they're trusted or not. I suggest
    looking at that.

    *   *David Wheeler (he/him)* in chat: https://wiki.postgresql.org/wiki/PL_Matrix    

    *   *Jeremy S* in chat: Linux had kernel modules forever, but many people
        were rightfully hesitant because a kernel module could easily crash
        your entire system. One of the reasons eBPF is exploding today is
        because it’s verified and safe and enables code (like entire
        networking apps) to run directly in the linux kernel.
        
        I see TLE similarly

*   A big thing regarding a trusted language is *performance.* There are a
    variety of trusted languages, and they all have different properties you
    know around them. The ones I'm showing today are the ones available in RDS
    Postgres. But the reason I want to show them is that, part of the idea of
    trusted language extensions is allowing app developers who may be less
    familiar with C to write extension code and access some of the same
    internals as a C extension, but from one of these languages.
     
*   Here are some of the known trusted languages today that work with TLE. If
    you're using the TlE open source project, you can use any available
    trusted language --- or you can use *untrusted* languages an just use the
    TLE packaging mechanism. In that case you lose the *trusted* part, but
    gain the extension installation aspect of TLE.

*   There are a few things included in TLE to make sure that TLE can be
    installed safely. It is an opt-in feature. We do have a shared preload
    library for pg_tle called "pg underscore TLE", and you do need to have your
    database super user install pg_le initially. This ensures that we're
    respecting your security boundary, If you're going to use trusted language
    extensions, you do have an explicit opt-in to using it.

    *   *David Wheeler (he/him)* in chat: https://github.com/aws/pg_tle

*   After that, an app developer can create their own trusted language
    extension.
    
*   Here's a simple example from the TlE announcement with two functions and
    packaged into an extension you can install. You can give it a name like
    any Postgres extension; this one is called "tle_test". The code looks like
    the SQL file in any extension. And it's effectively packaged up like an
    extension using the `pgtle.install_extension` command. If you go to the
    pg_le GitHub project you can see the the different interface points.

*   Once it's installed you can use `CREATE EXTENSION` like any other
    extension: it follows all the usual Postgres semantics: extension
    installation, uninstallation, software life cycle management. pg_tle has
    its own interface for that functionality, bu once you've installed it,
    managing the extension is just like managing any other Postgres extension,
    and follows those conventions.

*   Effectively TLE is offering, loosely, a packaging mechanism (I think
    packaging has a lot more connotations): it's a grouping mechanism for
    your code. One of the parts that I always found most useful in
    pg_tle was this part, effectively versioning my store procedures.
       
*   When I talked about the example where I was putting business logic into
    the database, one part I would usually mess up is: what version of my
    stored procedures was running in a given database. Particularly if you
    have hundreds or thousands of databases that you're managing, that can be a
    challenge.
    
*   Now I had far fewer databases I was managing, I was more dealing with our
    developer environments: staging and production. But I was managing the
    store procedures within our migration scripts --- which is totally fine,
    because if I know what version of the migration that I ran then I would
    know what version of the stored procedures are on that database. Kind of.
    Sort of. Maybe. You know: unless someone manually modified it --- in which
    case shame on me for giving access to the database. But there basically
    could be some gaps in knowing what version of a stored procedure was on a
    particular server.

*   With pg_le we can significantly reduce the risk of that problem because we
    have a way to *version* our store procedures, and be able to know exactly
    what we're running at any given time, and create a consistent packaging
    mechanism wherever we're running our code. And it goes beyond stored
    procedures because there's far more that you can can build with your code.

*   What else does TLE add? We discussed was the packaging mechanism, but a
    lot of the power of Postgres extensions is the ability to use the
    underlying Postgres internals. One of these types of internals is called a
    "hook".
    
    Hooks are the Postgres feature that you've never heard of, that are not
    well documented, and yet are the foundational part of many extensions.
    Hooks are almost everywhere in Postgres. You particularly see a lot of
    them during the query execution process. For example the process utility
    hook which allows you to modify any utility command, anything that's not a
    direct SQL statement. There are all sorts of hooks: there are password
    check hooks, client authentication hooks, hooks called around shared
    memory allocation, hooks called at each step of the the execution phase.

    *   *Florents Tselai* in chat: Hooks are almost undocumented indeed

        The best resources I've found:

        - https://github.com/taminomara/psql-hooks
        - and the standard: https://wiki.postgresql.org/images/e/e3/Hooks_in_postgresql.pdf

*   Hooks are very powerful; particularly enabling a lot of extensions adding
    different semantic behavior to Postgres. We could probably do a whole
    series of talks just on all the different ways you can extend Postgres. I
    mean, that's why David has organized the summit! But hooks are very simply
    a powerful mechanism to define behavior and Postgres.
    
*   Because they're so powerful, for the hooks that we expose in tle we
    make sure that there is a super user opt-in. Remember, an unprivileged user can define
    this behavior but you *do* need someone with privilege 
    to be able to enable something like a hook.
    
*   For example, a password check hook probably means that you have the
    ability to evaluate a plain text password that's coming through. Now on
    that topic we can have a very long debate, but let's save that for
    Vancouver. But with this hook, you do have the ability to do password
    checks, so you want to make sure that, when you enable a function that
    calling a password check hook that there's a certain level of privilege to
    that function. Or you you know you want to make sure you do your
    appropriate evaluation to make sure that you trust that function.
    
*   In addition to that check, there's an additional check from the pg_tle
    admin role that requires someone with administrative privileges over your
    TLE to register that hook. The concept of "TLE features" are  the way to
    map hooks into the TLE. We've been building it up
    since we launched TLE by adding a few hooks. There's both the check
    password hook and the client authentication hook.
    
*   There's also the ability to register custom data types --- which is pretty
    cool, because data types are what attracted me to Postgres when I was an
    app developer: "Oh! There are all these data types! I can do all these
    rich comparisons against an index? Cool! Oh wait, you can even add custom
    data types? That's even *cooler!*"
    
*   TLE allows you to create the *base* data type, so you can really expand
    the data types that you're able to add. This is what TLE features does: it
    enables that safe mapping  between trusted language code and the Postgres
    C internals.
    
*   In order to create a hook, you need to match the hook function definition.
    The TLE documentation documents how to create it appropriately, but it
    doesn't need all the parameters that you would find in the
    hook function.
    
*   In this check password hook --- I call this the "delay check password
    test", meaning you're probably trying to avoid someone trying to guess
    your password repeatedly, and if they keep failing so what, because
    they're not going to brute force it anyway. There are actually more
    practical examples of check password hooks. But what's cool is that you
    can define everything around the your hook behavior from within the hook
    function and then it acts as if you wrote a C-based hook! You just happen
    to write it in a in a trusted language.

*   Hooks do execute with elevated privileges, particularly around
    authentication you want to be very careful. So there are some safeguards
    built into TLE to make sure that you only enable hooks when you want to.

*   Last but not least: choosing a trusted language. I know this group is more
    focused on extension building, but I do want to talk about what an app
    developer goes through when choosing a
    trusted language.
    
*   Because everything has its trade-offs to consider. The Golden Rule (I
    actually took this from Jim Mlodgensky) is: when in doubt use PL/pgSQL,
    because it does have a lot of access to context that's already available
    in Postgres. What's interesting about this is that what we see today is
    based on PL/SQL. PL/pgSQL was developed to try to make it simpler to
    migrate from Oracle, but at the same time to provide a lot of rich
    functionality around Postgres.

*    As someone much more familiar with Ruby and Python, I can tell you that
     PL/pgSQL can be a little bit quirky. But it is very well documented, and
    it can solve all the problems that you need to in Postgres. And it already
    has a lot of very simple ways to directly access your data from Postgres.
    Certainly an easy choice to go with.
    
*   But wait, there's more!

*   like PL/v8, writing JavaScript in your database, this is really cool! I
    remember when it came out and how mind-blowing it was, in particular for
    JSON processing. PL/v8 is awesome. PL/v8 came out right around the same
    time as the document database! So you kind of had perfect storm of being
    able to process JSON and write it in JavaScript --- both within your
    Postgres database and it could be quite powerful.

*   Another really cool feature of PL/v8 is the ability to directly call
    another function or another PL/v8 function *from within PL/v8,* and not
    have to go through Postgres function processing, which adds a lot of
    additional overhead.
    
*   And now the one that's all abuzz right now: PL/Rust. Being able to write
    and execute Rust code *within Postgres.* This is pretty cool, because Rust
    is a compiled language! There's a trusted way to run PL/Rust within
    Postgres. There are a few techniques to do it. First, whenever you're
    running Rust on your server, to make sure that you're guarding against
    breakouts.
    
*   There is a library, I believe it called postgres FTD, that effectively
    compiles out some of the less dressed parts of Rust, such as unsafe
    function calls. But you can still get everything that you want in PL/Rust
    today: you get the Rust standard Library, the ability to run crates ---
    and you do want to evaluate crates to make sure that you're comfortable
    running them in your environment. But then you get this compiled language
    that is CPU efficient, memory efficient, and memory safe. (Well, a lot of
    Rust is memory safe) It's pretty cool!

    *   *Steven Miller* in chat: In PL/Rust, does it run the compilation when
        the function is created? Then if there is a compiler issue it just
        shows up right there?

*   I wrote a blog post last year that compared some different function calls
    between PL/pgSQL, PL/v8, and PL/Rust. First I was doing some array
    processing, and you could see that the Pl/Rust calls were very comparable
    to the C calls. And then there's some additional Vector processing, given
    that I've been obsessing on vectors for the past 14 months. Seeing rust
    actually win against PL/pgSQL and PL/v8 (I don't remember the numbers off
    the top of my head I can look up that blog as soon as I switch windows).
    Pretty cool!

*   This brings us in some ways to the best of all worlds, because I can take
    an extension that normally I would write in C, particularly because I'm
    focused on performance, I can write it in PL/Rust, package it as a trusted
    language extension, and run it anywhere that TLE and PL/Rust are
    supported. Again, that is very powerful, because suddenly I have what I
    hope is the best of all worlds: I have this portability, I don't have to
    worry as much about major version upgrades because pg_le is acting as that
    abstraction layer between the Postgres C code and the application code
    that I'm writing.
    
    *   *Jeremy S* in chat: Versioning of stored procedures is a very
        interesting use case

    *   *Darren Baldwin* in chat: Agreed! Moving stuff to the database layer
        seems to be something very foreign and “scary” to most app devs I’ve
        talked to

    *   *Anup Sharma* in chat: Is TLE a requirement for any PostgreSQL
        extension, or is it dependent?
    
    *   *Steven Miller* in chat: So during a major version upgrade, the
        function declaration stays the same, so that’s why your application
        doesn’t need to change with respect to the extensions during a major
        version upgrade. And at some point during the migration, you create
        the function again, which recompiles. So it all works the same! That’s
        great

*   Last slide, then I'm certainly looking forward to discussion. pg_tle is
    open source, and it's open source for a lot of reasons. A lot of it is
    because we want to make sure that trusted language extension are as
    portable as possible. But in some ways the ideas behind TLE are not
    original. If you look at other databases there is this notion of, let's
    call it inline extensions, or inline SQL, ou call them modules, you call
    them packages. But the idea is that I can take reusable chunks of code,
    package them together, and have them run anywhere. It doesn't matter where
    the database is located or hosted.

*   This is something that I personally want to work with folks on figuring
    out how we can make this possible in Postgres. Because even in Postgres
    this is not an original idea. Dimitri Fontaine was talking about this as
    far back as 2012 in terms of his vision of where of the extension
    framework was going.
    
*   What I'm looking forward to about this Extension Summit --- and hopefully
    and hopefully I'm not in conflicting meetings while it's going on --- is
    talking about how we can allow app developers to leverage all the great
    parts of Postgres around function writing, function building, and
    ultimately packaging these functions, and making it simple simpler for
    them to be able to move it wherever their applications are running.
    
*   So it is open source, open to feedback, under active development, continue
    to add more features to support Postgres. Iltimately we want to hear
    what'll make it easier for extension writers to be able to use TLE, both
    as a packaging mechanism and as a as a development mechanism.

*   So with that uh I that is the end of my slides and happy to uh get into a
    discussion about this.

## Discussion

*   David Wheeler (he/him): Awesome, thank you Jonathan. there was one
    question about PL/Rust in the comments. Stephen asks whether it compiles
    when you create the function, so if there are compiler issues they they
    show up there.

*   Jonathan Katz: Correct It compiles when you create the function and that's
    where you'll get compile errors. I have definitely received my fair share
    of those [chuckles]. There is a Discord. PL/Rust is developed principally
    by the folks uh responsible for the pgrx project, the folks at ZomboDB,
    and they were super helpful and debugging all of my really poor Rust code.

*   David Wheeler (he/him): While while people are thinking about the
    questions I'll just jump in here. You mentioned using crates with PL/Rust.
    How does that work with pg_le since they have to be loaded from somewhere?

*   Jonathan Katz: That's a good question. I kind of call it shifting the
    problem. TLE solves one problem in that you don't need to necessarily have
    everything installed on your on your local file system outside of pg_tle
    itself. If you're using PL/Rust and you need crates, you do need those
    crates available either within your file system or within whatever package
    management tools you're using. So it shifts the problem. I think it's
    going to be a good discussion, about what we can do to help ensure that
    there is a trusted way of loading those.

*   David Wheeler (he/him): Yeah I wonder if they could be vendored and then
    just included in the upload through the function call.
    
    Anup Sharma asked asked if pg_tle s a requirement any extension or
    is it dependent.
    
*   Jonathan Katz: It's not requirement. This is a project that is making it
    possible to write Postgres extensions in trusted languages. There ar
    plenty of extension authors on this call who have written very, very, very
    good extensions in C that do not use TLE.

*   David Wheeler (he/him): You can use trusted languages to write extensions
    without TLE as well. It's just a way of getting it into the
    database without access to the file system, right?

*   Jonathan Katz: Correct. I think I saw Keith here. pg_partman is PL/pgSQL.

    *   *Anup Sharma* in chat: Understood. Thanks

    *   *Tobias Bussmann* in chat: I think it is important not to confuse
        Trusted Language Extensions TLE with "trusted extensions" which is a
        feature of Postgres 13

    *   *Keith Fiske* in chat: Pretty much all of it is. Just the background
        worker isn't
    
    *   *Jonathan Katz* in chat: hat’s what I thought but didn’t want to
        misspeak 🙂

*   David Wheeler (he/him): Right Any other questions or comments or any
    implications that you're thinking about through for extension
    distribution, extension packaging, extension development?

    *   *Steven Miller* in chat: Is background worker the main thing that a
        TLE could not do in comparison to traditional extensions?

*   Jason Petersen: The crates thing kind of raised my interest. I don't know
    if Python has this ability to bring in libraries, or if JavaScript has
    those dependencies as well. But has there been any thought within pg_tle
    for first classing the idea of having a local subdirectory or a local file
    system layout for the "native" dependencies? I'm using "native" in quotes
    here because it could be JavaScript, it could be Python, whatever of those
    languages, so they could be installed in a way that's not operating system
    independent.
    
    I know this is kind of a complex setup, but what I'm getting at is that a
    lot of times you'll see someone say "you need to install this package
    which is called this and Red Hat or this on Mac or this on Debian --- and
    *then* you can install my extension. Has there been any push towards
    solving that problem by having your TLE extensions load things from like a
    a sort of Walled Garden that you set up or something? So it's specific to
    the database instead of the OS?

*   Jonathan Katz: That's a good question. There has been thought around this.
    I think this is going to be probably something that requires a thorough
    discussion in Vancouver. Because if you look at the trusted languages that
    exist in Postgres today, the definition of trusted language is: thou shall
    not access the file system. But if you look at all these different
    languages, they all have external dependencies in some in some way shape
    or form. Through Perl there's everything in CPAN; through
    JavaScript there's everything in npm. Let's say installed the appropriate CPAN libs and npm libs within uh your database for everything I recall from playing with trusted PL/v8 and PL/Perl is
    that you still can't access those libraries. You can't make the include or
    the require call to get them.
    
    Where PL/Rust is unique is that first off we just said,
    "yes, you can use your Cargo crates here." But I think that also requires
    some more thinking in terms of like how we make that available,
    if it's OS specific, vendor specific, or if there's
    something universal that we can build that helps to make that
    more of a trusted piece. Because I think at the end of the day, we
    still want to give the administrative discretion in terms of what they
    ultimately install.
    
    With the trusted language extensions themselves, we're able to say,
    "here's the post security boundary, we're operating within that security
    boundary." As soon as we start introducing additional dependencies,
    effectively that becomes a judgment call: are
    those dependencies going to operate within that security boundary or not.
    We need to be make sure that administrators still have the ability to
    to make that choice.
    
*   I think there are some very good discussion topics around this,  not just
    for something like PL/Rust but extension distribution in general I think
    that is you know one of the I think that'll be one of the key discussions
    at the Extension Summit.

    *   *David Wheeler (he/him)* in chat: What if the required
        modules/packages/whatever were in a table. e.g. in Perl I do `use
        Foo::Bar` and it has a hook to load a record with the ID Foo::Bar from
        a table

*   David Christensen: Has there been any thought to having the default
    version of an extension tied to the version of PostgreSQL? Instead of it
    just being 1.3 and, whether I'm on version 12 or 15, because 1.3 might not
    even work on version 12 but it would work on version 15. The versioning of
    the an extension and the versioning of PostgreSQL seem like they're almost
    *too* independent.

*   Jonathan Katz: So David, I think what you need to do is chastise the
    extension developers to let them know they should be versioning
    appropriately to to the the version of Postgres that they're using.
    [Chuckles]
    
    There is a good point in there, though. There is a lot of freedom in terms
    of how folks can build extensions. For example, just top of mind, pgvector
    supports all the supported versions of Postgres. Version 0.7.0 is going to
    be coming out soon so it's able to say, "pgvector 0.7.0 works with these
    versions." Dumb. PG plan meanwhile maintains several back releases; I
    think 1.6.0 is the latest release and it only supports Postgres 16. I
    don't believe it supports the earlier versions (I have to double check),
    but there's effectively things of that nature.

    And then there aer all sorts of different things out there, like PostGIS
    has its own life cycles. So there's something good in that and maybe the
    answer is that becomes part of the control file, saying what versions ov
    Postgres an extension is compatible with. That way we're not necessarily
    doing something to break some environment. I'm just brainstorming on on
    live TV.
    
*   David Christensen: The other day I open a but report on this. but
    PostgreSQL dump and restore will dump it without the version that's in the
    source database, and when yoq restore it, it's going to restore to
    whatever the current version for the control file is even if you're
    upgrading to a different database. versus restoring it to whatever the
    original version was. That dynamic just seemed problematic.
    
*   David Wheeler (he/him): I think it's less problematic for trusted language
    extensions or extensions that have no C code in them, because pg_dump does
    dump the extension, so you should be able to load it up. I assume base
    backup and the others do the same thing.
    
*   David Christensen: I haven't checked into that. It dumps `CREATE
    EXTENSION` and then it dump any user tables that are marked by the
    extension. So these code tables are marked as being user tables for TLE?
    
*   David Wheeler (he/him): What do you mean by code tables?

*   Regina Obe: That's a good point. For example my Tiger geocoder is all
    PL/pgSQL, but it's only the `CREATE EXTENSION` thing that's named. So for
    your TLE table, it would try to reload it from the original source,
    wouldn't it? In which case it would be the wrong version.

*   Jonathan Katz: We had to add some things into TLE to make sure it worked
    appropriately with pg_dump. Like I know for a fact that if you dump and
    load the extension it works it works fine. Of it doesn't then there's a
    bug and we need to fix it.

*   David Christensen: Okay yeah I haven't played with this. Literally this is
    new to me for the most part. I found the whole fact that the control file
    is not updated when you do `ALTER EXTENSION` to be, at least in my mind,
    buggy. 

*   Jonathan Katz: In the case of TLE, because it's in theory major
    version-agnostic. When I say "in theory," it's because we need to make
    sure the TLE code in library itself is able to work with every major
    version. But once that's abstracted away the TLEs themselves can just be
    dumped and reloaded into different versions of Postgres. I think we I we
    have a TAP test for that, I have to double check. But major version
    upgrades was something we 100% tested for
    
*   David Wheeler (he/him): I assume it'd be easier with pg_tle since there's
    no need to make sure the extension is is installed on the file system of
    the new server.

*   Jonathan Katz: Yep. if you look at the internals for pg_tle, effectively
    the TLEs themselves are in a table. When you do a `CREATE EXTENSION` it
    gets loaded from that particular table.
    
*   David Christensen: Right, and when you do a pg_dump you make suer that
    table was dumped to the dump file.

*   Jonathan Katz: Yes. But this is a key thing that we we had to make sure
    would does work: When loading in a pg_dump, a lot of the `CREATE
    EXTENSIONS` get called before the table. So we need to make sure that we
    created the appropriate dependency so that we load the TLE data *before*
    the `CREATE EXTENSION`. Or the `CREATE EXTENSION` for the TLE itself.
    
    *   *Jeremy S* in chat, replying to "Is background worker the main…":
        doing a background worker today, I think requires working in C, and I
        don’t think core PG exposes this yet. Maybe it could be possible to
        create a way to register with a hook to a rust procedure or something,
        but maybe a better way in many cases is using pg_cron

    *   *Jonathan Katz* in chat: We can add support for BGWs via the TLE API;
        it’s just not present currently.
    
    *   *nils* in chat: Creative thinking, if a background worker doesn’t work
        in TLE, how about create your UDF in tle and schedule with pg_cron 🤡

*   David Wheeler (he/him): You mentioned in the comments that you think that
    background workers could be added. How would that work?
    
*   Jonathan Katz: It would be similar to the the other things that we've
    added, the data types and the hooks. It's effectively creating the
    interface between the C API and what we'd expose as part of the TLE API.
    It's similar to things like pgrx, where it's binding to Postgres C API but
    it's exposing it through a Rust API. We do something similar with the TLE
    API.

    *   *Steven Miller* in chat: Thank you Jeremy. I like this idea to use
        TLE, then depend on cron for a recurring function call

    *   *Steven Miller* in chat: Ah yes Nils same idea 😄

    *   *Jason Petersen* in chat: Thumbs up to nils about pgcron. If you need
        a recurring BGW just write it in plpgsql and schedule it
    
    *  *nils* in chat: Great hackers think alike

    *   *Jason Petersen* in chat: (I know I do this)

*   David Wheeler (he/him): That that makes sense. I just thought the
    background workers were literally applications that are started when the
    postmaster starts up shut down when the postmaster shuts down.
    
*   Jonathan Katz: But there's dynamic background workers.

*   David Wheeler (he/him): Oh, okay.

*   Jonathan Katz: That's how a parallel query works.

    *   *Jeremy S* in chat: Threading? 😰

*   David Wheeler (he/him): Gotcha, okay. Sorry my information's out of date.
    [chuckles]

*   Jonathan Katz: Well maybe one day we'll have you know some some form of
    threading, too. I don't think like we'll get a wholesale replacement with
    threads, but I think there are certain areas where threads would help and
    certain areas workers are the way to go/
    
*   David Wheeler (he/him): Yeah, yeah that makes sense.

*   Jonathan Katz: Hot take!

*   David Wheeler (he/him): What other questions do you have for about TLEs or
    extensions more broadly and packaging in relation to TLEs?

*   David Christensen: Just a random thought: Have you thought about
    incorporating foreign servers and pointing the TLE, instead of a local
    database, point it to a master, company-wide foreign table?

*   David Wheeler (he/him): Like a TLE registry?

*   David Christensen: Right, yeah something global would be nice. like okay
    we hosted on PGXN at there's a TLE registry. But because for a company who
    wants maintain code internally between projects, and they want a shared
    library, they can publish it on one server, send up a link to it over
    foreign server, and then just point at that.

*   Jonathan Katz: Could be!

*   David Wheeler (he/him): I mean you could just use foreign foreign tables
    for that for the tables that TLE uses for its its registry, right?
    
*   David Christensen: That's I'm thinking.

*   David Wheeler (he/him): Yeah that's a cute idea.
    
*   Jonathan Katz: I think that just to to go back a few more minutes. I think
    you I was asked to talk about the vision. One one way to view extensions
    is trying things out before they're in core, or before they're in
    Postgres. The aspect that I would ultimately like to see in core someday
    is the ability to do that's called "inline modules." There is a SQL
    standard syntax, `CREATE MODULE`, that for this purpose. Some folks were
    trying to see see if we could get it into, I believe, Postgres 15. There
    was some push back on the design and it died on the vine for the time
    being.
    
    But I do think it's something to consider because when I talk to folks,
    whether it's random Postgres users RDS customers, etc., and I go through
    TLE, one of the things that really stands out is one of the things that we
    had discussed here and I saw in the chat, which is this aspect: being able
    to version your stored procedures. This is in part what modules aims to
    solve. One is just having a SQL interface to load all these things and
    group it together. But then once you have that grouping you have the
    ability to version it. This is the part that's very powerful. As soon as I
    saw this I was like, "man I could have used that that would have saved me
    like hours of debugging code in production." Mot saying that I was ever
    sloppy and you know in random store procedures in my production database!

    *   *David Wheeler (he/him)* in chat: I see CREATE MODULE in the db2 docs.

*   Jonathan Katz: But that's kind of the vision. The fact that Postgres is
    extensible has led to this very widely adopted database. But I think there
    are things that we can also learn in our extensions and bring back
    upstream. There are certainly reasons why they we developing things in
    extensions! Like pgvector is an example of that, where we talked about it
    at PGCon last year. And part of the thought of not trying to add a vector
    data type to Postgres was, first, to make sure we could settle on what the
    the binary format would be; and once that's solidified, then we could add
    it.
    
    But I had an aside with Tom [Lane] where we talked about the fact that
    this is something we need to move fast on, the vector space is moving very
    quickly, extensions are a way to be able to move quickly when something
    like Postgres moves more deliberately.
    
    This is in
    some ways where TLE is, our way to be able to see what kind of interface
    makes sense for being able to do inline extension loading
    and ultimately how we want that to look in core.

*   David Wheeler (he/him): Can you create data types with a binary
    representation in TLE?

*   Jonathan Katz: Yes as of (I want to say) the the 1.3 release. I have to
    double check the version. The way we're able to do it safely is that it
    actually leverages the BYTEA type. When you create that representation it
    stores it as a BYTEA. What you get for free today is that, if you create
    your equality/inequality operators, you can use a b-tree look up on these
    data types. 
    
    So there's a "dot dot dot" there. If we wanted to be able to use like GIST
    in GIN and build data types for our other index interfaces, there's more
    work to be done. That would require a TLE interface. I spent a lot of time
    playing with GIST and GIN, and the interface calls themselves involve
    pointers. So that will require some thought yeah.
    
*   David Wheeler (he/him): I assume it's a similar issue for Rust data types
    that are basically just serde-serialized.
    
*   Jonathan Katz: Yeah we can at least like store things in BYTEA, and that's
    half the battle. It allows us to do a safe representation on disk as
    opposed just "here's some random binary; good luck and don't crash the
    database!"

    *   *Jason Petersen* in chat: I also wondered about the function interface
        for things like storage features (table access methods).

        I assume they’re similarly hairy

*   David Wheeler (he/him): Any other last minute questions?

*   Jonathan Katz: Table access methods. Yes table access methods are very
    hairy as are index access methods. I spent a lot of time the past 14
    months looking at the index access method interface, which has a lot of
    brilliance in it, and certainly some more areas to develop. But it's
    amazing! The fact that we can implement vector
    indexes and get all the best parts of Postgres is a phenomenal
    advantage.
    
*   Jeremy S: One last question. We're leading up to Vancouver and we're going
    to be starting to think about  some of the topics that we want to make
    sure to talk about at the Summit. I think you mentioned one earlier (I
    should have written it down), but any final thoughts about topics that we
    should make sure to discuss?

*   Jonathan Katz: Just in general or TLE specific?

*   Jeremy S: Both. I mean for sure TLE-specific, but also just generally
    related to extensions

*   Jonathan Katz: My TLE-specific one dovetails into the general one. The
    first one is: is there ultimately a path forward to having some kind of
    inline extension management mechanism in core Postgres. That's the top,
    part one, I spent the past five minutes talking about that.
    
    But I think the big thing, and why we're all here today, is how do we make
    it easier for developers to install extensions, manage extensions, etc. I
    think the notion of package management thanks to the work of Andres
    finding the backdoor to xz also shines a new light, because there's a huge
    security component to this. I remember, David, some of our earlier chats
    around this. I think you know ---- again, being ap-developer sympathetic
    --- I definitely want to see ways to make it easier to be able to load
    extensions.
    
    Having spend spent a lot of time on the other side, the first thing that
    comes to mind is security. How do we create a protocol for managing the
    extension ecosystem that also allows folks to opt into it and apply their
    own security or operational or whatever the requirements are on top of it.
    That's the thing that's most top of mind. I don't expect to have like a
    full resolution from the Extension Summit on it, but at least the start of
    it. What is ultimately that universal packaging distribution protocol for
    Postgres extensions that we can all agree on?
    
*   David Wheeler (he/him): Thank you so much! Before we go I just wanted to
    tee up that in two weeks Yuri Rashkovskii is going to talk about his idea
    for universally buildable extensions: dev to prod. That'll be on May 1st
    at noon Eastern and 4pm UTC. Thank you everybody for coming.

  [mini-summit]: https://www.eventbrite.com/e/851125899477/
    "Postgres Extension Ecosystem Mini-Summit"
  [Jonathan Katz]: https://jkatz05.com
