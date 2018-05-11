--- 
date: 2009-03-30T00:30:00Z
slug: pgtap-0.20
title: pgTAP 0.20 Infiltrates Community
aliases: [/computers/databases/postgresql/pgtap-0.20.html]
tags: [Postgres, pgTAP, testing, unit testing, TAP, PL/pgSQL]
---

<p>I did all I could to stop it, but it just wasn’t possible. <a
href="http://pgtap.projects.postgresql.org/">pgTAP 0.20</a> has somehow made
its way from my Subversion server and infiltrated the PostgreSQL community.
Can nothing be done to stop this menace? Its use leads to cleaner, more
stable, and more-safely refactored code. This insanity must be stopped! Please
review the following list of its added vileness since 0.19 to determine how
you can stop the terrible, terrible influence on your PostgreSQL unit-testing
practices that is pgTAP:</p>

<ul>
<li>Changed the names of the functions tested in <code>sql/do_tap.sql</code> and
<code>sql/runtests.sql</code> so that they are less likely to be ordered differently
given varying collation orders provided in different locales and by
different vendors. Reported by Ingmar Brouns.</li>
<li>Added the <code>--formatter</code> and <code>--archive</code> options to <code>pg_prove</code>.</li>
<li>Fixed the typos in <code>pg_prove</code> where the output of <code>--help</code> listed
<code>--test-match</code> and <code>--test-schema</code> instead of <code>--match</code> and <code>--schema</code>.</li>
<li>Added <code>has_cast()</code>, <code>hasnt_cast()</code>, and <code>cast_context_is()</code>.</li>
<li>Fixed a borked function signature in <code>has_trigger()</code>.</li>
<li>Added <code>has_operator()</code>, <code>has_leftop()</code>, and <code>has_rightop()</code>.</li>
<li>Fixed a bug where the order of columns found for multicolum indexes by
<code>has_index()</code> could be wrong. Reported by Jeff Wartes. Thanks to Andrew
Gierth for help fixing the query.</li>
</ul>

<p>Don’t make the same mistake I did, where I wrote a lot of pgTAP tests for a client, and now testing database upgrades from 8.2 to 8.3 is just too reliable! <strong>YOU HAVE BEEN WARNED.</strong></p>

<p>Good luck with your mission.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/pgtap-0.20.html">old layout</a>.</small></p>


