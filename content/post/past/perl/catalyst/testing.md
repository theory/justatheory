--- 
date: 2009-11-09T18:36:15Z
slug: testing
title: Testing the Tutorial App
aliases: [/computers/programming/perl/catalyst/testing.html]
tags: [Perl, Catalyst, testing, MVC, Template::Declare]
type: post
---

Yet another entry in my [ongoing] attempt to rewrite the [Catalyst tutorial] in
my own coding style.

So far, I've been following the original tutorial pretty closely. But now I want
to skip ahead a bit to [chapter 8][]: testing. I skip because, really, we should
be writing tests from the very beginning. They shouldn’t be an afterthought
stuck in the penultimate chapter of a tutorial. So let’s write some tests. You
can follow along in the [Part 5 tag] in the GitHub repository.

### Oops, A Missing Dependency

Oh, wait! I forgot to tell the build system that we now depend on
[Catalyst::View::TD] and [DBIx::Connector]. So add these two lines to
`Makefile.PL`:

```perl
requires 'Catalyst::View::TD' => '0.11';
requires 'DBIx::Connector' => '0.30';
```

Okay, *now* we can write some tests.

### STFU

Well, no, actually, let’s start by running the tests we have:

    perl Makefile.PL
    make test

You should see some output after this — lots of stuff, actually — ending
something like this:

    [debug] Loaded Path actions:
    .-------------------------------------+--------------------------------------.
    | Path                                | Private                              |
    +-------------------------------------+--------------------------------------+
    | /                                   | /index                               |
    | /                                   | /default                             |
    | /books                              | /books/index                         |
    | /books/list                         | /books/list                          |
    '-------------------------------------+--------------------------------------'

    [info] MyApp powered by Catalyst 5.80013
    t/view_HTML.t ......... ok   
    All tests successful.
    Files=5, Tests=8,  3 wallclock secs ( 0.04 usr  0.02 sys +  2.19 cusr  0.25 csys =  2.50 CPU)
    Result: PASS

I don’t know about you, but having all that debugging crap just drives me nuts
while I'm running tests. It’s helpful while doing development, but mainly just
gets in the way of the tests. So let’s get rid of them. Open up `lib/MyApp.pm`
and change the `use Catalyst` statement to:

```perl
use Catalyst (qw(
    ConfigLoader
    Static::Simple
    StackTrace
), $ENV{HARNESS_ACTIVE} ? () : '-Debug');
```

Essentially, we're just turning on the debugging output only if the test harness
is not active. Now when we run the tests, we get:

    t/01app.t ............. ok   
    t/02pod.t ............. skipped: set TEST_POD to enable this test
    t/03podcoverage.t ..... skipped: set TEST_POD to enable this test
    t/controller_Books.t .. ok   
    t/view_HTML.t ......... ok   
    All tests successful.
    Files=5, Tests=8,  3 wallclock secs ( 0.04 usr  0.02 sys +  2.15 cusr  0.23 csys =  2.44 CPU)
    Result: PASS

*Much* better. Now I can actually see other stuff, such as the fact that I'm
skipping POD tests. Personally, I like to make sure that POD tests run all the
time, as I'm likely to forget to set the environment variable. So let’s edit
`t/02pod.t` and `t/03podcoverage.t` and delete this line from each:

```perl
plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};
```

So what does that get us?

    t/01app.t ............. ok   
    t/02pod.t ............. ok     
    t/03podcoverage.t ..... 1/6 
    #   Failed test 'Pod coverage on MyApp::Controller::Books'
    #   at /usr/local/lib/perl5/site_perl/5.10.1/Test/Pod/Coverage.pm line 126.
    # Coverage for MyApp::Controller::Books is 50.0%, with 1 naked subroutine:
    #   list

    #   Failed test 'Pod coverage on MyApp::Controller::Root'
    #   at /usr/local/lib/perl5/site_perl/5.10.1/Test/Pod/Coverage.pm line 126.
    # Coverage for MyApp::Controller::Root is 66.7%, with 1 naked subroutine:
    #   default
    # Looks like you failed 2 tests of 6.
    t/03podcoverage.t ..... Dubious, test returned 2 (wstat 512, 0x200)
    Failed 2/6 subtests 
    t/controller_Books.t .. ok   
    t/view_HTML.t ......... ok   

    Test Summary Report
    -------------------
    t/03podcoverage.t   (Wstat: 512 Tests: 6 Failed: 2)
      Failed tests:  2-3
      Non-zero exit status: 2
    Files=5, Tests=25,  3 wallclock secs ( 0.05 usr  0.02 sys +  2.82 cusr  0.29 csys =  3.18 CPU)
    Result: FAIL
    Failed 1/5 test programs. 2/25 subtests failed.

Well that figures, doesn’t it? We added the `list` action to MyApp::Controller
Books but never documented it. And for some reason, Catalyst creates the
`default` action in MyApp::Controller::Root with no documentation. Such a shame.
So let’s document those methods. Add this to `t/lib/MyApp/Controller/Root.pm`:

```perl
=head2 default

The default action. Just returns a 404/NOT FOUND error. Might want to update
later with a template to format the error like the rest of our site.

=cut
```

While there, I notice that the `index` action has a doc header, but nothing to
actually describe what it does. Let’s fix that, too:

    The default Catalyst action, which just displays the welcome message. This is
    the "Yay it worked!" page. Consider changing to a real home page for our app.

Great. Now open `t/lib/MyApp/Controller/Books.pm` and document the `list`
action:

```perl
=head2 list

Looks up all of the books in the system and executes a template to display
them in a nice table. The data includes the title, rating, and authors of each
book

=cut
```

Oh hey, look at that. There’s an `index` method that doesn’t do anything. And it
has a POD header and no docs, too. So let’s document it:

    The default method for the books controller. Currently just says that it
    matches the request; we'll likely want to change it to something more
    reasonable down the line.

Okay, so how do the tests look now?

    t/01app.t ............. ok   
    t/02pod.t ............. ok     
    t/03podcoverage.t ..... ok   
    t/controller_Books.t .. ok   
    t/view_HTML.t ......... ok   
    All tests successful.
    Files=5, Tests=25,  3 wallclock secs ( 0.05 usr  0.02 sys +  2.82 cusr  0.31 csys =  3.20 CPU)
    Result: PASS

Excellent! Now, the truth is that we didn’t document our templates, either.
Test::Pod doesn’t cotton on to that fact because they're not installed like
normal subroutines in the test classes. So it’s up to us to document them
ourselves. (Note to self: Consider adding a module to test that all
Template::Declare classes have docs for all of their templates.) I'll wait here
while you do that.

All done? Great! I had actually planned to start testing the view next, but I
think this is enough for today. Stay tuned for more testing goodness.

  [ongoing]: /computers/programming/perl/catalyst "Just a Theory: Catalyst"
  [Catalyst tutorial]: http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial
    "Catalyst Tutorial: Overview"
  [chapter 8]: Catalyst::Manual::Tutorial::08_Testing
    "Catalyst Tutorial - Chapter 8: Testing"
  [Part 5 tag]: http://github.com/theory/catalyst-tutorial/commits/part-05
  [Catalyst::View::TD]: http://search.cpan.org/perldoc?Catalyst::View::TD
    "Catalyst::View::TD on CPAN"
  [DBIx::Connector]: http://search.cpan.org/perldoc?DBIx::Connector
    "DBIx::Connector on CPAN"
