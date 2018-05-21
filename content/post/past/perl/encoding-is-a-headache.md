--- 
date: 2011-02-19T23:15:48Z
slug: encoding-is-a-headache
title: Encoding is a Headache
aliases: [/computers/programming/perl/encoding-is-a-headache.html]
tags: [Perl, Unicode, UTF-8, Markdown, HTML]
type: post
---

I have to spend *way* too much of my programming time worrying about character
encodings. Take my latest module, [Text::Markup] for example. The purpose of the
module is very simple: give in the name of a file, and it will figure out the
markup it uses (HTML, Markdown, Textile, whatever) and return a string
containing the HTML generated from the file. Simple, right?

But, *hang on.* Should the HTML it returns be decoded to Perl’s internal form?
I’m thinking not, because the HTML itself might declare the encoding, either in
a XML declaration or via something like

``` html
<meta http-equiv="Content-type" content="text/html;charset=Big5" />
```

And as you can see, it’s not UTF-8. So decoded it would be lying. So it should
be encoded, right? Parsers like [XML::LibXML::Parser] are smart enough to see
such declarations and decode as appropriate.

But wait a minute! Some markup languages, like [Markdown], don’t have XML
declarations or headers. They’re HTML fragments. So there’s no wait to tell the
encoding of the resulting HTML unless it’s decoded. So maybe it *should* be
decoded. Or perhaps it should be decoded, and then given an XML declaration that
declares the encoding as UTF-8 and encoded it as UTF-8 before returning it.

But, hold the phone! When reading in a markup file, should it be decoded before
it’s passed to the parser? Does [Text::Markdown] know or care about encodings?
And if it should be decoded, what encoding should one assume the source file
uses? Unless it uses a [BOM], how do you know what its encoding is?

Text::Markup is a dead simple idea, but virtually all of my time is going into
thinking about this stuff. It drives me nuts. When will the world cease to be
this way?

Oh, and you have answers to any of these questions, please do feel free to leave
a comment. I hate having to spend so much time on this, but I’d much rather do
so and get things right (or close to right) than wrong.

  [Text::Markup]: http://github.com/theory/text-markup/
  [XML::LibXML::Parser]: http://search.cpan.org/perldoc?XML::LibXML::Parser
  [Markdown]: http://daringfireball.net/projects/markdown/
  [Text::Markdown]: http://search.cpan.org/perldoc?Text::Markdown
  [BOM]: https://en.wikipedia.org/wiki/Byte_order_mark
