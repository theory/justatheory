--- 
date: 2006-02-06T18:15:55Z
slug: online-voting-security
title: How Does One Protect Online Ballot Box Stuffing?
aliases: [/computers/security/online_voting_security.html]
tags: [security, voting, elections, ballot box stuffing]
type: post
---

I need to set up an online voting system. It needs to be more robust than a
simple polling system, in order, primarily, to prevent ballot box stuffing. Of
course I realize that it's impossible to prevent ballot box stuffing by a
determined individual, but what I want to prevent is scripted attacks and denial
of service attacks. The features I've come up with so far to prevent attacks
are:

-   Require site registration. You must be a registered user of the site in
    order to vote in an election, and of course, you can vote only once.
-   Ignore votes when cookies are disabled, although make it look like a
    successful submission.
-   Update result statistics periodically, rather than after every vote. This
    will make it difficult for an exploiter to tell if his votes are being
    counted.
-   Use a [CAPTCHA] to prevent scripted voting.
-   Send a new digest hidden in every request that must be sent back and checked
    against a server-side session in order to prevent “curl” attacks.
-   Log IP addresses for all votes. These can be checked later if ballot box
    stuffing is suspected (though we'll have to ignore it if many users are
    behind a proxy server).

Of course someone behind a well-known proxy server who wants to repeatedly
create a new user account using different email addresses and deleting his
cookies before every vote could do *some* ballot box stuffing, but I think that
the above features will minimize the risk. But I'm sure I'm forgetting things.
What other steps should I take?

Leave a comment to let me know.

  [CAPTCHA]: https://en.wikipedia.org/wiki/Captcha "Wikipedia explains CAPTCHA"
