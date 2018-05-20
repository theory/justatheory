--- 
date: 2007-09-14T17:57:48Z
slug: ical-invite-file-location
title: Where iCal Keeps Invitations
aliases: [/computers/os/macosx/ical_invite_file_location.html]
tags: [macOS, iCal, ICS, iCalendar, VCS, caching]
type: post
---

I was fiddling with iCalendar invitations yesterday, trying to get [Sandy]'s
.ics files to import into Outlook. I got that figured out (yes!), but in the
meantime iCal started crashing on me. I was reasonable sure that it was due to a
bogus invitation file, but could not for the life of me figure out where iCal
was keeping such files. It just kept crashing on me as second or so after
starting up, every time.

I finally figured it out by quitting all my apps, moving all of the folders in
*\~/Library* to a temporary folder, and firing up iCal to see what folds it
would create. And there it was: *\~/Library/Caches/com.apple.iCal*. I quit iCal,
deleted the new folders in *\~/Library*, moved the originals back, and looked
inside the iCal caches folder to find a bunch of invitation files in the
*incoming* folder. I deleted them all and iCal fired up again without a hitch.
W00t!

So if you're having problems with iCal crashing and have a few invitations in it
and you're wondering how to get iCal to ignore them, just quit iCal, delete all
of the files in */Users/yourusername/Library/Caches/com.apple.iCal/incoming*,
and start iCal back up again.

And now I'll be able to find this information again when next I need it. :-)

  [Sandy]: http://www.iwantsandy.com/ "Meet Sandy: Your PersonalEmail Assistant"
