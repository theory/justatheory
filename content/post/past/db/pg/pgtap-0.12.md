--- 
date: 2008-10-11T04:50:03Z
slug: pgtap-0.12
title: pgTAP 0.12 Released
aliases: [/computers/databases/postgresql/pgtap-0.12.html]
tags: [Postgres, pgTAP, testing, unit testing, TAP, Test Anything Protocol]
type: post
---

<p>In anticipation of my <a href="http://www.postgresqlconference.org/west08/talks/" title="PostgreSQL Conference West 2008 Talks">PostgreSQL Conference West 2008 talk</a> on Sunday, I've just released <a href="http://pgfoundry.org/frs/?group_id=1000389" title="pgTAP Downloads">pgTAP 0.12</a>. This is a minor release with just a few tweaks:</p>

<ul>
  <li>Updated <code>plan()</code> to disable warnings while it creates its
    tables. This means that <code>plan()</code> no longer send NOTICE messages
    when they run, although tests still might, depending on the setting of
    <code>client_min_messages</code>.</li>
  <li>Added <code>hasnt_table()</code>, <code>hasnt_view()</code>,
    and <code>hasnt_column()</code>.</li>
  <li>Added <code>hasnt_pk()</code>, <code>hasnt_fk()</code>, <code>col_isnt_pk()</code>,
  and <code>col_isnt_fk()</code>.</li>
  <li>Added missing <code>DROP</code> statements
    to <code>uninstall_pgtap.sql.in</code>.</li>
</ul>

<p>I also have an idea to add functions that return the server version number (and each of the version number parts) and an OS string, to make testing things on various versions of PostgreSQL and on various operating systems a lot simpler.</p>

<p>I think I'll also spend some time in the next few weeks on an article explaining exactly what pgTAP is and why you'd want to use it. Provided, of course, I can find the tuits for that.</p>
