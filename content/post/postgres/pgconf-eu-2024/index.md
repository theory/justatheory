---
title: PGConf & Extension Ecosystem Summit EU 2024
slug: pgconf-extension-summit-eu
date: 2024-10-29T22:04:22Z
lastMod: 2024-10-29T22:04:22Z
description: |
  Notes and links from the Extension Ecosystem Summit EU 2024 and my first time
  at PGConf EU. Plus thoughts and photos from ancient sites and archeological
  museums I visited.
tags: [Postgres, Extensions, PGConf, Summit, Archaeology, Athens, Greece, Acropolis, Mycenae, Elgin Marbles]
type: post
image:
  src: pgconf-2024-logo.svg
  class: left
  width: 100px
  title: PostgreSQL Conference Europe 2024
  alt: The PGConf 2024 logo
  copyright: 2024 PostgreSQL Europe
---

Last week I MCed the first Extension Ecosystem Summit EU and attended my first
at PGConf EU in Athens, Greece. Despite my [former career as an archaeologist]
--- with a focus on Mediterranean cultures, no less! --- this was my first
visit to Greece. My favorite moment was the evening after the Summit, when I
cut out of a networking shindig to walk to [Pláka] and then circumnavigate the
[Acropolis]. I mean just look at this place!

{{% figure
    src       = "nite-acropolis.jpeg"
    alt       = "Nighttime photo of the Acropolis of Athens"
    caption   = "The Acropolis of Athens on the evening of October 22, 2024."
    copyright = "2024 David E. Wheeler"
%}}

Highlight of the trip for sure. But the Summit and conference were terrific,
as well.

Extension Ecosystem Summit
--------------------------

[Floor Drees] kindly organized The Extension Ecosystem Summit EU, the
follow-up to the [PGConf.dev original]. While the Vancouver Summit focused on
developers, we tailored this iteration to users. I started the gathering with
a condensed version of my [POSETTE talk], "State of the Postgres Extension
Ecosystem", but updated with a [Trunk OCI Distribution] demo. Links:

*   [PDF]({{% link "state-of-the-ecosystem-eu.pdf" %}})
*   [PDF with Notes]({{% link "state-of-the-ecosystem-eu-notes.pdf" %}})
*   [Keynote]({{% link "state-of-the-ecosystem-eu.key" %}})

We then moved into a lightning round of 10 minute introductions to a variety
of extensions:

*   [Jimmy Angelakos] showed off [pg_statviz], a "minimalist extension and
    utility pair for time series analysis and visualization of PostgreSQL
    internal statistics".
*   [Adam Hendel] gave a brief history of [pgmq], is a "lightweight message
    queue like AWS SQS and RSMQ, but on Postgres."
*   [Gülçin Yıldırım Jelínek] introduced [pgzx], "a library for developing
    PostgreSQL extensions written in [Zig]."
*   [James Sewell] talked about [pgvectorscale] and [pgai] for managing
    machine training workloads on Postgres.
*   [Alastair Turner] described [pg_tde], an extension that provides
    transparent data encryption for Postgres.

Quite the whirlwind! There followed open discussion, in which each maintainer
went to a corner to talk to attendees about contributing to their extensions.
Details to come in a more thorough writeup on the [Tembo blog], but I personally
enjoyed some fascinating discussions about extension distribution challenges.

PGConf.eu
---------

Following the Summit, I attended several thought-provoking and provocative
presentations at [PGConf.eu], which took place at the same hotel, conveniently
enough.

{{% figure
    src       = "floor-at-pgconf.jpeg"
    alt       = "Floor Drees speaking at a podium, next to a slide reading “Why Postgres?”"
    caption   = "Floor Drees speaking at PGConf.eu 2024."
    copyright = "2024 David E. Wheeler"
%}}

*   In the conference keynote, [Stacey Haysler] explained the [The PostgreSQL
    License Fee]. I'm pleased to say that my employer "pays" license fee!
*   [Andres Freund] (yes, [that one]) summarized [NUMA vs PostgreSQL],
    covering some of the issues and opportunities for optimization of
    PostgreSQL on servers using the [NUMA] multi-processor memory
    architecture.
*   [Heikki Linnakangas] offered an overview of [The Wire Protocol], that bit
    of PostgreSQL technology that lets clients talk to PostgreSQL.
*   [Ophir Lojkine] and Thomas Guillemard [showed] how a pretty sweet
    framework, [SQLPage], lets archaeologists like Thomas write complete web
    applications in pure SQL, enabling rapid data entry while in the field.
*   [Tomas Vondra]'s [Performance Archaeology] dug into the history of
    PostgreSQL improvements, mapping their compounding returns over time.
*   [Floor Drees] (photo above) talked about [Supporting extensions, but
    really now], making a strong case for the need to organize infrastructure
    to support the broader extension ecosystem.

There were many more talks, but clearly I tend to be drawn to the most
technical, core-oriented topics. And also archaeology.

Museums
-------

Speaking of which, I made time to visit two museums while in Athens. First up
was the [National Archaeological Museum of Athens], where I was delighted to
explore the biggest collection of [Mycenaean] artifacts I've ever seen,
including massive collections from the excavations of [Heinrich Schliemann].
So much great [Bronze Age] stuff here. I mean, just look at this absolute unit:

{{% figure
    src       = "mycenaean-krater.jpeg"
    alt       = "Photo of a Mycenaean Krater featuring a horse-drawn chariot"
    caption   = `From the museum description: “Fragment of a krater depicting a chariot with
two occupants. A male figure holding a staff walks in front of the chariot.
Much of the Mycenaean Pictorial Style pottery (14th-12th centuries BC) with
representations of humans, chariots, horses and bulls on large kraters, was
produced at Berbati in the Argolid and exported to Cyprus, where it was widely
imitated. Birds, fish, wild goats or imaginary creatures (i.e. sphinxes) occur
on other types of vessels, such as jugs and stirrup jars. Usually only
fragments of these vases survive in mainland Greece from settlement contexts.
In Cyprus, however, complete vases are preserved, placed as grave gifts in
tombs.”`
    copyright = "Photo 2024 David E. Wheeler"
%}}

The animal decorations on Mycenaean and [Akrotiri] pottery is simply
delightful. I also enjoyed the Hellenistic stuff, and seeing the famed
[Antikythera Mechanism] filled my nerd heart with joy. A good 3 hours poking
around; I'll have to go back and spend a few days there sometime. Thanks to my
pal [Evan Stanton] for gamely wandering around this fantastic museum with me.

Immediately after the PGConf.eu closing session, I dashed off to the
[Acropolis Museum], which stays open till 10 on Fridays. Built in 2009, this
modern concrete-and-glass building exhibits several millennia of artifacts and
sculpture exclusively excavated from the Acropolis or preserved from its
building façades. No photography allowed, alas, but I snapped this photo
looking out on the Acropolis from the top floor.

{{% figure
    src       = "acropolis-museum.jpeg"
    alt       = "Photo of the Acropolis as viewed from inside the Acropolis Museum."
    caption   = `The Acropolis as viewed from inside the Acropolis Museum. Friezes preserved
from the Parthenon inside the museum reflect in the glass, as does, yes, your
humble photographer.`
    copyright = "2024 David E. Wheeler"
%}}

I was struck by the beauty and effectiveness of the displays. It easily puts
the lie to the assertion that the [Elgin Marbles] must remain in the British
Museum to protect them. I saw quite a few references to the stolen sculptures,
particularly empty spots and artfully sloppy casts from the originals, but the
building itself makes the strongest case that the marbles should be returned.

But even without them there remains a ton of beautiful sculpture to see.
Highly recommended!

Back to Work
------------

Now that my sojourn in Athens has ended, I'm afraid I must return to work. I
mean, the event was work, too; I talked to a slew of people about a number of
projects in flight. More on those soon.

  [former career as an archaeologist]: {{% ref "/post/past/personal/five-things" %}}#2-i-used-to-be-an-archaeologist
    "Five Things You Don't Know About Me"
  [Pláka]: https://en.wikipedia.org/wiki/Plaka "Wikipedia: Plaka"
  [Acropolis]: https://en.wikipedia.org/wiki/Acropolis_of_Athens
    "Wikipedia: Acropolis of Athens"
  [Floor Drees]: https://dev.to/@floord
  [PGConf.dev original]: {{% ref "/post/postgres/extension-ecosystem-summit" %}}
    "Extension Ecosystem Summit 2024"
  [POSETTE talk]: {{% ref "/post/postgres/posette-2024" %}}#i-also-spoke
    "POSETTE 2024"
  [Trunk OCI Distribution]: {{% ref "/post/postgres/trunk-oci-poc" %}}#demo
    "POC: Distributing Trunk Binaries via OCI — Demo"
  [Jimmy Angelakos]: https://www.linkedin.com/in/vyruss/
  [pg_statviz]: https://pgxn.org/dist/pg_statviz/ "PGXN: pg_statviz"
  [Adam Hendel]: https://www.linkedin.com/in/adam-hendel/
  [pgmq]: https://pgxn.org/dist/pgmq/ "PGXN: pgmq"
  [Gülçin Yıldırım Jelínek]: https://www.linkedin.com/in/gulcinyildirim/
  [pgzx]: https://github.com/xataio/pgzx "GitHub: xataio/pgzx"
  [Zig]: https://ziglang.org/ "Zig Programming Language"
  [James Sewell]: https://www.linkedin.com/in/james-blackwood-sewell/
  [pgvectorscale]: https://github.com/timescale/pgvectorscale "GitHub: timescale/pgvectorscale"
  [pgai]: https://github.com/timescale/pgai "GitHub: timescale/pgai"
  [Alastair Turner]: https://www.linkedin.com/in/decodableminion/
  [pg_tde]: https://github.com/percona/pg_tde "GitHub: percona/pg_tde"
  [Tembo blog]: https://tembo.io/blog/ "Tembo’s Blog"
  [PGConf.eu]: https://2024.pgconf.eu "PostgreSQL Conference Europe 2024"
  [Stacey Haysler]: https://www.linkedin.com/in/stacey-haysler-ssh/
  [The PostgreSQL License Fee]: https://www.postgresql.eu/events/pgconfeu2024/schedule/session/5869/
  [Andres Freund]: https://www.linkedin.com/in/andres-freund/
  [that one]: https://www.npr.org/2024/04/11/1244174104
    "NPR: One engineer may have saved the world from a massive cyber attack"
  [NUMA vs PostgreSQL]: https://www.postgresql.eu/events/pgconfeu2024/schedule/session/5839/
  [NUMA]: https://en.wikipedia.org/wiki/Non-uniform_memory_access
    "Wikipedia: Non-uniform memory access"
  [Heikki Linnakangas]: https://www.linkedin.com/in/heikki-linnakangas-6b58bb203/
  [The Wire Protocol]: https://www.postgresql.eu/events/pgconfeu2024/schedule/session/5897/
  [Ophir Lojkine]: https://ophir.dev
  [showed]: https://www.postgresql.eu/events/pgconfeu2024/schedule/session/5707/ 
    "Unearthing the Past with PostgreSQL: How Open Source is Revolutionizing Digital Archaeology"
  [SQLPage]: https://sql.datapage.app/
  [Tomas Vondra]: https://github.com/tvondra
  [Performance Archaeology]: https://www.postgresql.eu/events/pgconfeu2024/schedule/session/5585/
  [Supporting extensions, but really now]: https://www.postgresql.eu/events/pgconfeu2024/schedule/session/5946/
  [National Archaeological Museum of Athens]: https://www.namuseum.gr/en/
  [Mycenaean]: https://en.wikipedia.org/wiki/Mycenaean_Greece
    "Wikipedia: https://en.wikipedia.org/wiki/Mycenaean Greece"
  [Heinrich Schliemann]: https://en.wikipedia.org/wiki/Heinrich_Schliemann
    "Wikipedia: Heinrich Schliemann"
  [Bronze Age]: https://en.wikipedia.org/wiki/Bronze_Age "Wikipedia: Bronze Age"
  [Akrotiri]: https://en.wikipedia.org/wiki/Akrotiri_(prehistoric_city)
    "Wikipedia: Akrotiri (prehistoric city)"
  [Hellenistic]: https://en.wikipedia.org/wiki/Hellenistic_period
    "Wikipedia: Hellenistic period"
  [Antikythera Mechanism]: https://en.wikipedia.org/wiki/Antikythera_mechanism
    "Wikipedia: Antikythera mechanism"
  [Evan Stanton]: https://www.linkedin.com/in/evan-hunter-stanton/
  [Acropolis Museum]: https://theacropolismuseum.gr/en/
  [Elgin Marbles]: https://en.wikipedia.org/wiki/Elgin_Marbles
    "Wikipedia: Elgin Marbles"
