---
date: 2002-06-30T21:54:37Z
description: How I added event handling to App::Info.
lastMod: 2022-10-02T22:39:29Z
slug: the-main-event
tags:
  - use Perl
  - Perl
  - App::Info
  - App::Info
title: The Main Event
---

I released a new version of App::Info on Thursday. This is a major new version
because I've added a new feature: event handling.

Dave Rolsky had [raised] some issues regarding how App::Info clients might be
able to interact with the API in order to confirm the data it has found or to
help it find data that it can't on its own. I had been thinking of App::Info as
a non-interactive API on which interactive APIs could be built. In other words,
if someone got data from App::Info, but wanted to confirm it via some interface,
they would have to write the wrapper code around App::Info to do it.

But I started thinking about the problem, since, as Dave pointed out, such a
wrapper would be very thin. It seemed unnecessary. I didn't want to just add
code to the App::Info subclasses that would prompt users and such, or issue
print statements to notify the user that something had happened, so I pondered
on other, more elegant solutions. I was somewhat stumped until I happened to be
leafing through [the GOF], where the chain of responsibility pattern hit me as a
near ideal solution.

This pattern inspired a major new feature for App::Info: *events and event
handling.* I added methods to the App::Info base class that can be used by
subclasses to trigger different kinds of events. By default, these event
requests aren't handled, but clients can associate event handler objects with a
given App::Info object, and those handlers can handle the event requests any way
they please. The advantage to this approach is that, by and large, subclass
implementors don't have to think about how to handle certain types of events,
only where they need to trigger them. At the same time, the pattern frees
App::Info users to handle those events in any way they wish. If they want to
ignore them, they can. If they want to print them to STDOUT or to a log file,
they can. If they want to prompt the user for more information, why, they can do
that, too.

The result is what I think of as a really solid API for gathering information
about locally-installed software in a highly flexible and configurable fashion.
There are four different types of events:

*   `info` events, which simply send a message describing what the object is
    doing.

*   `error` events, which send a message when something has gone wrong -- i.e.,
    non-fatal errors.

*   `unknown` events, which occur when the object is not able to collect a
    relevant piece of data on its own.

*   `confirm` events, which are triggered when a central piece of information
    has been collected, and the object needs to ensure that it's the correct
    data.

Any one or all of these types of events can be handled or not, by one event
handling object or different ones, however the client user sees fit. A single
event can even be handled by multiple events! I also provided some example event
handler classes that will likely cover the majority of uses. They print messages
to file handles, trigger `Carp` functions, or prompt the user for data to be
entered. But because of the event architecture, event handling is in no way
limited to these approaches. Someone might want to write a handler that uses
Log::Dispatch to record the events. Or maybe a developer wants to write a GUI
installer, and so needs to handle unknown events by presenting a Tk dialog box
to her users. The new event architecture allows these approaches and more.

I'd be interested in any feedback on this design. I gave it quite a bit of
thought, and I think it's pretty good. But I'm just one developer, and the
opinions of others will help make it a better API going forward (just as Dave's
comments triggered this development). I'd also like to encourage folks to start
thinking about new subclasses. There are a lot of software packages and
libraries out there that people depend to get their work done, and, IMHO,
App::Info provides a good standardized platform for determining those
dependencies.

In the meantime, I think I'll start by offering a patch to DBD::Pg's Makefile.PL
so that it can figure out where the PostgreSQL libraries are without forcing
people to set the `POSTGRES_INCLUDE` and `POSTGRES_LIB` environment variables.
Look for a patch later this week. I might also propose an OSCON lightening talk
on this topic; I'll have to give that some thought.

*Originally published [on use Perl;]*

  [raised]: http://use.perl.org/user/Theory/journal/5423
  [the GOF]: http://hillside.net/patterns/DPBook/DPBook.html
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/6083/
    "use.perl.org journal of Theory: “The Main Event”"
