---
title: "Borderline"
date: 2019-02-02T20:46:08Z
lastMod: 2019-02-02T20:46:08Z
description: Network perimeter protection is complicated, imperfect, and insufficient to protect sensitive and personal data.
tags: [Security, Privacy, GDPR, Network Perimeter, Goran Begic]
type: post
draft: true
---

In just about any discussion of the GDPR compliance, two proposals always come
up: disk encryption and network perimeter protection. I recently criticized the
[focus on disk encryption], particularly its inability to protect sensitive data
from live system exploits. Next I wanted to highlight the weaknesses of
perimeter protection. But in doing a little research on the topic, I found that
[Goran Begic] has already [made the case]:

> Many organizations, especially older or legacy enterprises, are struggling to
> adapt systems, behaviors, and security protocols to this new-ish and ever
> evolving network model. Outdated beliefs about the true nature of the network
> and the source of threats put many organizations, their information assets,
> and their customers, partners, and stakeholders at risk.
>
> What used to be carefully monitored, limited communication channels have
> expanded into an ever changing system of devices and applications. These
> assets are necessary for your organization to do business—they are what allow
> you to communicate, exchange data, and make business decisions and are the
> vehicle with which your organization's runs the business and delivers value to
> its clients.

Cloud computing and storage, remote workers, and the emerging preference for
micro-services over monoliths[^borderline-monoliths] vastly complicate network
designs and erode boundaries. Uber-services such as [Kubernetes] recover some
control by wrapping all those micro-services in the warm embrace of a monolithic
orchestration layer, but by no means restore the simplicity of earlier times. As
soon as needs demand distributing data and services to multiple data centers or
geographies, the complexity creeps back in. Host your data and services in the
cloud and you'll find the boundary all but gone. Where's the data? It's
*everywhere*.

In such an environment, staying on top of all the vulnerabilities --- all the
patches, all the services listening on this network or that, inside some
firewall or out, accessed by whom and via what means --- exponentially more
difficult. Even the most dedicated, careful, and meticulous of teams will sooner
or later overlook something. An unpatched vulnerability. An authentication bug
in an internal service. A rogue cloud storage container to which an employee
uploads unencrypted data. Any and all could happen. To judge by the [list of
data breaches], they *do* happen. Strive for the best; expect the worst.

__Because it's not a matter of whether or not your data will be breached. It's
simply a matter of *when.*__

Unfortunately, compliance discussions often end with these two mitigations, with
disk encryption and network perimeter protection. Absolutely take every possible
step to adopt them. And a discussion rightfully starts with them. But then it's
not over. No, these two basics of data protection are but only the first step to
protect sensitive data and to satisfy the responsibility to the [security of
processing (GDPR Article 32)][GDPR-32]. Because sooner or later, no matter how
comprehensive the data storage encryption and firewalling, eventually there will
be a breach. *And then what?*

"What next" bears some thinking about. What's important is reducing risk in the
inevitable event of a breach. How so? I suggest taking the provisions of the
GDPR at face value, and consider three things:

1.  [Privacy by design and default][GDPR-25]
2.  [Anonymization and aggregation][WP-29]
3.  [Pseudonymization]

Formally, items two and three fall under item 1, but I would summarize them as:

1.  Collect only the minimum data needed for the job at hand
2.  Anonymize and aggregate data to minimize its sensitivity
3.  Pseudonymize the remaining data to eliminate its breach value

Put these three together, and the risk of sensitive data loss and the costs of
mitigation decline dramatically. In short, take security seriously, yes, but
also take privacy seriously.

  [^borderline-monoliths]: It's okay, as a [former archaeologist] I'm allowed to
    let the metaphor stand on its own.

  [focus on disk encryption]: /2019/01/the-problem-with-disk-encryption/
    "The Problem With Disk Encryption"
  [Goran Begic]: https://www.immun.io/blog/author/goran-begic
  [made the case]: https://www.immun.io/blog/what-is-the-network-perimeter-anyway
    "What is the Network Perimeter, Anyway?"
  [former archaeologist]: /2007/03/five-things/#2-i-used-to-be-an-archaeologist
  [Kubernetes]: https://kubernetes.io "Production-Grade Container Orchestration"
  [list of data breaches]: https://en.wikipedia.org/wiki/List_of_data_breaches
  [GDPR-32]: https://gdpr-info.eu/art-32-gdpr/ "Art. 32 GDPR: Security of processing"
  [GDPR-25]: https://gdpr-info.eu/art-25-gdpr/
    "Art. 25 GDPR - Data protection by design and by default"
   [WP-29]: https://www.dataprotection.ro/servlet/ViewDocument?id=1085
    "Article 29 Data Protection Working Party: Opinion 05/2014 on Anonymisation Techniques (PDF)"
   [Pseudonymization]:
     https://iapp.org/news/a/top-10-operational-impacts-of-the-gdpr-part-8-pseudonymization/
     "IAPP: “Top 10 operational impacts of the GDPR: Part 8 - Pseudonymization”"