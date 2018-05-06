--- 
date: 2009-11-03T14:00:00Z
slug: tutorial-continued
title: Catalyst with DBIx::Connector and Template::Declare
aliases: [/computers/programming/perl/catalyst/tutorial-continued.html]
tags: [Perl, Catalyst, DBIx::Connector, Template::Declare, Postgres]
---

<p>Following up on my <a href="/computers/programming/perl/catalyst/catalyst-view-td.html" title="Create Catalyst Views with Template::Declare">post</a> yesterday introducing <a href="http://search.cpan.org/perldoc?Catalyst::View::TD" title="Catalyst::View::TD on CPAN">Catalyst::View::TD</a>, today I'd like to continue with the next step in <a href="http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics" title="Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics">chapter 3</a> of the Catalyst tutorial. The twist here is that I'm going to use <a href="http://www.postgresql.org/" title="PostgreSQL: The world's most advanced open source database">PostgreSQL</a> for the database back-end and start introducing some database best practices. I'm also going to make use of my <a href="http://search.cpan.org/perldoc?DBIx::Connector" title="DBIx::Connector on CPAN">DBIx::Connector</a> module to interact with the database.</p>

<h3>Create the Database</h3>

<p>Picking up with the <a href="http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics#CREATE_A_SQLITE_DATABASE" title="Create a SQLite Database">database creation</a> section of the tutorial, the first change I'd like to make is to use a <a href="http://en.wikipedia.org/wiki/Natural_key" title="Wikipedia: âNatural Keyâ">natural key</a> for the books table. All books have unique identifiers, known as ISBNs, so creating a <a href="http://en.wikipedia.org/wiki/Surrogate_key" title="Wikipedia: âSurrogate Keyâ">surrogate key</a> (the typical <code>id</code> column in ORM-managed applications) is redundant. One of the nice things about PostgreSQL is that it ships with a contributed library, <a href="http://www.postgresql.org/docs/current/static/isn.html" title="PostgreSQL Documentation: âisnâ">isn</a>, which validates ISBN and other international identifiers. So we use this contrib module (usually included in package-installed PostgreSQL servers) for the primary key for books. If you need to install it from source, it’s pretty easy:</p>

<pre>
cd postgresql-8.4.1/contrib/isn
make
make install
</pre>


<p>Ideally I'd use a natural key for the authors table too, but despite <a href="http://dlist.sir.arizona.edu/1716/" title="The Universal Author Identifier System (UAI_Sys)">some attempts</a> to create universal identifiers for authors, nothing has really caught on as far as I know. So I'll just stick to a surrogate key for now.</p>

<p>First step: create the database and install isn if it’s not already included in the template database:</p>

<pre>
createdb -U postgres myapp
psql -U postgres -d myapp -f /usr/local/pgsql/share/contrib/isn.sql
</pre>


<p>The <code>isn.sql</code> file may be somewhere else on your system. Now let’s create the database. Create <code>sql/001-books.sql</code> in the <code>MyApp</code> directory and paste this into it:</p>

<pre>
BEGIN;

CREATE TABLE books (
    isbn   ISBN13   PRIMARY KEY,
    title  TEXT     NOT NULL DEFAULT &#x27;&#x27;,
    rating SMALLINT NOT NULL DEFAULT 0 CHECK (rating BETWEEN 0 AND 5)
);

CREATE TABLE authors (
    id         BIGSERIAL PRIMARY KEY,
    surname    TEXT NOT NULL DEFAULT &#x27;&#x27;,
    given_name TEXT NOT NULL DEFAULT &#x27;&#x27;
);

CREATE TABLE book_author (
    isbn       ISBN13 REFERENCES books(isbn),
    author_id  BIGINT REFERENCES authors(id),
    PRIMARY KEY (isbn, author_id)
);

INSERT INTO books
VALUES (&#x27;1587201534&#x27;,        &#x27;CCSP SNRS Exam Certification Guide&#x27;, 5),
       (&#x27;978-0201633467&#x27;,    &#x27;TCP/IP Illustrated, Volume 1&#x27;,       5),
       (&#x27;978-0130183804&#x27;,    &#x27;Internetworking with TCP/IP Vol.1&#x27;,  4),
       (&#x27;978-1-56592-243-3&#x27;, &#x27;Perl Cookbook&#x27;,                      5),
       (&#x27;978-0735712010&#x27;,    &#x27;Designing with Web Standards&#x27;,       5)
;

INSERT INTO authors
VALUES (1, &#x27;Greg&#x27;,      &#x27;Bastien&#x27;),
       (2, &#x27;Sara&#x27;,      &#x27;Nasseh&#x27;),
       (3, &#x27;Christian&#x27;, &#x27;Degu&#x27;),
       (4, &#x27;Richard&#x27;,   &#x27;Stevens&#x27;),
       (5, &#x27;Douglas&#x27;,   &#x27;Comer&#x27;),
       (6, &#x27;Tom&#x27;,       &#x27;Christiansen&#x27;),
       (7, &#x27;Nathan&#x27;,    &#x27;Torkington&#x27;),
       (8, &#x27;Jeffrey&#x27;,   &#x27;Zeldman&#x27;)
;

INSERT INTO book_author
VALUES (&#x27;1587201534&#x27;,        1),
       (&#x27;1587201534&#x27;,        2),
       (&#x27;1587201534&#x27;,        3),
       (&#x27;978-0201633467&#x27;,    4),
       (&#x27;978-0130183804&#x27;,    5),
       (&#x27;978-1-56592-243-3&#x27;, 6),
       (&#x27;978-1-56592-243-3&#x27;, 7),
       (&#x27;978-0735712010&#x27;,    8)
;

COMMIT;
</pre>


<p>Yeah, I Googled for the ISBNs for those books. I found the ISBN-13 number for most of them, but it handles the old ISBN-10 format, too, automatically upgrading it to ISBN-13. I also added a <code>CHECK</code> constraint for the <code>rating</code> column, to be sure that the value is always <code>BETWEEN 0 AND 5</code>. I also like to include default values where it’s sensible to do so, and that syntax for inserting multiple rows at once is pretty nice to have.</p>

<p>Go ahead and run this against your database:</p>

<pre><code>psql -U postgres -d myapp -f sql/001-books.sql
</code></pre>

<p>Now if you connect to the server, you should be able to query things like so:</p>

<pre>
$ psql -U postgres myapp
psql (8.4.1)
Type &quot;help&quot; for help.

myapp=# select * from books;
       isbn        |               title                | rating 
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 978-1-58720-153-0 | CCSP SNRS Exam Certification Guide |      5
 978-0-201-63346-7 | TCP/IP Illustrated, Volume 1       |      5
 978-0-13-018380-4 | Internetworking with TCP/IP Vol.1  |      4
 978-1-56592-243-3 | Perl Cookbook                      |      5
 978-0-7357-1201-0 | Designing with Web Standards       |      5
(5 rows)
</pre>


<h3>Setup the Database Connection</h3>

<p>Great! The database is set. Now we need a way for the app to talk to it. I've not yet decided how I'm going to integrate <a href="http://search.cpan.org/perldoc?DBIx::Connector" title="DBIx::Connector on CPAN">DBIx::Connector</a> into a Catalyst model class; maybe I'll figure it out as I write these posts. But since my mantra is âthe database <em>is</em> the model,â for now I won’t bother with a model at all. Instead, I'll create a simple accessor in <code>MyApp</code> so we can easily get at the database connection wherever we need it. To do that, add these lines to <code>lib/MyApp.pm</code>:</p>

<pre>
use Moose;
use DBIx::Connector;
use Exception::Class::DBI;

has conn =&gt; (is =&gt; &#x27;ro&#x27;, lazy =&gt; 1, default =&gt; sub {
    DBIx::Connector-&gt;new( &#x27;dbi:Pg:dbname=myapp&#x27;, &#x27;postgres&#x27;, &#x27;&#x27;, {
        PrintError     =&gt; 0,
        RaiseError     =&gt; 0,
        HandleError    =&gt; Exception::Class::DBI-&gt;handler,
        AutoCommit     =&gt; 1,
        pg_enable_utf8 =&gt; 1,
    });
});
</pre>


<p>We load <a href="http://search.cpan.org/perldoc?Moose" title="Moose on CPAN">Moose</a> to get the <code>has</code> keyword, the officially sanctioned interface for defining attributes in Catalyst classes. Then I use that keyword to create the <code>conn</code> attribute. This attribute is read-only and has a DBIx::Connector object for its default value. The nice thing about this is that the DBIx::Connector object won’t be instantiated until it’s actually needed, and then it will be kept forever. We never have to do anything else to use it.</p>

<p>Oh, and I like to make sure that text data coming back from PostgreSQL is properly encoded as UTF-8, and I like to use <a href="http://search.cpan.org/perldoc?Exception::Class::DBI" title="Exception::Class::DBI on CPAN">Exception::Class::DBI</a> to turn DBI errors into exception objects.</p>

<p>Now it’s time to update our controller and template to fetch actual data from the database. Edit <code>lib/MyApp/Controller/Books.pm</code> and change the <code>list</code> method to:</p>

<pre>
sub list : Local {
    my ($self, $c) = @_;
    $c-&gt;stash-&gt;{books} = $c-&gt;conn-&gt;run(fixup =&gt; sub {
        my $sth = $_-&gt;prepare(&#x27;SELECT isbn, title, rating FROM books&#x27;);
        $sth-&gt;execute;
        $sth;
    });
}
</pre>


<p>All we're doing here is creating a statement handle for the query, executing the query, and storing the statement handle in the stash. Now we need to update the template to use the statement handle. Open up <code>lib/MyApp/Templates/HTML/Books.pm</code> and change the <code>list</code> template to:</p>

<pre>
template list =&gt; sub {
    my ($self, $args) = @_;
    table {
        row {
            th { &#x27;Title&#x27;  };
            th { &#x27;Rating&#x27; };
            th { &#x27;Author&#x27; };
        };
        my $sth = $args-&gt;{books};
        while (my $book = $sth-&gt;fetchrow_hashref) {
            row {
                cell { $book-&gt;{title}  };
                cell { $book-&gt;{rating} };
                cell { $book-&gt;{author} };
            };
        };
    };
};
</pre>


<p>All we do is fetch each row from the statement handle and output it. The only thing that’s changed is the use of the statement handle as an iterator rather than an array reference.</p>

<p>And now we're set! Restart your server with <code>script/myapp_server.pl</code> and point your browser at <code>http://localhost:3000/books/list</code>. Now you should see the book titles and ratings, though the authors still aren’t present. We'll fix that in a later post.</p>

<h3>Takeaway</h3>

<p>The takeaway from this post: Use PostgreSQL’s support for custom data types to create validated natural keys for your data, and use a stable, persistent database connection to talk directly to the database. No need for an ORM here, as the <a href="http://search.cpan.org/perldoc?DBI" title="The DBI on CPAN">DBI</a> provides a very Perlish access to a very capable <a href="http://en.wikipedia.org/wiki/Domain-specific_language" title="Wikipedia: âDomain-Specific Languageâ">DSL</a> for models called SQL.</p>

<p>More soon.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/catalyst/tutorial-continued.html">old layout</a>.</small></p>


