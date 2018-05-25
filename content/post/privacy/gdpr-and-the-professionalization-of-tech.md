---
title: "GDPR and the Professionalization of Tech"
date: 2018-05-25T21:20:27Z
lastMod: 2018-05-25T21:20:27Z
description: "The GDPR is a big deal. What will be the best approaches to comply? Hard work, good tools, and ingenious new products."
tags: [Privacy, GDPR, Compliance, Technology, Internet, ingenuity, Microsoft Azure, Amazon AWS, Ian Bogost, Sarah Jamie Lewis]
type: post
---

Happy GDPR day.

The [GDPR] is a big deal. It encodes significant personal and private data
rights for EU subjects, including, among others:

*   The [right to be informed] that organizations process your data
*   The [right to access] that data
*   The [right to rectification] of errors in your personal data
*   The [right to erasure] of your data (a.k.a. the right to deletion)
*   The [right to restriction of processing], to disallow an organization from
    using your data
*   The [right to data portability], so that no one organization can hoard your
    data

Organizations that process personal data, referred to as "data controllers,"
accept serious responsibilities to respect those rights, and to protect the
personal data they process. These responsibilities include, among others:

*   Clear communication of the [lawful basis of processing][^gdpr-pro-emails]
*   Acquisition of [freely-given consent] to collect personal data, or a
    legitimate legal basis to collect without direct consent
*   [Data protection by design and by default]
*   Maintenance of [records of processing activities]
*   Maintenance of an [appropriate level of security] around personal data, such
    as authentication, encryption, and [pseudonymization]
*   Notification in the event of a breach to both the [appropriate legal
    authority] and to the [people whose data may have been breached]

The regulations have teeth, too; [fines for non-compliance] add up to a
considerable financial penalty. Failure to notify in the event of a breach, for
example, may result in a fine of up to €20 million or 4% of global revenue,
whichever is greater.

There's a lot more, but the details have been [extensively covered elsewhere].
In contrast, I want to talk about the impact of the GDPR on the internet
products and services.

Impacts
-------

In my [GDPR advocacy] for iovation, I've argued that the enshrinement of
personal data rights marks a significant development for human rights in
general, and therefore is not something to be resisted as an imposition on
business. Yes, compliance requires a great deal of work for data controllers,
and few would have taken it on voluntarily. But the advent of the GDPR, with
application to over 500 million EU subjects, as well as to any and all
organizations that process EU subject personal data, tends to even out the cost.
If the GDPR requires all companies to comply, then no one company is
disadvantaged by the expense of complying.

This argument is true as far as it goes --- which isn't far. Not every company
has equal ability to ensure compliance. It might be a slog for Facebook or
Google to comply, but these monsters have more than enough resources to make it
happen.[^gdpr-pro-challenge] Smaller, less capitalized companies have no such
luxury. Some will struggle to comply, and a few may succumb to the costs. In
this light, the GDPR represents a barrier to entry, a step in the [inevitable
professionalization][Ian Bogost piece][^gdpr-pro-engineer] of tech that protects
existing big companies that can easily afford it, while creating an obstacle to
new companies working to get off the ground.

I worry that the GDPR marks a turning point in the necessary professionalization
of software development, increasing the difficulty for a couple people working
in their living room to launch something new on the internet. Complying with the
GDPR is the right thing to do, but requires the ability to respond to access and
deletion requests from individual people, as well as much more thorough data
protection than the average web jockey with a MySQL database can throw together.
For now, perhaps, they might decline to serve EU subjects; but expect
legislation like the GDPR to spread, including, eventually, to the US.

Personal data rights are here to stay, and the responsibility to adhere to those
rights applies to us all. While it might serve as a moat around the big data
controller companies, how can leaner, more agile concerns, from a single
developer to a moderately-sized startup, fulfill these obligations while
becoming and remaining a going concern?

Tools
-----

Going forward, I envision two approaches to addressing this challenge. First,
over time, new tools will be developed, sold, and eventually released as
open-source that reduce the overhead of bootstrapping a new data processing
service. Just as [Lucene] and [Elasticsearch] have commoditized full-text
search, new tools will provide encrypted data storage, anonymous authentication,
and tokenization services on which new businesses can be built. I fear it may
take some time, since the work currently underway may well be bound by corporate
release policies, intellectual property constraints, and quality
challenges.[^gdpr-pro-own] Developing, vetting, releasing, and proving new
security solutions *takes time.*

Commercial tools will emerge first. Already services like [Azure Information
Protection] secure sensitive data, while authentication services like [Azure
Active Directory] and [Amazon Cognito] delegate the responsibility (if not the
breach consequences) for secure user identities to big companies. Expect such
expensive services to eventually be superseded by more open solutions without
vendor lock-in --- though not for a couple years, at least.

Ingenuity
---------

I'm into that, even working on such tools at [work], but I suspect there's a
more significant opportunity to be had. To wit, *never underestimate the
ingenuity of people working under constraints.* And when such constraint include
the potentially high cost of managing personal data, more people will work
harder to dream up interesting new products that *collect no personal data at
all.*

Internet commerce has spent a tremendous amount of time over the last 10 years
figuring out how to collect more and more data from people, primarily to
commoditize that information --- especially for targeted advertising. Lately,
the social costs of such business models has become increasingly apparent,
including [nonconsensual personal data collection], [massive data breaches] and,
most notoriously, [political manipulation].

So what happens when people put their ingenuity to work to dream up new products
and services that require no personal data at all? What might such services look
like? What can you do with nothing more than an anonymized username and a
[properly hashed password]? To what degree can apps be designed to keep personal
data solely on a personal device, or transmitted exclusively via [end-to-end
encryption]? Who will build the first [dating app on Signal]?

I can't wait to see what creative human minds --- both constrained to limit data
collection and, not at all paradoxically, freed from the demand to collect ever
more personal data --- will come up with. The next ten years of internet
inventiveness will be fascinating to watch.

  [^gdpr-pro-emails]: This requirement has largely driven the avalanche of
    "We've updated privacy policy" messages in your inbox.

  [^gdpr-pro-challenge]: Or to mount legal challenges that create the legal
    precedents for the interpretation of the GDPR.

  [^gdpr-pro-engineer]: This [Ian Bogost piece] isn't specifically about the
    professionalization of tech, but the appropriation of the title "engineer"
    by developers. Still, I hope that software developers will eventually adopt
    the [Calling of the Engineer], which reads, in part, "My Time I will not
    refuse; my Thought I will not grudge; my Care I will not deny toward the
    honour, use, stability and perfection of any works to which I may be called
    to set my hand." Ethical considerations will have to become a deep
    responsibility for software developers in the same way it has for structural
    and civil engineers.
  
  [^gdpr-pro-own]: Like the [old saw] says: "Never implement your own crypto."
    Hell, [OpenSSL can't even get it right].

  [GDPR]: https://en.wikipedia.org/wiki/General_Data_Protection_Regulation
    "Wikipedia: “General Data Protection Regulation”"
  [right to be informed]: https://gdpr-info.eu/art-13-gdpr/
    "Art. 13 GDPR: Information to be provided where personal data are collected from the data subject"
  [right to access]: https://gdpr-info.eu/art-15-gdpr/
    "Art. 15: GDPR Right of access by the data subject"
  [right to rectification]: https://gdpr-info.eu/art-16-gdpr/
    "Art. 16 GDPR: Right to rectification"
  [right to erasure]: https://gdpr-info.eu/art-17-gdpr/
    "Art. 17 GDPR: Right to erasure (‘right to be forgotten’)"
  [right to restriction of processing]: https://gdpr-info.eu/art-18-gdpr/
    "Art. 18 GDPR: Right to restriction of processing"
  [right to data portability]: https://gdpr-info.eu/art-20-gdpr/
    "Art. 20 GDPR: Right to data portability"
  [lawful basis of processing]: https://gdpr-info.eu/art-6-gdpr/
    "Art. 6 GDPR: Lawfulness of processing"
  [freely-given consent]: https://gdpr-info.eu/art-7-gdpr/
    "Art. 7 GDPR: Conditions for consent"
  [Data protection by design and by default]: https://gdpr-info.eu/art-25-gdpr/
    "Art. 25 GDPR: Data protection by design and by default"
  [records of processing activities]: https://gdpr-info.eu/art-30-gdpr/
    "Art. 30 GDPR: Records of processing activities"
  [appropriate level of security]: https://gdpr-info.eu/art-32-gdpr/
    "Art. 32 GDPR: Security of processing"
  [pseudonymization]: https://en.wikipedia.org/wiki/Pseudonymization
    "Wikipedia: “Pseudonymization”"
  [people whose data may have been breached]: https://gdpr-info.eu/art-34-gdpr/
    "Art. 34 GDPR: Communication of a personal data breach to the data subject"
  [appropriate legal authority]: https://gdpr-info.eu/art-33-gdpr/
    "Art. 33 GDPR: Notification of a personal data breach to the supervisory authority"
  [extensively covered elsewhere]: https://duckduckgo.com/?q=GDPR
    "Duck Duck Go Search for “GDPR”"
  [fines for non-compliance]: https://gdpr-info.eu/art-83-gdpr/
    "Art. 83 GDPR: General conditions for imposing administrative fines"
  [GDPR advocacy]:
    https://www.iovation.com/resources/webinars/4-gdpr-hacks-to-mitigate-breach-risks-post-gdpr
    "iovation Webtalk: “4 GDPR Hacks to Mitigate Breach Risks Post GDPR”"
   [Ian Bogost piece]:
     https://www.theatlantic.com/technology/archive/2015/11/programmers-should-not-call-themselves-engineers/414271/
     "The Atlantic: “Programmers: Stop Calling Yourselves Engineers”"
  [Calling of the Engineer]:
    https://en.wikipedia.org/wiki/Ritual_of_the_Calling_of_an_Engineer
    "Wikipedia: “Ritual of the Calling of an Engineer”"
  [Lucene]: https://lucene.apache.org "Apache Lucene"
  [Elasticsearch]: https://www.elastic.co/products/elasticsearch
  [old saw]: https://xkcd.com/153/ "XKCD: “Cryptography”"
  [OpenSSL can't even get it right]: http://heartbleed.com "The Heartbleed Bug"
  [Azure Information Protection]:
    https://azure.microsoft.com/en-us/services/information-protection/
  [Azure Active Directory]: https://azure.microsoft.com/en-us/services/active-directory-b2c/
  [Amazon Cognito]: https://aws.amazon.com/cognito/
  [work]: https://iovation.com "iovation"
  [nonconsensual personal data collection]:
    https://motherboard.vice.com/en_us/article/bjpx3w/what-are-data-brokers-and-how-to-stop-my-private-data-collection
    "Motherboard: “What Are 'Data Brokers,' and Why Are They Scooping Up Information About You?”"
  [massive data breaches]: https://www.schneier.com/blog/archives/2017/09/on_the_equifax_.html
    "Schneier on Security: “On the Equifax Data Breach”"
  [political manipulation]: https://nyti.ms/2GB9dK4
    "New York Times: “How Trump Consultants Exploited the Facebook Data of Millions”"
  [properly hashed password]: https://password-hashing.net
    "Password Hashing Competition"
  [end-to-end encryption]: https://en.wikipedia.org/wiki/End-to-end_encryption
    "Wikipedia: “End-to-end encryption”"
  [dating app on Signal]: https://twitter.com/SarahJamieLewis/status/978060904259469312
    "Epic @SarahJamieLewis thread on decentralization, federation, and privacy"