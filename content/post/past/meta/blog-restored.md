--- 
date: 2009-01-29T19:16:30Z
slug: blog-restored
title: Blog Restored, Google Analytics, FeedBurner
aliases: [/computers/internet/weblogs/blog-restored.html]
Tags: [Just a Theory, failure, Blosxom, Google Analytics, FeedBurner, Linux, Debian]
type: post
---

<figure><a href="https://www.flickr.com/photos/theory/3236480663/" title="My “Server Room”"><img src="https://farm4.static.flickr.com/3504/3236480663_b2d1fd08be.jpg" alt="My “Server Room”" /></a></figure>

Some of you no doubt noticed that this site was down for several days, starting
last Friday and lasting until yesterday. Sorry about that. I had a hard disk
failure of some kind on the ca. 1999 OptiPlex I was using. I've had a newer box
(ca. 2005) to move to for a while, but lacked the tuits. With this change, I was
forced to make the switch. Fortunately, a Debian install CD let me login to the
OptiPlex and access all my files, so I was able to recover everything. I even
managed to keep the file modification times the same, so feeds won't show
everything as unread (which I've seen many times when other bloggers I've known
have switched providers or recovered from some catastrophe). Unless you tried to
hit this site over the weekend or on Monday or Tuesday, you should notice no
changes at all (except speed, the new box is a *lot* faster!).

Naturally, I took advantage of this opportunity to get my blog configuration
into SVN via my [Capistrano deployment system]. Hell, none of this stuff was
even backed up before (although I did back up all my blog entries about a week
before this happened—but not comments, yow!). The new box is now properly
backing itself up and backing up the [Kineticode] server, and I can make changes
to Blosxom and configure and reboot the blog from my MBP. Yay! No more remote
editing.

I've also upgraded my “server room,” moving out the gigantic 17" CRT and putting
in the 17" flat panel screen I've had floating around. I also plugged a USB
keyboard into my KVM, so I no longer have to move keyboards around when I switch
between the Linux server and the G3 Mac server. Of course, now that I have large
disks and Time Machine running on all the other boxes in the house, we don't use
the G3 anymore. So I think we'll be donating it soon.

Another change I've made was to stop doing my own log analysis (the command-line
tools are such a PITA) and switched to [Google Analytics] and [FeedBurner] for
tracking visitors to the blog and its feeds. I've still got the old log files
around, so I can see how things have changed since before the switch to outside
analytics providers, but I'll probably just create a report from them and then
ignore them from now on. Too much work to track that stuff.

In the future, I'd like to switch from [Blosxom] to some other tool. Maybe
[Movable Type], now that it's open source. It's pretty well-regarded and written
in Perl, so I could hack it pretty easily. What I should do is avoid writing my
own Blog engine. Right? **Right?!**. In the meantime, I have other priorities,
so I'll be sticking to Bloxsom for a while.

  [Capistrano deployment system]: https://svn.kineticode.com/cap/
    "Kineticode Capistrano Environment"
  [Kineticode]: http://www.kineticode.com
    "Kineticode. Setting knowledge in motion"
  [Google Analytics]: http://www.google.com/analytics/
  [FeedBurner]: http://www.feedburner.com/
  [Blosxom]: http://www.blosxom.com
  [Movable Type]: http://www.movabletype.org/opensource/
    "Movable Type Open Source Project"
