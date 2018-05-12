--- 
date: 2009-11-10T18:01:44Z
slug: testing-td-views
title: Testing Catalyst Template::Declare Views
aliases: [/computers/programming/perl/catalyst/testing-td-views.html]
tags: [Perl, Catalyst, Template::Declare, testing, Test::XPath]
type: post
---

<p>Now that we have our default Catalyst <a href="http://www.justatheory.com/computers/programming/perl/catalyst/testing.html" title="Testing the Tutorial App">tests passing</a>, let's have a look at testing the views we've created. You can follow along via the <a href="http://github.com/theory/catalyst-tutorial/commits/part-06">Part 6 tag</a> tag in the GitHub repository. Start by looking at the default test script for our HTML view, <code>t/view_HTML.t</code>. It should look something like this:</p>

<pre>
use strict;
use warnings;
use Test::More tests =&gt; 3;
# use Test::XPath;

BEGIN {
    use_ok &#x27;MyApp::View::HTML&#x27; or die;
    use_ok &#x27;MyApp&#x27; or die;
}

ok my $view = MyApp-&gt;view(&#x27;HTML&#x27;), &#x27;Get HTML view object&#x27;;

# ok my $output = $view-&gt;render(undef, &#x27;hello&#x27;, { user =&gt; &#x27;Theory&#x27; }),
#     &#x27;Render the &quot;hello&quot; template&#x27;;

# Test output using Test::XPath or similar.
# my $tx = Test::XPath-&gt;new( xml =&gt; $output, is_html =&gt; 1);
# $tx-&gt;ok(&#x27;/html&#x27;, &#x27;Should have root html element&#x27;);
# $tx-&gt;is(&#x27;/html/head/title&#x27;, &#x27;Hello, Theory&#x27;, &#x27;Title should be correct&#x27;);
</pre>

<p>Yeah, this looks a bit different that the view test created for Template Toolkit or Mason views. That's because <a href="http://search.cpan.org/dist/Catalyst-View-TD" title="Catalyst::View::TD on CPAN">Catalyst::View::TD</a> ships with its own test script template. One of the advantage is that it shows off testing the view without having to instantiate the entire app or send mock HTTP requests. These are unit tests, after all: we want to make sure that the view templates do what they want, not test an entire request process. The latter is more appropriate for integration tests, which I'll cover later.</p>

<p>So let's have a look at this test script. The first commented-out statement is:</p>

<pre>
# ok my $output = $view-&gt;render(undef, &#x27;hello&#x27;, { user =&gt; &#x27;Theory&#x27; }),
#     &#x27;Render the &quot;hello&quot; template&#x27;;
</pre>

<p>What this is showing us is that one can use the view's <code>render()</code> method to execute a view without a context object, thus saving the expense of initializing the application. And if you have templates that don't rely on it, I highly recommend this approach for keeping your tests fast. Even if the use of the the context object is fairly minimal, you can use <a href="http://search.cpan.org/perldoc?Test::MockObject" title="Test::MockObject on CPAN">Test::MockObject</a> to mock up a context object like so:</p>

<pre>
use Test::MockObject;
my $c = Test::MockObject-&gt;new;
$c-&gt;mock(uri_for =&gt; sub { $_[1] });
$c-&gt;mock(config  =&gt; sub { { name =&gt; &#x27;MyApp&#x27; } });
$c-&gt;mock(debug   =&gt; sub { });
$c-&gt;mock(log     =&gt; sub { });

ok my $output = $view-&gt;render($c, &#x27;hello&#x27;, { user =&gt; &#x27;Theory&#x27; }),
     &#x27;Render the &quot;hello&quot; template&#x27;;
</pre>

<p>Then you can use the <code>mock()</code> method to mock more methods as your template uses them.</p>

<p>Alas, our app has already passed the point where that seems worthwhile. So far we have just one template, <code>books/list</code>, and it requires that there also be a database statement handle available. Sure we could create a database connection and prepare a statement handle. But that would start to require a fair bit more code to set up. So let's just instantiate the application object and be done with it. Change the test plan to 5:</p>

<pre>
use Test::More tests =&gt; 5;
</pre>

<p>Then change the test body after the <code>BEGIN</code> block to:</p>

<pre>
# Instantiate the context object and the view.
ok my $c = MyApp-&gt;new, &#x27;Create context object&#x27;;
ok my $view = $c-&gt;view(&#x27;HTML&#x27;), &#x27;Get HTML view object&#x27;;

# Create a statement handle for books/list.
my $sth = $c-&gt;conn-&gt;run(sub { $_-&gt;prepare(q{
    SELECT isbn, title, rating, authors FROM books_with_authors
}) });
$sth-&gt;execute;

# Render books/list.
ok my $output = $view-&gt;render($c, &#x27;books/list&#x27;, {
    title =&gt; &#x27;Book List&#x27;,
    books =&gt; $sth,
}), &#x27;Render the &quot;books/list&quot; template&#x27;;
</pre>

<p>This allows us to get a full test of the view. </p>

<pre>
% prove &#x2d;&#x2d;lib &#x2d;&#x2d;verbose t/view_HTML.t
t/view_HTML.t .. 
1..5
ok 1 - use MyApp::View::HTML;
ok 2 - use MyApp;
ok 3 - Create context object
ok 4 - Get HTML view object
Explicit blessing to '' (assuming package main) at /usr/local/lib/perl5/site_perl/5.10.1/Catalyst.pm line 1281.
Explicit blessing to '' (assuming package main) at /usr/local/lib/perl5/site_perl/5.10.1/Catalyst.pm line 1281.
Explicit blessing to '' (assuming package main) at /usr/local/lib/perl5/site_perl/5.10.1/Catalyst.pm line 1281.
Explicit blessing to '' (assuming package main) at /usr/local/lib/perl5/site_perl/5.10.1/Catalyst.pm line 1281.
ok 5 - Render the "books/list" template
ok
All tests successful.
Files=1, Tests=5,  1 wallclock secs ( 0.02 usr  0.00 sys +  0.69 cusr  0.06 csys =  0.77 CPU)
Result: PASS
</pre>

<p>Hrm. Those warnings are rather annoying. Looking at <code>Catalyst.pm</code> I see that they come from the <code>uri_for()</code> method. I expect that they somehow result from a lack of state in the context object. That's not really important for our unit tests, so let's just mock that one method to do something reasonable. Add this code after instantiating the context object but before rendering the view:</p>

<pre>
use Test::MockObject::Extends;
my $mocker = Test::MockObject::Extends-&gt;new($c);
$mocker-&gt;mock( uri_for =&gt; sub { $_[1]} );
</pre>

<p>And now we get:</p>

<pre>
% prove &#x2d;&#x2d;lib &#x2d;&#x2d;verbose t/view_HTML.t
t/view_HTML.t .. 
1..5
ok 1 - use MyApp::View::HTML;
ok 2 - use MyApp;
ok 3 - Create context object
ok 4 - Get HTML view object
ok 5 - Render the &quot;books/list&quot; template
ok
All tests successful.
Files=1, Tests=5,  1 wallclock secs ( 0.02 usr  0.01 sys +  0.77 cusr  0.07 csys =  0.87 CPU)
Result: PASS
</pre>

<p>Ah, much better! And thanks to our mock, we also have a much better idea of what will be returned from <code>uri_for()</code>, which will be important for later tests.</p>

<p>Now that we have things properly mocked up and the objects created such that we can actually get the template to render, it's time to test the output from the template. For HTML and XML format, I like the <a href="http://search.cpan.org/perldoc?Test::XPath" title="Test::XPath on CPAN">Test::XPath</a> module. In fact, it's for this very use that I wrote Test::XPath. It's great because it allows me to effectively test the correctness of the template output. Here's the basic outline:</p>

<pre>
# Test output using Test::XPath.
my $tx = Test::XPath-&gt;new( xml =&gt; $output, is_html =&gt; 1);
test_basics($tx, &#x27;Book List&#x27;);

# Call this function for every request to make sure that they all
# have the same basic structure.
sub test_basics {
    my ($tx, $title) = @_;

    # Some basic sanity-checking.
    $tx-&gt;is( &#x27;count(/html)&#x27;,      1, &#x27;Should have 1 html element&#x27; );
    $tx-&gt;is( &#x27;count(/html/head)&#x27;, 1, &#x27;Should have 1 head element&#x27; );
    $tx-&gt;is( &#x27;count(/html/body)&#x27;, 1, &#x27;Should have 1 body element&#x27; );

    # Check the head element.
    $tx-&gt;is(
        &#x27;/html/head/title&#x27;,
        $title,
        &#x27;Title should be corect&#x27;
    );
    $tx-&gt;is(
        &#x27;/html/head/link[@type=&quot;text/css&quot;][@rel=&quot;stylesheet&quot;]/@href&#x27;,
        &#x27;/static/css/main.css&#x27;,
        &#x27;Should load the CSS&#x27;,
    );
}
</pre>

<p>I've set up the <code>test_basics()</code> function to test the things that should be mostly the same for every request. This will mainly cover the output of the wrapper, and includes things like making sure that there is just one <code>&lt;html&gt;</code> tag, one <code>&lt;head&gt;</code> tag, and one <code>&lt;body&gt;</code> tag; and that the title and CSS-related elements are output properly. Running this (with the test plan set to <code>no_plan</code> as I develop), I get:</p>

<pre>
% prove &#x2d;&#x2d;lib t/view_HTML.tt
t/view_HTML.t .. 2/? 
#   Failed test 'Should load the CSS'
#   at t/view_HTML.t line 52.
#          got: ''
#     expected: '/static/css/main.css'
# Looks like you failed 1 test of 10.
t/view_HTML.t .. Dubious, test returned 1 (wstat 256, 0x100)
Failed 1/10 subtests 

Test Summary Report
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
t/view_HTML.t (Wstat: 256 Tests: 10 Failed: 1)
  Failed test:  10
  Non-zero exit status: 1
Files=1, Tests=10,  1 wallclock secs ( 0.02 usr  0.01 sys +  0.79 cusr  0.08 csys =  0.90 CPU)
Result: FAIL
</pre>

<p>Hrm. Let's stick a <code>diag $output</code> in there and see what we get. Now the output includes this bit:</p>

<pre>
# &lt;html&gt;
#  &lt;head&gt;
#   &lt;title&gt;Book List&lt;/title&gt;
#   &lt;link rel=&quot;stylesheet&quot; href=&quot;/static/css/main.css&quot; /&gt;
#  &lt;/head&gt;
</pre>

<p>Ah! the <code>&lt;link&gt;</code> element for the stylesheet is missing the <code>type</code> attribute. So let's add it. Edit <code>lib/MyApp/Templates/HTML.pm</code> and change the proper bit of the wrapper template to:</p>

<pre>
link {
    rel is &#x27;stylesheet&#x27;;
    type is &#x27;text/css&#x27;;
    href is $c-&gt;uri_for(&#x27;/static/css/main.css&#x27; );
};
</pre>

<p>Note the addition of the <code>type</code> attribute. Now when we run the tests (removing the <code>diag</code>), we get:</p>

<pre>
% prove &#x2d;&#x2d;lib t/view_HTML.t
t/view_HTML.t .. ok    
All tests successful.
Files=1, Tests=10,  1 wallclock secs ( 0.02 usr  0.00 sys +  0.78 cusr  0.07 csys =  0.87 CPU)
Result: PASS
</pre>

<p>Ah, much better! A lot more testing should go in there to make sure that the wrapper is doing things right. I've <a href="http://github.com/theory/catalyst-tutorial/commit/b171bfb0cb624b3a5ef840d116e121a355f5fe7d">committed</a> such testing, so check it out.</p>

<p>Now we need to test the output specific to the <code>books/list</code> template. Below the call to <code>test_basics()</code>, add this code:</p>

<pre>
$tx-&gt;ok(&#x27;/html/body/div[@id=&quot;bodyblock&quot;]/div[@id=&quot;content&quot;]/table&#x27;, sub {
    $_-&gt;is(&#x27;count(./tr)&#x27;, 6, &#x27;Should have seven rows&#x27; );
    $_-&gt;ok(&#x27;./tr[1]&#x27;, sub {
        $_-&gt;is(&#x27;count(./th)&#x27;, 3, &#x27;Should have three table headers&#x27;);
        $_-&gt;is(&#x27;./th[1]&#x27;, &#x27;Title&#x27;, &#x27;... first is &quot;Title&quot;&#x27;);
        $_-&gt;is(&#x27;./th[2]&#x27;, &#x27;Rating&#x27;, &#x27;... second is &quot;Rating&quot;&#x27;);
        $_-&gt;is(&#x27;./th[3]&#x27;, &#x27;Authors&#x27;, &#x27;... third is &quot;Authors&quot;&#x27;);
    }, &#x27;Should have first table row&#x27;)
}, &#x27;Should have a table&#x27;);
</pre>

<p>Notice the nested block there? <a href="http://search.cpan.org/perldoc?Test::XPath" title="Test::XPath on CPAN">Test::XPath</a> supports passing blocks to its <code>ok()</code> method, so that you can naturally scope your tests to blocks of XML and HTML. Neat, huh? If you don't like the use of <code>$_</code>, the test object is also passed as the sole argument to such blocks.</p>

<p>Anyway, these tests makes sure that the table is where it should be, has the proper number of rows, and that the first row has three headers with their proper values. The test outputs:</p>

<pre>
% prove &#x2d;&#x2d;lib t/view_HTML.tt
t/view_HTML.t .. 1/? 
#   Failed test &#x27;... third is &quot;Authors&quot;&#x27;
#   at t/view_HTML.t line 42.
#          got: &#x27;Author&#x27;
#     expected: &#x27;Authors&#x27;
# Looks like you failed 1 test of 28.
t/view_HTML.t .. Dubious, test returned 1 (wstat 256, 0x100)
Failed 1/28 subtests 

Test Summary Report
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
t/view_HTML.t (Wstat: 256 Tests: 28 Failed: 1)
  Failed test:  28
  Non-zero exit status: 1
Files=1, Tests=28,  1 wallclock secs ( 0.03 usr  0.01 sys +  0.79 cusr  0.08 csys =  0.91 CPU)
Result: FAIL
</pre>

<p>Whoops! Looks like I forgot to change the header when I changed the template to output a list of authors <a href="/computers/programming/perl/catalyst/sql-view-aggregate-magic.html" title="My Catalyst Tutorial: Add Authors to the View">last week</a>. So edit <code>lib/MyApp/Templates/HTML/Books.pm</code> and change the template to output "Authors" instead of "Author":</p>

<pre>
row {
    th { &#x27;Title&#x27;   };
    th { &#x27;Rating&#x27;  };
    th { &#x27;Authors&#x27; };
};
</pre>

<p>And now all tests pass again:</p>

<pre>
% prove &#x2d;&#x2d;lib t/view_HTML.t
t/view_HTML.t .. ok    
All tests successful.
Files=1, Tests=28,  1 wallclock secs ( 0.02 usr  0.01 sys +  0.78 cusr  0.09 csys =  0.90 CPU)
Result: PASS
</pre>

<p>Great. So let's finish testing the rest of the output. Ah, but wait! We have on <code>ORDER BY</code> clause on the query, so the order in which the books will be output is undefined. So let's add an <code>ORDER BY</code> clause. Change the creation of the statement handle in the test file to:</p>

<pre>
my $sth = $c-&gt;conn-&gt;run(sub { $_-&gt;prepare(q{
    SELECT isbn, title, rating, authors
      FROM books_with_authors
     ORDER BY title
}) });
</pre>

<p>And now you can start to see why I use the <code>q{}</code> operator for SQL queries. You should also note that the inputs for the view test are now different than those from the controller, which still has no <code>ORDER BY</code> clause. It's likely that we'll want to go back and change that later, but I bring it up here to highlight the difference from integration tests -- and to emphasize that we'll need to write those integration tests at some point!</p>

<p>But back to the view unit tests. We can now test the contents of the table by adding code after the test for <code>./tr[1]</code>. Here's what the test for the next row looks like:</p>

<pre>
$_-&gt;ok(&#x27;./tr[2]&#x27;, sub {
    $_-&gt;is(&#x27;count(./td)&#x27;, 3, &#x27;Should have three cells&#x27;);
    $_-&gt;is(
        &#x27;./td[1]&#x27;,
        &#x27;CCSP SNRS Exam Certification Guide&#x27;,
        &#x27;... first is &quot;CCSP SNRS Exam Certification Guide&quot;&#x27;
    );
    $_-&gt;is(&#x27;./td[2]&#x27;, 5, &#x27;... second is &quot;5&quot;&#x27;);
    $_-&gt;is(
        &#x27;./td[3]&#x27;,
        &#x27;Bastien, Nasseh, Degu&#x27;,
        &#x27;... third is &quot;Bastien, Nasseh, Degu&quot;&#x27;,
    );
}, &#x27;Should have second table row&#x27;);
</pre>

<p>The other rows can be similarly tested; have a look at the <a href="http://github.com/theory/catalyst-tutorial/commit/e6018bd0339fb92b9c7fe9ac3d518ca3d302f7a0">commit</a> to see all the new tests.</p>

<p>This reminds me, however, that we never created an order for the list of authors. So it's possible that this test could fail, as the order of the author last names is undefined. We should go back and fix that, probably by listing the authors as they are actually listed on the cover of the book. But in the meantime, our test of this view is done.</p>

<p>Next up, I think I'll hit controller tests. So come on back!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/catalyst/testing-td-views.html">old layout</a>.</small></p>


