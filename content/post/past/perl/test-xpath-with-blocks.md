--- 
date: 2009-09-05T23:36:30Z
slug: test-xpath-with-blocks
title: Use Rubyish Blocks with Test::XPath
aliases: [/computers/programming/perl/modules/test-xpath-with-blocks.html]
tags: [Perl, XML, XPath, testing, unit testing, Test::XPath, HTML, XHTML, Ruby]
type: post
---

Thanks to the slick [Devel::Declare]-powered [PerlX::MethodCallWithBlock]
created by [gugod], the latest version of [Test::XPath] supports Ruby-style
blocks. The Ruby version of `assert_select`, as I mentioned [previously], looks
like this:

``` ruby
assert_select "ol" { |elements|
  elements.each { |element|
    assert_select element, "li", 4
  }
}
```

I've switched to the brace syntax for greater parity with Perl. Test::XPath,
meanwhile, looks like this:

``` perl
my @css = qw(foo.css bar.css);
$tx->ok( '/html/head/style', sub {
    my $css = shift @css;
    shift->is( './@src', $css, "Style src should be $css");
}, 'Should have style' );
```

But as of Test::XPath 0.13, you can now just use PerlX::MethodCallWithBlock to
pass blocks in the Rubyish way:

``` perl
use PerlX::MethodCallWithBlock;
my @css = qw(foo.css bar.css);
$tx->ok( '/html/head/style', 'Should have style' ) {
    my $css = shift @css;
    shift->is( './@src', $css, "Style src should be $css");
};
```

Pretty slick, eh? It required a single-line change to the source code. I'm
really happy with this sugar. Thanks for the [great hack], gugod!

  [Devel::Declare]: http://search.cpan.org/perldoc?Devel::Declare
    "Devel::Declare on CPAN"
  [PerlX::MethodCallWithBlock]: http://search.cpan.org/perldoc?PerlX::MethodCallWithBlock
    "PerlX::MethodCallWithBlock on CPAN"
  [gugod]: http://gugod.org/2009/08/running-in-the-compile-time.html
    "gugod's blog: “Running in the compile time”"
  [Test::XPath]: http://search.cpan.org/perldoc?Test::XPath
    "Test::XPath on CPAN"
  [previously]: /computers/programming/perl/test-with-xpath.html
    "Test XML and HTML with XPath"
  [great hack]: http://gugod.org/2009/08/perlx---perl-extension.html
    "gugod's blog: “PerlX - Perl Extension”"
