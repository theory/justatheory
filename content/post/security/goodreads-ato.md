---
title: How Goodreads Deleted My Account
slug: goodreads-ato
date: 2022-03-05T23:45:49Z
lastMod: 2022-05-22T21:36:50Z
description: Someone stole my Goodreads account; the company failed to recover it, then deleted it. It was all too preventable.
tags: [Security, Goodreads, Account Takeover, Fail]
type: post
---

On 12:31pm on February 2, I got an email from [Goodreads]:

> Hi David,
>
> This is a notice to let you know that the password for your account has been
> changed.
>
> If you did not recently reset or change your password, it is possible that
> your account has been compromised. If you have any questions about this,
> please reach out to us using our Contact Us form. Alternatively, visit
> Goodreads Help.

Since I had not changed my password, I immediately hit the "Goodreads Help" link
(not the one in the email, mind you) and reported the issue. At 2:40pm I wrote:

> I got an email saying my password had been changed. I did not change my
> password. I went to the site and tried go log in, but the login failed. I
> tried to reset my password, but got an email saying my email is not in the
> system. 
>
> So someone has compromised the account. Please help me recover it. 

I also tried to log in, but failed. I tried the app on my phone, and had been
logged out there, too.

The following day at 11:53am, Goodreads replied asking me for a link to my
account. I had no idea what the link to my account was, and since I assumed that
all my information had been changed by the attackers, I didn't think to search
for it.

Three minutes later, at 11:56, I replied:

> No, I always just used the domain and logged in, or the iOS app. I’ve attached
> the last update email I got around 12:30 EST yesterday, in case that helps.
> I’ve also attached the email telling me my password had been changed around
> 2:30 yesterday. That was when I became aware of the fact that the account was
> taken over.

A day and half later, at 5:46pm on the 4th, Goodreads support replied to say
that they needed the URL in order to find it and investigate and asked if I
remembered the name on the account. This seemed odd to me, since until at least
the February 2nd it was associated with my name and email address.

I replied 3 minutes later at 5:49:

> The name is mine. The username maybe? I’m usually “theory”, “itheory”, or
> “justatheory”, though if I set up a username for Goodreads it was *ages* ago
> and never really came up. Where could I find an account link?
>
> Over the weekend I can log into Amazon and Facebook and see if I see any old
> integration messages.

The following day was Saturday the fifth. I logged into Facebook to see what I
could find. I had deleted the link to Goodreads in 2018 (when I also ceased to
use Facebook), but there was still a record of it, so I sent the link ID
Facebook had. I also pointed out that my email address had been associated with
the account for many years until it was changed on Feb 2. Couldn't they find it
in the history for the account?

I still didn't know the link to my account, but forwarded the marketing redirect
links that had been in the password change email, as well as an earlier email
with a status on my reading activity.

After I sent the email, I realized I could ask some friends who I knew followed
me on Goodreads to see if they could dig up the link. Within a few minutes my
pal Travis had sent it to me,
`https://www.goodreads.com/user/show/7346356-david-wheeler`. I was surprised,
when I opened it, to see all my information there as I'd left it, no changes. I
still could not log in, however. I immediately sent the link to Goodreads
support (at 12:41pm).

That was the fifth. I did no hear back again until February 9th, when I was
asked if I could provide some information about the account so they could
confirm it was me. The message asked for:

> *   Any connected apps or devices
> *   Pending friend requests to your account
> *   Any accounts linked to your Goodreads account (Goodreads accounts can be
>     linked to Amazon, Apple, Google, and/or Facebook accounts)
> *   The name of any private/secret groups of which you are a part
> *   Any other account-specific information you can recall

Since I of course had no access to the account, I replied 30 minutes later with
what information I could recall from memory: my devices, Amazon Kindle
connection (Kindle would sometimes update my reading progress, though not
always), membership in some groups that may or may not have been public, and the
last couple books I'd updated.

Presumably, most of that information was public, and the devices may have been
changed by the hackers. I heard nothing back. I sent followup inquiries on
February 12th and 16th but got no replies.

On February 23rd I [complained on Twitter]. Four minutes later [@goodreads
replied] and I started to hope there might be some progress again. They [asked
me] to get in touch with Support again, which [i did] at 10:59am, sending all
the previous information and context I could.

Then, at 12:38am, this bombshell arrived in my inbox from Goodreads support:

> Thanks for your your patience while we looked into this. I have found that
> your account was deleted due to suspected suspicious activity. Unfortunately,
> once an account has been deleted, all of the account data is permanently
> removed from our database to comply with the data regulations which means that
> we are unable to retrieve your account or the related data. I know that’s not
> the news you wanted and I am sincerely sorry for the inconvenience.Please let
> me know if there’s anything else I ​can assist you with.

I was stunned. I mean of course there was suspicious activity, the account was
taken over 19 days previously! As of the 5th when I found the link it still
existed, and I had been in touch a number of times previously. Goodreads knew
that the account had been reported stolen and still deleted it?

And no chance of recovery due to compliance rules? I don't live in the EU, and
even if I was subject to the [GDPR] or [CCPA], there is no provision to delete
my data unless I request it.

WTAF.

So to summarize:

*   Someone took control of my account on February 2
*   I reported it within hours
*   On February 5 my account was still on Goodreads
*   We exchanged a number of messages
*   By February 23 the account was deleted with no chance of recovery due to
    suspicious activity

Because of course there was suspicious activity. I told them there was an issue!

How did this happen? What was the security configuration for my account?

*   I created an entry for Goodreads in 1Password on January 5, 2012. The
    account may have been older than that, but for at least 10 years I've had
    it, and used it semi-regularly.
*   The password was 16 random ASCII characters generated by 1Password on
    October 27, 2018. I create unique random passwords for all of my accounts,
    so it would not be found in a breached database (and I have updated all
    breached accounts 1Password has identified).
*   The account had no additional factors of authentication or fallbacks to
    something like SMS, because Goodreads does not offer them. There was only
    my email address and password.
*   On February 2nd someone changed my password.  I had clicked no links in
    emails, so phishing is unlikely. Was Goodreads support social-engineered to
    let someone else change the password? How did this happen?
*   I exchanged multiple messages with Goodreads support between February 2 and
    23rd, to no avail. By February 23rd, my account was gone with all my reviews
    and reading lists.

Unlike [Nelson], who's [account was _also_ recently deleted] without chance of
recovery, I had not been making and backups of my data. Never occurred to me,
perhaps because I never put a ton of effort into my Goodreads account, mostly
just tracked reading and a few brief reviews. I'll miss my reading list the
most. Will have to start a new one on my own machines.

Though all this, Goodreads support were polite but not particularly responsive.
days and then weeks went by without response. The company deleted the account
for suspicious activity an claim no path to recovery for the original owner.
Clearly the company doesn't give its support people the tools they need to
adequately support cases such as this.

I can think of a number of ways in which these situations can be better handled
and even avoided. In fact, given my current job designing identity systems I'm
going to put a lot of thought into it.

But sadly I'll be trusting third parties less with my data in the future.
Redundancy and backups are key, but so is adequate account protection.
[Letterboxed], for example, has no multifactor authentication features, making
it vulnerable should someone decide it's worthwhile to steal accounts to spam
reviews or try to artificially pump up the scores for certain titles. [Just made
a backup].

You should, too, and backup your Goodreads account regularly. Meanwhile, I'm on
the lookout for a new social reading site that supports multifactor
authentication. But even with that, in the future I'll post reviews here on Just
a Theory and just reference them, at best, from social sites.

<hr id="update" />

**Update April 3, 2022**: This past week, I finally got some positive news from
Goodreads, two months after this saga began:

> The Goodreads team would like to apologize for your recent poor experience
> with your account. We sincerely value your contribution to the Goodreads
> community and understand how important your data is to you. We have
> investigated this issue and attached is a complete file of your reviews,
> ratings, and shelvings. 

And that's it, along with some instructions for creating a new account and
loading the data. Still no account recovery, so my old URL is dead and there is
no information about my Goodreads friends. Still, I'm happy to at least have my
lists and reviews recovered. I imported them into a new Goodreads account, then
exported them again and imported them into my new [StoryGraph profile].

  [Goodreads]: https://www.goodreads.com
  [complained on Twitter]: https://twitter.com/theory/status/1496483369781243910
  [@goodreads replied]: https://twitter.com/goodreads/status/1496484238908178442
  [asked me]: https://twitter.com/goodreads/status/1496513088224468992
  [i did]: https://twitter.com/theory/status/1496515177809944581
  [GDPR]: https://gdpr-info.eu
  [CCPA]: https://www.oag.ca.gov/privacy/ccpa
  [Nelson]: https://www.somebits.com/weblog/ "Some Bits: Nelson’s weblog"
  [account was _also_ recently deleted]:
    https://www.somebits.com/weblog/tech/bad/goodreads-lost-all-my-data.html
    "Some Bits: “Goodreads lost all of my reviews”"
  [Letterboxed]: https://letterboxd.com "Letterboxd • Social film discovery."
  [Just made a backup]: https://letterboxd.com/settings/data/
  [StoryGraph profile]: https://app.thestorygraph.com/profile/itheory