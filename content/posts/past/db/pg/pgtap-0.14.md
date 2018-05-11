--- 
date: 2008-10-27T23:42:56Z
slug: pgtap-0.14
title: pgTAP 0.14 Released
aliases: [/computers/databases/postgresql/pgtap-0.14.html]
tags: [Postgres, pgTAP, testing, unit testing, TAP, Test Anything Protocol]
---

<p>I've just released <a href="http://pgfoundry.org/frs/?group_id=1000389"
title="pgTAP Downloads">pgTAP 0.14</a>. This release focuses on getting more
schema functions into your hands, as well as fixing a few issues. Changes:</p>

<ul>
  <li>Added <code>SET search_path</code> statements to <code>uninstall_pgtap.sql.in</code> so that
        it will work properly when TAP is installed in its own schema. Thanks to
        Ben for the catch!</li>
  <li>Added commands to drop <code>pg_version()</code> and <code>pg_version_num()</code>
        to<code>uninstall_pgtap.sql.in</code>.</li>
  <li>Added <code>has_index()</code>, <code>index_is_unique()</code>, <code>index_is_primary()</code>,
        <code>is_clustered()</code>, and <code>index_is_type()</code>.</li>
  <li>Added <code>os_name()</code>. This is somewhat experimental. If you have <code>uname</code>,
        it's probably correct, but assistance in improving OS detection in the
        <code>Makefile</code> would be greatly appreciated. Notably, it does not detect
        Windows.</li>
  <li>Made <code>ok()</code> smarter when the test result is passed as <code>NULL</code>. It was
        dying, but now it simply fails and attaches a diagnostic message
        reporting that the test result was <code>NULL</code>. Reported by Jason Gordon.</li>
  <li>Fixed an issue in <code>check_test()</code> where an extra character was removed
        from the beginning of the diagnostic output before testing it.</li>
  <li>Fixed a bug comparing <code>name[]</code>s on PostgreSQL 8.2, previously hacked
        around.</li>
  <li>Added <code>has_trigger()</code> and <code>trigger_is()</code>.</li>
  <li>Switched to pure SQL implementations of the <code>pg_version()</code> and
        <code>pg_version_num()</code> functions, to simplify including pgTAP in module
        distributions.</li>
  <li>Added a note to <code>README.pgtap</code> about the need to avoid <code>pg_typeof()</code>
        and <code>cmp_ok()</code> in tests run as part of a distribution.</li>
</ul>

<p>Enjoy!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/pgtap-0.14.html">old layout</a>.</small></p>


