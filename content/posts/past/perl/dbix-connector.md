--- 
date: 2009-10-05T23:11:52Z
slug: dbix-connector
title: Database Handle and Transaction Management with DBIx::Connector
aliases: [/computers/programming/perl/modules/dbix-connector.html]
tags: [Perl, DBI, DBix::Class, DBIx::Connector, transactions, savepoints]
---

<p>As part of my ongoing effort to wrestle Catalyst into working the way
that <em>I</em> think it should work, I've just
uploaded <a href="http://search.cpan.org/perldoc?DBIx::Connector" title="DBIx::Connector on the CPAN">DBIx::Connector</a> to the CPAN. See, I
was using <a href="http://search.cpan.org/perldoc?Catalyst::Model::DBI" title="Catalyst::Model::DBI the CPAN">Catalyst::Model::DBI</a>, but it turned
out that I wanted to use the database handle in places other than the Catalyst
parts of <a href="http://github.com/theory/circle/" title="Circle on GitHub">my app</a>. I was bitching about this to 
<a href="http://www.trout.me.uk/" title="Matt S Trout">mst</a> on #catalyst,
and he said that Catalyst::Model::DBI was actually a fork of DBIx::Class's
handle caching, and quite out of date. I said, “But this already exists. It's
called <a href="/computers/programming/perl/dbi-connect-cached-hack.html" title="Keep DBI's connect_cached From Horking
Transactions"><code>connect_cached()</code></a>.” I believe his response was,
“OH FUCK OFF!”</p>

<p>So I started digging into what Catalyst::Model::DBI and DBIx::Class do to
cache their database handles, and how it differs from
<code>connect_cached()</code>. It turns out that they were pretty smart, in
terms of checking to see if the process had forked or a new thread had been
spawned, and if so, deactivating the old handle and then returning a new one.
Otherwise, things are just cached. This approach works well in Web
environments, including under <a href="http://perl.apache.org/">mod_perl</a>;
in forking applications, like <a href="http://search.cpan.org/perldoc?POE" title="POE on CPAN">POE</a> apps; and in plain Perl scripts. Matt said he'd
always wanted to pull that functionality out of DBIx::Class and then make
DBIx::Class depend on the external implementation. That way everyone could
take advantage of the functionality, including people like me who don't want
to use an ORM.</p>

<p>So I did it. Maybe it was crazy (mmmmm…yak meat), but I can now use the
same database interface in the Catalyst and POE parts of my application
without worry:</p>

<pre>
my $dbh = DBIx::Connector-&gt;connect(
    &#x0027;dbi:Pg:dbname=circle&#x0027;, &#x0027;postgres&#x0027;, &#x0027;&#x0027;, {
        PrintError     =&gt; 0,
        RaiseError     =&gt; 0,
        AutoCommit     =&gt; 1,
        HandleError    =&gt; Exception::Class::DBI-&gt;handler,
        pg_enable_utf8 =&gt; 1,
    },
);

$dbh-&gt;do($sql);
</pre>

<p>But it's not just database handle caching that I've included in
DBIx::Connector; no, I've also stolen some of the transaction management stuff
from DBIx::Class. All you have to do is grab the connector object which
encapsulates the database handle, and take advantage of
its <code>txn_do()</code> method:</p>

<pre>
my $conn = DBIx::Connector-&gt;new(@args);
$conn-&gt;txn_do(sub {
    my $dbh = shift;
    $dbh-&gt;do($_) for @queries;
});
</pre>

<p>The transaction is scoped to the code reference passed to
<code>txn_do()</code>. Not only that, it avoids the overhead of calling
<code>ping()</code> on the database handle unless something goes wrong. Most
of the time, nothing goes wrong, the database is there, so you can proceed
accordingly. If it is gone, however, <code>txn_do()</code> will re-connect and
execute the code reference again. The cool think is that you will never notice
that the connection was dropped -- unless it's still gone after the second
execution of the code reference.</p>

<p>And finally, thanks to some pushback from mst,
<a href="http://rabbit.us/">ribasushi</a>, and others, I added
<a href="https://en.wikipedia.org/wiki/Savepoint" title="Wikipedia: “Savepoint”">savepoint</a> support. It's a little different than that provided
by DBIx::Class; instead of relying on a magical <code>auto_savepoint</code>
attribute that subtly changes the behavior of <code>txn_do()</code>, you just
use the <code>svp_do()</code> method from within <code>txn_do()</code>. The
scoping of subtransactions is thus nicely explicit:</p>

<pre>
$conn-&gt;txn_do(sub {
    my $dbh = shift;
    $dbh-&gt;do(&#x0027;INSERT INTO table1 VALUES (1)&#x0027;);
    eval {
        $conn-&gt;svp_do(sub {
            shift-&gt;do(&#x0027;INSERT INTO table1 VALUES (2)&#x0027;);
            die &#x0027;OMGWTF?&#x0027;;
        });
    };
    warn &quot;Savepoint failed\n&quot; if $@;
    $dbh-&gt;do(&#x0027;INSERT INTO table1 VALUES (3)&#x0027;);
});
</pre>

<p>This transaction will insert the values 1 and 3, but not 2. If you call
<code>svp_do()</code> outside of <code>txn_do()</code>, it will call
<code>txn_do()</code> for you, with the savepoint scoped to the entire
transaction:</p>

<pre>
$conn-&gt;svp_do(sub {
    my $dbh = shift;
    $dbh-&gt;do(&#x0027;INSERT INTO table1 VALUES (4)&#x0027;);
    $conn-&gt;svp_do(sub {
        shift-&gt;do(&#x0027;INSERT INTO table1 VALUES (5)&#x0027;);
    });
});
</pre>

<p>This transaction will insert both 3 and 4. And note that you can nest
savepoints as deeply as you like. All this is dependent on whether
the database supports savepoints; so far, PostgreSQL, MySQL (InnoDB),
Oracle, MSSQL, and SQLite do. If you know of others, fork the
<a href="http://github.com/theory/dbix-connector/" title="DBIx::Connector on GitHub">repository</a>, commit changes to a branch, and send me a pull
request!</p>

<p>Overall I'm very happy with this module, and I'll probably use it in all my
Perl database projects from here on in. Perhaps later I'll build a model class
on it (something like Catalyst::Model::DBI, only better!), but next up, I plan
to finish documenting
<a href="http://search.cpan.org/perldoc?Template::Declare" title="Template::Declare on the CPAN">Template::Declare</a> and writing some
views with it. More on that soon.</p>




<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/dbix-connector.html">old layout</a>.</small></p>


