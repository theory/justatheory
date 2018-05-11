--- 
date: 2010-07-28T19:38:54Z
description: After some prodding from the MySQL Community Manager, some OSCON hacking yields tangible results.
slug: introducing-mytap
title: Introducing MyTAP
aliases: [/computers/databases/mysql/introducing_mysql.html]
tags: [MySQL, myTAP, pgTAP, testing, unit testing, Postgres, database, test-driven database development, test-driven database design]
---

<p>I gave my <a href="http://www.oscon.com/oscon2010/public/schedule/detail/14168" title="Test Driven Database Development">OSCON tutorial</a> (<a href="https://www.slideshare.net/justatheory/test-drivern-database-development" title="slides on SlideShare">slides</a>) last week. It went okay. I spent <em>way</em> too much time helping to get everyone set up with <a href="http://pgtap.org/">pgTAP</a>, and then didn't have time to have the attendees do the exercises, and I had to rush through 2.5 hours of material in 1.5 hours. Yikes! At least the video will be better when it's released (more when that happens).</p>

<p>But as often happens, I was asked whether something like pgTAP exists for <a href="http://www.mysql.com/">MySQL</a>. But this time I was asked by MySQL Community Manager <a href="http://datacharmer.blogspot.com/">Giuseppe Maxia</a>, who also said that he'd tried to create a test framework himself (a fellow Perl hacker!), but that it wasn't as nice as pgTAP. Well, since I was at OSCON and tend to like to hack on side projects while at conferences, and since I hoped that Giuseppe will happily take it over once I've implemented the core, I started hacking on it myself. And today, I'm pleased to announce the release of <a href="http://github.com/theory/mytap/">MyTAP</a> 0.01 (<a href="http://github.com/theory/mytap/downloads">downloads</a>).</p>

<p>Once you've downloaded it, install it against your MySQL server like so:</p>

<pre>mysql -u root &lt; mytap.sql</pre>

<p>Here's a very simple example script:</p>

<pre>&#x002d;&#x002d; Start a transaction.
BEGIN;

&#x002d;&#x002d; Plan the tests.
SELECT tap.plan(1);

&#x002d;&#x002d; Run the tests.
SELECT tap.pass( &#x0027;My test passed, w00t!&#x0027; );

&#x002d;&#x002d; Finish the tests and clean up.
CALL tap.finish();
ROLLBACK;
</pre>

<p>You can run this test from a <code>.sql</code> file using the <code>mysql</code>  client like so:</p>

<pre>mysql -u root &#x002d;&#x002d;disable-pager &#x002d;&#x002d;batch &#x002d;&#x002d;raw &#x002d;&#x002d;skip-column-names &#x002d;&#x002d;unbuffered &#x002d;&#x002d;database try &#x002d;&#x002d;execute &#x0027;source test.sql&#x0027;
</pre>

<p>But that's a PITA and can only run one test at a time. Instead, put all of your tests into a directory, perhaps named <code>tests</code>, each with the suffix “.my”, and use <a href="http://search.cpan.org/perldoc?my_prove"><code>my_prove</code></a> (install <a href="http://search.cpan.org/dist/TAP-Parser-SourceHandler-MyTAP/">TAP::Parser::SourceHandler::MyTAP</a> from CPAN to get it) instead:</p>

<pre>my_prove -u root &#x002d;&#x002d;database try tests/</pre>

<p>For MyTAP's own tests, the output looks like this:</p>

<pre>tests/eq.my ........ ok
tests/hastap.my .... ok
tests/matching.my .. ok
tests/moretap.my ... ok
tests/todotap.my ... ok
tests/utils.my ..... ok
All tests successful.
Files=6, Tests=137,  1 wallclock secs
(0.06 usr  0.03 sys +  0.01 cusr  0.02 csys =  0.12 CPU)
Result: PASS
</pre>

<p>Nice, eh? Of course there are quite a few more assertion functions. See the <a href="http://theory.github.com/mytap/documentation.html">complete documentation</a> for details.</p>

<p>Now, I did my best to keep the interface the same as pgTAP, but there are a few differences:</p>

<ul>
<li>MySQL temporary tables are <a href="http://dev.mysql.com/doc/refman/5.0/en/temporary-table-problems.html">teh suck</a>, so I had to use permanent tables to track test state. To make this more feasible, MyTAP is always installed in its own database, (named “tap” by default), and you must always schema-qualify your use of the MyTAP functions.</li>
<li>Another side-effect of permanent tables is that MyTAP must keep track of test outcomes without colliding with the state from tests running in multiple concurrent connections. So MyTAP uses <a href="http://dev.mysql.com/doc/refman/5.0/en/information-functions.html#function_connection-id"><code>connection_id()</code></a> to keep track of state for a single test run. It also deletes the state when tests <code>finish()</code>, but if there's a crash before then, data can be left in those tables. If the connection ID is ever re-used, this can lead to conflicts. This seems mostly avoidable by using <a href="http://dev.mysql.com/doc/refman/5.0/en/innodb.html">InnoDB</a> tables and transactions in the tests.</li>
<li>The word “is” is strictly reserved by MySQL, so the function that corresponds to pgTAP's <code>is()</code>  is <code>eq()</code> in MyTAP. Similarly, <code>isnt()</code> is called <code>not_eq()</code> in MyTAP.</li>
<li>There is no way to throw an exception in MySQL functions an procedures, so the code cheats by instead performing an illegal operation: selecting from a non-existent column, where the name of that column is the error message. Hinky, but should get the point across.</li>
</ul>

<p>Other than these issues, things went fairly smoothly. I finished up the 0.01 version last night and released it today with most of the core functionality in place. And now I want to find others to take over, as I am not a MySQL hacker myself and thus unlikely ever to use it. If you're interested, my recommendations for things to do next are:</p>

<ul>
<li><p>Move <code>has_table()</code> to its own file, named <code>mytap-schema.sql</code> or similar, and start porting the relevant pgTAP <a href="http://pgtap.org/documentation.html#Table+For+One">table assertion functions</a>, <a href="http://pgtap.org/documentation.html#The+Schema+Things">schema assertion functions</a>, <a href="http://pgtap.org/documentation.html#To+Have+or+Have+Not">have assertion functions</a>, <a href="http://pgtap.org/documentation.html#Feeling+Funky">function and procedure assertion functions</a>, and <a href="http://pgtap.org/documentation.html#Database+Deets">assorted other database object assertion functions</a>.</p></li>
<li><p>Consider an approach to porting the <a href="http://pgtap.org/documentation.html#Pursuing+Your+Query">pgTAP relation comparison assertion functions</a>, perhaps by requiring that prepared statements be created and their names passed to the functions. The functions can then select from the prepared statements into temporary tables to compare results (as in <code>set_eq()</code> and <code>bag_eq()</code>), or use cursors to iterate over the prepared statements row-by-row (as in <code>results_eq()</code>)</p></li>
<li><p>Set up a mail list and a permanent home for MyTAP (I've used GitHub pages for the <a href="http://theory.github.com/mytap/">current site</a>, but I don't think it should remain tightly associated with my GitHub identity). I'd like to see some folks from the MySQL community jump on this.</p></li>
</ul>

<p>So fork on <a href="http://github.com/theory/mytap/" title="MyTAP on GitHub">GitHub</a> or contact me if you'd like to be added as a collaborator (I'm looking at <em>you,</em> <a href="http://datacharmer.blogspot.com/">Giuseppe</a>!).</p>

<p>Hope you find it useful.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/mysql/introducing_mysql.html">old layout</a>.</small></p>


