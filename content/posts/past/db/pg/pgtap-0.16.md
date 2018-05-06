--- 
date: 2009-02-03T18:19:38Z
slug: pgtap-0.16
title: pgTAP 0.16 in the Wild
aliases: [/computers/databases/postgresql/pgtap-0.16.html]
tags: [Postgres, PL/pgSQL, TAP, pgTAP, SQL, testing]
---

<p>I've been writing a lot tests for a client in <a href="http://pgtap.projects.postgresql.org/" title="pgTAP: Unit Testing for PostgreSQL">pgTAP</a> lately. It's given me a lot to think about in terms of features I need and best practices in writing tests. I'm pleased to say that, overall, it has been absolutely invaluable. I'm doing a <em>lot</em> of database refactoring, and having the safety of solid test coverage has been an absolute godsend. pgTAP has done a lot to free me from worry about the effects of my changes, as it ensures that everything about the databases continue to just work.</p>

<p>Of course, that's not to say that I don't scew up. There are times when my refactorings have introduced new bugs or incompatibilities; after all, the tests I write of existing functionality extend only so far as I can understand that functionality. But as such issues come up, I just add regression tests, fix the issues, and move on, confident in the knowledge that, as long as the tests continue to be run regularly, those bugs will never come up again. Ever.</p>

<p>As a result, I'll likely be posting a bit on best practices I've found while writing pgTAP tests. As I've been writing them, I've started to find the cow paths that help me to keep things sane. Most helpful is the large number of assertion functions that pgTAP offers, of course, but there are a number of techniques I've been developing as I've worked. Some are better than others, and still others suggest that I need to find other ways to do things (you know, when I'm cut-and-pasting a lot, there must be another way, though I've always done a lot of cut-and-pasting in tests).</p>

<p>In the meantime, I'm happy to announce the release of pgTAP 0.16. This version includes a number of improvements to the installer (including detection of Perl and <a href="http://search.cpan.org/dist/Test-Harness/" title="TAP::Harness on CPAN">TAP::Harness</a>, which are required to use the included <code>pg_prove</code> test harness app. The installer also has an important bug fix that greatly increases the chances that the <code>os_name()</code> function will actually know the name of your operating system. And of course, there are new test functions:</p>

<ul>
  <li><code>has_schema()</code> and <code>hasnt_schema()</code>, which test for the presence of absence of a schema</li>
  <li><code>has_type()</code> and <code>hasnt_type()</code>, which test for the presence and absence of a data type, domain, or enum</li>
  <li><code>has_domain()</code> and <code>hasnt_domain()</code>, which test for the presence and absence of a data domain</li>
  <li><code>has_enum()</code> and <code>hasnt_enum()</code>, which test for the presence and absence of an enum</li>
  <li><code>enum_has_lables()</code> which tests that an enum has an expected list of labels</li>
</ul>

<p>As usual, you can <a href="http://pgfoundry.org/frs/?group_id=1000389" title="Download pgTAP">download</a> the latest release from pgFoundry. Visit the <a href="http://pgtap.projects.postgresql.org/" title="pgTAP: Unit Testing for PostgreSQL">pgTAP site</a> for more information and for documentation.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/pgtap-0.16.html">old layout</a>.</small></p>


