--- 
date: 2008-06-07T05:24:27Z
slug: introducing-pgtap
title: Introducing pgTAP
aliases: [/computers/databases/postgresql/introducing_pgtap.html]
tags: [Postgres, TAP, Test Anything Protocol, Perl, testing, unit testing]
---

<p>So I started working on a new PostgreSQL data type this week. More on that
soon; in the meantime, I wanted to create a test suite for it, and wasn't sure
where to go. The only PostgreSQL tests I've seen are those distributed with
Elein Mustain's
<a href="http://www.varlena.com/varlena/GeneralBits/Tidbits/email_test.sql" title="Testing the email data type">tests</a>

for the email data type she created in a
<a href="http://www.varlena.com/GeneralBits/128.php" title="Base Type using Domains">PostgreSQL General Bits</a>
posting from a couple of years ago. I used the same approach myself for my <a
href="http://pgfoundry.org/projects/gtin/" title="GTIN data type project
info">GTIN data type</a>, but it was rather hard to use: I had to pay very close
attention to what was output in order to tell the description output from the
test output. It was quite a PITA, actually.</p>

<p>This time, I started down the same path, then then started thinking about
Perl testing, where each unit test, or <q>assertion,</q> in the xUnit
parlance, triggers output of a single line of information indicating whether
or not a test succeeded. It occurred to me that I could just run a bunch of
queries that returned booleans to do my testing. So my first stab looked
something like this:</p>

<pre>
\set ON_ERROR_STOP 1
\set AUTOCOMMIT off
\pset format unaligned
\pset tuples_only
\pset pager
\pset null &#x0027;[NULL]&#x0027;

SELECT foo() = &#x0027;bar&#x0027;;
SELECT foo(1) = &#x0027;baz&#x0027;;
SELECT foo(2) = &#x0027;foo&#x0027;;
</pre>

<p>The output looked like this:</p>

<pre>
% psql try -f ~/Desktop/try.sql
t
t
t
</pre>

<p>Once I started down that path, and had written ten or so tests, It suddenly
dawned on me that the Perl
<a href="http://search.cpan.org/perldoc?Test::More" title="Test::More on CPAN">Test::More</a>
module and its core <code>ok()</code> subroutine worked just like that. It
essentially just depends on a boolean value and outputs text based on that
value. A couple minutes of hacking and I had this:</p>

<pre>
CREATE TEMP SEQUENCE __tc__;
CREATE OR REPLACE FUNCTION ok ( boolean, text ) RETURNS TEXT AS $$
    SELECT (CASE $1 WHEN TRUE THEN &#x0027;&#x0027; ELSE &#x0027;not &#x0027; END) || &#x0027;ok&#x0027;
        || &#x0027; &#x0027; || NEXTVAL(&#x0027;__tc__&#x0027;)
        || CASE $2 WHEN &#x0027;&#x0027; THEN &#x0027;&#x0027; ELSE COALESCE( &#x0027; - &#x0027; || $2, &#x0027;&#x0027; ) END;
$$ LANGUAGE SQL;
</pre>

<p>I then rewrote my test queries like so:</p>

<pre>
\echo 1..3
SELECT ok( foo() = &#x0027;bar&#x0027;   &#x0027;foo() should return &quot;bar&quot;&#x0027; );
SELECT ok( foo(1) = &#x0027;baz&#x0027;, &#x0027;foo(1) should return &quot;baz&quot;&#x0027; );
SELECT ok( foo(2) = &#x0027;foo&#x0027;, &#x0027;foo(2) should return &quot;foo&quot;&#x0027; );
</pre>

<p>Running these tests, I now got:</p>

<pre>
% psql try -f ~/Desktop/try.sql
1..3
ok 1 - foo() should return &quot;bar&quot;
ok 2 - foo(1) should return &quot;baz&quot;
ok 3 - foo(2) should return &quot;foo&quot;
</pre>

<p>And, <strong><em>BAM!</em></strong> I had the beginning of a test framework
that emits pure <a href="http://testanything.org/" title="Test Anything Protocol">TAP</a>
output.</p>

<p>Well, I was so excited about this that I put aside my data type for a few
hours and banged out the rest of the framework. Why was this exciting to me?
Because now I can use a standard test harness to run the tests, even mix them
in with other TAP tests on any project I might work on. Just now, I quickly
hacked together a quick script to run the tests:</p>

<pre>
use TAP::Harness;

my $harness = TAP::Harness->new({
    timer   => $opts->{timer},
    exec    => [qw( psql try -f )],
});

$harness->runtests( @ARGV );
</pre>

<p>Now I'm able to run the tests like so:</p>

<pre>
% try ~/Desktop/try.sql        
/Users/david/Desktop/try........ok   
All tests successful.
Files=1, Tests=3,  0 wallclock secs ( 0.00 usr  0.00 sys +  0.01 cusr  0.00 csys =  0.01 CPU)
Result: PASS
</pre>

<p>Pretty damn cool! And lest you wonder whether such a suite of TAP-emitting
test functions is suitable for testing SQL, here are a few examples of tests
I've written:</p>

<pre>
&#x002d;&#x002d; Plan the tests.
SELECT plan(4);

&#x002d;&#x002d; Emit a diagnostic message for users of different locales.
SELECT diag(
    E&#x0027;These tests expect LC_COLLATE to be en_US.UTF-8,\n&#x0027;
  || &#x0027;but yours is set to &#x0027; || setting || E&#x0027;.\n&#x0027;
  || &#x0027;As a result, some tests may fail. YMMV.&#x0027;
)
  FROM pg_settings
 WHERE name = &#x0027;lc_collate&#x0027;
   AND setting &lt;&gt; &#x0027;en_US.UTF-8&#x0027;;

SELECT is( &#x0027;a&#x0027;, &#x0027;a&#x0027;, &#x0027;&quot;a&quot; should = &quot;a&quot;&#x0027; );
SELECT is( &#x0027;B&#x0027;, &#x0027;B&#x0027;, &#x0027;&quot;B&quot; should = &quot;B&quot;&#x0027; );

CREATE TEMP TABLE try (
    name lctext PRIMARY KEY
);

INSERT INTO try (name)
VALUES (&#x0027;a&#x0027;), (&#x0027;ab&#x0027;), (&#x0027;â&#x0027;), (&#x0027;aba&#x0027;), (&#x0027;b&#x0027;), (&#x0027;ba&#x0027;), (&#x0027;bab&#x0027;), (&#x0027;AZ&#x0027;);

SELECT ok( &#x0027;a&#x0027; = name, &#x0027;We should be able to select the value&#x0027; )
  FROM try
 WHERE name = &#x0027;a&#x0027;;

SELECT throws_ok(
    &#x0027;INSERT INTO try (name) VALUES (&#x0027;&#x0027;a&#x0027;&#x0027;)&#x0027;,
    &#x0027;23505&#x0027;,
    &#x0027;We should get an error inserting a lowercase letter&#x0027;
);

&#x002d;&#x002d; Finish the tests and clean up.
SELECT * FROM finish();
</pre>

<p>As you can see, it's just SQL. And yes, I have ported most of the test
functions from <a href="http://search.cpan.org/perldoc?Test::More" title="Test::More on CPAN">Test::More</a>, as well as a couple
from <a href="http://search.cpan.org/perldoc?Test::Exception" title="Test::Exception on CPAN">Test::Exception</a>.</p>

<p>So, without further ado, I'd like to introduce
<a href="https://svn.kineticode.com/pgtap/trunk" title="pgTAP Subversion repository">pgTAP</a>, a lightweight test framework for PostgreSQL implemented
in PL/pgSQL and PL/SQL. I'll be hacking on it more in the coming days, mostly
to get a proper client for running tests hacked together. Then I think I'll
see if pgFoundry is interested in it.</p>

<p>Whaddya think? Is this something you could use? I can see many uses,
myself, not only for testing a custom data type as I develop it, but also
custom functions in PL/pgSQL or PL/Perl, and, heck, just regular schema stuff.
I've had to write a lot of Perl tests to test my database schema (triggers,
rules, functions, etc.), all using the DBI and being very verbose. Being able
to do it all in a single psql script seems so much cleaner. And if I can end
up mixing the output of those scripts in with the rest of my unit tests,
so much the better!</p>

<p>Anyway, feedback welcome. Leave your comments, suggestions, complaints,
patches, etc., below. Thanks!</p>



<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/introducing_pgtap.html">old layout</a>.</small></p>


