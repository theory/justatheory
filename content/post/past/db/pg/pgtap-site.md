--- 
date: 2008-09-20T00:37:06Z
description: The new version features compatibility back as far as PostgreSQL 8.0 and lots of cool functions for testing database schemas. The site's cool, too.
slug: pgtap-site
title: pgTAP 0.10 Released, Web Site Launched
aliases: [/computers/databases/postgresql/pgtap_site.html]
tags: [Postgres, Test Anything Protocol, pgTAP, Perl, PpFoundry, YAPC, Module::Build, Python, PHP]
type: post
---

<p>Two major announcements this week with regard to pgTAP:</p>

<p>First, I've release <a href="http://pgfoundry.org/frs/?group_id=1000389" title="Download pgTAP">pgTAP 0.10</a>. The two major categories of changes are
compatibility as far back as PostgreSQL 8.0 and new functions for testing
database schemas. Here's a quick example:</p>

<pre>
BEGIN;
SELECT plan(7);

SELECT has_table( &#x0027;users&#x0027; );
SELECT has_pk(&#x0027;users&#x0027;);
SELECT col_is_fk( &#x0027;users&#x0027;, ARRAY[ &#x0027;family_name&#x0027;, &#x0027;given_name&#x0027; ]);

SELECT has_table( &#x0027;widgets&#x0027; );
SELECT has_pk( &#x0027;widgets&#x0027; );
SLEECT col_is_pk( &#x0027;widgets&#x0027;, &#x0027;id&#x0027; );
SELECT fk_ok(
    &#x0027;widgets&#x0027;,
    ARRAY[ &#x0027;user_family_name&#x0027;, &#x0027;user_given_name&#x0027; ],
    &#x0027;users&#x0027;,
    ARRAY[ &#x0027;family_name&#x0027;, &#x0027;given_name&#x0027; ],
);

SELECT * FROM finish();
ROLLBACK;
</pre>

<p>Pretty cool, right?
Check <a href="http://pgtap.projects.postgresql.org/documentation.html" title="The complete pgTAP Documentation">the documentation</a> for all the
details.</p>

<p>Speaking of the documentation, that link goes to the
new <a href="http://pgtap.projects.postgresql.org/" title="pgTAP Home">pgTAP Web site</a>. Not only does it include the complete documentation for pgTAP,
but also instructions
for <a href="http://pgtap.projects.postgresql.org/integration.html" title="Integrate pgTAP">integrating pgTAP</a> into your application's
preferred test environment. Right now it includes detailed instructions for
Perl + Module::Build and for PostgreSQL, but has only placeholders for PHP
and Python. Send me the details on those languages or any others into which
you integrate pgTAP tests and I'll update the page.</p>

<p>Oh, and it has a beer. <a href="http://pgtap.projects.postgresql.org/" title="pgTAP">Enjoy</a>.</p>

<p>I think I'll take a little time off from pgTAP next week to
give <a href="http://bricolage.cc/" title="Bricolage">Bricolage</a> some
much-needed love. But as I'll be given another talk on pgTAP
at <a href="http://www.postgresqlconference.org/west08/talks/" title="Talks at PostgreSQL Conference West 2008">PostgreSQL Conference West</a> next month,
worry not! I'll be doing a lot more with pgTAP in the coming weeks.</p>

<p>Oh, and one more thing: I'm looking for consulting work. Give me a shout
(david - at - justatheory.com) if you have some PostgreSQL, Perl, Ruby, MySQL,
or JavaScript hacking you'd like me to do. I'm free through November.</p>

<p>That is all.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/pgtap_site.html">old layout</a>.</small></p>


