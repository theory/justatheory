---
title: The Watch is You
date: 2015-04-16T20:00:00Z
description: Apple Watch and the future of identity.
tags: [Apple, Apple Watch, Identity, Authentication, MFA, Glenn Fleishman]
type: post
---

{{% figure
   src     = "iphone-watch.jpg"
   alt     = "“iPhone and Apple Watch“"
   caption = "Multiple factors."
   class   = "right"
   attr    = "Apple"
   attrlink = "https://www.apple.com/"
%}}

Back when Apple introduced Touch ID, I had an idea for a blog post, never
written, entitled "Touch ID is Step Zero in Apple's Authentication Plan." As an
ardent user of online services (over 500 passwords in 1Password!), the challenge
of passwords frequently frustrates me. Passwords stink. People don't like them,
don't like the crazy and often pointless complexities piled on them by naïve
developers. Worse, many sites employ useless techniques, such as secret images
and challenge questions, utterly failing to understand the distinctions between
the various [factors of authentication].

Touch ID, I thought, was a solid step toward solving these problems. Initially,
it would simplify the act of identifying yourself to your iPhone. Long-term, I
hoped, it would extend to other applications and online accounts. As late as
last last month, I Tweeted my desire to have Touch ID on the MacBook line so I
could finally stop mis-typing my password to access my desktop.

Turns out I wasn't thinking big enough. The next step in Apple's identity plan
wasn't online logins (though some apps take advantage of it).

It was Apple Pay.

An under-appreciated benefit of Apple Pay is its implementation of multi-factor
authentication. The first factor is your PIN --- something you *know* --- which
you must put into your iPhone when you turn it on. Then, at purchase, you use
Touch ID, authenticating with a second factor --- something you *are.* This
*greatly* reduces the chances of identity theft: someone would have to steal
your iPhone and both circumvent the PIN *and* somehow fake your fingerprint in
order to use it. Both exploits are [notoriously difficult] to pull off. An Apple
Pay transaction almost certainly cannot be hacked or spoofed.

Crucially, the Apple Watch also offers Apple Pay and requires two factors of
authentication. The first is the iPhone with which the Watch is
paired --- something you *have.* The second is a passcode input when you put the
Watch on --- something you *know* --- and you'll stay "logged in" as long as the
Watch remains on your wrist. This is *not quite* as invulnerable as Touch ID on
presentation, but still a powerful indicator of the identity of the customer.

Which brings us back to the issue of authentication. Well, not authentication so
much as *identity.* If the Watch is an effectively low risk means of identifying a
credit card owner, why not use it for identification in general? Consider these
recent developments:

*   You might soon be able to use your phone as your [driving license]
*   Apple CEO Tim Cook suggests that the Watch will [replace your car keys]
*   [Apple demonstrated] the display of an airline boarding pass bar code to get
    through airport security
*   Tech polymath Glenn Fleishman envisions the Watch as the center of your
    [universe of things]

Let's take these developments to their logical conclusions. Before long, you'll
be able to use the Watch to:

*   Open your hotel room or rental car without even checking in
*   Control lights when you walk into a room
*   Adjust the car seat and mirrors to your preferred positions
*   Identify yourself when picking up packages at the post office
*   Access and use public transportation
*   And yes, unlock your computer or phone (thanks Glenn)

In the end, the Watch isn't a gadget. It isn't (just) jewelry. It's more than a
password or wallet replacement, more than a controller for the devices around
you. The Watch is your identification, an ever-present token that represents
your presence in the universe.

Effectively, the Watch is you.

<small>This post [originally appeared] on *Medium.*</small>

[factors of authentication]:
  https://en.wikipedia.org/wiki/Authentication#Factors_and_identity
  "Wikipedia: Authentication Factors and identity"
[notoriously difficult]:
  http://www.macrumors.com/2013/10/04/security-researchers-detail-new-combination-of-touch-id-and-ios-7-security-feature-bypasses/
  "MacRumors: Security Researchers Detail New Combination of Touch ID and iOS 7 Security Feature Bypasses"
[driving license]:
  https://bgr.com/2014/12/12/iphone-and-android-drivers-license-app/
  "BGR: “iPhone and Android are about to take another huge step toward replacing your wallet”"
[replace your car keys]:
  https://www.telegraph.co.uk/technology/apple/watch/11439847/Apple-Watch-will-replace-your-car-keys-says-Tim-Cook.html
  "The Telegraph: “Apple Watch will replace your car keys, says Tim Cook”"
[Apple demonstrated]:
  https://www.recode.net/2015/3/9/11559942/the-apple-watch-is-here-you-have-10000-or-349
  "Recode: “The Apple Watch Is Here. You Have $17,000?”"
[universe of things]:
  https://glog.glennf.com/blog/2015/2/18/iwatch-ihub
  "Glenn Fleishman: “iWatch, iHub”"
[originally appeared]: https://medium.com/@theory/the-watch-is-you-ef0e416ce0f9
