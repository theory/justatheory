--- 
date: 2009-03-06T05:59:55Z
slug: html-embed-test
title: Embed HTML on Your Site
aliases: [/computers/internet/html/embed-test.html]
tags: [Web, blogrolls, HTML, XHTML]
---

<p>If you're a regular visitor to my blog (and who could blame you?), you
likely have noticed a few changes recently. In addition to adding the
<a href="/computers/internet/weblogs/blosxom/sociable/introducing-sociable.html"
title="Sociable Plugin for Blosxom">sociable links</a> a couple days ago, I've
also been adding bits of embedded JavaScript in the right column displaying my
three most recent Tweets and my three most recent Delicious bookmarks. These
work reasonably well: I just embed <code>&lt;script&gt;</code> tags with the
appropriate stuff, then style the HTML that they deliver.</p>

<p>Tonight I was talking to <a href="http://infotrope.net/blog/" title="Infotropism Kirrily Robert’s blog">Skud</a> about embedding like this.
It turns out that some folks were getting a big blank area when they viewed
a <a href="http://infotrope.net/blog/2009/03/05/books-read-february-2009/" title="Infotropism: Books read, February 2009">blog entry</a> on her site in
RSS readers and the like, they sometimes just saw a big blank area where there
was supposed to be a list of books. She was looking for examples of sites that
provided HTML snippets that people could cut-n-paste into their blog entries,
so that they can avoid this problem, or use it in places that disallow
JavaScript embedding, such as
<a href="http://www.livejournal.com/">LiveJournal</a>. I had no examples for
her, but it suddenly occurred to me: Why not embed a link to an HTML URL that
serves a snippet of HTML, rather than a bit of JavaScript that uses
the <code>document</code> object to write HTML?</p>

<p>A quick Googling and I found a page
a <a href="http://joliclic.free.fr/html/object-tag/en/" title="What is the HTML object tag">great article</a> about the <code>&lt;object&gt;</code> element.
It was intended as a general replacement for the <code>&lt;img&gt;</code>
and <code>&lt;applet&gt;</code> elements, although tht really hasn't happened.
But what you <em>can</em> do is embed HTML with it. Here's a quick example:</p>

<style type="text/css">code.embedded { background: green; }</style>
<object data="/computers/internet/html/testembed.html" type="text/html" style="background: lightblue; width: 100%; border: 1px dotted darkblue;" id="testembed">
  <p>If you can't see this, then the <code>&lt;object&gt;</code> tag doesn't
  work in your browser. :-(</p>
</object>

<p>Hopefully you can see the embedded HTML above. I've styled it with a light
blue background and dark blue dotted border, so it stands out. That styling is
in the <code>&lt;object&gt;</code> tag, BTW, not in the HTML loaded from the
snippet. I'm sure I could figure out how to add <code>&lt;param&gt;</code>
tags that would tell it to include various styles, too, since it appears that
CSS I have in this page has no effect on the content of the object (I have
some CSS to make the <code>&lt;code&gt;</code> tag have a green background,
but for me at least, it has no effect.</p>

<p>So why isn't this more common? It
<a href="http://joliclic.free.fr/html/object-tag/en/object-results.php"
title="tests: object tag">seems to work well</a> in a lot of browsers. Would
you use it? What are the downsides?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/internet/html/embed-test.html">old layout</a>.</small></p>


