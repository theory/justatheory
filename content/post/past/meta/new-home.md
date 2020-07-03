--- 
date: 2012-04-10T05:52:00Z
slug: new-home
title: New Home
aliases: [/computers/blog/new-home.html]
tags: [Just a Theory, Blogging, Blosxom, Daring Fireball]
type: post
---

After [the Fireballing] week before last, I put aside a bit of time to rejigger
things. This blog now has a new home.

-   Moved all content to a [Linode] virtual server. No more serving from my
    crappy old desktop system behind my Comcast connection. The VPS is kind of
    skimpy on the RAM, but seems fine for my basic needs.
-   Still using [Blosxom], but all content is statically-generated.
-   Switched to [Nginx]. It's fast. Especially for a 100% static site.
-   Search is gone. No one used it, anyway. That's what [Duck Duck Go] is for.
-   Comments are gone, sort of. I removed the plugin for adding comments to
    posts. Existing comments are still shown, though.
-   Added [Disqus] commenting. The upshot is that, for the first time in years,
    one can comment on *any* post at *any* time. No more closing comments after
    two weeks.
-   Got rid of the "sociable" junk. No one needs hand-holding for sharing, and
    very few sharing sites are relevant anymore, anyway.

Oh, and I also moved [strongrrl.com], [kineticode.com], and my [PGXN mirror] to
the Linode host. They're all static, too, so everything is nice and peppy.

So that's step 1. It's enough that I can get back to posting stuff and, on the
off chance that I get Fireballed again, I *think* things will hold up (a simple
[ab] test shows pretty good throughput at about 100 requests/second at a
concurrency of 100). Over the next few months, I have other plans:

-   Throw up a new [kineticode.com]. The company has actually shut down, so I
    need to put up a new page to direct interested parties elsewhere.
-   Redesign Just a Theory. This design was okay in 2004, but never very
    forward-looking. I want to vastly simplify things. Just down to the bare
    essentials, really. Be prepared for more junk to disappear.
-   Move to a new blog engine. Blosxom is okay, but finicky. There are a lot of
    steps to publishing a post, most of them involving SCP and SSH. I just want
    to write to a directory to do stuff, and support drafts and whatnot.

That last task is the one I'm least likely to find a lot of time to work on,
though, as I am already overcommitted to [numerous][] [other][] [things], and
thinking of [new][] [stuff] all the time. But I'd really like to make things
much nicer for myself, so we'll see.

  [the Fireballing]: /computers/blog/how-not-to-withstand-a-fireballing.html
  [Linode]: http://www.linode.com/
  [Blosxom]: http://blosxom.sourceforge.net/
  [Nginx]: http://www.nginx.org/
  [Duck Duck Go]: http://duckduckgo.com/
  [Disqus]: http://disqus.com/
  [strongrrl.com]: http://www.strongrrl.com/
  [kineticode.com]: https://www.kineticode.com/
  [PGXN mirror]: http://pgxn.justatheory.com/
  [ab]: http://httpd.apache.org/docs/2.2/programs/ab.html
  [numerous]: http://www.iovation.com/
  [other]: http://pgxn.org/
  [things]: http://www.designsceneapp.com/
  [new]: http://github.com/theory/sqitch
  [stuff]: /computers/databases/postgresql/dbix-connector-and-ssi.html
