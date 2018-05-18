--- 
date: 2009-10-27T23:21:49Z
slug: new-pod-simple
title: Pod::Simple 3.09 Hits the CPAN
aliases: [/computers/programming/perl/modules/new-pod-simple.html]
tags: [Perl, Pod, Pod::Simple, Allison Randal]
type: post
---

<p>I spent some time over the last few days helping Allison fix bugs and close
tickets for a new version of
<a href="http://search.cpan.org/perldoc?Pod::Simple" title="Pod::Simple on CPAN">Pod::Simple</a>. I'm not sure how I convinced Allison to suddenly
dedicate her day to fixing Pod::Simple bugs and putting out a new release. She
must've had some studies or Parrot spec work she wanted to get out of or
something.</p>

<p>Either way, it's got some useful fixes and improvements:</p>

<ul>
  <li><p>The XHTML formatter now supports tables of contents (via the
  poorly-named-but-consistent-with-the-HTML-formatter <code>index</code>
  parameter).</p></li>

  <li>
    <p>You can now reformat verbatim blocks via the
    <code>strip_verbatim_indent</code> parameter/method. Because you have to
    indent verbatim blocks (code examples) with one or more spaces, you end up
    with those spaces remaining in output. Just have a look at
    <a href="http://search.cpan.org/perldoc?DBIx::Connector" title="DBix::Connector">an example</a> on search.cpan.org. See how the
    code in the Synopsis is indented? That's because it's indented in the POD.
    But maybe you don't want it to be indented in your final output. If not, you can 
    strip out leading spaces via <code>strip_verbatim_indent</code>. Pass in
    the text to strip out:</p>

    <pre>$parser-&gt;strip_verbatim_indent(&#x0027;  &#x0027;);</pre>

    <p>Or a code reference that figures out what to strip out. I'm fond of
    stripping based on the indentation of the first line, like so:</p>

    <pre>
$new-&gt;strip_verbatim_indent(sub {
      my $lines = shift;
      (my $indent = $lines-&gt;[0]) =~ s/\S.*//;
      return $indent;
  });
</pre>
  </li>

  <li><p>You can now use the <code>nocase</code> parameter to
      Pod::Simple::PullParser to tell the parser to ignore the case of POD
      blocks when searching for author, title, version, and description
      information. This is a hack that Graham has used for a while on
      search.cpan.org, in part because I nagged him about my modules, which
      don't use uppercase <code>=head1</code> text. Thanks Graham!</p></li>

  <li><p>Fixed entity encoding in the XHTML formatter. It was failing to
      encode entities everywhere except code spans and verbatim blocks. Oops.
      It also now properly encodes <code>E&lt;sol&gt;</code> and
      <code>E&lt;verbar&gt;</code>, as well as numeric entities.</p></li>

  <li><p>Multiparagraph items now work properly in the XHTML formatter, as do
      text items (definition lists).</p></li>

  <li><p>A POD tag found inside a complex POD tag (e.g., <code>C&lt;&lt;&lt;
	C&lt;foo&gt; &gt;&gt;&gt;</code>) is now properly parsed as text and
	entities instead of a tag embedded in a tag (e.g.,
        <code>&lt;foo&gt;</code>). This is in compliance
        with <a href="http://search.cpan.org/perldoc?perlpod">perlpod</a>.</p></li>
</ul>

<p>This last item is the only change I think might lead to problems. I fixed
it in response to
a <a href="https://rt.cpan.org/Public/Bug/Display.html?id=12239" title="C&lt;&lt;&lt; C&lt;&lt;foo&gt;&gt; &gt;&gt;&gt; not rendered
properly.">bug report</a> from Schwern. The relevant bit from
the <a href="http://search.cpan.org/perldoc?perlpod">perlpod</a> spec is:</p>

<blockquote>
    <p>A more readable, and perhaps more “plain” way is to use an alternate
       set of delimiters that doesn’t require a single “&gt;” to be escaped.
       With the Pod formatters that are standard starting with perl5.5.660,
       doubled angle brackets (“&lt;&lt;” and “&gt;&gt;”) may be used if and
       only if there is whitespace right after the opening delimiter and
       whitespace right before the closing delimiter! For example, the
       following will do the trick:</p>

    <pre>C&lt;&lt; $a &lt;=&gt; $b &gt;&gt;</pre>

    <p>In fact, you can use as many repeated angle‐brackets as you like so
       long as you have the same number of them in the opening and closing
       delimiters, and make sure that whitespace immediately follows the last
       ’&lt;’ of the opening delimiter, and immediately precedes the first
       “&gt;” of the closing delimiter. (The whitespace is ignored.) So the
       following will also work:</p>

    <pre>C&lt;&lt;&lt; $a &lt;=&gt; $b &gt;&gt;&gt;
C&lt;&lt;&lt;&lt;  $a &lt;=&gt; $b     &gt;&gt;&gt;&gt;</pre>

    <p>And they all mean exactly the same as this:</p>

    <pre>C&lt;$a E&lt;lt&gt;=E&lt;gt&gt; $b&gt;</pre>
</blockquote>

<p>Although all of the examples use <code>C&lt;&lt; &gt;&gt;</code>, it seems
pretty clear that it applies to all of the span tags (
<code>B&lt;&lt; &gt;&gt;</code>, <code>I&lt;&lt; &gt;&gt;</code>,
<code>F&lt;&lt; &gt;&gt;</code>, etc.). So I made the change so that tags
embedded in these “complex” tags, as comments in Pod::Simple call them, are
not treated as tags. That is, all <code>&lt;</code> and <code>&gt;</code>
characters are encoded.</p>

<p>Unfortunately, despite what the perlpod spec says (at least in my reading),
Sean had quite a few pathological examples in the tests that expected POD tags
embedded in complex POD tags to work. Here's an example:</p>

<pre>L&lt;&lt;&lt; Perl B&lt;Error E&lt;77&gt;essages&gt;|perldiag &gt;&gt;&gt;</pre>

<p>Before I fixed the bug, that was expected to be output as this XML:</p>

<pre>&lt;L to=&quot;perldiag&quot; type=&quot;pod&quot;&gt;Perl &lt;B&gt;Error Messages&lt;/B&gt;&lt;/L&gt;</pre>

<p>After the bug fix, it's:</p>

<pre>&lt;L content-implicit=&quot;yes&quot; section=&quot;Perl B&amp;#60;&amp;#60;&amp;#60; Error E&amp;#60;77&amp;#62;essages&quot; type=&quot;pod&quot;&gt;&amp;#34;Perl B&amp;#60;&amp;#60;&amp;#60; Error E&amp;#60;77&amp;#62;essages&amp;#34;&lt;/L&gt;</pre>

<p>Well, there's a lot more crap that Pod::Simple puts in there, but the
important thing to note is that neither the <code>B&lt;&gt;</code> nor
the <code>E&lt;&gt;</code> is evaluated as a POD tag inside
the <code>L&lt;&lt;&lt; &gt;&gt;&gt;</code> tag. If that seems inconsistent at
all, just remember that POD tags still work inside non-complex POD tags (that
is, when there is just one set of angle brackets:</p>

<pre>L&lt;Perl B&lt;Error E&lt;77&gt;essages&gt;|perldiag&gt;</pre>

<p>I'm pretty sure that few users were relying on POD tags working inside
complex POD tags anyway. At least I hope so. I'm currently working up a patch
for blead that updates Pod::Simple in core, so it will be interesting to see
if it breaks anyone's POD. Here's to hoping it doesn't!</p>
