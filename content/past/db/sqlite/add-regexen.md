--- 
date: 2006-01-13T16:08:17Z
slug: add-regexen
title: Add Regular Expression Operator to SQLite
aliases: [/computers/databases/sqlite/add_regexen.html]
tags: [SQLite, Perl, Regular Expressions, DBD::SQLite, DBI, Matt Sergeant]
type: post
---

<p>As I <a href="http://www.justatheory.com/computers/databases/sqlite/custom_perl_aggregates.html" title="Custom Aggregates in Perl">discussed</a> a couple of months ago, <a href="http://search.cpan.org/dist/DBD-SQLite/" title="DBD::SQLite on CPAN">DBD::SQLite</a> exposes the <a href="http://www.sqlite.org/" title="Learn all about SQLite">SQLite</a> <code>sqlite3_create_function()</code> API for adding Pure-Perl functions and aggregates to SQLite on a per-connection basis.  This is cool, but in perusing the <a href="http://www.sqlite.org/lang_expr.html" title="Query Language Understood by SQLite: expression">SQLite expression</a> documentation, I came across this gem:</p>

<blockquote cite="http://www.sqlite.org/lang_expr.html"><p>The <code>REGEXP</code> operator is a special syntax for the <code>regexp()</code> user function. No <code>regexp()</code> user function is defined by default and so use of the <code>REGEXP</code> operator will normally result in an error message. If a user-defined function named <q>regexp</q> is defined at run-time, that function will be called in order to implement the <code>REGEXP</code> operator.</p></blockquote>

<p><em>Well hell!</em> I thought. <em>I can do that!</em></p>

<p>In a brief search, I could find no further documentation of this feature, but all it took was a little experimentation to figure it out. The <code>regexp()</code> function should expect two arguments. The first is the regular expression, and the second is the value to match. So it can be added to DBD::SQLite like this:</p>

<pre>
$dbh = DBI-&gt;connect(&#x0027;dbi:SQLite:dbfile=test.db&#x0027;);
$dbh-&gt;func(&#x0027;regexp&#x0027;, 2, sub {
    my ($regex, $string) = @_;
    return $string =~ /$regex/;
}, &#x0027;create_function&#x0027;);
</pre>

<p>Yep, that's it! Now, I have my own module for handling database connections, and I wanted to make sure that all of my custom functions are always present, every time I connect to the database. In a <code><a href="http://perl.apache.org/" title="Run Perl inside of Apache!">mod_perl</a></code> environment, you can end up with a lot of connections, and a single process has the potential disconnect and reconnect more than once (due to exceptions thrown by the database and whatnot). The easiest way to ensure that the functions are always there as soon as you connect and every time you connect, I learned thanks to a tip from Tim Bunce, is to subclass the DBI and implement a <code>connected()</code> method. Here's what it looks like:</p>

<pre>
package MyApp::SQLite;
use base &#x0027;DBI&#x0027;;

package MyApp::SQLite::st;
use base &#x0027;DBI::st&#x0027;;

package MyApp::SQLite::db;
use base &#x0027;DBI::db&#x0027;;

sub connected {
    my $dbh = shift;
    # Add regexp function.
    $dbh-&gt;func(&#x0027;regexp&#x0027;, 2, sub {
        my ($regex, $string) = @_;
        return $string =~ /$regex/;
    }, &#x0027;create_function&#x0027;);
}
</pre>

<p>So how does this work? Here's a quick app I wrote to demonstrate the use of the <code>REGEXP</code> expression in SQLite using Perl regular expressions:</p>

<pre>
#!/usr/bin/perl -w

use strict;

my $dbfile = shift || die &quot;Usage: $0 db_file\n&quot;;
my $dbh = MyApp::SQLite-&gt;connect(
    &quot;dbi:SQLite:dbname=$dbfile&quot;, &#x0027;&#x0027;, &#x0027;&#x0027;,
    {
        RaiseError  =&gt; 1,
        PrintError  =&gt; 0,
    }
);

END {
    $dbh-&gt;do(&#x0027;DROP TABLE try&#x0027;);
    $dbh-&gt;disconnect;
}

$dbh-&gt;do(&#x0027;CREATE TABLE try (a TEXT)&#x0027;);

my $ins = $dbh-&gt;prepare(&#x0027;INSERT INTO try (a) VALUES (?)&#x0027;);
for my $val (qw(foo bar bat woo oop craw)) {
    $ins-&gt;execute($val);
}

my $sel = $dbh-&gt;prepare(&#x0027;SELECT a FROM try WHERE a REGEXP ?&#x0027;);

for my $regex (qw( ^b a w?oop?)) {
    print &quot;&#x0027;$regex&#x0027; matches:\n  &quot;;
    print join &quot;\n  &quot; =&gt;
        @{ $dbh-&gt;selectcol_arrayref($sel, undef, $regex) };
    print &quot;\n\n&quot;;
}
</pre>

<p>This script outputs:</p>

<pre>
'^b' matches:
  bar
  bat

'a' matches:
  bar
  bat
  craw

'w?oop?' matches:
  foo
  woo
  oop

</pre>

<p>Pretty slick, no? I wonder if it'd make sense for DBD::SQLite to add the <code>regexp()</code> function itself, in C, using the Perl API, so that it's just <em>always</em> available to DBD::SQLite apps?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqlite/add_regexen.html">old layout</a>.</small></p>


