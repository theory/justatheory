--- 
date: 2004-08-08T20:43:23Z
slug: oscon-notes
title: OSCON 2004 Notes
aliases: [/computers/conferences/oscon2004/notes.html]
tags: [OSCON, Open Source]
type: post
---

I'm finally getting round to typing up my thoughts on my OSCon 2004 experience.
I would've done it sooner, but I spent most of last week on the road and fixing
bugs in Bricolage.

OSCon 2004 was, in a word, *great!* I spent every day of the week there, getting
there around 8:30 each morning, and finally leaving the hotel or a party each
night somewhere between midnight and 3 am. I was even there late on Sunday
night, talking to folks who just came in, and late on Friday night, at a party
in [Matt Sergeant's] room. It was great to see so many friends there, including
[Casey], [Schwern][] [Jesse], [Nat], [Bruce], [Josh], [David], [Elein], [Dan],
[Nicholas], [James], [Arthur], [Robert], [Ask] and Vani, my brother, [Alex], and
probably lots of other people I'm forgetting about.

There were more conversations between members of different communities than I
can recall seeing at past OSCons, and people were generally excited and engaged.
I'm told that they had the highest number of attendees since 2001. The energy at
the conference was very positive, and people seemed very interested in things
that other people were doing. Some of the highlights for me:

[PHP on Parrot]

:   Speakers Sterling Hughes and Thies C. Arntzen talked about how amped they
    are at the idea of poring PHP to run on Parrot, the virtual machine being
    developed for Perl 6 and other dynamic languages. The session ended up as a
    conversation between Sterling and Thies, on the one hand, and Larry Wall and
    Dan Sugalski, who were sitting in the front row, on the other. Larry assured
    them that any programming language community's members would be “first-class
    citizens” in the Parrot world, and Dan told them that all they need do is
    ask for things they need and the Parrot developers would help as much as
    they could. Sterling wrapped up by saying something like, “I guess the real
    reason we're so excited about Parrot is because we really love Perl!” That
    got a good laugh.

[PostgreSQL]

:   There was a bigger PostgreSQL presence than ever at OSCon this year, with
    lots of great discussion. There seemed to be quite a few Perl folks going to
    the PostgreSQL sessions, too. Dan Sugalski was suitably impressed with
    what's coming up in PostgreSQL 8.0 (formerly 7.5) that he told me that he
    was moving up his plans for implementing pl/Parrot. A few of the core
    PostgreSQL folks said that they felt like people were finally being more
    open and exited about their use of PostgreSQL, rather than keeping quiet
    about this “strategic advantage.” And the features in 8.0 sound extremely
    promising, including Win32 support, save points/nested transactions,
    point-in-time recovery, tablespaces, and pl/Perl. It's going to be a
    kick-ass release, no doubt about it. Watch for the beta this week.

[SQLite]

:   SQLite is fast, ACID-compliant, relational database engine in a
    public-domain C library. It's great for embedding into an application
    because it's not a client-server application, but a simple library that
    stores databases in files. It's twice as fast as MySQL or PostgreSQL because
    it doesn't have the client/server overhead, and its extremely portable.
    Version 3.0 adds UTF-8 and UTF-16, which makes it a real possibility for use
    in Bricolage 2.0 (for small installations and demo servers, for example).

    I was pretty amazed at what this little database can do, and not only is it
    open-source, but because it is in the public domain, there are *no*
    constraints on its use. It's just one sexy library. Everybody run out and
    use it now! Perl users get it for free by installing [DBD::SQLite] from
    CPAN.

[Pie]

:   A year later, Dan lost the bet with Guido, and gave him a case of beer, ten
    bucks, and the right to put pie in his face. Dan even made two key-lime pies
    for the occasion! At the Python lightening talks, Guido graciously declined
    to pie Dan. The Pythoners seemed to think that this was very nice of Guido,
    but the Perlers in the audience (including yours truly), were shouting, “Get
    him! Give him the pie! Do it, Guido!”. As Allison commented later, it's nice
    how “the Perl community takes care of its own.”

    Dan later auctioned off the right for someone else to pie him in the face.
    Schwern ponied (heh) up the cash, a ca. $500 donation to the Perl foundation
    for the right, but gave it to Ponie developer Nicholas to enjoy. The event
    came off just ahead of the final keynote. This time Guido decided to go
    ahead, and he doused Dan in cream pie. Then Nicholas came out and gave Dan
    the dessert, so to speak. Great fun for all.

    The upshot, according to Dan, is that Guido wrote a really evil test suite
    with seven tests exercising 75% of Python's ops. Of the seven tests, Dan got
    4 working on Parrot, and 3 of those were 2-3 times faster than on Python.
    Things look very good indeed for Parrot going forward. Look for the tests to
    be fully working on Parrot (and fast!) in the next few months.

There were parties and conversations every night, lots of great talk, good food,
good friends, and, well, I just had a great time. I can't wait until next year's
OSCon!

  [Matt Sergeant's]: https://web.archive.org/web/20111219193703/http://use.perl.org/~Matts/journal/
    "Matt Sergeant's Journal"
  [Casey]: https://web.archive.org/web/20111108030929/http://use.perl.org/~cwest/journal/
    "Casey West's Journal"
  [Schwern]: https://web.archive.org/web/20120106183825/http://use.perl.org/~schwern/journal/
    "Schwern's Journal"
  [Jesse]: https://pallas.eruditorum.org "Jesse Vincent's Journal"
  [Nat]: https://nathan.torkington.com/ "Nat Torkington"
  [Bruce]: https://momjian.us "Bruce Momjian's Website"
  [Josh]: https://www.databasesoup.com "AglioDBS"
  [David]: http://fetter.org "David Fetter's Website"
  [Elein]: http://varlena.com/ "Elein Mutain's Company"
  [Dan]: https://www.sidhe.org/blog/ "The Parrot Squawks at Midnight"
  [Nicholas]: https://web.archive.org/web/20111230042947/http://use.perl.org/~nicholas/journal/
    "Nicholas Clark's Journal"
  [James]: http://www.whoot.org/ "James Duncan's Blog"
  [Arthur]: https://web.archive.org/web/20120126080215/http://use.perl.org/~sky/journal/
    "Arthur Bergman's Journal"
  [Robert]: https://web.archive.org/web/20110818042534/http://use.perl.org/~Robrt/journal/
    "Robert Spier's Journal"
  [Ask]: https://www.askask.com "Ask Bjørn Hansen's Website"
  [Alex]: http://www.alexwheeler.net/ "Alex's Website"
  [PHP on Parrot]: http://conferences.oreillynet.com/cs/os2004/view/e_sess/5049
    "Chasing the Dragon: Compiling PHP to Run on Parrot"
  [PostgreSQL]: http://conferences.oreillynet.com/cs/os2004/view/e_sess/5359
    "State of PostgreSQL"
  [SQLite]: http://conferences.oreillynet.com/cs/os2004/view/e_sess/5701
    "Introducing SQLite version 3.0"
  [DBD::SQLite]: https://metacpan.org/dist/DBD-SQLite/ "DBD::SQLite on CPAN"
  [Pie]: http://www.oreillynet.com/pub/a/oscon2004/friday/index.html
    "The Dan Sugalski Pie Series"
