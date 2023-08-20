--- 
date: 2011-01-08T21:16:35Z
slug: byline-google-apple
title: "Byline: A Case Study Apple and Google Philosophical Differences"
aliases: [/computers/os/ios/byline-google-apple.html]
tags: [iOS, Byline, Google, Google Reader, Apple, Philosophy, UI, UX]
type: post
---

My favorite iPhone feed reading app is [Byline] by [Phantom Fish]. It syncs
really well with Google Reader, so that things stay more-or-less in sync with
[NetNewsWire] on my Mac. Unlike NetNewsWire, which added Google Reader syncing
[in 2009], Byline was built with Google Reader syncing from the beginning.
Version 3.0 is [especially good]; I love the ability to swipe between posts. And
the killer feature is the archiving of all content after a sync, so that
everything loads fast — or on cross-country flights. News junkie that I am,
Byline is one of my most-used apps.

{{% figure
   src   = "edit_mode.png"
   alt   = "Byline Edit Mode"
   class = "left"
%}}

Another great feature is Byline’s edit mode. When looking at a long list of new
posts in a particular feed (for me it most often happens with the [CPAN Uploads
feed] — CPAN gets a *lot* of uploads every day!), most of which I don’t care to
read, I tap the “Edit” button to enter edit mode and then start tapping the blue
dots to mark a whole bunch of items as unread. But not all of them; I leave the
ones I’d like to read. But there’s a problem. At the top of the screen, directly
above the top read/unread toggle button, is a button labeled “Mark All as Read.”
As soon as you tap this button, Byline exits edit mode and shifts back to the
main screen.

It’s a handy shortcut if you actually want to mark all as read. But what if you
accidentally hit it, as I’ve done, oh, 20 or 30 times? Well, easy, right? Just
go back into that feed, enter edit mode again, and then go over the list again
and mark those you still want to read as unread, right? Yes, except for one
thing: if Byline syncs before you’ve had a chance to read those posts you’ve
just marked as unread, they automatically *get marked as unread again*. If
you’ve elected to include unread items in Byline (it’s a setting), you can’t
tell which ones were magically marked as unread by the sync. And if you don’t
have unread items included in Byline, those items are just *gone.*

This has annoyed me many times.

In fairness, it’s not entirely Byline’s fault. One of its design philosophies is
to use the Google API eagerly. So as soon as you’re done reading something, it’s
marked as read, whether or not the app is actively syncing to Google Reader.
This is handy because it means as soon as I’ve read something, if I sync
NetNewsWire on my desktop, it’s marked as read there, too. It minimizes the
appearance of duplication.

{{% figure
   src   = "phfish_tweet.png"
   alt   = `@phfish: "@theory I think they do it for performance reasons. It is a bit of an irritation, though."`
   link  = "https://twitter.com/phfish/status/17540435819896832"
   class = "frame"
%}}

One of the APIs it calls ASAP is Google Reader’s “Mark All as Read API call”,
and as Phantom Fish [has said], Google provides no way to un-do that call. The
result, for me at least, and certainly [other users], is the loss of unread
items.

I’ve had an interesting Twitter conversation with Phantom Fish about this issue
this morning, trying to brainstorm ways to work around it. For me, I’d like to
see either a confirmation button when I hit “Mark All as Read,” or have it not
immediately leave edit mode but turn the “Mark All as Read” button into an
“Undo” button, so that I have a chance to undo the marking all as read while
still in edit mode, before the API call gets sent to Google. Phantom Fish is
understandably reluctant to make a change such as this, however, because so many
people like and have requested the single-tap to mark all as read. There are
users who want both things. And Phantom Fish is reluctant to add a setting for
such a feature, and indeed, I also tend to favor convention over configuration.

It’s a bit of a thorny issue, but one that I think nicely highlights the
philosophical difference between Apple and Google. On iOS, I’m used to nothing I
do while in an edit mode being committed until I hit the “Done” button. Byline’s
“Mark All as Read” button short-circuits this behavior by ending the editing
without me hitting “Done,” and instantly calls the Reader API. This is very
convenient for power users (who never hit the “Mark All as Read” button
accidentally, I guess), and strongly reminds me of how Geek-oriented Google
applications like Reader are. I’m guessing such power users are Google Reader
users. I’m not, I just use it for syncing.

The emphasis of “Mark all as Read” and its underlying API is ro “get things done
in as few steps as possible.” This contrasts with the Apple philosophy exhibited
in iOS, where things should of course be done as efficiently as possible, but
where, I think, the [principle of least surprise] is emphasized. It’s handy to
mark all as read with one tap, unless you didn’t want to, in which case it’s
surprising that you can’t get the unread items back—specially since you never
told the app you were done editing. Google Reader power-user types want the
convenience of one tap. Folks like me, used to the relatively low levels of the
unexpected on iOS, want things to change only when we say we’re ready for the
change.

Anyway, I expect that Phantom Fish will work out some way to deal with this
issue. (Frankly, I’d welcome the ability to exclude certain feeds from Byine, as
NetNewsWire for iOS does, so that I don’t have to bother with some feeds on my
iPhone, but that’s a different feature request.) But I thought it was
interesting, in discussing the issue, how UI philosophical interests can
conflict. Frankly, I think that iOS apps should be more iOSy in this respect (in
all other ways Byline is *very* iOSy), but others disagree, and it makes for an
interesting conversation.

  [Byline]: http://www.phantomfish.com/byline.html
    "Phantom Fish - Byline - Google Reader on the go."
  [Phantom Fish]: http://www.phantomfish.com/
  [NetNewsWire]: http://netnewswireapp.com/mac/
  [in 2009]: http://www.macworld.com/article/142009/2009/07/netnewswire_32_beta_arrives_with_google_reader_syncing.html
    "Macworld: “NetNewsWire 3.2 beta arrives with Google Reader syncing”"
  [especially good]: http://www.macworld.com/appguide/app.html?id=87018
  [CPAN Uploads feed]: https://metacpan.org/feed/recent
  [has said]: https://twitter.com/#!/phfish/status/17147289806045184
  [other users]: https://twitter.com/#!/flynjets/status/17112345658527744
    "@flynjets: ”@phfish Bug: Mark all as read, then edit - mark item as unread, then sync. Unread items disappear every time.”"
  [principle of least surprise]: https://en.wikipedia.org/wiki/Principle_of_least_astonishment
