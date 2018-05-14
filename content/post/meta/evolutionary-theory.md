---
title: "Evolutionary Theory"
date: 2018-05-14T18:06:29Z
description: "The relaunch of Just a Theory"
tags: [Meta, blogging]
type: post
---

Back in 2013, a slew of new top-level domains became available, and I pounced a
number of them, thinking it'd be a good time to make make a shorter domain my
own. My favorite was theory.pm. In the early years of *Just a Theory,* I wrote
mostly about [Perl] and related topics like [Bricolage]. I thought naming a Perl
blog like a Perl module would be appropriate. By that time I often also wrote
about [Postgres], and didn't want to mix topics. So alongside theory.pm, I also
launched theory.so --- as in "stored objects". Both used a new static design
built on [Octopress] hosted on [GitHub Pages].

Unfortunately, by this time I wrote very little about Perl anymore. I wrote more
on Postgres and [Sqitch], but had to shut down theory.so when the domain
registration became too expensive. I merged it into theory.pm, but it never felt
right to post about Postgres a "Perl blog". I wrote a few link posts about
security and privacy, topics I've been thinking about quite a lot, but it still
felt…off. My [last post] to theory.pm was nearly two years ago.

I've posted little personal writing, either: no politics, photos, travelogues,
essays, or anything else. I let [Twitter], [Instagram], and [Facebook] fill
those gaps.

Lately, though, I've had the itch to write my own site again, both to think
through technical and cultural issues in the technology business, but also to
reclaim a personal space on the net. The recent privacy challenges for the
big social media companies finally drove me from their easy embrace back onto
the open web. But where to put down my hypertext roots?

### My friends, *Just a Theory* returns

In retrospect, I now realize that my original domain name was just right. It's,
me, *just me,* but not topic limited. I can post whatever I want, without
constraints imposed by attention-limited domains. I decided to rehabilitate it.

Of course I could no longer use the [old design]. Inspired by the likes of
[Slashdot], it was boxy, crowded, and 2004-era ugly. I took a few weeks,
imported the theory.pm posts into a new [Hugo]-powered site, and revamped the
design from there. I took on the arduous task to import all the original *Just a
Theory* posts, cleaning up typos and fixing images.

The result is the revamped site you now see in your browser. Or perhaps in your
RSS reader (The old URLs should have redirected you here). The result is
something far better than any of the previous sites:

*   The design emphasizes readability above all. I've made it as clean and
    attractive as I can. The design is my own, and likely full of flaws; don't
    hesitate to holler if you spot anything that doesn't look right.
*   No baggage. The new design uses no JavaScript --- no tracking or analytics
    at all. I'll never host ads, so I don't need all the weight of ad-tech. The
    site is 100% HTML and CSS and nothing else. Only the custom fonts,
    [Source Sans Pro] and [Source Code Pro], add to the bandwidth.
*   No comments. I'm serious about shedding the baggage. Wading through comment
    spam wastes valuable writing and family time, while the comment services
    demand heavy JavaScript and tracking penalties. I generally get very few
    comments, but if you really want to talk to me, hit me up on
    [Twitter] or drop me an email (`david` at this domain).
*   The imported historical posts have no comments, either, but you can still
    browse the [old design] if you need to see them. Each migrated post
    links to the original, as well.
*   History. Previously, it was impossible to find stuff on *Just a Theory.* The
    new design borrows a page from [kottke.org] to provide links to [all the
    tags], and all tag pages are paginated --- as is the home page. Plus, the
    [Archives] lists every post and link post on the site, nice and friendly to
    search engines.
*   Speaking of tags, each has its own RSS feed. If you're only interested in a
    particular subject, you can just subscribe its feed. I will never create
    topic-specific sites again; tagging is *so* much easier.
*   Identity. Yes, this is really *Just a Theory,* and you can tell because the
    TLS certificate proves it. Thanks to [CloudFront] and [Let's Encrypt] for
    making it a cinch.
*   Scaling. It's unlikely *Just a Theory* will be [Fireballed] again anytime
    soon, but since I'm using CloudFront for TLS already, this is a no-brainer.
    *Just a Theory* should be served from somewhere reasonable close to you.

### Punctuated Equilibrium

I plan to write a fair bit over the next few months. I've been thinking a lot
about security, privacy, and the impact of data privacy regulations like the
GDPR on data rights and the technology business in general. I'm happy to once
again have a place to write on such topics. I expect to make social posts too,
to share what's going on with friends and family. Before long, I expect to also
make photoblog-style posts and perhaps integrate micro-blogging posts.

Let's find out if I'm as good as my word.

[Perl]: /tags/perl/ "Posts about “Perl”"
[Bricolage]: /tags/bricolage/ "Posts about Bricolage”"
[Postgres]: /tags/postgres/ "Posts about Postgres"
[Sqitch]: /tags/sqitch/ "Posts about Sqitch"
[Octopress]: http://octopress.org/ "Octopress: A blogging framework for hackers"
[GitHub Pages]: https://pages.github.com
[last post]: /2016/07/wanted-new-svnnotify-maintainer/ "Wanted: New SVN::Notify Maintainer"
[Twitter]: https://twitter.com/theory "@theory on Twitter"
[Instagram]: https://instagram.com/theory "@theory on Instagram"
[Facebook]: https://facebook.com/david.e.wheeler "David E. Wheeler on Facebook"
[Slashdot]: http://slashdot.org
[Hugo]: https://gohugo.io "Hugo open-source static site generator"
[Source Sans Pro]: https://github.com/adobe-fonts/source-sans-pro
[Source Code Pro]: https://github.com/adobe-fonts/source-code-pro
[old design]: https://past.justatheory.com/ "Browse the old Just a Theory"
[kottke.org]: https://kottke.org/ "kottke.org ♥ 20 years of hypertext products"
[all the tags]: /tags/ "Just Theory Tags"
[Archives]: /archives/ "Previously, on Just a Theory"
[AWS CloudFront]: https://aws.amazon.com/cloudfront/ "Amazon CloudFront"
[Let's Encrypt]: https://letsencrypt.org "Let’s Encrypt: Free, automated, and open Certificate Authority."
[Fireballed]: /2012/04/how-not-to-withstand-a-fireballing/ "How Not to Withstand a Fireballing"