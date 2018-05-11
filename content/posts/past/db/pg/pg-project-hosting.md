--- 
date: 2009-12-28T01:34:59Z
slug: pg-project-hosting
title: Quest for PostgreSQL Project Hosting
aliases: [/computers/databases/postgresql/pg-project-hosting.html]
tags: [Postgres, CPAN, Perl, PpFoundry, GForge]
---

<p>The <a href="http://pgtap.projects.postgresql.org/">pgTAP</a> project is currently hosted by <a href="http://pgfoundry.org/">pgFoundry</a>. This is an old version of <a href="http://gforge.org/">GForge</a>, and from what I understand, highly modified for the PostgreSQL project. That’s fine, except that it apparently makes it impossible for anyone to find the tuits to upgrade it to newer versions.</p>

<p>And it needs upgrading. One annoying thing I noticed is that the URLs for release files include an integer in them. For example, the URL to download pgTAP 0.23 is <a href="http://pgfoundry.org/frs/download.php/2511/pgtap-0.23.tar.bz2">http://pgfoundry.org/frs/download.php/2511/pgtap-0.23.tar.bz2</a>. See the “25111” there? It appears to be a primary key value or something, but is completely irrelevant for a release URL. I would much prefer that the URL be something like http://pgfoundry.org/frs/download.php/pgtap-0.23.tar.bz2 or, even better, http://pgfoundry.org/projects/pgtap/frs/pgtap-0.23.tar.bz2. But such is not the case now.</p>

<p>Another issue is hosting. I've registered pgtap.org to use for hosting the pgTAP Web site, but there is no support for pointing a hostname at a pgFoundry/GForge site.</p>

<p>These issues could of course be worked out if someone had the tuits to take them on, but apparently there is no one. So I'm looking to move.</p>

<p>The question is, where to? I could get a paid GitHub account (the pgTAP source is already on GitHub) and be able to have a pgTAP site on pgtap.org from there, so that’s a plus. And I can do file releases, too, in which case the URL format would be something like http://cloud.github.com/downloads/theory/pgtap/pgtap-0.23.tar.bz2, which isn’t ideal, but is a hell of a lot better than a URL with a sequence number in it. I could put them on the hosted site, too, in which case they'd have whatever URL I wanted them to have.</p>

<p>There are only two downsides I can think of to moving to GitHub:</p>

<ol>
<li><p>No mail list support. The pgTAP mail list has next to no traffic so far, so I'm not sure this is a big deal. I could also set up a list elsewhere, like <a href="http://librelist.com/">Librelist</a>, if I really needed one. I'd prefer to have @pgtap.org mail lists, but it’s not a big deal.</p></li>
<li><p>I would lose whatever community presence I gain from hosting on pgFoundry. I know that when I release a Perl module to CPAN that it will be visible to lots of people in the Perl community, and automatically searchable via <a href="http://search.cpan.org/">search.cpan.org</a> and other tools. A CPAN release is a release to the Perl community.</p>

<p>There is nothing like this for PostgreSQL. pgFoundry is the closest thing, and, frankly, nowhere near as good (pgFoundry’s search rankings have always stunk). So if I were to remove my projects from pgFoundry, how could I make them visible to the community? Is there any other central repository of or searchable list of third-party PostgreSQL offerings?</p></li>
</ol>

<p>So I'm looking for advice. Does having an email list matter? If I can get pgTAP announcements included in the <a href="http://www.postgresql.org/community/weeklynews/">PostgreSQL Weekly News</a>, is that enough community visibility? Do you know of a nice project hosting site that offers hosting, mail lists, download mirroring and custom domain handling?</p>

<p>I'll follow up with a summary of what I've found in a later post.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/pg-project-hosting.html">old layout</a>.</small></p>


