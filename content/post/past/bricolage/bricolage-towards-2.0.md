--- 
date: 2008-05-01T01:03:43Z
slug: towards-bricolage-2.0
title: Moving Towards Bricolage 2.0
aliases: [/bricolage/towards_2.0.html]
tags: [Bricolage, Apache, mod_perl, Ajax, MySQL]
type: post
---

Today I've finished just about over two and a half weeks of hacking on
Bricolage. It has been a couple of years since I gave it much attention, but
there was so much good stuff that other people have contributed that, since I
had a little time, it seemed worth it to give it some love. So here's a quick
list of all that I've done in the last two weeks:

-   Fixed all reported issues with Bricolage 1.10. [Scott Lanning] kindly
    [released 1.10.5] yesterday with all of those fixes.

-   I integrated the element occurrence branch that [Christian Muise] had worked
    on as his [2006 Google Summer of Code project]. Christian's project added
    support for maximum and minimum specifications for subelements in Bricolage,
    which allows administrators to define how many fields and elements can occur
    in a story or media document. All I had to do was add a few UI tweaks to
    support the new fields and their specification in the story profile, and all
    was ready to go. Oh, and I did have to go back and make the SOAP interface
    work with the feature, but the only reason it never did was lazy hacking of
    the SOAP interface (way before Christian's time). Nice work, Christian, and
    thank you for your contribution!

-   I fixed a few bugs with Arsu Andrei's port of Bricolage to MySQL, which was
    his [2006 Google Summer of Code project][1]. Arsu did a terrific job with
    the port, with only a few minor things missed that he likely could not have
    caught anyway. This work had already been merged into the trunk. Thanks
    Arsu!

-   I fixed a bunch of bugs from [Marshall Roch]'s AJAXification of Bricolage,
    carried out during his [2006 Google Summer of Code project][2]. Marshall
    actually did a lot more stuff than he'd planned, as it all went quite
    smoothly. I found only a few minor oversights that I was able to easily
    address. This work represents the single most visible change to how users
    user Bricolage since we launched the project back in 2001. Editing stories,
    in particular, is now a *lot* cleaner, with far fewer page loads. Thanks a
    million, Marshall!

-   I completed the work started by Chris Heiland of the University of
    Washington, Bothell, and [Scott Lanning] of the World Health Organization to
    port Bricolage to Apache 2. They really did most of the hard work, and I
    just spent several days integrating everything, making sure all the features
    work, and updating the installer to handle differences in configuration. I
    thought this would take me a day or two, but it actually took the better
    part of a week! So much has changed, but in truth Bricolage is now better
    for running on mod\_perl 2. Expect to see Apache 2 bet the recommended
    platform for Bricolage in a release in the near future.

-   I integrated a number of patches from Brian Smith of [Gossamer Threads] to
    allow the installer to be run as a non-root user. The key here is if the
    installer has to become the database super user, which is required for
    [ident authentication], and of course whether files are to be installed
    somewhere on the system requiring super user access. This work is not done,
    yet, as `make upgrade` and `make uninstall` are not quite there yet. But
    we're getting there, and it should be all done in time for 2.0, thanks to
    Brian.

-   I added support for a whole slew of environment variables to the installer.
    Now you can set environment variables to override default settings for
    installation parameters, such as choice of RDBMS, Apache, location of an SSL
    cert and key, whether to support SLL, and lots of other stuff, besides. This
    is all documented in the “Quick Installation Instructions” section of
    [Bric::Admin/*INSTALL*].

-   I fully tested and fixed a lot of bugs leftover from making the installer
    database- and Apache-neutral. Now all of these commands should work
    perfectly:

    -   make
    -   make cpan
    -   make test
    -   make install
    -   make devtest
    -   make clone
    -   make uninstall

-   I improved the DHTML functionality of the “Add More” widget, which is used
    to add contact information to users and contributors, rules to alert types,
    and extensions to media types. I think it's pretty slick, now! This was
    built on Marshall's AJAX work.

All of these changes have been integrated into the Bricolage [trunk] and I've
pushed out a [developer release] today. Please do check out all the goodness on
a test box and [send feedback] or [file bug reports]! There are only a couple of
other features waiting to go into Bricolage before we start the release
candidate process. And, oh yeah, tht title of this blog post? It's not a lie.
The next production release of Bricolage, based on all this work, will be
Bricolage 2.0. Enough of the features we'd planned for Bricolage lo these many
years ago are in the trunk that the new version number is warranted. I for one
will be thrilled to see 2.0 ship in time for [OSCON].

And in case it isn't already clear, *many* thanks to the [Google Summer of Code]
and participating students for the great contributions! This release would not
have been possible without them.

Also in the news today, the Bricolage server has been replaced! The new server,
which hosts the [Web site], the wiki and the instance of Bricolage used to
manage the site itself, is graciously provided by the kind folks at [Gossamer
Threads]. The server is Gossamer Threads's way of giving back to the Bricolage
community as they prepare to launch a hosted Bricolage solution. Thaks GT!

The old Bricolage server was provided by [pair Networds] for the last five
years. I'd just like to thank pair for the generous five-year loan of that box,
which helped provided infrastructure for both Bricolage *and* Kineticode. Thank
you, pair!

And with that, I'm going heads-down on some other projects. I'll pop back up to
make sure that Bricolage 2.0 is released in a few months, but otherwise, I'm on
to other things again for a while. Watch this space for details!

  [Scott Lanning]: https://linkedin.com/in/lannings/ "Scott Lanning on LinkedIn"
  [released 1.10.5]: http://perlmonks.org/?node_id=683442
    "Bricolage 1.10.5 released, 1.11 imminent"
  [Christian Muise]: http://www.haz.ca/
  [2006 Google Summer of Code project]: https://developers.google.com/open-source/gsoc/2006/#bricolage
    "Occurrence Specification"
  [1]: https://developers.google.com/open-source/gsoc/2006/#bricolage
    "Database porting SOC Proposal"
  [Marshall Roch]: http://mroch.com/ "Marshall Roch"
  [2]: https://developers.google.com/open-source/gsoc/2006/#bricolage
    "AJAX element editing SOC proposal"
  [Gossamer Threads]: http://www.gossamer-threads.com/
    "Gossamer Threads: Creative Web Engineering"
  [ident authentication]: http://www.depesz.com/index.php/2007/10/04/ident/
    "depesz: “FATAL: Ident authentication failed”, or how cool ideas get bad usage schemas"
  [Bric::Admin/*INSTALL*]: https://bricolagecms.org/docs/devel/api/?Bric::Admin
    "Bric::Admin documentation"
  [trunk]: https://github.com/bricoleurs/bricolage/ "Bricolage on GitHub"
  [developer release]: https://bricolagecms.org/news/announce/2008/04/30/bricolage-1.11.0/
    "Bricolage-Devel 1.11.0 Released"
  [send feedback]: https://bricolagecms.org/support/lists "The Bricolage Mail Lists"
  [file bug reports]: http://bugs.bricolage.cc/ "Bricolage Bug Tracker"
  [OSCON]: http://en.oreilly.com/oscon2008/public/content/home "OSCON 2008"
  [Google Summer of Code]: http://code.google.com/soc/2006/
    "Google Summer of Code 2006"
  [Web site]: https://bricolagecms.org/ "The Bricolage Web site"
  [pair Networds]: http://pair.net "pair Networks"
