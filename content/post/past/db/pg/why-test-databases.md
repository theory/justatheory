--- 
date: 2009-03-11T04:35:41Z
slug: why-test-databases
title: Why Test Databases?
aliases: [/computers/databases/postgresql/why-test-databases.html]
tags: [Postgres, testing, unit testing, databases, pgTAP]
type: post
---

I’m going to be doing some presentations on testing for database administrators.
I’ve been really excited to be working on [pgTAP], and have started using it
extensively to write tests for a client with a bunch of PostgreSQL databases.
But as I start to push the idea of testing within the PostgreSQL community, I’m
running into some surprising resistance.

I asked a major figure in the community about this, someone who has expressed
skepticism in my past presentations. He feels that it’s hard to create a generic
testing framework. He told me:

> Well, you are testing for bugs, and bugs are pretty specific in where they
> appear. Writing the tests is 90% of the job; writing the infrastructure is
> minor. If the infrastructure has limitations, which all do, you might as well
> write that extra 10% too.

I have to say that this rather surprised me. I guess I just thought that
*everyone* was on board with the idea of testing. The PostgreSQL core, after
all, has a test suite. But the idea that one writes test to test for bugs seems
like a major misconception about testing: I don’t write tests to test bugs (that
*is* what regression tests are for, but there is much more to testing than
regression tests); I write tests to ensure consistent and correct behavior in my
code as development continues over time.

It has become clear to me that I need to reframe my database testing
presentations to emphasize not the *how* to go about testing; I think that pgTAP
does a pretty good job of making it a straight-forward process (at least as
straight-forward as when writing tests in Ruby or Perl, for example). What I
have to address first is the *why* of testing. I need to convince database
administrators that testing is an essential tool in their kits, and the way to
do that is to show them *why* it’s essential.

With this in mind, I asked, [via Twitter], why should database people test their
databases? I got some great answers (and, frankly, the 140 character limit of
Twitter made them admirably pithy, which is a huge help):

-   [chromatic\_x][]: @theory, because accidents that happen during tests are
    much easier to recover from than accidents that happen live.
-   [caseywest][]: @Theory When you write code that’s testable you tend to write
    better code: cleaner interfaces, reusable components, composable pieces.
-   [depesz\_com][]: @Theory testing prevents repeating mistakes.
-   [rjbs][]: @Theory The best ROI for me is “never ship the same bug twice.”
-   [elein][]: @Theory trust but verify
-   [cwinters][]: @Theory so they can change the system without feeling like
    they’re on a suicide mission
-   [caseywest][]: @Theory So they can document how the system actually works.
-   [hanekomu][]: @Theory Regression tests - to see whether, after having
    changed something here, something else over there falls over.
-   [robrwo][]: @Theory Show them a case where bad data is inserted into/deleted
    from database because constraints weren’t set up.

Terrific ideas there. I thank you, Tweeps. But I ask here, too: Why should we
write tests against our databases? Leave a comment with your (brief!) thoughts.

And thank you!

  [pgTAP]: http://pgtap.projects.postgresql.org/
  [via Twitter]: https://twitter.com/Theory/status/1307497041
  [chromatic\_x]: https://twitter.com/chromatic_x "chromatic"
  [caseywest]: https://twitter.com/caseywest "caseywest"
  [depesz\_com]: https://twitter.com/depesz_com "depsz"
  [rjbs]: https://twitter.com/rjbs "Ricardo Signes"
  [elein]: https://twitter.com/elein "elein"
  [cwinters]: https://twitter.com/cwinters "Chris Winters"
  [hanekomu]: https://twitter.com/hanekomu "Marcel Grünauer"
  [robrwo]: https://twitter.com/robrwo "Robert Rothenberg"
