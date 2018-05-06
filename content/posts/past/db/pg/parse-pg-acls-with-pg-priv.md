--- 
date: 2009-10-30T23:59:48Z
slug: parse-pg-acls-with-pg-priv
title: Pg::Priv Hits CPAN (Thanks Etsy!)
aliases: [/computers/databases/postgresql/parse-pg-acls-with-pg-priv.html]
tags: [Postgres, ACLs, Etsy, Perl, Pg::Priv]
---

<p>Earlier this year, I was working on an administrative utility for
<a href="http://www.etsy.com/">Etsy</a> that validates PostgreSQL database
permissions. Of course, in order to verify that permissions were correct or
needed updating, I had to have a way to examine PostgreSQL ACLs, which are
arrays made of of strings that look like this:</p>

<pre><code>my $acl = [
   'miriam=arwdDxt/miriam',
   '=r/miriam',
   'admin=arw/miriam',
];
</code></pre>

<p>So following
<a href="http://www.postgresql.org/docs/current/static/sql-grant.html#SQL-GRANT-NOTES"
title="PostgreSQL: “GRANT — Notes”">the documentation</a>, I wrote a module
that iterates over an ACL, parses each privilege string, and returns an object
describing it. Using it is pretty easy. If you wanted to see what the
permissions looked like on all the tables in a database, you could do it like
so:</p>

<pre>
#!/usr/bin/perl -w
use strict;
use warnings;
use DBI;
use Pg::Priv;

my $dbname = shift or die &quot;Usage: $0 dbname\n&quot;;

my $dbh = DBI-&gt;connect(&quot;dbi:Pg:dbname=$dbname&quot;, &#x0027;postgres&#x0027;, &#x0027;&#x0027;);
my $sth = $dbh-&gt;prepare(
    q{SELECT relname, relacl FROM pg_class WHERE relkind = &#x0027;r&#x0027;}
);

$sth-&gt;execute;
print &quot;Permissions for $dbname:\n&quot;;
while (my $row = $sth-&gt;fetchrow_hashref) {
    print &quot;  Table $row-&gt;{relname}:\n&quot;;
    for my $priv ( Pg::Priv-&gt;parse_acl( $row-&gt;{relacl} ) ) {
        print &#x0027;    &#x0027;, $priv-&gt;by, &#x0027; granted to &#x0027;, $priv-&gt;to, &#x0027;: &#x0027;,
            join( &#x0027;, &#x0027;, $priv-&gt;labels ), $/;
    }
}
</pre>

<p>And here's what the output looks like:</p>

<pre>
Permissions for bric:
  Table media__output_channel:
    postgres granted to postgres: UPDATE, SELECT, INSERT, TRUNCATE, REFERENCE, DELETE, TRIGGER
    postgres granted to bric: UPDATE, SELECT, INSERT, DELETE
  Table media_uri:
    postgres granted to postgres: UPDATE, SELECT, INSERT, TRUNCATE, REFERENCE, DELETE, TRIGGER
    postgres granted to bric: UPDATE, SELECT, INSERT, DELETE
  Table media_fields:
    postgres granted to postgres: UPDATE, SELECT, INSERT, TRUNCATE, REFERENCE, DELETE, TRIGGER
</pre>

<p>There are a bunch of utility methods to make it pretty simple to examine
PostgreSQL privileges.</p>

<p>And now, I'm pleased to announce the release yesterday of
<a href="http://search.cpan.org/perldoc?Pg::Priv" title="Pg::Priv on CPAN">Pg::Priv</a>.
My thanks to Etsy for agreeing to the release, and particularly to
<a href="http://chaddickerson.com/">Chad Dickerson</a> for championing it. This
module is a little thing compared to some things I've seen open-sourced by major
players, but even the simplest utilities can save folks mountains of time. I
hope you find Pg::Priv useful.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/parse-pg-acls-with-pg-priv.html">old layout</a>.</small></p>


