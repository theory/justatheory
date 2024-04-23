---
title: PGXN V2 Architecture
slug: pgxn-v2-architecture
date: 2024-04-23T20:08:44Z
lastMod: 2024-04-23T20:08:44Z
description: 
  I've written and published a document outlining the vision and strategy for
  the next iteration of PGXN. It includes diagrams. Everybody loves diagrams.
tags: [Postgres, PGXN, Architecture]
type: post
link: https://wiki.postgresql.org/wiki/PGXN_v2/Architecture
image:
  src: future-extension-ecosystem.png
  link: https://wiki.postgresql.org/wiki/PGXN_v2/Architecture
  title: PGXN Future Architecture
  alt: |
    Diagram of the extension distribution ecosystem vision, featuring “Root
    Registry” in the center and bidirectional lines to four of the surrounding
    nodes: “Web UX”, “Client”, “Packaging”, and “Interactions”. The “Packaging”
    and “Interactions” boxes also have a bi-directional arrow between them, while
    the fifth box, “Stats & Reports”, has a bi--directional arrow pointing to
    “Interactions” and another arrow pointing to “Root Registry”.
  heading: PGXN Future Architecture
  caption: |
    High-level diagram of the six logical services making up the proposed future
    extension distribution architecture. The *Root Registry* sits at the center,
    providing APIs for the other services to consume for their own use cases.
    Trusted instances of those services submit additional data about extensions
    via the *Interactions* service to enhance and enrich the service to better
    inform and delight users.
---

Over on the [Postgres Wiki] I've published a new document for the [PGXN v2]
project: [PGXN v2 Architecture]. It has diagrams, such as the one above! From
the introduction:

> This document outlines the project to build extension distribution,
> discovery, and packaging tools and services to power the growth,
> accessability, and utility of the Postgres extension ecosystem. Taking the
> overall Postgres community as its audience, it defines the services to be
> provided and the architecture to run them, as well as the strategic vision
> to guide project planning and decision-making.
> 
> With the goal to think strategically and plan pragmatically, this document
> describes the former to enable the latter. As such, it is necessarily
> high-level; details, scoping, and planning will be surfaced in more
> project-focused documents.
> 
> Bear in mind that this document outlines an ambitious, long-term strategy.
> If you're thinking that there's too much here, that we'er over-thinking and
> over-designing the system, rest assured that project execution will be
> fundamentally incremental and pragmatic. This document is the guiding light
> for the project, and subject to change as development proceeds and new
> wrinkles arise.

For those of you interested in the future of Postgres extension distribution,
please give it a read! I expect it to guide the planning and implementation of
the the new services and tools in the coming year. Please do consider it a
living document, however; it's likely to need updates as new issues and
patterns emerge. Log in and hit the "watch" tab to stay in the loop for those
changes or the "discussion" tab to leave feedback.

I've also moved the [previously-mentioned] document [Extension Ecosystem: Jobs
and Tools] to the wiki, and created a top-level [PGXN v2] and [PGXN category]
for all PGXN-related content. It also includes another new document, [Service
Disposition], which describes itself as:

> A summary of the ambitiously-envisioned future PGXN services and
> architecture, followed by an examination of existing services and how they
> will gradually be refactored or replaced for the updated platform.

Check it out for how I expect existing services to evolve into or be replaced
by the updated platform.

  [Postgres Wiki]: https://wiki.postgresql.org/
  [PGXN v2]: https://wiki.postgresql.org/wiki/PGXN_v2
  [PGXN v2 Architecture]: https://wiki.postgresql.org/wiki/PGXN_v2/Architecture
  [previously-mentioned]: {{% ref "/post/postgres/pgxn-architecture" %}}
    "Presentation: Introduction to the PGXN Architecture"
  [Extension Ecosystem: Jobs and Tools]: https://wiki.postgresql.org/wiki/Extension_Ecosystem:_Jobs_and_Tools
  [PGXN category]: https://wiki.postgresql.org/wiki/Category:PGXN
  [Service Disposition]: https://wiki.postgresql.org/wiki/PGXN_v2/Service_Disposition
