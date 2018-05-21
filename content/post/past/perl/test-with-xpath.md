--- 
date: 2009-09-01T21:51:10Z
description: Introducing a Rails-inspired Perl module to test the structure and content of an XML or HTML document using CSS selectors.
slug: test-with-xpath
title: Test XML and HTML with XPath
aliases: [/computers/programming/perl/test-with-xpath.html]
tags: [Perl, XML, XPath, testing, unit testing, Test::XPath, HTML, XHTML]
type: post
---

When I was hacking Rails projects back in 2006-2007, there was a lot of stuff
about Rails that drove me absolutely batshit (\<cough\>ActiveRecord\</cough\>),
but there were also a (very) few things that I really liked. One of those things
was the [`assert_select`] test method. There was a bunch of magic involved in
sending a request to your Rails app and stuffing the body someplace hidden (hrm,
that sounds kind of evil; intentional?), but then you could call `assert_select`
to use CSS selectors to test the structure and content of the document
(assuming, of course, that it was HTML or XML). For example, (to borrow from the
Rails docs), if you wanted to test that a response contains two ordered lists,
each with four list elements then you'd do something like this:

``` ruby
assert_select "ol" do |elements|
    elements.each do |element|
    assert_select element, "li", 4
    end
end
```

What it does is select all of the `<ol>` elements and pass them to the `do`
block, where you can call `assert_select` on each of them. Nice, huh? You can
also implicitly call `assert_select` on the entire array of passed elements,
like so:

``` ruby
assert_select "ol" do
    assert_select "li", 8
end
```

Slick, right? I've always wanted to have something like this in Perl, but until
last week, I didn't really have an immediate need for it. But I've started on a
Catalyst project with my partners at [PGX], and of course I'm using a view to
generate XHTML output. So I started asking around for advice on proper unit
testing for Catalyst views. The answer I got was, basically,
[Test::WWW::Mechanize::Catalyst]. But I found it insufficient:

``` perl
$mech->get_ok("/");
$mech->html_lint_ok( "HTML should be valid" );
$mech->title_is( "Root", "On the root page" );
$mech->content_contains( "This is the root page", "Correct content" );
```

Okay, I can check the title of the document directly, which is kind of cool, but
there's no other way to examine the structure? Really? And to check the content,
there's just `content_contains()`, which concatenates all of the content without
any tags! This is useful for certain very simple tests, but if you want to make
sure that your document is properly structured, and the content is in all the
right places, you're [SOL].

Furthermore, the `html_link_ok()` method didn't like the Unicode characters
output by my view:

    #   Failed test 'HTML should be valid (http://localhost/)'
    #   at t/view_TD.t line 30.
    # HTML::Lint errors for http://localhost/
    #  (4:3) Invalid character \x2019 should be written as &rsquo;
    #  (18:5) Invalid character \xA9 should be written as &copy;
    # 2 errors on the page

Of course, those characters aren't invalid, they're perfectly good UTF-8
characters. In some worlds, I suppose, they should be wrong, but I actually want
them in my document.

So I switched to [Test::XML], which uses a proper XML parser to validate a
document:

``` perl
ok my $res = request("http://localhost:3000/"), "Request home page";
ok $res->is_success, "Request should have succeeded";

is_well_formed_xml $res->content, "The HTML should be well-formed";
```

Cool, so now I know that my XHTML document is valid, it's time to start
examining the content and structure in more detail. Thinking fondly on
`assert_select`, I went looking for a test module that uses XPath to test an XML
document, and found [Test::XML::XPath] right in the Test::XML distribution,
which looked to be just what I wanted. So I added it to my test script and added
this line to test the content of the `<title>` tag:

``` perl
is_xpath $res->content, "/html/head/title", "Welcome!";
```

I ran the test…and waited. It took around 20 seconds for that test to run, and
then it failed!

    #   Failed test at t/view_TD.t line 25.
    #          got: ''
    #     expected: 'Welcome!'
    #   evaluating: /html/head/title
    #      against: <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
    # <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    #  <head>
    #   <title>Welcome!</title>
    #  </head>
    # </html>

No doubt the alert among my readership will spot the problem right away, but I
was at a loss. Fortunately, [Ovid] was over for dinner last week, and he pointed
out that it was due to the namespace. That is, the `xmlns` attribute of the
`<html>` element requires that one register a namespace prefix to use in the
XPath expression. He pointed me to his fork of XML::XPath, called
[Test::XHTML::XPath], in his [Escape project]. It mostly duplicates
Test::XML::XPath, but contains this crucial line of code:

``` perl
$xpc->registerNs( x => "http://www.w3.org/1999/xhtml" );
```

By registering the prefix “x” for the XHTML namespace, he's able to write tests
like this:

``` perl
is_xpath $res->content, "/x:html/x:head/x:title", "Welcome!";
```

And that works. It seems that the XPath spec [requires that one use prefixes]
when referring to elements within a namespace. Test::XML::XPath, alas, provides
no way to register a namespace prefix.

Perhaps worse is the performance problem. I discovered that if I stripped out
the DOCTYPE declaration from the XHTML before I passed it to `is_xpath`, the
test was lightning fast. Here the issue is that [XML::LibXML], used by
Test::XML::XPath, is fetching the DTD from the w3.org Web site as the test runs.
I can disable this by setting the `no_network` and `recover_silently`
XML::LibXML options, but, again, Test::XML::XPath provides no way to do so.

Add to that the fact that Test::XML::XPath has no interface for recursive
testing like `assert_select` and I was ready to write my own module. One could
perhaps update Test::XML::XPath to be more flexible, but for the fact that it
falls back on [XML::XPath] when it can't find XML::LibXML, and XML::XPath, alas,
behaves differently than XML::LibXML (it didn't choke on my lack of a namespace
prefix, for example). So if you ship an application that uses Test::XML::XPath,
tests might fail on other systems where it would use a different XPath module
than you used.

And so I have written a new test module.

Introducing [Test::XPath], your Perl module for flexibly running XPath-powered
tests on the content and structure of your XML and HTML documents. With this new
module, the test for my Catalyst application becomes:

``` perl
my $tx = Test::XPath->new( xml => $res->content, is_html => 1 );
$tx->is("/html/head/title", "Welcome", "Title should be correct" );
```

Notice how I didn't need a namespace prefix there? That's because the `is_html`
parameter coaxes XML::LibXML into using its HTML parser instead of its XML
parser. One of the side-effects of doing so is that the namespace appears to be
assumed, so I can ignore it in my tests. The HTML parser doesn't bother to fetch
the DTD, either. For tests where you really need namespaces, you'd do this:

``` perl
my $tx = Test::XPath->new(
    xml     => $res->content,
    xmlns   => { x => "http://www.w3.org/1999/xhtml" },
    options => { no_network => 1, recover_silently => 1 },
);
$tx->is("/x:html/x:head/x:title", "Welcome", "Title should be correct" );
```

Yep, you can specify XML namespace prefixes via the `xmlns` parameter, and pass
options to XML::LibXML via the `options` parameter. Here I've shut off the
network, so that XML::LibXML prevents network access, and told it to recover
silently when it tries to fetch the DTD, but fails (because, you know, it can't
access the network). Not bad, eh?

Of course, the module provides the usual array of [Test::More]-like test
methods, including `ok()`, `is()`, `like()` and `cmp_ok()`. They all work just
like in Test::More, except that the first argument must be an XPath expressions.
Some examples borrowed from the documentation:

``` perl
$tx->ok( '//foo/bar', 'Should have bar element under foo element' );
$tx->ok( 'contains(//title, "Welcome")', 'Title should "Welcome"' );

$tx->is( '/html/head/title', 'Welcome', 'Title should be welcoming' );
$tx->isnt( '/html/head/link/@type', 'hello', 'Link type should not' );

$tx->like( '/html/head/title', qr/^Foobar Inc.: .+/, 'Title context' );
$tx->unlike( '/html/head/title', qr/Error/, 'Should be no error in title' );

$tx->cmp_ok( '/html/head/title', 'eq', 'Welcome' );
$tx->cmp_ok( '//story[1]/@id', '==', 1 );
```

But the real gem is the recursive testing feature of the `ok()` test method. By
passing a code reference as the second argument, you can descend into various
parts of your XML or HTML document to test things more deeply. `ok()` will pass
if the XPath expression argument selects one or more nodes, and then it will
call the code reference for each of those nodes, passing the Test::XPath object
as the first argument. This is a bit different than `assert_select`, but I view
the reduced magic as a good thing.

For example, if you wanted to test for the presence of `<story>` elements in
your document, and to test that each such element had an incremented `id`
attribute, you'd do something like this:

``` perl
my $i = 0;
$tx->ok( '//assets/story', sub {
    shift->is('./@id', ++$i, "ID should be $i in story $i");
}, 'Should have story elements' );
```

For convenience, the XML::XPath object is also assigned to `$_` for the duration
of the call to the code reference. Either way, you can call `ok()` and pass code
references anywhere in the hierarchy. For example, to ensure that an Atom feed
has entries and that each entry has a title, a link, and a very specific author
element with name, uri, and email subnodes, you can do this:

``` perl
$tx->ok( '/feed/entry', sub {
    $_->ok( './title', 'Should have a title' );
    $_->ok( './author', sub {
        $_->is( './name',  'Larry Wall',       'Larry should be author' );
        $_->is( './uri',   'http://wall.org/', 'URI should be correct' );
        $_->is( './email', 'perl@example.com', 'Email should be right' );
    }, 'Should have author elements' );
}, 'Should have entry elements' );
```

There are a lot of core XPath functions you can use, too. For example, I'm going
to write a test for every page returned by my application to make sure that I
have the proper numbers of various tags:

``` perl
$tx->is('count(/html)',     1, 'Should have 1 html element' );
$tx->is('count(/html/head') 1, 'Should have 1 head element' );
$tx->is('count(/html/body)  1, 'Should have 1 body element' );
```

I'm going to use this module to the hilt in all my tests for HTML and XML
documents from here on in. The only thing I'm missing from `assert_select` is
that it supports CSS 2 selectors, rather than XPath expressions, and the
[implementation] offers quite a few other features including regular expression
operators for matching attributes, pseudo-classes, and other fun stuff. Still,
XPath gets me all that I need; the rest is just sugar, really. And with the
ability to [define custom XPath functions in Perl], I can live without the extra
sugar.

Maybe you'll find it useful, too.

  [`assert_select`]: http://api.rubyonrails.org/classes/ActionController/Assertions/SelectorAssertions.html#M000569
    "ActionController::Assertions::SelectorAssertions"
  [PGX]: http://www.pgexperts.com/ "PostgreSQL Experts, Inc."
  [Test::WWW::Mechanize::Catalyst]: http://search.cpan.org/perldoc?Test::WWW::Mechanize::Catalyst
    "Test::WWW::Mechanize::Catalyst on CPAN"
  [SOL]: http://www.urbandictionary.com/define.php?term=S.O.L.
    "Urban Dictionary: “S.O.L”"
  [Test::XML]: http://search.cpan.org/perldoc?Test::XML "Test::XML on CPAN"
  [Test::XML::XPath]: http://search.cpan.org/perldoc?Test::XML::XPath
    "Test::XML::XPath on CPAN"
  [Ovid]: http://use.perl.org/~Ovid/ "Ovid on use Perl;"
  [Test::XHTML::XPath]: http://github.com/Ovid/Escape-/blob/master/t/lib/Test/XHTML/XPath.pm
    "Test::XHTML::XPath on GitHub"
  [Escape project]: http://github.com/Ovid/Escape-/tree "Escape on GitHub"
  [requires that one use prefixes]: http://www.edankert.com/defaultnamespaces.html
    "edankert: “XPath and Default Namespace handling”"
  [XML::LibXML]: search.cpan.org/perldoc?XML::LibXML "XML::LibXML on CPAN"
  [XML::XPath]: http://search.cpan.org/perldoc?XML::XPath "XML::XPath on CPAN"
  [Test::XPath]: http://search.cpan.org/perldoc?Test::XPath
    "Test::XPath on CPAN"
  [Test::More]: http://search.cpan.org/perldoc?Test::More "Test::More on CPAN"
  [implementation]: http://api.rubyonrails.org/classes/HTML/Selector.html
    "Ruby HTML::Selector"
  [define custom XPath functions in Perl]: http://search.cpan.org/dist/Test-XPath/lib/Test/XPath.pm#xpc
    "Test::XPath: Define new XPath functions"
