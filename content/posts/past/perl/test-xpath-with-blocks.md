--- 
date: 2009-09-05T23:36:30Z
slug: test-xpath-with-blocks
title: Use Rubyish Blocks with Test::XPath
aliases: [/computers/programming/perl/modules/test-xpath-with-blocks.html]
tags: [Perl, XML, XPath, testing, unit testing, Test::XPath, HTML, XHTML, Ruby]
---

<p>Thanks to the slick <a href="http://search.cpan.org/perldoc?Devel::Declare"
title="Devel::Declare on
CPAN">Devel::Declare</a>-powered <a href="http://search.cpan.org/perldoc?PerlX::MethodCallWithBlock"
title="PerlX::MethodCallWithBlock on CPAN">PerlX::MethodCallWithBlock</a>
created by <a href="http://gugod.org/2009/08/running-in-the-compile-time.html"
title="gugod's blog: “Running in the compile time”">gugod</a>, the latest
version of <a href="http://search.cpan.org/perldoc?Test::XPath"
title="Test::XPath on CPAN">Test::XPath</a> supports Ruby-style blocks. The
Ruby version of <code>assert_select</code>, as I
mentioned <a href="/computers/programming/perl/test-with-xpath.html"
title="Test XML and HTML with XPath">previously</a>, looks like this:</p>

<pre>
assert_select &quot;ol&quot; { |elements|
  elements.each { |element|
    assert_select element, &quot;li&quot;, 4
  }
}
</pre>

<p>I've switched to the brace syntax for greater parity with Perl.
Test::XPath, meanwhile, looks like this:</p>

<pre>
my @css = qw(foo.css bar.css);
$tx->ok( &#x0027;/html/head/style&#x0027;, sub {
    my $css = shift @css;
    shift->is( &#x0027;./@src&#x0027;, $css, &quot;Style src should be $css&quot;);
}, &#x0027;Should have style&#x0027; );
</pre>

<p>But as of Test::XPath 0.13, you can now just use PerlX::MethodCallWithBlock
to pass blocks in the Rubyish way:</p>

<pre>
use PerlX::MethodCallWithBlock;
my @css = qw(foo.css bar.css);
$tx->ok( &#x0027;/html/head/style&#x0027;, &#x0027;Should have style&#x0027; ) {
    my $css = shift @css;
    shift->is( &#x0027;./@src&#x0027;, $css, &quot;Style src should be $css&quot;);
};
</pre>

<p>Pretty slick, eh? It required a single-line change to the source code. I'm
really happy with this sugar. Thanks for
the <a href="http://gugod.org/2009/08/perlx---perl-extension.html"
title="gugod's blog: “PerlX - Perl Extension”">great hack</a>, gugod!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/test-xpath-with-blocks.html">old layout</a>.</small></p>


