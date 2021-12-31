--- 
date: 2009-02-18T02:01:33Z
slug: now-with-markdown
title: Now with Markdown!
aliases: [/computers/internet/weblogs/now-with-markdown.html]
tags: [Just a Theory, Markdown, Comments]
type: post
---

Lately I’ve been fiddling a bit with [Markdown], John Gruber’s minimalist plain
text markup syntax. I’ve become more and more attracted to Markdown after I’ve
had to spend some time using [Trac] and, to a lesser degree, [Twiki] and
[MediaWiki]. The plain-text markup syntax in these projects is…how shall I put
this?…*gawdawful.* Why do I hate these wiki syntaxes? Becaus they’re unnatural.
Maybe it’s just because I’m most familiar with it, but Trac’s syntax is just
completely random and inconsistent. Trying to get anything other than simple
paragraphs formatted just right is just a giant pain in the ass. Just try have
multiple paragraphs in a hierarchical bulleted list and you’ll see what I mean.
If I wanted to worry about space this much I’d hack Python! I mean, seriously,
there’s a reason I write my blog entries in pure HTML. It’s not so
user-friendly, but at least I know exactly how something will be formatted when
I’m done.

But Markdown is different. It’s syntax is almost exactly like what I’ve been
using in lain-text email messages since the mid-1990s. It’s humane in a way that
[Textile] only approaches in its inline markup (as long as you don’t use
attributes, of course). There are a few oddities, such as the definition list
syntax used by [PHP Markdown Extra] and [MultiMarkdown] is a bit unnatural. But
overall, it’s quite close to what I type anyway. I’ve been writing the [pgTAP
documentation] in Markdown, using [Discount] to generate the HTML you see on the
Web site (plus my own custom hack to create the table of contents), and it’s
just a thrill that it’s so easy to maintain: I can easily read and edit the
[README] file like any other text file, and then generate the HTML for the Web
site with a simple `make` target. It has been such a great experience that I’m
tempted to stop writing documentation in [POD]!

So in my next app, I’ll likely be making use of MultiMarkdown for the end-user
management of content. It has nearly everything I want, formatting-wise, and I
can likely get used to the few cases where its syntax seems a bit weird to me.
Plus, I can then use the generated HTML to output PDFs and other formats from
the same document. I expect it to be a dream to work with. (Oh, and thanks to
[Aristotle Pagaltzis] for patiently putting up with my questions about markdown
in private email messages; they’ll help keep me from saying anything too
embarrassing on the Markdown mail list!)

In the meantime, I’ve modified the comment system on this blog to support
Markdown. You can still use HTML in comments, same as always, as Markdown passes
HTML through unmolested. But few of you ever did that, and I was always adding
HTML tags to the comments. Now maybe I won’t have to: Markdown is so easy and
natural to use, that the vast majority of commenters will just leave paragraphs
and they’ll look beautiful.

At any rate, you now have one less reason not to leave a comment!

  [Markdown]: https://daringfireball.net/projects/markdown/
    "Daring Fireball: Markdown"
  [Trac]: http://trac.edgewall.org/ "The Trac Project"
  [Twiki]: http://www.twiki.org/
    "TWiki® - the Open Source Enterprise Wiki and Web 2.0 Application Platform"
  [MediaWiki]: http://www.mediawiki.org/wiki/MediaWiki
  [Textile]: http://www.textism.com/tools/textile/
    "Textile: A Humane Web Text Generator"
  [PHP Markdown Extra]: http://michelf.com/projects/php-markdown/extra/
  [MultiMarkdown]: http://fletcherpenney.net/multimarkdown/
  [pgTAP documentation]: http://pgtap.projects.postgresql.org/documentation.html
  [Discount]: http://www.pell.portland.or.us/~orc/Code/markdown/
    "Discount — a C implementation of the Markdown markup language"
  [README]: https://github.com/theory/pgtap/#readme "pgTAP README"
  [POD]: https://perldoc.perl.org/perlpod.html
    "perlpod - the Plain Old Documentation format"
  [Aristotle Pagaltzis]: http://plasmasturm.org/
