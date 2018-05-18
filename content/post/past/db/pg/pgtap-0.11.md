--- 
date: 2008-09-24T22:05:06Z
slug: pgtap-0.11
title: pgTAP 0.11 Released
aliases: [/computers/databases/postgresql/pgtap-0.11.html]
tags: [Postgres, pgTAP, testing, unit testing, TAP, Test Anything Protocol]
type: post
---

<p>So I've just released <a href="http://pgfoundry.org/frs/?group_id=1000389" title="pgTAP downloads">pgTAP 0.11</a>. I know I said I wasn't going to work on it for a while, but I changed my mind. Here's what's changed:</p>

<ul>
  <li>Simplified the tests so that they now load <code>test_setup.sql</code> instead of
    setting a bunch of stuff themselves. Now only <code>test_setup.sql</code> needs
    to be created from <code>test_setup.sql.in</code>, and the other <code>.sql</code> files
    depend on it, meaning that one no longer has to specify <code>TAPSCHEMA</code>
    for any <code>make</code> target other than the default.</li>
  <li>Eliminated all uses of <code>E&#x0027;&#x0027;</code> in the tests, so that we don't have to
    process them for testing on 8.0.</li>
  <li>Fixed the spelling of <code>ON_ROLLBACK</code> in the test setup. Can't believe I
    had it with one L in all of the test files before! Thanks to Curtis
    "Ovid" Poe for the spot.</li>
  <li>Added a couple of variants of <code>todo()</code> and <code>skip()</code>, since I can never
    remember whether the numeric argument comes first or second. Thanks to
    PostgreSQL's functional polymorphism, I don't have to. Also, there are
    variants where the numeric value, if not passed, defaults to 1.</li>
  <li>Updated the link to the pgTAP home page in <code>pgtap.sql.in</code>.</li>
  <li>TODO tests can now nest.</li>
  <li>Added <code>todo_start()</code>, <code>todo_end()</code>, and <code>in_todo()</code>.</li>
  <li>Added variants of <code>throws_ok()</code> that test error messages as well as
    error codes.</li>
  <li>Converted some more tests to use <code>check_test()</code>.</li>
  <li>Added <code>can()</code> and <code>can_ok()</code>.</li>
  <li>Fixed a bug in <code>check_test()</code> where the leading whitespace for
    diagnostic messages could be off by 1 or more characters.</li>
  <li>Fixed the <code>installcheck</code> target so that it properly installs PL/pgSQL
    into the target database before the tests run.</li>
</ul>

<p>Now I really am going to do some other stuff for a bit, although I do want to see what I can poach from <a href="http://epictest.org/" title="Epic: More full of fail than any other testing tool">Epic Test</a>. And I <em>do</em> have that <a href="http://www.postgresqlconference.org/west08/talks/" title="PostgreSQL Conference West 2008 Talks">talk</a> on pgTAP next month. So I'll be back with more soon enough.</p>
