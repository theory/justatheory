--- 
date: 2007-09-14T17:57:48Z
slug: ical-invite-file-location
title: Where iCal Keeps Invitations
aliases: [/computers/os/macosx/ical_invite_file_location.html]
tags: [macOS, iCal, ICS, iCalendar, VCS, caching]
---

<p>I was fiddling with iCalendar invitations yesterday, trying to
get <a href="http://www.iwantsandy.com/" title="Meet Sandy: Your PersonalEmail Assistant">Sandy</a>'s .ics files to import into Outlook. I got that
figured out (yes!), but in the meantime iCal started crashing on me. I was
reasonable sure that it was due to a bogus invitation file, but could not for
the life of me figure out where iCal was keeping such files. It just kept
crashing on me as second or so after starting up, every time.</p>

<p>I finally figured it out by quitting all my apps, moving all of the folders
in <em>~/Library</em> to a temporary folder, and firing up iCal to see what
folds it would create. And there it
was: <em>~/Library/Caches/com.apple.iCal</em>. I quit iCal, deleted the new
folders in <em>~/Library</em>, moved the originals back, and looked inside the
iCal caches folder to find a bunch of invitation files in
the <em>incoming</em> folder. I deleted them all and iCal fired up again
without a hitch. W00t!</p>

<p>So if you're having problems with iCal crashing and have a few invitations
in it and you're wondering how to get iCal to ignore them, just quit iCal,
delete all of the files
in <em>/Users/yourusername/Library/Caches/com.apple.iCal/incoming</em>, and
start iCal back up again.</p>

<p>And now I'll be able to find this information again when next I need it.
:-)</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/os/macosx/ical_invite_file_location.html">old layout</a>.</small></p>


