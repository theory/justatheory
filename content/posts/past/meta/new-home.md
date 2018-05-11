--- 
date: 2012-04-10T05:52:00Z
slug: new-home
title: New Home
aliases: [/computers/blog/new-home.html]
tags: [Meta, blogging, Blosxom, Daring Fireball]
---

<p>After
<a href="/computers/blog/how-not-to-withstand-a-fireballing.html">the Fireballing</a>
week before last, I put aside a bit of time to rejigger things. This blog
now has a new home.</p>

<ul>
<li>Moved all content to a <a href="http://www.linode.com/">Linode</a> virtual server. No more serving from my crappy old desktop system behind my Comcast connection. The VPS is kind of skimpy on the RAM, but seems fine for my basic needs.</li>
<li>Still using <a href="http://blosxom.sourceforge.net/">Blosxom</a>, but all content is statically-generated.</li>
<li>Switched to <a href="http://www.nginx.org/">Nginx</a>. It's fast. Especially for a 100% static site.</li>
<li>Search is gone. No one used it, anyway. That's what <a href="http://duckduckgo.com/">Duck Duck Go</a> is for.</li>
<li>Comments are gone, sort of. I removed the plugin for adding comments to posts. Existing comments are still shown, though.</li>
<li>Added <a href="http://disqus.com/">Disqus</a> commenting. The upshot is that, for the first time in years, one can comment on <em>any</em> post at <em>any</em> time. No more closing comments after two weeks.</li>
<li>Got rid of the "sociable" junk. No one needs hand-holding for sharing, and very few sharing sites are relevant anymore, anyway.</li>
</ul>

<p>Oh, and I also moved <a href="http://www.strongrrl.com/">strongrrl.com</a>, <a href="http://www.kineticode.com/">kineticode.com</a>, and my <a href="http://pgxn.justatheory.com/">PGXN mirror</a> to the Linode host. They're all static, too, so everything is nice and peppy.</p>

<p>So that's step 1. It's enough that I can get back to posting stuff and, on the off chance that I get Fireballed again, I <em>think</em> things will hold up (a simple <a href="http://httpd.apache.org/docs/2.2/programs/ab.html">ab</a> test shows pretty good throughput at about 100 requests/second at a concurrency of 100). Over the next few months, I have other plans:</p>

<ul>
<li>Throw up a new <a href="http://www.kineticode.com/">kineticode.com</a>. The company has actually shut down, so I need to put up a new page to direct interested parties elsewhere.</li>
<li>Redesign Just a Theory. This design was okay in 2004, but never very forward-looking. I want to vastly simplify things. Just down to the bare essentials, really. Be prepared for more junk to disappear.</li>
<li>Move to a new blog engine. Blosxom is okay, but finicky. There are a lot of steps to publishing a post, most of them involving SCP and SSH. I just want to write to a directory to do stuff, and support drafts and whatnot.</li>
</ul>

<p>That last task is the one I'm least likely to find a lot of time to work on, though, as I am already overcommitted to <a href="http://www.iovation.com/">numerous</a> <a href="http://pgxn.org/">other</a> <a href="http://www.designsceneapp.com/">things</a>, and thinking of <a href="http://github.com/theory/sqitch">new</a> <a href="/computers/databases/postgresql/dbix-connector-and-ssi.html">stuff</a> all the time. But I'd really like to make things much nicer for myself, so we'll see.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/blog/new-home.html">old layout</a>.</small></p>


