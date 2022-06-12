--- 
date: 2011-01-20T05:52:02Z
slug: designscene-has-landed
title: DesignScene Has Landed
aliases: [/computers/apps/designscene-has-landed.html]
tags: [DesignScene, Design, iPad, Objective-C, Cocoa programming, MVC, Roger Wong]
type: post
image:
  src: ds_early_comp.jpg
  alt: Roger’s Original Mockup
  class: right
  metaOnly: true
---

I know I’ve been fairly quiet lately, though for good reasons. One is that I did
some of my more recent blogging on the [PGXN Blog], though even there it has
been a while. The main reason for my silence has been my focus on coding
[DesignScene], a new app for the iPad that I developed with my friend and
partner [Roger Wong].

Some history. Early last year I started learning Objective-C to implement an
iPhone application. I’d had a great idea for a simple app to replace SMS, and so
set about learning the ropes, and got relatively far in the development of the
UI. (Fortunately, [borange] and [atebits] released [Textie] and I was able to
kill that project.) As I worked, I started tweeting things about working with
Objective-C and cocoa (both completely new experiences for me), and Roger, whom
I’ve known since he and [Strongrrl] were in art school together in the early
90s, and who’d had an idea of his own, took notice and DMed me about a
partnership.

Roger [envisioned] an application in which he could absorb himself in all the
images and feeds he normally explored as part of his everyday work of gathering
inspiration as a graphic designer. His initial mockup looked great, and I was
immediately drawn to the idea of an app with carefully curated content in a
beautiful interface to serve a specific (and design-savvy) niche. We agreed to
meet at [iPad Dev Camp] in April to see if the idea had any legs, and whether we
could work well together.

{{% figure
  src   = "ds_early_comp.jpg"
  alt   = "Roger’s Original Mockup"
  class = "right"
%}}

iPad Dev Camp was a great success for us. [Jayant Sai] was especially helpful,
hanging out in the “newbie room” and pointing out that Roger could work on stuff
in Interface Builder while I hacked code. It made it much easier to figure out
how we could collaborate (though in fairness Roger has had to wait for me to
learn and code a lot of stuff). [Bill Dudney] was there too, and helped us work
out some of the details of animating the browser view. Good stuff. By the time
it was over, we had a prototype of the UI nicely working, and even won an
[honorable mention] at the hackathon.

Since then, we’ve had times when I’ve been able to give development more or less
time. I spent six weeks over the summer developing the back end in my spare time
from my [day][] [jobs]. The code there regularly harvests from all the feeds
we’ve selected, finds good images, extracts summaries, and provides a single,
clean feed for DesignScene to consume. This allows the app to sync very quickly,
which we felt was important for optimizing the user experience.

And as I worked on the iPad app itself, I’ve learned a *lot* about real [MVC]
design patterns and development, which is quite different from the stuff we web
app developers tend to call MVC. And in the last few months the app really came
together, as we started pulling in actual content and applying the fit and
finish. And now it’s here, [in the App Store]. I’m so thrilled with how it
turned out, so happy to be using it. Hell, it’s one of the few apps I’ve ever
developed that I actually *enjoy using* on a day-to-day basis. You will too; go
get it!

Oh, and just dig the awesome trailer Roger put together. It’s such a joy to work
with someone who knows Photoshop and After Effects like I know Perl and SQL.

<video width="640" height="360" poster="https://raw.githubusercontent.com/lunar-theory/designsceneapp.com/c199ec3d40a11a4a559d31df4a1e995ee1220b8d/res/ds_video_poster.jpg" controls>
	<source src="https://media.lunar-theory.com/DesignScene/DesignScene_Trailer_v2_640x360.mp4" type="video/mp4" />
	<source src="https://media.lunar-theory.com/DesignScene/DesignScene_Trailer_v2_640x360.webm" type="video/webm" />
	<source src="https://media.lunar-theory.com/DesignScene/DesignScene_Trailer_v2_640x360.ogv" type="video/ogg" />
</video>

Since we launched on Tuesday, we’ve been fortunate to receive some really
terrific coverage:

-   [Gizzmodo][] (includes a video of the UI in action)
-   [macstories]
-   [Padvance]
-   [Shawn Blanc]
-   [MacMagazine][] (Portuguese)

And we’re not sitting still. I’m working through a short list of burrs and spurs
that need to be polished off, and then moving on to some other great features we
have planned. Stay tuned!

  [PGXN Blog]: https://blog.pgxn.org/
  [DesignScene]: http://www.designsceneapp.com/
  [Roger Wong]: https://rogerwong.me/
  [borange]: https://twitter.com/borange
  [atebits]: https://twitter.com/atebits
  [Textie]: https://www.textie.me
  [Strongrrl]: http://www.strongrrl.com/
  [envisioned]: https://web.archive.org/web/20110131000632/http://www.lunarboy.com/blog/post/introducing-designscene-app-for-ipad/
  [iPad Dev Camp]: http://www.iosdevcamp.org/
  [Jayant Sai]: https://twitter.com/j6y6nt
  [Bill Dudney]: http://bill.dudney.net/roller/objc/
  [honorable mention]: http://www.iosdevcamp.org/2010/04/18/quick-list-of-hackathon-winners/
  [day]: https://kineticode.com/
  [jobs]: https://www.pgexperts.com/
  [MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93View%E2%80%93Controller
    "Wikipedia: “Model-View-Controller”"
  [in the App Store]: https://web.archive.org/web/20110125072110/http://itunes.apple.com/us/app/designscene/id412753716?mt=8
  [Gizzmodo]: https://www.gizmodo.com.au/2011/01/designscene-for-ipad-is-the-21st-century-muse/
    "DesignScene for iPad Is the 21st Century Muse"
  [macstories]: https://www.macstories.net/reviews/designscene-an-inspiration-browser-for-graphic-designers/
    "DesignScene: An Inspiration Browser For Graphic Design"
  [Padvance]: http://www.padvance.com/story/new-app-a-day-designscene
    "New App a Day: DesignScene"
  [Shawn Blanc]: https://shawnblanc.net/2011/01/designscene/ "DesignScene"
  [MacMagazine]: https://macmagazine.com.br/post/2011/01/19/precisando-de-inspiracao-voce-pode-encontra-la-no-seu-ipad-com-o-designscene/
    "Precisando de inspiração? Você pode encontrá-la no seu iPad, com o DesignScene"
