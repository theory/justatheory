--- 
date: 2011-01-20T05:52:02Z
slug: designscene-has-landed
title: DesignScene Has Landed
aliases: [/computers/apps/designscene-has-landed.html]
tags: [DesignScene, design, iPad, Objective-C, Cocoa programming, MVC, Roger Wong]
---

<p>I know I’ve been fairly quiet lately, though for good reasons. One is that I did some of my more recent blogging on the <a href="http://blog.pgxn.org/">PGXN Blog</a>, though even there it has been a while. The main reason for my silence has been my focus on coding <a href="http://www.designsceneapp.com/">DesignScene</a>, a new app for the iPad that I developed with my friend and partner <a href="http://lunarboy.com/">Roger Wong</a>.</p>

<p>Some history. Early last year I started learning Objective-C to implement an iPhone application. I’d had a great idea for a simple app to replace SMS, and so set about learning the ropes, and got relatively far in the development of the UI. (Fortunately, <a href="https://twitter.com/borange">borange</a> and <a href="https://twitter.com/atebits">atebits</a> released <a href="http://itun.es/iFV4J8">Textie</a> and I was able to kill that project.) As I worked, I started tweeting things about working with Objective-C and cocoa (both completely new experiences for me), and Roger, whom I’ve known since he and <a href="http://www.strongrrl.com/">Strongrrl</a> were in art school together in the early 90s, and who’d had an idea of his own, took notice and DMed me about a partnership.</p>

<p>Roger <a href="http://www.lunarboy.com/blog/post/introducing-designscene-app-for-ipad/">envisioned</a> an application in which he could absorb himself in all the images and feeds he normally explored as part of his everyday work of gathering inspiration as a graphic designer. His initial mockup looked great, and I was immediately drawn to the idea of an app with carefully curated content in a beautiful interface to serve a specific (and design-savvy) niche. We agreed to meet at <a href="http://www.iosdevcamp.org/">iPad Dev Camp</a> in April to see if the idea had any legs, and whether we could work well together.</p>

<img src="https://lunarboy.com/wp-content/uploads/2011/01/ds_early_comp.jpg" alt="Roger's Original Mockup" class="right" />

<p>iPad Dev Camp was a great success for us. <a href="https://twitter.com/j6y6nt">Jayant Sai</a> was especially helpful, hanging out in the “newbie room” and pointing out that Roger could work on stuff in Interface Builder while I hacked code. It made it much easier to figure out how we could collaborate (though in fairness Roger has had to wait for me to learn and code a lot of stuff). <a href="http://bill.dudney.net/roller/objc/">Bill Dudney</a> was there too, and helped us work out some of the details of animating the browser view. Good stuff. By the time it was over, we had a prototype of the UI nicely working, and even won an <a href="http://www.iosdevcamp.org/2010/04/18/quick-list-of-hackathon-winners/">honorable mention</a> at the hackathon.</p>

<p>Since then, we’ve had times when I’ve been able to give development more or less time. I spent six weeks over the summer developing the back end in my spare time from my <a href="http://www.kineticode.com/">day</a> <a href="http://www.pgexperts.com/">jobs</a>. The code there regularly harvests from all the feeds we’ve selected, finds good images, extracts summaries, and provides a single, clean feed for DesignScene to consume. This allows the app to sync very quickly, which we felt was important for optimizing the user experience.</p>

<p>And as I worked on the iPad app itself, I’ve learned a <em>lot</em> about real <a href="https://en.wikipedia.org/wiki/Model%E2%80%93View%E2%80%93Controller" title="Wikipedia: “Model-View-Controller”">MVC</a> design patterns and development, which is quite different from the stuff we web app developers tend to call MVC. And in the last few months the app really came together, as we started pulling in actual content and applying the fit and finish. And now it’s here, <a href="http://bit.ly/eIsh3J">in the App Store</a>. I’m so thrilled with how it turned out, so happy to be using it. Hell, it’s one of the few apps I’ve ever developed that I actually <em>enjoy using</em> on a day-to-day basis. You will too; go get it!</p>

<p>Oh, and just dig the awesome trailer Roger put together. It’s such a joy to work with someone who knows Photoshop and After Effects like I know Perl and SQL.</p>

<video width="640" height="360" poster="https://raw.githubusercontent.com/lunar-theory/designsceneapp.com/c199ec3d40a11a4a559d31df4a1e995ee1220b8d/res/ds_video_poster.jpg" controls>
	<source src="http://media.lunar-theory.com/DesignScene/DesignScene_Trailer_v2_640x360.mp4"  type="video/mp4" />
	<source src="http://media.lunar-theory.com/DesignScene/DesignScene_Trailer_v2_640x360.webm"  type="video/webm" />
	<source src="http://media.lunar-theory.com/DesignScene/DesignScene_Trailer_v2_640x360.ogv"  type="video/ogg" />
	<object width="640" height="385"><param name="movie" value="https://www.youtube.com/v/ya99agbX0yk?fs=1&amp;hl=en_US&amp;rel=0&amp;hd=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="https://www.youtube.com/v/ya99agbX0yk?fs=1&amp;hl=en_US&amp;rel=0&amp;hd=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="640" height="385"></embed></object>
</video>

<p>Since we launched on Tuesday, we’ve been fortunate to receive some really terrific coverage:</p>

<ul>
<li><a href="http://gizmo.do/gLfLhl" title="DesignScene for iPad Is the 21st Century Muse">Gizzmodo</a> (includes a video of the UI in action)</li>
<li><a href="http://www.macstories.net/?p=18633" title="DesignScene: An Inspiration Browser For Graphic Design">macstories</a></li>
<li><a href="http://www.padvance.com/story/new-app-a-day-designscene" title="New App a Day: DesignScene">Padvance</a></li>
<li><a href="http://shawnblanc.net/2011/01/designscene/" title="DesignScene">Shawn Blanc</a></li>
<li><a href="http://macmagazine.com.br/?p=125141" title="Precisando de inspiração? Você pode encontrá-la no seu iPad, com o DesignScene">MacMagazine</a> (Portuguese)</li>
</ul>


<p>And we’re not sitting still. I’m working through a short list of burrs and spurs that need to be polished off, and then moving on to some other great features we have planned. Stay tuned!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/apps/designscene-has-landed.html">old layout</a>.</small></p>


