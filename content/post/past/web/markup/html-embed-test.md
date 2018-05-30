--- 
date: 2009-03-06T05:59:55Z
slug: html-embed-test
title: Embed HTML on Your Site
aliases: [/computers/internet/html/embed-test.html]
tags: [Web, Blogrolls, HTML, XHTML]
type: post
---

If you're a regular visitor to my blog (and who could blame you?), you likely
have noticed a few changes recently. In addition to adding the [sociable links]
a couple days ago, I've also been adding bits of embedded JavaScript in the
right column displaying my three most recent Tweets and my three most recent
Delicious bookmarks. These work reasonably well: I just embed `<script>` tags
with the appropriate stuff, then style the HTML that they deliver.

Tonight I was talking to [Skud] about embedding like this. It turns out that
some folks were getting a big blank area when they viewed a [blog entry] on her
site in RSS readers and the like, they sometimes just saw a big blank area where
there was supposed to be a list of books. She was looking for examples of sites
that provided HTML snippets that people could cut-n-paste into their blog
entries, so that they can avoid this problem, or use it in places that disallow
JavaScript embedding, such as [LiveJournal]. I had no examples for her, but it
suddenly occurred to me: Why not embed a link to an HTML URL that serves a
snippet of HTML, rather than a bit of JavaScript that uses the `document` object
to write HTML?

A quick Googling and I found a page a [great article] about the `<object>`
element. It was intended as a general replacement for the `<img>` and `<applet>`
elements, although tht really hasn't happened. But what you *can* do is embed
HTML with it. Here's a quick example:

<style type="text/css">code.embedded { background: green; }</style>
<object data="/code/testembed.html" type="text/html" style="background: lightblue; width: 100%; border: 1px dotted darkblue;" id="testembed">
  <p>If you can see this, then the <code>&lt;object&gt;</code> tag doesn't
  work in your browser. :-(</p>
</object>

Hopefully you can see the embedded HTML above. I've styled it with a light blue
background and dark blue dotted border, so it stands out. That styling is in the
`<object>` tag, BTW, not in the HTML loaded from the snippet. I'm sure I could
figure out how to add `<param>` tags that would tell it to include various
styles, too, since it appears that CSS I have in this page has no effect on the
content of the object (I have some CSS to make the `<code>` tag have a green
background, but for me at least, it has no effect.

So why isn't this more common? It [seems to work well] in a lot of browsers.
Would you use it? What are the downsides?

  [sociable links]: /computers/internet/weblogs/blosxom/sociable/introducing-sociable.html
    "Sociable Plugin for Blosxom"
  [Skud]: http://infotrope.net/blog/ "Infotropism Kirrily Robert’s blog"
  [blog entry]: http://infotrope.net/blog/2009/03/05/books-read-february-2009/
    "Infotropism: Books read, February 2009"
  [LiveJournal]: http://www.livejournal.com/
  [great article]: http://joliclic.free.fr/html/object-tag/en/
    "What is the HTML object tag"
  [seems to work well]: http://joliclic.free.fr/html/object-tag/en/object-results.php
    "tests: object tag"
