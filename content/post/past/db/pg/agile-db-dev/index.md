--- 
date: 2013-06-06T19:02:55Z
lastMod: 2022-01-02T17:18:32Z
slug: agile-db-dev
title: Agile Database Development Tutorial
aliases: [/computers/databases/postgresql/agile-db-dev.html]
tags: [Postgres, Git, Sqitch, pgTAP, PgCON]
type: post
---

I gave a tutorial at [PGCon] a couple weeks back, entitled “[Agile Database
Development] with Git, Sqitch, and pgTAP.” It went well, I think. The Keynote
document and an exported PDF have been [posted on PGCon.org][Agile Database
Development], and also uploaded [here] and to [Speaker Deck]. And embedded
below, too. Want to follow along? Clone the [tutorial Git repository] and follow
along. Here’s the teaser:

> Hi, I’m David. I like to write database apps. Just as much as I like to write
> web apps. (Maybe more!) How? Not by relying on bolted-on, half-baked database
> integration tools like migrations, I’ll tell you that!. Instead, I make
> extensive use of best-of-breed tools for source control ([Git]), database unit
> testing ([pgTAP]), and database change management and deployment ([Sqitch]).
> If you’d like to get as much pleasure out of database development as you do
> application development, join me for this tutorial. We’ll develop a sample
> application using the processes and tools I’ve come to depend on, and you’ll
> find out whether they might work for you. Either way, I promise it will at
> least be an amusing use of your time.

<object
  data="{{% link "agile_database_development.pdf" %}}"
  class="slides"
  type="application/pdf"
  title="Agile Database Development">
</object>

  [PGCon]: https://www.pgcon.org/2013/
  [Agile Database Development]: https://www.pgcon.org/2013/schedule/events/615.en.html
  [here]: {{% link "agile_database_development.pdf" %}}
    "Download “Agile Database Development”"
  [Speaker Deck]: https://speakerdeck.com/theory/agile-database-development
    "Speaker Deck: “Agile Database Development”"
  [tutorial Git repository]: https://github.com/sqitchers/agile-flipr
  [Git]: https://git-scm.com
  [pgTAP]: https://pgtap.org/
  [Sqitch]: https://sqitch.org/
