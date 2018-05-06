--- 
date: 2005-10-31T23:47:58Z
slug: custom-perl-aggregates
title: Custom Aggregates in Perl
aliases: [/computers/databases/sqlite/custom_perl_aggregates.html]
tags: [SQLite, API, Perl, Postgres]
---

<p>About a year ago, <a href="http://blogs.ittoolbox.com/database/soup/" title="Josh Berkus's Database Soup">Josh Berkus</a> was reviewing some Bricolage SQL code, looking to optimize it for PostgreSQL. One of the things he noticed was that we were fetching a lot more rows for an object than we needed to. The reason for this is that an object might be associated with one or more groups, and to get back a list of all of the group IDs, we were getting multiple rows. For example, if I wanted to fetch a single story with the ID 10, I might get back rows like this:</p>

<pre>
SELECT s.id, s.title, grp.id
FROM   story s, member m, grp g
WHERE  s.id = m.story_id
       AND m.grp_id = g.id
       AND s.id = 10;
s.id |        s.title      | grp.id
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
  10 | The Princess Bride  | 23
  10 | The Princess Bride  | 24
  10 | The Princess Bride  | 25
  10 | The Princess Bride  | 26
  10 | The Princess Bride  | 27
</pre>

<p>Now, that's a lot of extra data to have to fetch for just a single row to be different; it's very wasteful, really. So Josh said, <q>Why don't you use a custom aggregate for that?</q> I knew nothing about aggregates, but I did some research, and figured out how to write PostgreSQL custom aggregates in SQL. I wrote a very simple one, called <code>id_list()</code>, that joins up all of the values in a column with an empty space. The aggregate code looks like this:</p>

<pre>
CREATE   FUNCTION append_id(TEXT, INTEGER)
RETURNS  TEXT AS &#x0027;
    SELECT CASE WHEN $2 = 0 THEN
                $1
           ELSE
                $1 || &#x0027;&#x0027; &#x0027;&#x0027; || CAST($2 AS TEXT)
           END;&#x0027;
LANGUAGE &#x0027;sql&#x0027;
WITH     (ISCACHABLE, ISSTRICT);

CREATE AGGREGATE id_list (
    SFUNC    = append_id,
    BASETYPE = INTEGER,
    STYPE    = TEXT,
    INITCOND = &#x0027;&#x0027;
);
</pre>

<p>Now I was able to vastly simplify the results returned by the query:</p>

<pre>
SELECT s.id, s.title, id_list(grp.id)
FROM   story s, member m, grp g
WHERE  s.id = m.story_id
       AND m.grp_id = g.id
       AND s.id = 10;
GROUP BY s.id, s.title
s.id |        s.title      | id_list
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
  10 | The Princess Bride  | 23 24 25 26 27
</pre>

<p>So then I just had to split the <code>id_list</code> column on the white space and I was ready to go. Cool!</p>

<p>So recently, was thinking about how I might do something similar in SQLite. It turns out that SQLite has a way to add custom aggregates, too, via its <a href="http://www.sqlite.org/capi3ref.html#sqlite3_create_function" title="C/C++ Interface For SQLite Version 3: sqlite_add_function"><code>sqlite_add_function</code></a> function. But I don't know C, and had been wondering for a while how, even if I figured out how to write an aggregate function in C, whether I would have to require users to compile SQLite with my C aggregate in order to get it to work.</p>

<p>However, as a Perl developer, I thought it might be worthwhile to just quickly check the <a href="http://search.cpan.org/dist/DBD-SQLite/" title="DBD::SQLite on CPAN">DBD::SQLite</a> docs might have to say on the matter. And it turns out that the ability to add aggregates to SQLite is supported in DBD::SQLite via the <code>create_aggregate</code> custom function. And what's more, the aggregate can be written in Perl! Whoa! I couldn't believe that it could be that easy, but a quick test script demonstrated that it is:</p>

<pre>
#!/usr/bin/perl -w

use strict;

use DBI;

my $dbfile = shift;
my $dbh = DBI->connect(&quot;dbi:SQLite:dbname=$dbfile&quot;, &#x0027;&#x0027;, &#x0027;&#x0027;);

END {
    $dbh->disconnect;
    unlink $dbfile;
};

$dbh->do(&#x0027;CREATE TABLE foo (a int)&#x0027;);
$dbh->do(&#x0027;BEGIN&#x0027;);
$dbh->do(&#x0027;INSERT INTO foo (a) VALUES (?)&#x0027;, undef, $_) for 1..10;
$dbh->do(&#x0027;COMMIT&#x0027;);

# Create a new aggregate.
$dbh->func(&#x0027;joiner&#x0027;, 1, &#x0027;My::Join&#x0027;, &#x0027;create_aggregate&#x0027;);

my $sel = $dbh->prepare(q{SELECT joiner(a) FROM foo});
$sel->execute;
$sel->bind_columns(\my $val);
print &quot;$val\n&quot; while $sel->fetch;
</pre>

<p>The first argument to <code>create_aggregate()</code> (itself invoked via the DBI <code>func()</code> method) the name of the aggregate, the second is the number of arguments to the aggregate (use -1 for an unlimited number), and the third is the name of a Perl class that implements the aggregate. That class needs just three methods: <code>new()</code>, an object constructor; <code>step()</code>, called for each aggregate row, and <code>finalize</code>, which must return the value calculated by the aggregate. My simple implementation looks like this:</p>

<pre>
package My::Join;

sub new { bless [] }
sub step {
    my $self = shift;
    push @$self, @_;
}
sub finalize {
    my $self = shift;
    return join q{ }, @$self;
}
</pre>

<p>Yep, that's really it! When I run the script, the output looks like this:</p>

<pre>
% try foo
1 2 3 4 5 6 7 8 9 10
</pre>

<p>Keen! I mean, that is just <em>so</em> slick! And it really demonstrates the power of SQLite as an embeddable database, as well. Thanks <a href="http://www.sergeant.org/view/Matt" title="Matt Sergeant">Matt</a>, for making the SQLite API available to us mere mortal Perl developers!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqlite/custom_perl_aggregates.html">old layout</a>.</small></p>


