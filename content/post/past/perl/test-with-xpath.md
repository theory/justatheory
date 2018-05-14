--- 
date: 2009-09-01T21:51:10Z
description: Introducing a Rails-inspired Perl module to test the structure and content of an XML or HTML document using CSS selectors.
slug: test-with-xpath
title: Test XML and HTML with XPath
aliases: [/computers/programming/perl/test-with-xpath.html]
tags: [Perl, XML, XPath, testing, unit testing, Test::XPath, HTML, XHTML]
type: post
---

<p>When I was hacking Rails projects back in 2006-2007, there was a lot of
stuff about Rails that drove me absolutely batshit
(&lt;cough&gt;ActiveRecord&lt;/cough&gt;), but there were also a (very) few
things that I really liked. One of those things was
the <a href="http://api.rubyonrails.org/classes/ActionController/Assertions/SelectorAssertions.html#M000569"
title="ActionController::Assertions::SelectorAssertions"><code>assert_select</code></a>
test method. There was a bunch of magic involved in sending a request to your
Rails app and stuffing the body someplace hidden (hrm, that sounds kind of
evil; intentional?), but then you could call <code>assert_select</code> to use
CSS selectors to test the structure and content of the document (assuming, of
course, that it was HTML or XML). For example, (to borrow from the Rails
docs), if you wanted to test that a response contains two ordered lists, each
with four list elements then you'd do something like this:</p>

<pre>
assert_select &quot;ol&quot; do |elements|
  elements.each do |element|
    assert_select element, &quot;li&quot;, 4
  end
end
</pre>

<p>What it does is select all of the <code>&lt;ol&gt;</code> elements and pass
them to the <code>do</code> block, where you can
call <code>assert_select</code> on each of them. Nice, huh? You can also
implicitly call <code>assert_select</code> on the entire array of passed
elements, like so:</p>

<pre>
assert_select &quot;ol&quot; do
  assert_select &quot;li&quot;, 8
end
</pre>

<p>Slick, right? I've always wanted to have something like this in Perl, but
until last week, I didn't really have an immediate need for it. But I've
started on a Catalyst project with my partners
at <a href="http://www.pgexperts.com/" title="PostgreSQL Experts, Inc.">PGX</a>, and of course I'm using a view to generate XHTML output. So I
started asking around for advice on proper unit testing for Catalyst views.
The answer I got was,
basically, <a href="http://search.cpan.org/perldoc?Test::WWW::Mechanize::Catalyst" title="Test::WWW::Mechanize::Catalyst on
CPAN">Test::WWW::Mechanize::Catalyst</a>. But I found it insufficient:</p>

<pre>
$mech->get_ok(&quot;/&quot;);
$mech->html_lint_ok( &quot;HTML should be valid&quot; );
$mech->title_is( &quot;Root&quot;, &quot;On the root page&quot; );
$mech->content_contains( &quot;This is the root page&quot;, &quot;Correct content&quot; );
</pre>

<p>Okay, I can check the title of the document directly, which is kind of
cool, but there's no other way to examine the structure? Really? And to check
the content, there's just <code>content_contains()</code>, which concatenates
all of the content without any tags! This is useful for certain very simple
tests, but if you want to make sure that your document is properly structured,
and the content is in all the right places,
you're <a href="http://www.urbandictionary.com/define.php?term=S.O.L." title="Urban Dictionary: “S.O.L”">SOL</a>.</p>

<p>Furthermore, the <code>html_link_ok()</code> method didn't like the Unicode
characters output by my view:</p>

<pre>
#   Failed test &#x0027;HTML should be valid (http://localhost/)&#x0027;
#   at t/view_TD.t line 30.
# HTML::Lint errors for http://localhost/
#  (4:3) Invalid character \x2019 should be written as &amp;rsquo;
#  (18:5) Invalid character \xA9 should be written as &amp;copy;
# 2 errors on the page
</pre>

<p>Of course, those characters aren't invalid, they're perfectly good UTF-8
characters. In some worlds, I suppose, they should be wrong, but I actually
want them in my document.</p>

<p>So I switched to <a href="http://search.cpan.org/perldoc?Test::XML" title="Test::XML on CPAN">Test::XML</a>, which uses a proper XML parser to
validate a document:</p>

<pre>
ok my $res = request(&quot;http://localhost:3000/&quot;), &quot;Request home page&quot;;
ok $res->is_success, &quot;Request should have succeeded&quot;;

is_well_formed_xml $res->content, &quot;The HTML should be well-formed&quot;;
</pre>

<p>Cool, so now I know that my XHTML document is valid, it's time to start
examining the content and structure in more detail. Thinking fondly on
<code>assert_select</code>, I went looking for a test module that uses XPath
to test an XML document, and
found <a href="http://search.cpan.org/perldoc?Test::XML::XPath" title="Test::XML::XPath on CPAN">Test::XML::XPath</a> right in the Test::XML
distribution, which looked to be just what I wanted. So I added it to my test
script and added this line to test the content of
the <code>&lt;title&gt;</code> tag:</p>

<pre>
is_xpath $res->content, &quot;/html/head/title&quot;, &quot;Welcome!&quot;;
</pre>

<p>I ran the test…and waited. It took around 20 seconds for that test to run,
and then it failed!</p>

<pre>
#   Failed test at t/view_TD.t line 25.
#          got: &#x0027;&#x0027;
#     expected: &#x0027;Welcome!&#x0027;
#   evaluating: /html/head/title
#      against: &lt;!DOCTYPE html PUBLIC &quot;-//W3C//DTD XHTML 1.1//EN&quot; &quot;http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd&quot;&gt;
# &lt;html xmlns=&quot;http://www.w3.org/1999/xhtml&quot; xml:lang=&quot;en&quot;&gt;
#  &lt;head&gt;
#   &lt;title&gt;Welcome!&lt;/title&gt;
#  &lt;/head&gt;
# &lt;/html&gt;
</pre>

<p>No doubt the alert among my readership will spot the problem right away,
but I was at a loss. Fortunately, <a href="http://use.perl.org/~Ovid/"
title="Ovid on use Perl;">Ovid</a> was over for dinner last week, and he
pointed out that it was due to the namespace. That is, the <code>xmlns</code>
attribute of the <code>&lt;html&gt;</code> element requires that one register
a namespace prefix to use in the XPath expression. He pointed me to his fork
of XML::XPath,
called <a href="http://github.com/Ovid/Escape-/blob/master/t/lib/Test/XHTML/XPath.pm" title="Test::XHTML::XPath on GitHub">Test::XHTML::XPath</a>, in
his <a href="http://github.com/Ovid/Escape-/tree" title="Escape on GitHub">Escape project</a>. It mostly duplicates Test::XML::XPath, but contains
this crucial line of code:</p>

<pre>
$xpc->registerNs( x => &quot;http://www.w3.org/1999/xhtml&quot; );
</pre>

<p>By registering the prefix “x” for the XHTML namespace, he's able to write
tests like this:</p>

<pre>
is_xpath $res->content, &quot;/x:html/x:head/x:title&quot;, &quot;Welcome!&quot;;
</pre>

<p>And that works. It seems that the XPath
spec <a href="http://www.edankert.com/defaultnamespaces.html" title="edankert: “XPath and Default Namespace handling”">requires that one use prefixes</a>
when referring to elements within a namespace. Test::XML::XPath, alas,
provides no way to register a namespace prefix.</p>

<p>Perhaps worse is the performance problem. I discovered that if I stripped
out the DOCTYPE declaration from the XHTML before I passed it
to <code>is_xpath</code>, the test was lightning fast. Here the issue is
that <a href="search.cpan.org/perldoc?XML::LibXML" title="XML::LibXML on CPAN">XML::LibXML</a>, used by Test::XML::XPath, is fetching the DTD from the
w3.org Web site as the test runs. I can disable this by setting
the <code>no_network</code> and <code>recover_silently</code> XML::LibXML
options, but, again, Test::XML::XPath provides no way to do so.</p>

<p>Add to that the fact that Test::XML::XPath has no interface for recursive
testing like <code>assert_select</code> and I was ready to write my own
module. One could perhaps update Test::XML::XPath to be more flexible, but for
the fact that it falls back
on <a href="http://search.cpan.org/perldoc?XML::XPath" title="XML::XPath on CPAN">XML::XPath</a> when it can't find XML::LibXML, and XML::XPath, alas,
behaves differently than XML::LibXML (it didn't choke on my lack of a
namespace prefix, for example). So if you ship an application that uses
Test::XML::XPath, tests might fail on other systems where it would use a
different XPath module than you used.</p>

<p>And so I have written a new test module.</p>

<p>Introducing <a href="http://search.cpan.org/perldoc?Test::XPath" title="Test::XPath on CPAN">Test::XPath</a>, your Perl module for flexibly
running XPath-powered tests on the content and structure of your XML and HTML
documents. With this new module, the test for my Catalyst application
becomes:</p>

<pre>
my $tx = Test::XPath->new( xml => $res->content, is_html => 1 );
$tx->is(&quot;/html/head/title&quot;, &quot;Welcome&quot;, &quot;Title should be correct&quot; );
</pre>

<p>Notice how I didn't need a namespace prefix there? That's because
the <code>is_html</code> parameter coaxes XML::LibXML into using its HTML
parser instead of its XML parser. One of the side-effects of doing so is that
the namespace appears to be assumed, so I can ignore it in my tests. The HTML
parser doesn't bother to fetch the DTD, either. For tests where you really
need namespaces, you'd do this:</p>

<pre>
my $tx = Test::XPath->new(
    xml     => $res->content,
    xmlns   => { x => &quot;http://www.w3.org/1999/xhtml&quot; },
    options => { no_network => 1, recover_silently => 1 },
);
$tx->is(&quot;/x:html/x:head/x:title&quot;, &quot;Welcome&quot;, &quot;Title should be correct&quot; );
</pre>

<p>Yep, you can specify XML namespace prefixes via the <code>xmlns</code>
parameter, and pass options to XML::LibXML via the <code>options</code>
parameter. Here I've shut off the network, so that XML::LibXML prevents
network access, and told it to recover silently when it tries to fetch the
DTD, but fails (because, you know, it can't access the network). Not bad,
eh?</p>

<p>Of course, the module provides the usual array
of <a href="http://search.cpan.org/perldoc?Test::More" title="Test::More on CPAN">Test::More</a>-like test methods, including <code>ok()</code>,
<code>is()</code>, <code>like()</code> and <code>cmp_ok()</code>. They all
work just like in Test::More, except that the first argument must be an XPath
expressions. Some examples borrowed from the documentation:</p>

<pre>
$tx->ok( &#x0027;//foo/bar&#x0027;, &#x0027;Should have bar element under foo element&#x0027; );
$tx->ok( &#x0027;contains(//title, &quot;Welcome&quot;)&#x0027;, &#x0027;Title should &quot;Welcome&quot;&#x0027; );

$tx->is( &#x0027;/html/head/title&#x0027;, &#x0027;Welcome&#x0027;, &#x0027;Title should be welcoming&#x0027; );
$tx->isnt( &#x0027;/html/head/link/@type&#x0027;, &#x0027;hello&#x0027;, &#x0027;Link type should not&#x0027; );

$tx->like( &#x0027;/html/head/title&#x0027;, qr/^Foobar Inc.: .+/, &#x0027;Title context&#x0027; );
$tx->unlike( &#x0027;/html/head/title&#x0027;, qr/Error/, &#x0027;Should be no error in title&#x0027; );

$tx->cmp_ok( &#x0027;/html/head/title&#x0027;, &#x0027;eq&#x0027;, &#x0027;Welcome&#x0027; );
$tx->cmp_ok( &#x0027;//story[1]/@id&#x0027;, &#x0027;==&#x0027;, 1 );
</pre>

<p>But the real gem is the recursive testing feature of the <code>ok()</code>
test method. By passing a code reference as the second argument, you can
descend into various parts of your XML or HTML document to test things more
deeply. <code>ok()</code> will pass if the XPath expression argument selects
one or more nodes, and then it will call the code reference for each of those
nodes, passing the Test::XPath object as the first argument. This is a bit
different than <code>assert_select</code>, but I view the reduced magic as a
good thing.</p>

<p>For example, if you wanted to test for the presence
of <code>&lt;story&gt;</code> elements in your document, and to test that each
such element had an incremented <code>id</code> attribute, you'd do something
like this:</p>

<pre>
my $i = 0;
$tx->ok( &#x0027;//assets/story&#x0027;, sub {
    shift->is(&#x0027;./@id&#x0027;, ++$i, &quot;ID should be $i in story $i&quot;);
}, &#x0027;Should have story elements&#x0027; );
</pre>

<p>For convenience, the XML::XPath object is also assigned to <code>$_</code>
for the duration of the call to the code reference. Either way, you can
call <code>ok()</code> and pass code references anywhere in the hierarchy. For
example, to ensure that an Atom feed has entries and that each entry has a
title, a link, and a very specific author element with name, uri, and email
subnodes, you can do this:</p>

<pre>
$tx->ok( &#x0027;/feed/entry&#x0027;, sub {
    $_->ok( &#x0027;./title&#x0027;, &#x0027;Should have a title&#x0027; );
    $_->ok( &#x0027;./author&#x0027;, sub {
        $_->is( &#x0027;./name&#x0027;,  &#x0027;Larry Wall&#x0027;,       &#x0027;Larry should be author&#x0027; );
        $_->is( &#x0027;./uri&#x0027;,   &#x0027;http://wall.org/&#x0027;, &#x0027;URI should be correct&#x0027; );
        $_->is( &#x0027;./email&#x0027;, &#x0027;perl@example.com&#x0027;, &#x0027;Email should be right&#x0027; );
    }, &#x0027;Should have author elements&#x0027; );
}, &#x0027;Should have entry elements&#x0027; );
</pre>

<p>There are a lot of core XPath functions you can use, too. For example,
I'm going to write a test for every page returned by my application to make
sure that I have the proper numbers of various tags:</p>

<pre>
$tx->is(&#x0027;count(/html)&#x0027;,     1, &#x0027;Should have 1 html element&#x0027; );
$tx->is(&#x0027;count(/html/head&#x0027;) 1, &#x0027;Should have 1 head element&#x0027; );
$tx->is(&#x0027;count(/html/body)  1, &#x0027;Should have 1 body element&#x0027; );
</pre>

<p>I'm going to use this module to the hilt in all my tests for HTML and XML
documents from here on in. The only thing I'm missing
from <code>assert_select</code> is that it supports CSS 2 selectors, rather
than XPath expressions, and
the <a href="http://api.rubyonrails.org/classes/HTML/Selector.html" title="Ruby HTML::Selector">implementation</a> offers quite a few other
features including regular expression operators for matching attributes,
pseudo-classes, and other fun stuff. Still, XPath gets me all that I need; the
rest is just sugar, really. And with the ability to
<a href="http://search.cpan.org/dist/Test-XPath/lib/Test/XPath.pm#xpc" title="Test::XPath: Define new XPath functions">define custom XPath functions
in Perl</a>, I can live without the extra sugar.</p>

<p>Maybe you'll find it useful, too.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/test-with-xpath.html">old layout</a>.</small></p>


