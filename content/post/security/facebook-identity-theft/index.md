---
title: "Facebook Identity Theft"
date: 2018-06-14T14:49:26Z
lastMod: 2018-06-14T14:49:26Z
description: Some rando cybercriminal created a Facebook account to try to get a Foothold in my identity. Here's what I did about it.
tags: [Security, Identity Theft, Facebook, Social Login, Rando Cybercriminal]
type: post
---

I get email:

{{% figure
  src     = "confirm-account.png"
  alt     = "Action Required: Confirm Your Facebook Account"
  class   = "frame"
  caption = "Needless to say, I did not just register for Facebook."
%}}

Hrm. That's weird, since my Facebook account dates back to 2007. Wait, there's
another email:

{{% figure
  src     = "phone-added.png"
  alt     = "(219) 798-8705 added to your Facebook account"
  class   = "frame"
  caption = "That’s not my phone number."
%}}

I've never seen that phone number before in my life. In fact, I removed my phone
number from Facebook not long ago for privacy reasons. So what's going on?

A quick look at the email address tells the story: It's my Gmail address. Which
I never use. Since I never use it, it's not associated with any account,
including Facebook. What's happened is someone created a new Facebook account
with my Gmail address. If I were to click the "Confirm your account" button, I
would give someone else a valid Facebook account using my identity. It'd be even
worse if I also approved the phone number. Doing so would cede complete control
over this Facebook account to someone else. These kinds of messages are so
common that it wouldn't surprise me if some people just clicked those links and
entered the confirmation code.

It's only Facebook, you might think. But Facebook, isn't "only" anything
anymore. It's a juggernaut. Facebook is so massive, and has promoted itself so
heavily as an identity platform, that many organizations rely on it for identity
proofing vias [social logins]. That means someone can "prove" they're me by
logging into that Facebook account. Via that foothold, they can gradually
control other online accounts and effectively control the identity associated
with my Gmail address.

That would not be good.

So after inspecting the email to make sure that its URLs are all actually
on `facebook.com`, I visit the "please secure your account" link:

{{% figure
  src     = "secure-your-account.png"
  alt     = "Secure your account?"
  title   = "If you think someone else is logging into your account, we can help you secure it with a few security steps."
  class   = "frame"
  caption = "This isn't right…"
%}}

This is a little worrying. It's not that I think someone else is logging into my
account. It's that someone else has created an account using my Gmail address,
and therefore a slice of my identity. Still, locking it down seems like a good
idea. I hit the "Secure Account" button.

{{% figure
  src     = "upload-photo-id.png"
  alt     = "Secure your account?"
  title   = "Upload a photo ID"
  class   = "frame"
  caption = "What? Fuck no."
%}}

Now we've reached to the point point where I'm at risk of actually associating
my physical photo ID with an account someone else created and controls? *Fuck
no.* I don't want to associate a photo ID with my real Facebook account, let
alone one set up by some rando cybercriminal. Neither should you.

I close that browser tab, switch to another browser, and log into my real
Facebook account. If the problem is that someone else wants proof of control
over my Gmail address, I have to take it back. So I add my Gmail address to the
[settings] for my real Facebook account, wait for the confirmation email, and
hit the confirmation link.

{{% figure
  src     = "email-confirmation.png"
  alt     = "Contact Email Confirmation"
  title   = "You are about to add the email to your Facebook account. This will remove it from any other Facebook account. Any Facebook account left with no valid emails will become inaccessible."
  class   = "frame"
  caption = "That should do it."
%}}

Great, that other account no longer has any control over my Gmail address. Hope
it doesn't have any other email addresses associated with it.

Oh, one more step: Facebook decided this new address should be my primary email
address, so I had to change it back.

I don't know how people without Facebook accounts would deal with this
situation. Facebook needs to give people a way to say: "This is not me, this
is not my account, I don't want an account, please delete this bogus account."
It shouldn't require uploading a photo ID, either.

  [social logins]: https://en.wikipedia.org/wiki/Social_login
    "Wikipedia: “Social login”"
  [settings]: https://www.facebook.com/settings?tab=account&section=email&view
    "Facebook General Account Settings"
