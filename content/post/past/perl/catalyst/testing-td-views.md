--- 
date: 2009-11-10T18:01:44Z
slug: testing-td-views
title: Testing Catalyst Template::Declare Views
aliases: [/computers/programming/perl/catalyst/testing-td-views.html]
tags: [Perl, Catalyst, Template::Declare, testing, Test::XPath]
type: post
---

Now that we have our default Catalyst [tests passing], let's have a look at
testing the views we've created. You can follow along via the [Part 6 tag] tag
in the GitHub repository. Start by looking at the default test script for our
HTML view, `t/view_HTML.t`. It should look something like this:

```perl
use strict;
use warnings;
use Test::More tests => 3;
# use Test::XPath;

BEGIN {
    use_ok 'MyApp::View::HTML' or die;
    use_ok 'MyApp' or die;
}

ok my $view = MyApp->view('HTML'), 'Get HTML view object';

# ok my $output = $view->render(undef, 'hello', { user => 'Theory' }),
#     'Render the "hello" template';

# Test output using Test::XPath or similar.
# my $tx = Test::XPath->new( xml => $output, is_html => 1);
# $tx->ok('/html', 'Should have root html element');
# $tx->is('/html/head/title', 'Hello, Theory', 'Title should be correct');
```

Yeah, this looks a bit different that the view test created for Template Toolkit
or Mason views. That's because [Catalyst::View::TD] ships with its own test
script template. One of the advantage is that it shows off testing the view
without having to instantiate the entire app or send mock HTTP requests. These
are unit tests, after all: we want to make sure that the view templates do what
they want, not test an entire request process. The latter is more appropriate
for integration tests, which I'll cover later.

So let's have a look at this test script. The first commented-out statement is:

    # ok my $output = $view->render(undef, 'hello', { user => 'Theory' }),
    #     'Render the "hello" template';

What this is showing us is that one can use the view's `render()` method to
execute a view without a context object, thus saving the expense of initializing
the application. And if you have templates that don't rely on it, I highly
recommend this approach for keeping your tests fast. Even if the use of the the
context object is fairly minimal, you can use [Test::MockObject] to mock up a
context object like so:

```perl
use Test::MockObject;
my $c = Test::MockObject->new;
$c->mock(uri_for => sub { $_[1] });
$c->mock(config  => sub { { name => 'MyApp' } });
$c->mock(debug   => sub { });
$c->mock(log     => sub { });

ok my $output = $view->render($c, 'hello', { user => 'Theory' }),
    'Render the "hello" template';
```

Then you can use the `mock()` method to mock more methods as your template uses
them.

Alas, our app has already passed the point where that seems worthwhile. So far
we have just one template, `books/list`, and it requires that there also be a
database statement handle available. Sure we could create a database connection
and prepare a statement handle. But that would start to require a fair bit more
code to set up. So let's just instantiate the application object and be done
with it. Change the test plan to 5:

```perl
use Test::More tests => 5;
```

Then change the test body after the `BEGIN` block to:

```perl
# Instantiate the context object and the view.
ok my $c = MyApp->new, 'Create context object';
ok my $view = $c->view('HTML'), 'Get HTML view object';

# Create a statement handle for books/list.
my $sth = $c->conn->run(sub { $_->prepare(q{
    SELECT isbn, title, rating, authors FROM books_with_authors
}) });
$sth->execute;

# Render books/list.
ok my $output = $view->render($c, 'books/list', {
    title => 'Book List',
    books => $sth,
}), 'Render the "books/list" template';
```

This allows us to get a full test of the view.

    % prove --lib --verbose t/view_HTML.t
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

Hrm. Those warnings are rather annoying. Looking at `Catalyst.pm` I see that
they come from the `uri_for()` method. I expect that they somehow result from a
lack of state in the context object. That's not really important for our unit
tests, so let's just mock that one method to do something reasonable. Add this
code after instantiating the context object but before rendering the view:

```perl
use Test::MockObject::Extends;
my $mocker = Test::MockObject::Extends->new($c);
$mocker->mock( uri_for => sub { $_[1]} );
```

And now we get:

    % prove --lib --verbose t/view_HTML.t
    t/view_HTML.t .. 
    1..5
    ok 1 - use MyApp::View::HTML;
    ok 2 - use MyApp;
    ok 3 - Create context object
    ok 4 - Get HTML view object
    ok 5 - Render the "books/list" template
    ok
    All tests successful.
    Files=1, Tests=5,  1 wallclock secs ( 0.02 usr  0.01 sys +  0.77 cusr  0.07 csys =  0.87 CPU)
    Result: PASS

Ah, much better! And thanks to our mock, we also have a much better idea of what
will be returned from `uri_for()`, which will be important for later tests.

Now that we have things properly mocked up and the objects created such that we
can actually get the template to render, it's time to test the output from the
template. For HTML and XML format, I like the [Test::XPath] module. In fact,
it's for this very use that I wrote Test::XPath. It's great because it allows me
to effectively test the correctness of the template output. Here's the basic
outline:

```perl
# Test output using Test::XPath.
my $tx = Test::XPath->new( xml => $output, is_html => 1);
test_basics($tx, 'Book List');

# Call this function for every request to make sure that they all
# have the same basic structure.
sub test_basics {
    my ($tx, $title) = @_;

    # Some basic sanity-checking.
    $tx->is( 'count(/html)',      1, 'Should have 1 html element' );
    $tx->is( 'count(/html/head)', 1, 'Should have 1 head element' );
    $tx->is( 'count(/html/body)', 1, 'Should have 1 body element' );

    # Check the head element.
    $tx->is(
        '/html/head/title',
        $title,
        'Title should be corect'
    );
    $tx->is(
        '/html/head/link[@type="text/css"][@rel="stylesheet"]/@href',
        '/static/css/main.css',
        'Should load the CSS',
    );
}
```

I've set up the `test_basics()` function to test the things that should be
mostly the same for every request. This will mainly cover the output of the
wrapper, and includes things like making sure that there is just one `<html>`
tag, one `<head>` tag, and one `<body>` tag; and that the title and CSS-related
elements are output properly. Running this (with the test plan set to `no_plan`
as I develop), I get:

    % prove --lib t/view_HTML.tt
    t/view_HTML.t .. 2/? 
    #   Failed test 'Should load the CSS'
    #   at t/view_HTML.t line 52.
    #          got: ''
    #     expected: '/static/css/main.css'
    # Looks like you failed 1 test of 10.
    t/view_HTML.t .. Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/10 subtests 

    Test Summary Report
    -------------------
    t/view_HTML.t (Wstat: 256 Tests: 10 Failed: 1)
      Failed test:  10
      Non-zero exit status: 1
    Files=1, Tests=10,  1 wallclock secs ( 0.02 usr  0.01 sys +  0.79 cusr  0.08 csys =  0.90 CPU)
    Result: FAIL

Hrm. Let's stick a `diag $output` in there and see what we get. Now the output
includes this bit:

    # <html>
    #  <head>
    #   <title>Book List</title>
    #   <link rel="stylesheet" href="/static/css/main.css" />
    #  </head>

Ah! the `<link>` element for the stylesheet is missing the `type` attribute. So
let's add it. Edit `lib/MyApp/Templates/HTML.pm` and change the proper bit of
the wrapper template to:

```perl
link {
    rel is 'stylesheet';
    type is 'text/css';
    href is $c->uri_for('/static/css/main.css' );
};
```

Note the addition of the `type` attribute. Now when we run the tests (removing
the `diag`), we get:

    % prove --lib t/view_HTML.t
    t/view_HTML.t .. ok    
    All tests successful.
    Files=1, Tests=10,  1 wallclock secs ( 0.02 usr  0.00 sys +  0.78 cusr  0.07 csys =  0.87 CPU)
    Result: PASS

Ah, much better! A lot more testing should go in there to make sure that the
wrapper is doing things right. I've [committed] such testing, so check it out.

Now we need to test the output specific to the `books/list` template. Below the
call to `test_basics()`, add this code:

```perl
$tx->ok('/html/body/div[@id="bodyblock"]/div[@id="content"]/table', sub {
    $_->is('count(./tr)', 6, 'Should have seven rows' );
    $_->ok('./tr[1]', sub {
        $_->is('count(./th)', 3, 'Should have three table headers');
        $_->is('./th[1]', 'Title', '... first is "Title"');
        $_->is('./th[2]', 'Rating', '... second is "Rating"');
        $_->is('./th[3]', 'Authors', '... third is "Authors"');
    }, 'Should have first table row')
}, 'Should have a table');
```

Notice the nested block there? [Test::XPath] supports passing blocks to its
`ok()` method, so that you can naturally scope your tests to blocks of XML and
HTML. Neat, huh? If you don't like the use of `$_`, the test object is also
passed as the sole argument to such blocks.

Anyway, these tests makes sure that the table is where it should be, has the
proper number of rows, and that the first row has three headers with their
proper values. The test outputs:

    % prove --lib t/view_HTML.tt
    t/view_HTML.t .. 1/? 
    #   Failed test '... third is "Authors"'
    #   at t/view_HTML.t line 42.
    #          got: 'Author'
    #     expected: 'Authors'
    # Looks like you failed 1 test of 28.
    t/view_HTML.t .. Dubious, test returned 1 (wstat 256, 0x100)
    Failed 1/28 subtests 

    Test Summary Report
    -------------------
    t/view_HTML.t (Wstat: 256 Tests: 28 Failed: 1)
      Failed test:  28
      Non-zero exit status: 1
    Files=1, Tests=28,  1 wallclock secs ( 0.03 usr  0.01 sys +  0.79 cusr  0.08 csys =  0.91 CPU)
    Result: FAIL

Whoops! Looks like I forgot to change the header when I changed the template to
output a list of authors [last week]. So edit
`lib/MyApp/Templates/HTML/Books.pm` and change the template to output "Authors"
instead of "Author":

```perl
row {
    th { 'Title'   };
    th { 'Rating'  };
    th { 'Authors' };
};
```

And now all tests pass again:

    % prove --lib t/view_HTML.t
    t/view_HTML.t .. ok    
    All tests successful.
    Files=1, Tests=28,  1 wallclock secs ( 0.02 usr  0.01 sys +  0.78 cusr  0.09 csys =  0.90 CPU)
    Result: PASS

Great. So let's finish testing the rest of the output. Ah, but wait! We have on
`ORDER BY` clause on the query, so the order in which the books will be output
is undefined. So let's add an `ORDER BY` clause. Change the creation of the
statement handle in the test file to:

```perl
my $sth = $c->conn->run(sub { $_->prepare(q{
    SELECT isbn, title, rating, authors
        FROM books_with_authors
        ORDER BY title
}) });
```

And now you can start to see why I use the `q{}` operator for SQL queries. You
should also note that the inputs for the view test are now different than those
from the controller, which still has no `ORDER BY` clause. It's likely that
we'll want to go back and change that later, but I bring it up here to highlight
the difference from integration tests -- and to emphasize that we'll need to
write those integration tests at some point!

But back to the view unit tests. We can now test the contents of the table by
adding code after the test for `./tr[1]`. Here's what the test for the next row
looks like:

```perl
$_->ok('./tr[2]', sub {
    $_->is('count(./td)', 3, 'Should have three cells');
    $_->is(
        './td[1]',
        'CCSP SNRS Exam Certification Guide',
        '... first is "CCSP SNRS Exam Certification Guide"'
    );
    $_->is('./td[2]', 5, '... second is "5"');
    $_->is(
        './td[3]',
        'Bastien, Nasseh, Degu',
        '... third is "Bastien, Nasseh, Degu"',
    );
}, 'Should have second table row');
```

The other rows can be similarly tested; have a look at the [commit] to see all
the new tests.

This reminds me, however, that we never created an order for the list of
authors. So it's possible that this test could fail, as the order of the author
last names is undefined. We should go back and fix that, probably by listing the
authors as they are actually listed on the cover of the book. But in the
meantime, our test of this view is done.

Next up, I think I'll hit controller tests. So come on back!

  [tests passing]: http://www.justatheory.com/computers/programming/perl/catalyst/testing.html
    "Testing the Tutorial App"
  [Part 6 tag]: http://github.com/theory/catalyst-tutorial/commits/part-06
  [Catalyst::View::TD]: http://search.cpan.org/dist/Catalyst-View-TD
    "Catalyst::View::TD on CPAN"
  [Test::MockObject]: http://search.cpan.org/perldoc?Test::MockObject
    "Test::MockObject on CPAN"
  [Test::XPath]: http://search.cpan.org/perldoc?Test::XPath
    "Test::XPath on CPAN"
  [committed]: http://github.com/theory/catalyst-tutorial/commit/b171bfb0cb624b3a5ef840d116e121a355f5fe7d
  [last week]: /computers/programming/perl/catalyst/sql-view-aggregate-magic.html
    "My Catalyst Tutorial: Add Authors to the View"
  [commit]: http://github.com/theory/catalyst-tutorial/commit/e6018bd0339fb92b9c7fe9ac3d518ca3d302f7a0
