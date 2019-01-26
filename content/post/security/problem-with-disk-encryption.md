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
your PC, or [Android Device Encryption] on your phone, please go do it now (iOS
encrypts storage by default). It's easy, efficient, and secure. You will likely
never notice the difference in usage or performance. Seriously. This is a
no-brainer.

Once enabled, device encryption prevents just about anyone from accessing device
data. Unless a malefactor possesses both device and authentication credentials,
the data is secure.

Mostly.

Periodically, vulnerabilities arise that allow circumvention of device
encryption, usually by exploiting a bug in a background service. OS vendors tend
to fix such issues quickly, so keep your system up to date. And if you work in
IT, enable full disk encryption on all of your users' devices and drives. Doing
so greatly reduces the risk of sensitive data exposure via lost or stolen
personal devices.

Servers, however, are another matter.

The point of disk encryption is to prevent data compromise by entities with
physical access to a device. If a governmental or criminal organization takes
possession encrypted storage devices, gaining access to an of the data presents
an immense challenge. Their best bet is to power up the devices and scan their
ports for potentially-vulnerable services to exploit. The OS allows such
services transparent access the file system via automatic decryption. Exploiting
such a service allows access to any data the service can access.

But, law enforcement investigations aside,[^law-enforcement-access] who bothers
with physical possession? Organizations increasingly rely on cloud providers
with data distributed across multiple servers, perhaps hundreds or thousands,
rendering the idea of physical confiscation nearly meaningless. Besides, when
exfiltration typically relies on service vulnerabilities, why bother taking
possession  hardware at all? Just exploit vulnerabilities remotely and leave the
hardware alone.

Which brings me to the issue of compliance. I often hear IT professionals assert
that simply encrypting all data at rest[^and-in-transit] satisfies the
responsibility to the [security of processing (GDPR Article 32)][GDPR-32]. This
interpretation may be legally correct[^gdpr-precedents] and relatively
straight-forward to achieve: simply enable [disk encryption], protect the keys
via an appropriate and closely-monitored key management system, and migrate data
to the encrypted file systems.[^or-databases]

This level of protection against physical access is absolutely necessary for
protecting sensitive data.

**_Necessary_, but not _sufficient._**

When was the last time a breach stemmed from physical access to a server? Sure,
some reports in the [list of data breaches] identify "lost/stolen media" as the
beach method. But we're talking lost (and unencrypted) laptops and drives. Hacks
(service vulnerability exploits), accidental publishing,[^more-on-access-later]
and "poor security" account for the vast majority of breaches. Encryption of
server data at rest addresses none of these issues.

By all means, encrypt data at rest, and for the love of Pete *please* keep your
systems and services up-to-date with the latest patches. Taking these steps,
along with full network encryption, is essential for protecting sensitive data.
But don't assume that such steps adequately protect sensitive data, or that
doing so will achieve compliance with [GDPR Article 32][GDPR-32].

Don't simply encrypt your disks or databases, declare victory, and go home.

Bear in mind that data protection comes in layers, and those layers correspond
to levels of exploitable vulnerability. Simply addressing the lowest-level
requirements at the data layer does nothing to prevent exposure at higher
levels. Start disk encryption, but then think through how best to protect data
at the application layer, the API layer, and, yes, [the human layer], too.

  [^law-enforcement-access]: Presumably, a legitimate law enforcement
    investigation will compel a target to provide the necessary credentials to
    allow access by legal means, such as a court order, without needing to
    exploit the system. Such an investigation might confiscate systems to
    prevent a suspect from deleting or modifying data until such access can be
    compelled --- or, if such access is impossible (e.g., the suspect is
    unknown, deceased, or incapacitated) --- until the data can be forensically
    extracted.
  [^and-in-transit]: Yes, and in transit.
  [^gdpr-precedents]: Although currently no precedent-setting case law exists.
    Falling back on [PCI standards] may drive this interpretation.
  [^or-databases]: Or databases. The fundamentals are the same: encrypted data
    at rest with transparent access provided to services.
  [^more-on-access-later]: I plan to write about accidental exposure of data in
    a future post.

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
