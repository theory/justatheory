--- 
date: 2008-05-01T01:03:43Z
slug: bricolage-towards-2.0
title: Moving Towards Bricolage 2.0
aliases: [/bricolage/towards_2.0.html]
tags: [Bricolage, Apache, mod_perl, Ajax, MySQL]
---

<p>Today I've finished just about over two and a half weeks of hacking on
Bricolage. It has been a couple of years since I gave it much attention, but
there was so much good stuff that other people have contributed that, since I
had a little time, it seemed worth it to give it some love. So here's a quick
list of all that I've done in the last two weeks:</p>

<ul>
  <li><p>Fixed all reported issues with Bricolage 1.10. <a href="http://use.perl.org/~slanning/" title="Scott Lanning on use Perl">Scott Lanning</a> kindly <a href="http://perlmonks.org/?node_id=683442" title="Bricolage 1.10.5 released, 1.11 imminent">released 1.10.5</a> yesterday with all of those fixes.</p></li>
  <li><p>I integrated the element occurrence branch that <a href="http://www.haz.ca/" title="">Christian Muise</a> had worked on as his <a href="http://code.google.com/soc/2006/bric/appinfo.html?csaid=BF87FD1CE9FF0758" title="Occurrence Specification">2006 Google Summer of Code project</a>. Christian's project added support for maximum and minimum specifications for subelements in Bricolage, which allows administrators to define how many fields and elements can occur in a story or media document. All I had to do was add a few UI tweaks to support the new fields and their specification in the story profile, and all was ready to go. Oh, and I did have to go back and make the SOAP interface work with the feature, but the only reason it never did was lazy hacking of the SOAP interface (way before Christian's time). Nice work, Christian, and thank you for your contribution!</p></li>
  <li><p>I fixed a few bugs with Arsu Andrei's port of Bricolage to MySQL, which was his <a href="http://code.google.com/soc/2006/bric/appinfo.html?csaid=61E07C2D23D20FEC" title="Database porting SOC Proposal">2006 Google Summer of Code project</a>. Arsu did a terrific job with the port, with only a few minor things missed that he likely could not have caught anyway. This work had already been merged into the trunk. Thanks Arsu!</p></li>
  <li><p>I fixed a bunch of bugs from <a href="http://mroch.com/" title="Marshall Roch">Marshall Roch</a>'s AJAXification of Bricolage, carried out during his <a href="http://code.google.com/soc/2006/bric/appinfo.html?csaid=934CEE0CC330C22A" title="AJAX element editing SOC proposal">2006 Google Summer of Code project</a>. Marshall actually did a lot more stuff than he'd planned, as it all went quite smoothly. I found only a few minor oversights that I was able to easily address. This work represents the single most visible change to how users user Bricolage since we launched the project back in 2001. Editing stories, in particular, is now a <em>lot</em> cleaner, with far fewer page loads. Thanks a million, Marshall!</p></li>
  <li><p>I completed the work started by Chris Heiland of the University of Washington, Bothell, and <a href="http://use.perl.org/~slanning/" title="Scott Lanning on use Perl">Scott Lanning</a> of the World Health Organization to port Bricolage to Apache 2. They really did most of the hard work, and I just spent several days integrating everything, making sure all the features work, and updating the installer to handle differences in configuration. I thought this would take me a day or two, but it actually took the better part of a week! So much has changed, but in truth Bricolage is now better for running on mod_perl 2. Expect to see Apache 2 bet the recommended platform for Bricolage in a release in the near future.</p></li>
  <li><p>I integrated a number of patches from Brian Smith of <a href="http://www.gossamer-threads.com/" title="Gossamer Threads: Creative Web Engineering">Gossamer Threads</a> to allow the installer to be run as a non-root user. The key here is if the installer has to become the database super user, which is required for <a href="http://www.depesz.com/index.php/2007/10/04/ident/" title="depesz: “FATAL: Ident authentication failed”, or how cool ideas get bad usage schemas">ident authentication</a>, and of course whether files are to be installed somewhere on the system requiring super user access. This work is not done, yet, as <code>make upgrade</code> and <code>make uninstall</code> are not quite there yet. But we're getting there, and it should be all done in time for 2.0, thanks to Brian.</p></li>
  <li><p>I added support for a whole slew of environment variables to the installer. Now you can set environment variables to override default settings for installation parameters, such as choice of RDBMS, Apache, location of an SSL cert and key, whether to support SLL, and lots of other stuff, besides. This is all documented in the <q>Quick Installation Instructions</q> section of <a href="http://www.bricolage.cc/docs/devel/api/?Bric::Admin" title="Bric::Admin documentation">Bric::Admin/<em>INSTALL</em></a>.</p></li>
  <li><p>I fully tested and fixed a lot of bugs leftover from making the installer database- and Apache-neutral. Now all of these commands should work perfectly:</p>
    <ul>
      <li>make</li>
      <li>make cpan</li>
      <li>make test</li>
      <li>make install</li>
      <li>make devtest</li>
      <li>make clone</li>
      <li>make uninstall</li>
    </ul>
  </li>
  <li><p>I improved the DHTML functionality of the <q>Add More</q> widget, which is used to add contact information to users and contributors, rules to alert types, and extensions to media types. I think it's pretty slick, now! This was built on Marshall's AJAX work.</p></li>
</ul>

<p>All of these changes have been integrated into the Bricolage <a href="http://svn.bricolage.cc/bricolage/trunk/" title="Bricolage in Subversion">trunk</a> and I've pushed out a <a href="http://bricolage.cc/news/announce/2008/04/30/bricolage-1.11.0/" title="Bricolage-Devel 1.11.0 Released">developer release</a> today. Please do check out all the goodness on a test box and <a href="http://bricolage.cc/support/lists" title="The Bricolage Mail Lists">send feedback</a> or <a href="http://bugs.bricolage.cc/" title="Bricolage Bug Tracker">file bug reports</a>! There are only a couple of other features waiting to go into Bricolage before we start the release candidate process. And, oh yeah, tht title of this blog post? It's not a lie. The next production release of Bricolage, based on all this work, will be Bricolage 2.0. Enough of the features we'd planned for Bricolage lo these many years ago are in the trunk that the new version number is warranted. I for one will be thrilled to see 2.0 ship in time for <a href="http://en.oreilly.com/oscon2008/public/content/home" title="OSCON 2008">OSCON</a>.</p>

<p>And in case it isn't already clear, <em>many</em> thanks to the <a href="http://code.google.com/soc/2006/" title="Google Summer of Code 2006">Google Summer of Code</a> and participating students for the great contributions! This release would not have been possible without them.</p>

<p>Also in the news today, the Bricolage server has been replaced! The new server, which hosts the <a href="http://www.bricolage.cc/" title="The Bricolage Web site">Web site</a>, the <a href="http://wiki.bricolage.cc/" title="The Bricolage Wiki">wiki</a> and the instance of Bricolage used to manage the site itself, is graciously provided by the kind folks at <a href="http://www.gossamer-threads.com/" title="Gossamer Threads: Creative Web Engineering">Gossamer Threads</a>. The server is Gossamer Threads's way of giving back to the Bricolage community as they prepare to launch a hosted Bricolage solution. Thaks GT!</p>

<p>The old Bricolage server was provided by <a href="http://pair.net" title="pair Networks">pair Networds</a> for the last five years. I'd just like to thank pair for the generous five-year loan of that box, which helped provided infrastructure for both Bricolage <em>and</em> Kineticode. Thank you, pair!</p>

<p>And with that, I'm going heads-down on some other projects. I'll pop back up to make sure that Bricolage 2.0 is released in a few months, but otherwise, I'm on to other things again for a while. Watch this space for details!</p>




<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/towards_2.0.html">old layout</a>.</small></p>


