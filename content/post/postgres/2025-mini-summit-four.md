---
title: "Mini Summit 4 Transcript: The User POV"
slug: 2025-mini-summit-four
date: 2025-05-01T21:02:39Z
lastMod: 2025-05-01T21:02:39Z
description: |
  Last week Floor Drees moderated a panel on "The User POV" at the fourth
  Extension Mini-Summit. Read on for the transcript and link to the video.
tags: [Postgres, Extensions, PGConf, Summit, Celeste Horgan, Sonia Valeja, Alexey Palazhchenko]
type: post
author: { name: Floor Drees }
image:
  src: /shared/extension-ecosystem-summit/user-pov.jpeg
  link: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/events/306682786/
  title: "PostgresSQL Extension Mini Summit: The User POV"
  alt: |
    Orange card with large black text reading "The User POV". Smaller text
    above reads "04.23.2025" and below reads "Celeste Horgan (Aiven),
    Sonia Valeja (Percona), & Alexey Palazhchenko (FerretDB)"
---

On April 23, we hosted the fourth of five (5) virtual Mini-Summits that lead
up to the big one at the Postgres Development Conference ([PGConf.dev]),
taking place May 13-16, in Montreál, Canada. [Celeste Horgan], Developer
Educator at Aiven, [Sonia Valeja], PostgreSQL DBA at Percona, and [Alexey
Palazhchenko], CTO FerretDB, joined for a panel discussion moderated by [Floor
Drees].

*   [Video](https://www.youtube.com/watch?v=d6XjsNAUvIw)

Amd now, the transcripts of "The User POV" panel, by [Floor Drees]

## Introduction

My name is Floor, I'm one of the organizers of these Extension Ecosystem
Mini-Summits. Other organizers are also here:

*   [David Wheeler], Principal Architect at [Tembo], maintainer of [PGXN]
*   [Yurii Rashkovskii], [Omnigres]
*   [Keith Fiske], [Crunchy Data]
*   [Floor Drees], Principal Program Manager at [EDB], PostgreSQL CoCC member,
    PGDay Lowlands organizer

The stream and the closed captions available for the recording are supported
by PGConf.Dev and their gold level [sponsors], Google, AWS, Huawei, Microsoft,
and EDB.

Next, and last in this series, on May 7 we're gonna have [Gabriele Bartolini]
talk to us about [Extension Management in CloudNativePG]. Definitely make
sure you head over to the [Meetup] page, if you haven't already, and RSVP for
that one!

## The User POV

**Floor:** For the penultimate edition of this series, we're inviting a couple
of Postgres extension and tooling users to talk about how they pick and choose
projects that they want to use, how they do their due diligence and, their
experience with running extensions.

But I just wanted to set the context for the meeting today. We thought that
being in the depth of it all, if you're an extension developer, you kind of
lose the perspective of what it's like to use extensions and other auxiliary
tooling. You lose that user's point of view. But users, maybe they're coming
from other ecosystems are used to, maybe a different, probably smoother
experience. I'm coming from the Rails and Ruby community, so RubyGems are my
one stop shop for extending functionality.

That's definitely a completely different experience from when I started using
Postgres extensions. That's not to say that those ecosystems and NPM and PIP
and WordPress don't have their own issues, ut we can certainly learn from some
of the differences between the ecosystems. Ultimately, what we want to cover
today is the experience of using extensions in 2025, and what are our users'
wishes for the future?

**Celeste:** Hello my name is Celeste, I am on the developer relations team at
Aiven. I only really started using Postgres as a part of my job here at Aiven,
but have been a much longer contributor to similar-sized ecosystems. I was
really heavily involved in the Kubernetes ecosystem for quite a while.
Kubernetes is an extensible-by-design piece of software, but it's many, many
generations of software development later than some of the concepts that
Postgres pioneered. Thank you for having me, Floor!

**Sonia:** Hello everybody! I started working with PostgreSQL in the year
2012, and since then it has been a quite a journey. Postgres has been my
primary database, and along with learning PostgreSQL, I learned the other
database alongside. I learned Oracle, I learned SQLServer, but only from the
perspective --- which is important --- to migrate from X database to
PostgresSQL, as in Oracle to PostgreSQL migration, SQLServer to PostgreSQL
migration. I learned about the other databases and I'm fortunate to work as a
PostgreSQL developer, PL/pgSQL Developer, PostgreSQL DBA, onsite coordinator,
offsite coordinator, sometimes a trainer. So, in and out, it has been like I'm
breathing PostgreSQL since then.

**Alexey:** Thanks for having me! I first worked with Postgres in 2005. Fast
forward to today and I am doing FerretDB, which is the open source MongoDB
replacement built on top of PostgreSQL and also on top of the DocumentDB
extension recently open-sourced by Microsoft. We provide this extension to our
users, but also we consume this extension as users of that extension.
Somewhere in between, between 2005 and now, I also worked at Percona. At
Percona I worked on monitoring software and worked with pg_stat_statements and
pg_stat_monitor, which is made by Percona and I have pretty much a lot of
experience with Postgres extensions.

**Floor:** And you're cheating a little on this panel, seeing as you are not
only a user but also a provider. I definitely have some questions for you!

And y'all talked a little about your sort of experience with extensibility of
other software or technology, and comparing that to the Postgres experience.
Can you all talk about what the main differences are that you have observed
with other ecosystems?

**Celeste:** I think as somebody who's a bit of a newer Postgres user and I
guess comes from a different community, the biggest thing that weirded me out,
when I started working with Postgres, is that there's no way to install an
extension except to install it against your live database.

If you compare that to something like Kubernetes, which again has a rather
robust extensibility ecosystem, both on the networking side of things, but
also other aspects of it, the inherent software architecture makes it so that
you have to plan out what you're going to do, and then you apply a plan. In
theory you can't apply a plan or add extensions to Kubernetes that won't work
or will somehow break the system. Again, in theory, in practice things are
more interesting.

But with Postgres and with databases in general, you're always working with
the live dataset, or at some point you have to work with the live dataset. So
there's no real way to test.

**Sonia:** Most of the other databases --- apart from PostgreSQL, which I have
worked with --- most of them are licensed. So Oracle and SQLServer. When it
comes to PostgreSQL, it's an open source, so you do your own thing: you do the
installation, do the checkout everything, which is open source, you can see
the code, and things like that. But when it comes to other databases, I since
it's licensed, it is managed by the specific vendor, so you do not have rights
to do anything else. The things which will be common, like you do the POC in
both the databases before you actually implement it in the production
environment.

**Alexey:** Floor, you mentioned RubyGems, and I was thinking that actually
there is something similar between PostgreSQL extensions and RubyGems in a
sense that RubyGems quite often extend built-in Ruby classes, and Postgres
extensions could do the same. There is no separation between public and
private inside PostgreSQL, it's all just C symbols, no special mark, don't
touch the CPI, we are going to change it at central detail. Nothing like that.
They try not to break compatibility needlessly, but on the other hand, you
have to check all versions of your extensions with all separate versions of
PostgreSQL. In that sense it's quite similar, unlike some other languages
where's there's better separation between internal private, if not on the
compiler level, at least on like documentation level or something like that.

**Celeste:** That's not necessarily a criticism of Postgres. I think it's just
that's those were the tools available to Postgres as a community when Postgres
was being developed. There are some advantages to that too, because, for lack
of a better word, the lack of checks and balances let some Postgres extensions
do very, very interesting things that would maybe not be possible under a more
restricted framework.

**Floor:** The main difference I see between those two is that I know to go to
RubyGems as my place to get my plugins --- or my gems, in that case. Whereas
with Postgres, they can live pretty much anywhere, right? There's different
directories and there's different places where you can get your stuff and
maybe there's something that is in a private repo somewhere because that's
what another team at your company is working on. It's a bit of a mess, you
know? It's really difficult to navigate, where maybe other things are lot less
difficult to navigate because there's just the single place.

I wanna talk a little bit about when you're looking for an extension to do a
certain thing for you. What do you consider when you're looking for an
extension or when you're comparing some of its tooling? I wrote down a couple
of things that you might be looking at, or what I might be looking at: maybe
it's docs and tutorials, maybe it's "has it seen a recent release?" Has it
seen frequent releases? Is there only one company that is offering this
extension? Or is it multiple companies supporting this extension? Is it a
community-built tool? Is it already in use by other teams in your company? So
it's something that has been tested out with your system, with your stack, and
you feel like it's something that you can easily adopt.

So what are some of the things for you that you definitely look at when you're
looking to adopt new tooling?

**Celeste:** I think the main thing you wanna look for when you're looking at
really any open source project, whether it's an extension or not, is both
proof points within the project, but also social proof. Proof points within
the project are things that you mentioned, like is there documentation? Does
this seem to be actively maintained? Is the commit log in GitHub moving? How
many open issues are there? Are those open issues being closed over time?
Those are project health indicators. For example, if you look at the [CHAOSS
Project], Dawn Foster has done a ton of work around monitoring project health
there.

But I think the other half of this --- and this was actually something we
worked on a lot at the Cloud Native Computing Foundation when I was there, and
that work continues  --- is --- and this makes a bit more sense in some cases
than others --- is social proof. So, are there other companies using it? Can
you point to case studies? Can you point to case studies of something being in
production? Can you point to people giving conference talks where they mention
something being in use?

This becomes really important when you start thinking about things being
enterprise-grade, an when you start thinking about the idea of
enterprise-grade open source. Everybody who's on this panel works for a
company that does enterprise-grade open source database software, and you have
to ask yourself what that means. A lot of what that means is that other
enterprises are using it ,because that's means that something comes to a
certain level of reliability.

**Sonia:** I would like to add some things. What I look at is how difficult or
how easy it is to install, configure, and upgrade the extension, and, whether
it needs restart of the database service or not. Why do I look at the restart
aspect? Because when I install it or configure or upgrade or whatever activity
I perform with it, if it requires the restart, that means it is not configured
online, so I need to involve other folks to do the database restart, as in an
application is connecting to it. When I restart, it goes for a maintenance
window for a very small time --- whatever duration it goes offline, the
database service. So whether it requires restart or not, that is also very
important for me to understand.

Apart from the documentation, which should be of course easy to understand.
That is one of the aspects while you install and configure. It should not be
that difficult that I need to refer every time, everything, and do it, and
then maybe, I might need to create another script to use it. It should not be
the case. I look to those aspects, as well.

Apart from that, I also see how do I monitor the activities of this extension,
like whether it is available in the logs --- what that extension is doing. So
it should not break my existing things basically. So how stable and how
durable it is, and I should be able to monitor the activities, whatever that
extension is doing.

From the durability perspective, even if I'm not able to monitor via logs, it
should be durable enough to that it should not break anything else, which is
up and running.

One more thing. I will definitely perform the POC, before putting it into the
production, into some lower environment or in my test environment somewhere
else.

**Floor:** How do you figure out though, how easy something is to sort of set
up and configure? Are you looking for that information from a README or
some documentation? Because I've definitely seen some very poorly documented
stuff out there...

**Sonia:** Yeah, documentation is one aspect. Apart from that, when you do the
POC, you will actually using you'll be actually using that. So with that POC
itself, you'll be able to understand how easy it is to install, configure, and
use it.

**Alexey:** For me as a user, I would say the most important thing is whatever
extension is packaged and easy to install. And if it's not packaged in the
same way as PostgreSQL is packaged. For example, if I get PostgreSQL from my
Ubuntu distribution, if extension is not in the same Ubuntu target, it might
as well not exist for me because there is no way I'm going to compile it
myself. It's like hundreds of flags and that being C, and okay, I can make it
1% faster, but then it'll be insecure and will bring PostgreSQL down, or
worse. So there are a lot of problems like that.

If it's not a package, then I would just probably just do something which is
not as good, not as stable, but I will do it myself and will be able to
support them using some third party extensions that is not packaged properly.
And properly for me, is the high bar. So if it's some third party network of
extensions, that might be okay, I will take a look. But then of course, if
it's in the Ubuntu repository or Debian repository, that would be of course,
much better.

**Floor:** I think that's the build versus buy --- or not necessarily *buy* if
it's open source. Not to say that open source is free. But that's the
discussion, right? When do you decide to spend the time to build something
over adopting something? And so for you, that's mainly down to packaging?

**Alexey:** For me that's the most important one because for features we
generally need to use in the current job and previous jobs, there are enough
hooks on the PostgreSQL itself to make what we want to do ourselves. Like if
sometimes we need to parse logs, sometimes we need to parse some low level
counters, but that's doable and we could do it in a different language and in
the way we can maintain it ourselves. If you talk about PostgreSQL, I
typically recommend C and if there's some problem, we will have a bigger
problem finding someone to maintain it, to fix it fast.

**Floor:** Alright When you build it yourself, would you then also open-source
it yourself and take on the burden of maintenance?

**Alexey:** I mean that really depends on the job. Like at Percona we open
sourced pg_stat_monitor. But that was like, implicit goal of making this
extension open source to make it like a superset of pg_stat_statement. In
FerretDB of course, DocumentDB is open source --- we contribute to it, but I
couldn't say that's easier. Of course if it was written like in our perfect
language, Go, it would be much, much easier. Unfortunately, it's not. So we
have to deal with it with packaging and what not.

**Floor:** I guess it's also like build versus buy versus fork because there's
definitely different forks available for a similar tooling that is just
optimized for a little bit of a different use case. But again, that's then
another project out there that needs to be maintained.

**Alexey:** But at the same time, if you fork something, and don't want to
contribute back, you just don't have this problem of maintaining it for
someone else. You just maintain it for yourself. Of course, like if someone
else in upstream wants to pull your changes, they will be able to. And then
when they look at you like you're a bad part of the community because you
don't contribute back, but that depends on the size of the company, whatever
you have the sources and all that.

**Celeste:** But now you're touching on something that I feel very strongly
about when it comes to open source. Why open source anything to begin with? If
we can all just maintain close forks of everything that we need, why is
Postgres open source to begin with and why does it continue to be open source
and why are we having this discussion 30 or 40 years into the lifespan of
Postgres at this point?

The fact of the matter is that Postgres being open source is the reason that
we're still here today. Postgres is a 30 plus year old database at this point.
Yes, it's extremely well architected because it continues to be applicable to
modern use cases when it comes to data. But really the fundamental of the
matter is that it is *free,* and being free means that two things can happen.
One, it's a very smart move for businesses to build a business on top of a
particular piece of software. But two --- and I would argue that this is
actually the more important point when it comes to open source and the long
term viability of open source --- is that because it is free, that means it is
A) proliferative, it has proliferated across the software industry and B) it
is extremely valuable for professionals to learn Postgres or to learn
Kubernetes or to learn Linux because they know that they're gonna encounter
that sometime in their career.

So when it comes to extensions, why open source an extension? You could simply
close source an extension. It's the same reason: if you use open source
extensions, you can then hire for people who have potentially encountered
those extensions before.

I work for a managed service provider that deploys quite a few Postgreses for
quite a few clients. I obviously have a bit of a stake in the build versus buy
versus fork debate that is entirely financial and entirely linked to my
wellbeing. Regardless, it still makes sense for a company like Aiven to invest
in open source technologies, but it makes a lot more sense for us to hire
Postgres experts who can then manage those extensions and manage the
installation of those extensions and manage whether your database works or not
against certain extensions, than it is for literally every company out there
on the planet to hire a Postgres professional. There's still a use case for
open-sourcing these things. That is a much larger discussion though, and I
don't wanna derail this panel. [Laughs.]

**Floor:** I mean, if Alexey is game, you got yourself a conversation.

**Alexey:** First of all, I completely agree with you and I of course built my
whole carrier on open source. But there's also the other side. So let's say
you build an open source extension which is very specific, very niche, solves
your particular problem. And there are like 20 other people who are like, you
have the same problem, and then all 20 come to your GitHub and ask questions
about it. And they do it for free. You just waste your time supporting them
essentially. And you are a small company, you are just three people and you
open-source this extension just for fun. And they are three people and two of
them work full time and support that.

**Celeste:** Oh yeah, no, I didn't say the economics of this worked out for
the people doing the open-sourcing, just to be perfectly clear. I think a much
larger question around the sustainability of open source communities in
general. Postgres, the overall project, and say, for example, the main
Kubernetes project, are outliers in terms of the amount of support and the
amount of manpower and people and the energy they get. Whereas most things
that get open-sourced are --- I think Tidelift had [a survey]: the average
maintainer size for any given open source project is one. That is a much
larger debate though. Realistically it makes a lot of sense, particularly for
larger companies, to use open source software, Postgres included, because it
accelerates their time to innovation. They don't need to worry about
developing a database, for example. And if they're using Postgres and they
decide they want time series data, they don't need to worry about migrating to
a time series database when they can just use Timescale.

However, "are they contributing back to those projects?" becomes a really big
question. I think the next questions that Floor would like to lead us to, amd
I'm just going to take the reins here, Floor ---

**Floor:** Are you taking my job??

**Celeste:** Hardly, hardly, I could never! My understanding of why we're
having this series of conversations that's around the sustainability of the
Postgres extensions ecosystem,is that there's a governance question there as
well. For the end user, the ideal state for any Postgres extension is that
they're blessed and vetted by the central project. But as soon as you start
doing that, you start realizing how limited the resources in even a massive
project like Postgres are. And then you start asking: Where should those
people be coming from? And then you start thinking: There are companies like
Microsoft out there in the world that are hiring a lot of open source
contributors, and that's great, but... What about the governments? What about
the universities? What about the smaller companies? The real issue is the
manpower and there's only so far you can go, as a result of that. There's
always sustainability issues around all open source, including Postgres
extensions, that come down to the sustainability of open source as a whole and
whether or not this is a reasonable way of developing software. Sorry to get
deep. [Laughs.]

**Floor:** Yeah, I think these are discussions that we're definitely having a
lot in the open source community, and in the hallway at a lot of conferences.

We're gonna open it up to  audience questions too in a minute. So if people
want to continue talking about the drama that is open source and sustainable
open source, we can definitely continue this discussion.

Maybe going back a little bit, Alexey, can we talk a little bit about ---
because you're also a provider --- what your definition of "done" is or what
you wanna offer your users at minimum when you do decide to open-source some
of your stuff or make available some of some of your stuff.

**Alexey:** As an open source company, what we do, we just publish our code on
GitHub and that's it. It's open source, that's done. Knock yourself out and if
you want some support, you just pay us, and then we will. That's how we make
money. Well, of course not. That's more complicated than that, and I wish it
was like to some degree, sometimes. Now there still a lot of users who just
come and ask for questions for free, and you want to support them because you
want to increase adoption and all that.

The same with extensions. So as I just described the situation, of course,
that was a bit like, not to provoke a discussion, but, let's say you built a
PostgreSQL extension, you need to have some hooks in the core that ideally
would be stable, don't change between versions as we discussed. That's a bit
of a problem. PostgreSQL, no separation between private and public API. Then
how do you install? You need to package it some way that is the same way as
your current PostgreSQL version is packaged. There is no easy way, for
example, to extend a version of PostgreSQL, which is a part of Docker, you
just build your own container.

**Celeste:** I'll segway into the point that I think I was supposed to make
when we were talking about extensions ecosystem, as opposed to a rant about
the sustainability of open source, which I am unfortunately always down to
give. Here's the thing with extensions ecosystems. For the end user, it is
significantly more beneficial if those extensions are somehow
centrally-controlled. If you think about something like RubyGems or the Python
package installer or even Docker to a certain extent, those are all ways of
centralizing. Though with some of the exploits that have gone on with NPM
recently, there are obviously still problems there.

I mentioned, there's always staffing problems when it comes to open source.
Assigning somebody to approve every single extension under the sun isn't
really sustainable from a human perspective. The way that we handle this in
the Kubernetes community --- particularly the container network interfaces, of
which there are many, many, many --- is we effectively manage it with
governance. We have a page on the documentation in the website that says: here
are all the container network interfaces that have chosen to list themselves
with us. The listings are alphabetical, so there is no order of precedence.

The community does not take responsibility for this code because we simply
cannot. In being a container network interface, it means that they implement
certain functionalities, like an interface in the programming sense. We just
left it at that. That was the solution that the Kubernetes community came to.
I don't know if that's the solution that the Postgres community will
eventually come to, but community governance is a huge part of the solution to
that problem, in my opinion.

**Alexey:** I think one big difference between NPM and NodeJS ecosystem in
general, and, for example, Postgres extensions, is that NPM was so popular and
there are so many packages mostly because NodeJS by itself is quite small. The
core of NodeJS is really, really small. There is now standard library and a
lot of functionality is external. So I would say as long as your core, like
PostgreSQL or Ruby or Kubernetes is large enough, the amount of extensions
will be limited just by that. Because many people will not use any extensions,
they will just use the core. That could solve a problem of waiting and
name-squatting, but just by itself. I would say PostgreSQL more or less solves
this problem to some degree.

**Floor:** Before we open up for some questions from participants, Sonia, in a
previous call, shared a little bit of a horror story with us, with wanting to
use a certain extension and not being able to. I think this is something that
other people can resonate with, having been through a similar thing. Let's
hear that story, And then, of course, Celeste, Alexey, if you have similar
stories, do share before we open up for questions from the rest of the peeps
joining here.

**Sonia:** So there was this requirement to transfer data from one database to
another database, specifically with respect to PostgreSQL. I wanted to
transfer the data from the production environment to some other environment,
or internally within the non-production environments. I created this extension
called [dblink]. I'm talking about way back, 2012, 2013, somewhere, when I
started working with PostgreSQL, I used that extension. When you configure
that extension, we need to give the credentials in a human readable format.
And then, at times it also gets stored in the logs or somewhere.

I mean, even if it is not storing the logs, what the security team or the
audit team mentioned was that since it is using the credentials in a human
readable format, this is not good. And if somebody has has access to X
database, they also get the access to the Y database or the Y cluster. And
what if it goes to the production environment and then somebody can just steal
the data, without us even knowing it. It'll not get logged inside the logs,
that somebody has accessed my production database via non-production database.
So that's not good, and was not acceptable by the auditors.

I love that extension today also, because without doing any scripting or
anything, you just access one database from another database and then get
whatever you want. But then as a developer, it might be very easy for me to
use that thing. But then as an other person who is trying to snoop into your
production database or the other data of anything, it's easy for them. So we
were asked not to use that extension specifically, at least not to connect to
the production environment. 

I was working for a taxation project. It was a financial critical data, and
they did not want it to have any risk of anybody reaching to that data because
it was the numbers, the financial figures, and was critical. So that's the
reason we were refrained from using it for that particular project. But then
other projects, which were not that critical, I somehow managed to convince
them to use it. [Laughs.]

**Floor:** So it's sometimes you will choose it for convenience and it's
acceptable risk, and then there might be restrictions from other teams as
well. Thanks for sharing that. If anyone wants to un-mute and ask questions or
share their own horror stories, you're now very welcome to.

**Yurii:** There was a really good point about extensions being available as
part of your operating system environment, for example Ubuntu packages or Red
Hat packages. This is where we still have a lot of difficulty in general, in
this ecosystem. Obviously PGDG is doing an amazing job capturing a fraction of
those extensions. But because it is a complicated job, oftentimes unpaid,
people are trying to make the best out of it. On the one hand, it does serve
as a filter, as in only the best of the best extensions that people really use
get through that filter and become part of PGDG distribution. But it also
creates an impediment. For example, PGDG is not always able to update them as
the releases come out. Oftentimes people do need the latest, the best releases
available, and not when the packagers have time.

The other problem is how do extensions become popular if they're not there in
the first place? It creates that kind of problem where you're stuck with what
you have. And there's a problem with a discovery: how do I find them? And how
do I trust this build? Or can I even get those builds for my operating system?

Obviously there are some efforts that try to mitigate that by building a
docker container and you run them with just copies of those files. But
obviously there's a demand for a native deployment method. That is, if I
deploy my Postgres this way --- say using RPM in my Red Hat-based distro, or
Debian based --- I want everything else to fall into that. I don't want a new
system.

I think we, we still have a lot of work to do on that end. I've been putting
some effort on our end to try and find how can we save a packager's time that
has basically decreased the amount of work that that needs to be done. Can we
go essentially from, here's the URL for the extension, figure it out. Like 80%
of them can, we just figure them out and package them automatically, and
repackage them when new versions come out, an only assign people on them for
the remaining 20% that are not building according to a certain convention. So
they need some attention.

This way we can get more extensions out and extract more value out of these
extensions. By using them, we're helping the authors gain a wider audience and
effectively create value for everybody in the community. Otherwise, they would
feel like, "I can't really promote this as well as I would've loved to, like
another ecosystems --- RubyGems were mentioned today, and NPM, etc. It's easy
to get your stuff out there. Whereas in the Postgres community, it is not easy
to get your stuff out there. Because there are so many risks associated with
that, we are oftentimes working with production data, right?

We need to make sure there is less friction on any other side. We need to get
these extensions to get considered. That's at least one of the points that I
wanted to mention. I think there's a lot to be done and I really hope that the
conference next month in Montreal will actually be a great place to get the
best minds together again and hash out some of the ideas that we've been
discussing in the past number of months.

**Floor:** David, do you wanna ask your question of where people go to learn
more about extensions and find their extensions?

**David:** This is something that I tried to solve a while ago with a modicum
of success --- a bit. My question is, where do you all go to learn more about
extensions? To find out what extensions are available or, is there an
extension that does X, Y, Z? How do you find out if there is and, then
evaluate it? Where do you go?

**Alexey:** I generally just search, I guess. I don't go to anything. The last
place I generally research and quite often I learned on some blog post on
sometimes on GitHub itself.

**Celeste:** If you think about that project-level activity proof, and then
the social proof, I think that Postgres actually has a really unique advantage
compared to a lot of other open source projects because it's been going for so
long and because there is a very entrenched community. It's very easy to find
social proof for basically anything Postgres-related that you might want.

If you do a search for, like, "I want a Postgres extension that does X",
you're going to get comparatively better Google search results because there's
years and years and years of search results in some cases. However, that does
come with the equal and opposite problem of when you have maintenance issues,
because things have been going for years and years, and you don't know whether
things have been maintained or not. 

I'm thinking about this from an open source management perspective, and as
somebody who is not necessarily involved in the open source development of
Postgres. I think there is a case that you could make for some amount of
community vetting of some extensions and publicizing that community-vetting,
and having a small subset of --- this has some sort of seal of approval, it's
not gonna like nuke your database. To a certain extent, I think Postgres
already does that, because it does ship with a set of extensions by default.
In shipping with those extensions, it's effectively saying the upstream
Postgres community blesses these, such that we will ship Postgres with them
because we are pretty confident that these are note going to nuke your
database.

When I was at the CNCF, I supported a whole bunch of different open source
projects. I was everybody's documentation girl. So I'm trying to throw things
at them and then hopefully you can talk about them in Montreal and maybe
something useful will come of it. Another thing that you can use is almost
like an alpha beta experimental sort of feature where you define some set of
criteria for something being alpha or experimental, you define some set of
criteria that if met, they can call themselves beta, you define some set of
criteria of something being "production ready" for an extensions ecosystem.
Then you can have people submit applications and then it's less of a mad rush.

I guess if I had any advice --- not that Postgres needs my Charlton advice ---
it would be to think about how you wanna manage this from a community
governance perspective, or else you will find yourself in utter mayhem.
There's a reason that the Kubernetes container network interface page
specifies that things have to be listed in alphabetical order. It's because
there was mayhem until we decided to list things in alphabetical order. It
seems completely silly, but it is real. [Laughs.]

**Alexey:** So my next project is going to start with "aa".

**Sonia:** Yeah, what Celeste said. I will research about it online, normally,
and I will find something and, if I get lots of options for doing X thing, a
lot of extensions, I will go and search the documentation on postgresql.org
and then try to figure out which one is the one to start with my POC.

**Celeste:** Let me flip the question for you, Sonia. In an ideal world. If
you were to try and find an extension to use for a particular task, how would
you find that extension?

**Sonia:** Normally I will research it, Google it most of the times, and then try
to find out ---

**Celeste:** But pretend you don't have to Google it. Pretend that maybe
there's a website or a resource. What would your ideal way of doing that be?
If you had some way that would give you more of a guarantee that it was
trustworthy, or would make it easier to find, or something. Would it be a tool
like RubyGems? Would it be a page on the Postgres website's documentation?

**Sonia:** Page! The PostgreSQL website documentation. The Postgres
documentation is like a Bible for me, so I keep researching on that. In fact,
previously when you used to Google out anything, you used to get the initial
link as the postgresql.org, the website. Nowadays you don't get the link as a
first link, but then I will scroll down to the page. I will try to figure out
where it is postgresql.org and then go there. That's the first thing. Now
since I've been into the field, since a very long time, then I know, okay,
this website is authentic, I can go and check out the blogs, like who else has
used it or what is their experience or things like that.

**Jay Miller:** I have to ask this only because I am new to thinking about
Postgres outside of how I interact with it from a web developer's perspective.
Usually I use some ORM, I use some module. I'm a Python developer, so I use
Python, and then from there, I don't think about my database ever again.

Now I want to think about it more. I want to have a very strong relationship
with it. And we live in a world where you have to say that one of the answers
is going to be AI. One of the answers is I search for something, I get some
AI response, and, and here's like the...

> **David in comments:** SLOP.

**Jay:** Exactly, this is the problem. If I don't know what I should do and I
get a response, when the response could have just been, "use this extension,
it does everything you need to do and it makes your life so much easier."
Instead, I wind up spending days, if not weeks, going in and fighting against
the system itself. Sonia, you mentioned having that experience. The idea or
the ability to discern when to go with some very kludgey PostgreSQL function
that makes your life miserable, to, "oh, there's an extension for this
already! I'm just going to use that." How do you expose that to people who are
not dumb, they're not vibe coding, they just finally have a reason to actively
think about what their database is doing behind the scenes.

**Sonia:** If I understood your question correctly, you wanted to explore what
kind of activities a specific extension is doing.

**Jay:** I would just love the like, "hey, you're trying to do a thing, this
has already been solved in this extension over here, so you don't have to
think about it." Or "you're trying to do something brand new, no one's thought
about this before, or people have thought about it before and talked about how
much of a pain it is. Maybe you should create an extension that does this. And
here's the steps to do that." Where is the proper documentation around coming
to that decision, or the community support for it?

**Sonia:** That's a great question to discuss inside the community, to be
honest. Like, how do we go about that?

**David:** Come to Montreal and help us figure it out.

**Jay:** I was afraid of that answer. I'll see you in New York, or hopefully
Chicago on Friday.

**Floor:** Fair enough, but definitely a wonderful question that we should
note down for the discussion.

**Sonia:** One thing which I want to add, this just reminded me of. There was
[one podcast which I was listening with Robert Haas]. The podcast is organized
by one of the Microsoft folks. The podcast was revolving around how to commit
inside the PostgreSQL, or how to read what is written inside the PostgreSQL
and the ecosystem around that. The questions were related to that. That could
also help. And of course, definitely when you go to a conference, which we are
discussing at the moment, there you'll find a good answer. But listening to
that podcast will help you give the answers to an extent.

**Floor:** I think that's [Talking Postgres] with Claire Giordano, or if it
was the previous version, it was the "Path to Citus Con", because that was
what it was called before.

**David:** The summit that's in Montreal on May 13th is an unconference
session. We have a limited amount of time, so we want to collect topic ideas
and ad hoc votes for ideas of things to discuss. Last year I used a website
with Post-Its. This year I'm just trying a spreadsheet. I posted a link to the
Google Sheet, which anybody in the world can access and pollute --- I mean,
put in great ideas --- and star the ideas they're really interested in talking
about. And I'd really appreciate, people contributing to that. Good topics
came up today! Thank you.

**Floor:** Thanks everyone for joining us. Thank you for our panelists
specifically, for sharing their experiences.

  [Celeste Horgan]: https://www.linkedin.com/in/celeste-horgan-b65b5a1a/
  [Sonia Valeja]: https://www.linkedin.com/in/sonia-valeja-69517a140/
  [Alexey Palazhchenko]: https://www.linkedin.com/in/alexeypalazhchenko/overlay/about-this-profile/
  [Floor Drees]: https://dev.to/@floord
  [Meetup]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/
    "Postgres Extension Ecosystem Mini-Summit on Meetup"
  [PGConf.dev]: https://2025.pgconf.dev "PostgreSQL Development Conference 2025"
  [CNPG]: https://cloudnative-pg.io "Run PostgreSQL. The Kubernetes way."
  [Gabriele Bartolini]: https://www.gabrielebartolini.it
  [David Wheeler]: {{% ref "/" %}}
  [Tembo]: https://tembo.io/
  [PGXN]: https://pgxn.org/
  [Yurii Rashkovskii]: https://ca.linkedin.com/in/yrashk
  [Omnigres]: https://omnigres.com/
  [Keith Fiske]: https://pgxn.org/user/keithf4/
  [Crunchy Data]: https://www.crunchydata.com/
  [EDB]: https://enterprisedb.com "EnterpriseDB"
  [sponsors]: https://2025.pgconf.dev/sponsors.html
  [Extension Management in CloudNativePG]: https://www.meetup.com/postgres-extensions-ecosystem-mini-summits/events/306551747/
  [CHAOSS Project]: https://chaoss.community
  [a survey]: https://tidelift.com/open-source-maintainer-survey-2024
    "The 2024 Tidelift state of the open source maintainer report"
  [dblink]: https://www.postgresql.org/docs/current/contrib-dblink-function.html
  [one podcast which I was listening with Robert Haas]: https://talkingpostgres.com/episodes/why-mentor-postgres-developers-with-robert-haas
  [Talking Postgres]: https://talkingpostgres.com
