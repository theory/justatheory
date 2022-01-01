--- 
date: 2004-10-05T04:06:06Z
slug: making-a-better-cms
title: On Making a Better Open-Source CMS
aliases: [/bricolage/competition/making_a_better_cms.html]
tags: [Bricolage, Jeffrey Veen, Content Management, Open Source, Jargon, XHTML, CSS, RSS]
type: post
---

Jeffrey Veen [posted] some of his thoughts on the (dreary) state of open-source
CMSs. So I just thought I'd comment on his thoughts. Keep your salt grains
handy.

As a CMS developer, my point of view is quite naturally biased. However, I agree
with some of Jeffrey's points, and disagree with others. Well, not disagree so
much as wish to qualify. Many of your points betray a certain perspective that
does not (and, naturally, cannot) apply to anyone and everyone who is evaluating
content management systems. So let me just try to address each of your points
and how they related to [Bricolage].

**Make it easy to install.** Well, yes, of course, and I'll be the first to
admit that Bricolage is difficult to install. But your requirement that you be
able to install it from the browser just isn't feasible with a CMS that aims to
scale to the needs of a [large organization]. The security implications alone
make give me the heebee-jeebies. It's fine if you want to just manage your own
personal site, but not if you're aiming to serve the complex needs of the
corporate marketplace.

That said, it might be reasonable to create a simple installer that's useful for
doing a local evaluation of a major CMS, one that doesn't rely on an RDBMS and
an Apache Web server installation. ([RT][] (not a CMS) has been working on a
simple executable that uses an embedded database and Web server for those who
want to evaluate it. For Bricolage, we at one time had a KNOPPIX CD that one
could use to try it out. But for the rest, the best solution is probably an RPM,
BSD Package, Debian package, or the like--something that can integrate the
application into the base operating system.

**Make it easy to get started.** Bricolage is pretty bad about this, mostly
because the default templates that come with it suck. That will change
eventually, but the bigger issue is that when you have a complex, flexible
application, it's tricky to present a simple getting started configuration
without locking the user into just using that configuration (witness all the
identical Microsoft Home Page sites on the 'Net to see what I mean). But that's
no excuse for a system like Bricolage--those who need the more advanced features
could take advantage of them when they're ready. It's just a matter of finding
the tuits (or the volunteer) to make it happen.

**Write task-based documentation *first*.** In my experience, most complex
open-source applications that have task-based documentation have it when they
author a book. Yes, most of these systems have grown organically, and
documentation gets written as volunteers make the time. But the best
documentation I've found for open-source software has tended to be in published
books. Though I think that trend is gradually changing.

**Separate the administration of the CMS from the editing and managing of
content.** In Bricolage, you do not have to switch accounts to have access to
the administrative tools. And although the administrative tools are part of the
same UI, they have an entirely different section and set of navigation menus.
Users who don't have permission to use those tools don't notice them.

**Users of a public web site should never--*never*--be presented with a way to
log into the CMS.** Amen, brotha.

**Stop it with the jargon already.** Finding good terminology is hard, hard
work. Bricolage is broken in this respect in a few ways, but I'm thinking of
replacing “jobs” with “fembots” in 2.0. What do you think?

But seriously, we try to match the terms to what is commonly used, such as
“document”, “site”, “category”, “keyword”, “template”, etc. Other terms, such as
“element” (the parts of a document are its elements) are well-integrated into
the system, so that users pick up on it very quickly.

**Why do you insist Web sites have *columns*?** I'm in complete agreement with
you here. In Bricolage, you can write templates to output any kind of content
you want, in any format you want. If you want columns, fine, [generate them from
Bricolage]. If you want a standards-compliant layout, [generate it from
Bricolage]. You can have [1998-era tables with Flash] and you can have [RSS
feeds]. Do what you want, make it [flexible] or make it [complex].

But note that the flexibility comes at the price of complexity. And try as we
might to make Bricolage “The Macintosh of Content Management Systems,” as long
as the definition of the term “Content Management System” is all over the map,
commonalities of metaphors, interfaces, and, well, philosophies between CMSs
will continue to be all over the map.

But that's just my opinion.

  [posted]: https://veen.com/jeff/archives/000622.html
    "Making a Better Open Source CMS"
  [Bricolage]: https://bricolagecms.org/ "Visit the Bricolage CMS Website"
  [large organization]: https://www.who.int
    "The World Health Organization uses Bricolage"
  [RT]: https://bestpractical.com/request-tracker "Request Tracker"
  [generate them from Bricolage]: https://www.who.int/
    "The WHO generates a three-column layout with Bricolage"
  [generate it from Bricolage]: https://bricolagecms.org/
    "Bricolage.cc is valid XHTML 1.1 generated by Bricolage"
  [1998-era tables with Flash]: https://www.etonline.com "ETonline uses Bricolage"
  [RSS feeds]: https://www.rfa.org/english/rss.xml
    "Radio Free Asia generates RSS Feeds in Bricolage"
  [flexible]: https://www.rfa.org/ "RFA outputs XHTML and CSS from Bricolage"
  [complex]: https://www.plsweb.com/
    "Performance Learning Systems uses Bricolage"
