--- 
date: 2009-11-09T18:36:15Z
slug: testing
title: Testing the Tutorial App
aliases: [/computers/programming/perl/catalyst/testing.html]
tags: [Perl, Catalyst, testing, MVC, Template::Declare]
type: post
---

<p>Yet another entry in my <a href="/computers/programming/perl/catalyst" title="Just a Theory: Catalyst">ongoing</a> attempt to rewrite the <a href="http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial" title="Catalyst Tutorial: Overview">Catalyst tutorial</a> in my own coding style.</p>

<p>So far, I've been following the original tutorial pretty closely. But now I want to skip ahead a bit to <a href="Catalyst::Manual::Tutorial::08_Testing" title="Catalyst Tutorial - Chapter 8: Testing">chapter 8</a>: testing. I skip because, really, we should be writing tests from the very beginning. They shouldn’t be an afterthought stuck in the penultimate chapter of a tutorial. So let’s write some tests. You can follow along in the <a href="http://github.com/theory/catalyst-tutorial/commits/part-05">Part 5 tag</a> in the GitHub repository.</p>

<h3>Oops, A Missing Dependency</h3>

<p>Oh, wait! I forgot to tell the build system that we now depend on <a href="http://search.cpan.org/perldoc?Catalyst::View::TD" title="Catalyst::View::TD on CPAN">Catalyst::View::TD</a> and <a href="http://search.cpan.org/perldoc?DBIx::Connector" title="DBIx::Connector on CPAN">DBIx::Connector</a>. So add these two lines to <code>Makefile.PL</code>:</p>

<pre>
requires &#x27;Catalyst::View::TD&#x27; =&gt; &#x27;0.11&#x27;;
requires &#x27;DBIx::Connector&#x27; =&gt; &#x27;0.30&#x27;;
</pre>


<p>Okay, <em>now</em> we can write some tests.</p>

<h3>STFU</h3>

<p>Well, no, actually, let’s start by running the tests we have:</p>

<pre>
perl Makefile.PL
make test
</pre>


<p>You should see some output after this — lots of stuff, actually — ending something like this:</p>

<pre>
[debug] Loaded Path actions:
.&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;.
| Path                                | Private                              |
+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+
| /                                   | /index                               |
| /                                   | /default                             |
| /books                              | /books/index                         |
| /books/list                         | /books/list                          |
&#x27;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x27;

[info] MyApp powered by Catalyst 5.80013
t/view_HTML.t ......... ok   
All tests successful.
Files=5, Tests=8,  3 wallclock secs ( 0.04 usr  0.02 sys +  2.19 cusr  0.25 csys =  2.50 CPU)
Result: PASS
</pre>


<p>I don’t know about you, but having all that debugging crap just drives me nuts while I'm running tests. It’s helpful while doing development, but mainly just gets in the way of the tests. So let’s get rid of them. Open up <code>lib/MyApp.pm</code> and change the <code>use Catalyst</code> statement to:</p>

<pre>
use Catalyst (qw(
    ConfigLoader
    Static::Simple
    StackTrace
), $ENV{HARNESS_ACTIVE} ? () : &#x27;-Debug&#x27;);
</pre>


<p>Essentially, we're just turning on the debugging output only if the test harness is not active. Now when we run the tests, we get:</p>

<pre>
t/01app.t ............. ok   
t/02pod.t ............. skipped: set TEST_POD to enable this test
t/03podcoverage.t ..... skipped: set TEST_POD to enable this test
t/controller_Books.t .. ok   
t/view_HTML.t ......... ok   
All tests successful.
Files=5, Tests=8,  3 wallclock secs ( 0.04 usr  0.02 sys +  2.15 cusr  0.23 csys =  2.44 CPU)
Result: PASS
</pre>


<p><em>Much</em> better. Now I can actually see other stuff, such as the fact that I'm skipping POD tests. Personally, I like to make sure that POD tests run all the time, as I'm likely to forget to set the environment variable. So let’s edit <code>t/02pod.t</code> and <code>t/03podcoverage.t</code> and delete this line from each:</p>

<pre>
plan skip_all =&gt; &#x27;set TEST_POD to enable this test&#x27; unless $ENV{TEST_POD};
</pre>


<p>So what does that get us?</p>

<pre>
t/01app.t ............. ok   
t/02pod.t ............. ok     
t/03podcoverage.t ..... 1/6 
#   Failed test &#x27;Pod coverage on MyApp::Controller::Books&#x27;
#   at /usr/local/lib/perl5/site_perl/5.10.1/Test/Pod/Coverage.pm line 126.
# Coverage for MyApp::Controller::Books is 50.0%, with 1 naked subroutine:
#   list

#   Failed test &#x27;Pod coverage on MyApp::Controller::Root&#x27;
#   at /usr/local/lib/perl5/site_perl/5.10.1/Test/Pod/Coverage.pm line 126.
# Coverage for MyApp::Controller::Root is 66.7%, with 1 naked subroutine:
#   default
# Looks like you failed 2 tests of 6.
t/03podcoverage.t ..... Dubious, test returned 2 (wstat 512, 0x200)
Failed 2/6 subtests 
t/controller_Books.t .. ok   
t/view_HTML.t ......... ok   

Test Summary Report
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
t/03podcoverage.t   (Wstat: 512 Tests: 6 Failed: 2)
  Failed tests:  2&#x2d;3
  Non&#x2d;zero exit status: 2
Files=5, Tests=25,  3 wallclock secs ( 0.05 usr  0.02 sys +  2.82 cusr  0.29 csys =  3.18 CPU)
Result: FAIL
Failed 1/5 test programs. 2/25 subtests failed.
</pre>

<p>Well that figures, doesn’t it? We added the <code>list</code> action to  MyApp::Controller Books but never documented it. And for some reason, Catalyst creates the <code>default</code> action in MyApp::Controller::Root with no documentation. Such a shame. So let’s document those methods. Add this to <code>t/lib/MyApp/Controller/Root.pm</code>:</p>

<pre>
=head2 default

The default action. Just returns a 404/NOT FOUND error. Might want to update
later with a template to format the error like the rest of our site.

=cut
</pre>

<p>While there, I notice that the <code>index</code> action has a doc header, but nothing to actually describe what it does. Let’s fix that, too:</p>

<pre>
The default Catalyst action, which just displays the welcome message. This is
the &quot;Yay it worked!&quot; page. Consider changing to a real home page for our app.
</pre>

<p>Great. Now open <code>t/lib/MyApp/Controller/Books.pm</code> and document the <code>list</code> action:</p>

<pre>
=head2 list

Looks up all of the books in the system and executes a template to display
them in a nice table. The data includes the title, rating, and authors of each
book

=cut
</pre>

<p>Oh hey, look at that. There’s an <code>index</code> method that doesn’t do anything. And it has a POD header and no docs, too. So let’s document it:</p>

<pre>
The default method for the books controller. Currently just says that it
matches the request; we&#x27;ll likely want to change it to something more
reasonable down the line.
</pre>

<p>Okay, so how do the tests look now?</p>

<pre>
t/01app.t ............. ok   
t/02pod.t ............. ok     
t/03podcoverage.t ..... ok   
t/controller_Books.t .. ok   
t/view_HTML.t ......... ok   
All tests successful.
Files=5, Tests=25,  3 wallclock secs ( 0.05 usr  0.02 sys +  2.82 cusr  0.31 csys =  3.20 CPU)
Result: PASS
</pre>

<p>Excellent! Now, the truth is that we didn’t document our templates, either. Test::Pod doesn’t cotton on to that fact because they're not installed like normal subroutines in the test classes. So it’s up to us to document them ourselves. (Note to self: Consider adding a module to test that all Template::Declare classes have docs for all of their templates.) I'll wait here while you do that.</p>

<p>All done? Great! I had actually planned to start testing the view next, but I think this is enough for today. Stay tuned for more testing goodness.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/catalyst/testing.html">old layout</a>.</small></p>


