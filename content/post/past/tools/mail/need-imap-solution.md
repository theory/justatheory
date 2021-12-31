--- 
date: 2008-02-03T22:49:48Z
description: I've had my own IMAP server and have recently been burned by a commercial solution. So I'd like suggestions for where to go next.
slug: need-imap-solution
title: Need Suggestions for IMAP Solution and Migration
aliases: [/computers/internet/mail/need_imap_solution.html]
tags: [Tools, IMAP, Email]
type: post
---

For the last several years, I've run a [Courier-IMAP] mail server for all of the
mail for [this site], [Kineticode], [Strongrrl] and other domains. We mainly
used Mail.app on Mac OS X to communicate with the server, and it worked really
well. Today, [Julie] has over 3 GB of mail data, and I have around 1.5 GB, all
managed via IMAP.

Recently, I decided it was time to move the mail elsewhere. I've been meaning to
do it for a while, primarily because the server I was using is now used for the
[Bricolage] project, and because I never set up any spam filtering. Julie was
suddenly getting 100s of spam messages in her inbox. (It really didn't help that
she was still using Panther.) So on the advice of a good friend who had been
evaluating various mail services--and who for now shall go nameless and therefor
blameless--I moved all of our mail to [FuseMail].

At first this seamed like a pretty good solution. Our spam rates went way down,
I could set up unlimited mail lists, aliases, and forwards, and there was a
migration tool that automated moving all of our existing mail from the old IMAP
server to the new one. There were some glitches with the migration tool, but in
the end all of our mail was moved and in tact.

But that's when I started to notice the issues. To summarize:

-   Mail put into the “Sent Items” folder by Mail.app was marked as unread. This
    didn't happen on the old server, and apparently has something to so with how
    FuseMail names the sent folder: “Sent Items” rather than “Sent Messages.”
-   Mail.app is syncing *constantly*. Even once it had successfully synced the
    all of our email in all of our IMAP folders (which took *days*, it is
    syncing all the time, to the extent that I am sometimes waiting for up to a
    minute to read a mail when I double-click it, because there are all these
    other threads doing stuff and taking up all the resources. It can take
    several minutes for mail I'm sending to be *sent* (though that might be a
    delay in Mail.app copying the message to the Sent Items folder rather than
    the actual sending).
-   Deleting mail takes for*ever!* This is probably the same issue as the
    syncing problem, but when I delete 1000s of messages from my Junk mail
    folder, it runs forever, and all other activities are delayed eve further.
    It turns out to be much more efficient to empty the Junk and Deleted Items
    folders using the webmail interface. And even then, Mail.app can take a
    while to delete locally-cached items from the folder when it syncs.
-   Suddenly, Julie is getting a lot less spam. She went from several hundred
    messages showing up in her Junk mailbox a few days ago to just five on
    Friday and two yesterday--one of which was a false positive). As she had
    been expecting a message from someone that she never got, this naturally
    made her very suspicious. Where is all the spam? Is she getting all of her
    mail?
-   Since FuseMail uses a mailbox named “Sent Items” instead of the traditional
    “Sent Messages” for all sent mail, I asked if they could move the 1.8 GB of
    messages from Julie's Sent Messages to their Sent Items, since Mail.app
    would just choke on such a task. Though my request was escalated to the
    FuseMail developers, the answer came back “no.” Which I guess means that
    they're not using [Maildir], because in that case it would be a cinch, n'est
    pas?
-   Backups are not really feasible. Of course FuseMail has its own backup
    regimen, but if I ever want to move elsewhere or deal with some sort of
    catastrophic failure, I want my own backups. There is no rsync service
    available for this (remember: no maildir), so I have to use the IMAP
    interface. I've been trying for the past two weeks to get [Offline IMAP] to
    back up all of Julie's and my mail, but it keeps choking. It gets a little
    further every time I run it; eventually it will get it all. But this only
    allows me to backup those accounts for which I happen to have a password. I
    have accounts set up for a few other users, but don't have access to their
    passwords, so I can't back them up. This does not make for very good support
    for corporate backup and retention policies.
-   Mail forwarded by FuseMail has its `Return-Path` header modified. This made
    [RT] break until I hacked it to ignore that header (which is its by-default
    preferred header for identifying senders.

So I'm pretty fed up. It took me a week to get all of our mail on FuseMail, and
now I'm looking at moving it off again (once OfflineIMAP finishes a full sync).
Grr. I'm considering finding a virtual host somewhere and setting up my own IMAP
server again, but then I have the spam problem again. So then I could use a
forwarding service like [Pobox], or I can set up my own spam filtering
(something I had hoped never to get into managing myself). My old IMAP server
required very little maintenance, which was nice, but then the span filtering
stuff always seemed daunting. Don't you have to update things all the time?a

But before I go off and do something else, and unlike before I moved to
FuseMail, I wanted to get an idea what other folks are doing? Do you use IMAP?
Do you use it to manage a shitload (read: Gigabytes) of mail? Do you get very
little spam and still get all of your valid mail? Are IMAP folder maintenance
actions fast for you (in Mail.app in particular)? Are you paying a
not-unreasonable amount of money for your setup? If you answered yes to all of
these questions, please, for the love of all that is good in this world, tell me
how you do it. I'm looking for something that I don't have to work very hard to
maintain (hence my original attempt to have some company that specializes in
this stuff do it), but I'll do what I have to to make this thing right. So how
do you make it right? And if I have to run my own server, where should I host it
that won't cost me an arm and a leg?

Thanks for your help!

  [Courier-IMAP]: http://www.courier-mta.org/imap/ "Courier-IMAP Home"
  [this site]: / "Just a Theory"
  [Kineticode]: https://kineticode.com/ "Kineticode Home"
  [Strongrrl]: http://www.strongrrl.com/ "Strongrrl Home"
  [Julie]: http://www.strongrrl.com/ "Julie Wheeler is principal at Strongrrl"
  [Bricolage]: http://bricolage.cc "Bricolage CMS Home"
  [FuseMail]: http://www.fusemail.com/ "FuseMail Home"
  [Maildir]: https://en.wikipedia.org/wiki/Maildir "Maildir as described by Wikipedia"
  [Offline IMAP]: http://www.offlineimap.org "OfflineIMAP community's website"
  [RT]: http://www.bestpractical.com/rt/ "Request Tracker Home"
  [Pobox]: http://www.pobox.com/ "Pobox Home"
