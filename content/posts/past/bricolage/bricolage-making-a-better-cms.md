--- 
date: 2004-10-05T04:06:06Z
slug: bricolage-making-a-better-cms
title: On Making a Better Open-Source CMS
aliases: [/bricolage/competition/making_a_better_cms.html]
tags: [Bricolage, Jeffrey Veen, Content Management, open source, jargon, XHTML, CSS, RSS]
---

<p>Jeffrey Veen <a href="http://www.veen.com/jeff/archives/000622.html" title="Making a Better Open Source CMS">posted</a> some of his thoughts on the (dreary) state of open-source CMSs. So I just thought I'd comment on his thoughts. Keep your salt grains handy.</p>

<p>As a CMS developer, my point of view is quite naturally biased. However, I agree with some of Jeffrey's points, and disagree with others. Well, not disagree so much as wish to qualify. Many of your points betray a certain perspective that does not (and, naturally, cannot) apply to anyone and everyone who is evaluating content management systems. So let me just try to address each of your points and how they related to <a href="http://www.bricolage.cc/" title="Visit the Bricolage CMS Website">Bricolage</a>.</p>

<p><strong>Make it easy to install.</strong> Well, yes, of course, and I'll be the first to admit that Bricolage is difficult to install. But your requirement that you be able to install it from the browser just isn't feasible with a CMS that aims to scale to the needs of a <a href="http://www.who.int/" title="The World Health Organization uses Bricolage">large organization</a>. The security implications alone make give me the heebee-jeebies. It's fine if you want to just manage your own personal site, but not if you're aiming to serve the complex needs of the corporate marketplace.</p>

<p>That said, it might be reasonable to create a simple installer that's useful for doing a local evaluation of a major CMS, one that doesn't rely on an RDBMS and an Apache Web server installation. (<a href="http://www.bestpractical.com/rt/" title="Request Tracker">RT</a> (not a CMS) has been working on a simple executable that uses an embedded database and Web server for those who want to evaluate it. For Bricolage, we at one time had a KNOPPIX CD that one could use to try it out. But for the rest, the best solution is probably an RPM, BSD Package, Debian package, or the like--something that can integrate the application into the base operating system.</p>

<p><strong>Make it easy to get started.</strong> Bricolage is pretty bad about this, mostly because the default templates that come with it suck. That will change eventually, but the bigger issue is that when you have a complex, flexible application, it's tricky to present a simple getting started configuration without locking the user into just using that configuration (witness all the identical Microsoft Home Page sites on the 'Net to see what I mean). But that's no excuse for a system like Bricolage--those who need the more advanced features could take advantage of them when they're ready. It's just a matter of finding the tuits (or the volunteer) to make it happen.</p>

<p><strong>Write task-based documentation <em>first</em>.</strong> In my experience, most complex open-source applications that have task-based documentation have it when they author a book. Yes, most of these systems have grown organically, and documentation gets written as volunteers make the time. But the best documentation I've found for open-source software has tended to be in published books. Though I think that trend is gradually changing.</p>

<p><strong>Separate the administration of the CMS from the editing and managing of content.</strong> In Bricolage, you do not have to switch accounts to have access to the administrative tools. And although the administrative tools are part of the same UI, they have an entirely different section and set of navigation menus. Users who don't have permission to use those tools don't notice them.</p>

<p><strong>Users of a public web site should never--<em>never</em>--be presented with a way to log into the CMS.</strong> Amen, brotha.</p>

<p><strong>Stop it with the jargon already.</strong> Finding good terminology is hard, hard work. Bricolage is broken in this respect in a few ways, but I'm thinking of replacing <q>jobs</q> with <q>fembots</q> in 2.0. What do you think?</p>

<p>But seriously, we try to match the terms to what is commonly used, such as <q>document</q>, <q>site</q>, <q>category</q>, <q>keyword</q>, <q>template</q>, etc. Other terms, such as <q>element</q> (the parts of a document are its elements) are well-integrated into the system, so that users pick up on it very quickly.</p>

<p><strong>Why do you insist Web sites have <em>columns</em>?</strong> I'm in complete agreement with you here. In Bricolage, you can write templates to output any kind of content you want, in any format you want. If you want columns, fine, <a href="http://www.who.int/" title="The WHO generates a three-column layout with Bricolage">generate them from Bricolage</a>. If you want a standards-compliant layout, <a href="http://www.bricolage.cc/" title="Bricolage.cc is valid XHTML 1.1 generated by Bricolage">generate it from Bricolage</a>. You can have <a href="http://et.yahoo.com/" title="ETonline uses Bricolage">1998-era tables with Flash</a> and you can have <a href="http://www.rfa.org/english/rss.xml" title="Radio Free Asia generates RSS Feeds in Bricolage">RSS feeds</a>. Do what you want, make it <a href="http://www.rfa.org/" title="RFA outputs XHTML and CSS from Bricolage">flexible</a> or make it <a href="http://www.plsweb.com/" title="Performance Learning Systems uses Bricolage">complex</a>.</p>

<p>But note that the flexibility comes at the price of complexity. And try as we might to make Bricolage <q>The Macintosh of Content Management Systems,</q> as long as the definition of the term <q>Content Management System</q> is all over the map, commonalities of metaphors, interfaces, and, well, philosophies between CMSs will continue to be all over the map.</p>

<p>But that's just my opinion.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/competition/making_a_better_cms.html">old layout</a>.</small></p>


