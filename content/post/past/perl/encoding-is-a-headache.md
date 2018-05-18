--- 
date: 2011-02-19T23:15:48Z
slug: encoding-is-a-headache
title: Encoding is a Headache
aliases: [/computers/programming/perl/encoding-is-a-headache.html]
tags: [Perl, Unicode, UTF-8, Markdown, HTML]
type: post
---

<p>I have to spend <em>way</em> too much of my programming time worrying about character encodings. Take my latest module, <a href="http://github.com/theory/text-markup/">Text::Markup</a> for example. The purpose of the module is very simple: give in the name of a file, and it will figure out the markup it uses (HTML, Markdown, Textile, whatever) and return a string containing the HTML generated from the file. Simple, right?</p>

<p>But, <em>hang on.</em> Should the HTML it returns be decoded to Perl’s internal form? I’m thinking not, because the HTML itself might declare the encoding, either in a XML declaration or via something like</p>

<pre><code>&lt;meta http-equiv="Content-type" content="text/html;charset=Big5" /&gt;
</code></pre>

<p>And as you can see, it’s not UTF-8. So decoded it would be lying. So it should be encoded, right? Parsers like <a href="http://search.cpan.org/perldoc?XML::LibXML::Parser">XML::LibXML::Parser</a> are smart enough to see such declarations and decode as appropriate.</p>

<p>But wait a minute! Some markup languages, like <a href="http://daringfireball.net/projects/markdown/">Markdown</a>, don’t have XML declarations or headers. They’re HTML fragments. So there’s no wait to tell the encoding of the resulting HTML unless it’s decoded. So maybe it <em>should</em> be decoded. Or perhaps it should be decoded, and then given an XML declaration that declares the encoding as UTF-8 and encoded it as UTF-8 before returning it.</p>

<p>But, hold the phone! When reading in a markup file, should it be decoded before it’s passed to the parser? Does <a href="http://search.cpan.org/perldoc?Text::Markdown">Text::Markdown</a> know or care about encodings? And if it should be decoded, what encoding should one assume the source file uses? Unless it uses a <a href="https://en.wikipedia.org/wiki/Byte_order_mark">BOM</a>, how do you know what its encoding is?</p>

<p>Text::Markup is a dead simple idea, but virtually all of my time is going into thinking about this stuff. It drives me nuts. When will the world cease to be this way?</p>

<p>Oh, and you have answers to any of these questions, please do feel free to leave a comment. I hate having to spend so much time on this, but I’d much rather do so and get things right (or close to right) than wrong.</p>
