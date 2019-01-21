---
title: "The Problem With Disk Encryption"
date: 2019-01-21T20:23:30Z
lastMod: 2019-01-21T20:23:30Z
description: Full disk encryption is necessary but insufficient to protect sensitive and personal data under the GDPR.
tags: [Security, Privacy, Encryption, GDPR]
type: post
draft: true
---

Full disk encryption provides incredible data protection for personal devices.
If you haven't enabled [FileVault] on your Mac, [Windows Device Encryption] on
your PC, or [Android Device Encryption] on your phone (iOS devices are encrypted
by default), please go do it now. It's easy, efficient, and secure. You will
likely never notice the difference in usage or performance. Seriously. This is a
no-brainer.

Once enabled, device encryption prevents just about anyone from accessing device
data. Unless malefactor possesses both device and authentication credentials,
the data is secure.

Mostly.

Periodically, vulnerabilities arise that allow circumvention of device
encryption, generally by exploiting a bug in a background service. Ths OS
vendors generally fix such issues quickly, so keep your system up to date, too.
And if you work in IT, enable full disk encryption on all of your users' devices
and disks. Doing so greatly reduces the risk of sensitive data exposure due to
lost or stolen personal devices.

Servers, however, are another matter.

The point of disk encryption is to prevent data compromise by entities with
physical access to a device. If a governmental[^law-enforcement-access] or
criminal organization takes physical possession of servers, it will be an
immense challenge for them to gain access to any of the data. Their best bet is
to power them on, let them boot up, then start port scanning for
potentially-vulnerable services to exploit. The OS generally provides
services access to the file system via automatic decryption. Exploiting such
a service allows a malefactor to access any of the data the service can
access.

But these days, who would bother with physical possession? organizations
increasingly rely on cloud providers with data distributed across multiple
servers, perhaps hundreds or thousands. In such a context, physical confiscation
becomes nearly meaningless. Besides, since exfiltration generally relies on
service vulnerabilities, why bother taking possession of the hardware at all?
Just exploit vulnerabilities remotely and leave the hardware alone.

Which brings me to the issue of compliance. I often hear that meeting the
responsibility to the [security of processing (GDPR Article 32)][GDPR-32] is
achieved simply by requiring encryption for sensitive data at
rest[^and-in-transit]. This interpretation may be legally
correct[^gdpr-precedents] and relatively straight-forward to achieve: simply
enable [disk encryption], lock down the keys, and migrate data to the encrypted
file systems[^or-databases].

This level of protection against physical access is absolutely necessary for
protecting sensitive data.

**Necessary, but not sufficient.**

When was the last reported data breach that stemmed from physical access to a
server? Sure, some of the [list of data breaches] identifies "lost/stolen media"
as the beach method. But we're talking lost (and unencrypted) laptops and hard
drives. The vast majority of the breaches were via hacks (exploits), accidental
publishing[^more-on-access-later], or poor security. Encryption of data at rest
on servers addresses none of these issues.

By all means, keep all data encrypted at rest, and for the love of Pete *please*
keep your systems and services up-to-date with the latest patches. Taking these
steps, along with full network encryption, is absolutely necessary for
protecting sensitive data. But don't assume that such steps adequately protect
sensitive data, or that doing so will achieve compliance with
[GDPR Article 32][GDPR-32].

Don't simply encrypt your disks or databases, declare victory, and go home.

Bear in mind that data protection comes in layers, and those layers correspond
to the levels of exploitable vulnerability. Simply addressing the lowest-level
requirements at the data layer does nothing to prevent exposure at higher
levels. Start there, but then think through how best to protect data at the
application layer, the API layer, and, yes, [the human layer], too.

  [^law-enforcement-access]: Presumably, a legitimate law enforcement
    investigation would generally be able to compel a target to provide the
    necessary credentials to allow access by legal means, such as a court order,
    without needing to exploit the system. Such an investigation might be best
    served by physically confiscating systems to prevent a suspect from deleting
    or modifying data until such access can be compelled --- or, if such access
    is impossible (e.g., the suspect is unknown, deceased, or otherwise unable
    of provide) --- until the data can be forensically extracted.
  [^and-in-transit]: Yes, and in transit.
  [^gdpr-precedents]: Although there are so far no legal precedents to rely on.
    Falling back on the precedents of [PCI standards] may be the driver for this
    interpretation.
  [^or-databases]: Or databases. The fundamentals are the same: encrypted data
    at rest with transparent access provided to services.
  [^more-on-access-later]: I plan to write about preventing accidental exposure
    of data in a future post.

  [FileVault]: https://support.apple.com/en-us/HT204837
    "Apple Support: “Use FileVault to encrypt the startup disk on your Mac”"
  [Windows Device Encryption]:
    https://support.microsoft.com/en-us/help/4028713/windows-10-turn-on-device-encryption
    "Windows Support: “Turn on device encryption”"
  [Android Device Encryption]:
    https://docs.microsoft.com/en-us/intune-user-help/encrypt-your-device-android
    "Microsoft: “How to protect your Android device using encryption”"
  [GDPR-32]: https://gdpr-info.eu/art-32-gdpr/ "Art. 32 GDPR: Security of processing"
  [PCI standards]: https://www.pcisecuritystandards.org
  [list of data breaches]: https://en.wikipedia.org/wiki/List_of_data_breaches
  [the human layer]: https://en.wikipedia.org/wiki/Layer_8 "Wikipedia: “Layer 8”"