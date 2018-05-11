--- 
date: 2009-11-05T14:00:00Z
slug: sql-view-aggregate-magic
title: "My Catalyst Tutorial: Add Authors to the View"
aliases: [/computers/programming/perl/catalyst/sql-view-aggregate-magic.html]
tags: [Perl, Catalyst, Template::Declare, database, DBI, Postgres, SQL]
---

<p>Another post in my ongoing <a href="/computers/programming/perl/catalyst%20title=" title="Just a Theory: “Catalyst”">series</a> of posts on using Catalyst with Template::Declare and DBIx::Connector. This will be the last post covering material from <a href="http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics" title="Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics">chapter 3</a>, I promise. This is a fun one, though, because we continue to use this really nice <a href="https://en.wikipedia.org/wiki/Domain-specific_language" title="Wikipedia: “Domain-Specific Language”">DSL</a> called “SQL,” which I think is more expressive than an ORM would be.</p>

<p>To whit, the next task is to add the missing list of authors to the book list. The thing is, the more I work with databases, the more I'm inclined to think about them not only as the “M” in “<a href="https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller" title="Wikipedia: “Model-view-controller”">MVC</a>”, but also the “V”. I'll show you what I mean.</p>

<h3>A Quick Fix</h3>

<p>But first, a diversion. In the <a href="/computers/programming/perl/catalyst/tutorial-continued.html">second post</a> in this series, I created an SQL statement to insert book authors, but I made a mistake: the values for surnames and given names were reversed. Oops. Furthermore, I included explicit author IDs, even though the <code>id</code> column uses a sequence for it’s default value. So first we need to fix these issues. Change  the <code>INSERT INTO authors</code> statement in <code>sql/001-books.sql</code> to:</p>

<pre>
INSERT INTO authors (surname, given_name)
VALUES (&#x27;Bastien&#x27;,      &#x27;Greg&#x27;),
       (&#x27;Nasseh&#x27;,       &#x27;Sara&#x27;),
       (&#x27;Degu&#x27;,         &#x27;Christian&#x27;),
       (&#x27;Stevens&#x27;,      &#x27;Richard&#x27;),
       (&#x27;Comer&#x27;,        &#x27;Douglas&#x27;),
       (&#x27;Christiansen&#x27;, &#x27;Tom&#x27;),
       (&#x27;Torkington&#x27;,   &#x27;Nathan&#x27;),
       (&#x27;Zeldman&#x27;,      &#x27;Jeffrey&#x27;)
;
</pre>

<p>This time, we're letting the sequence populate the <code>id</code> column. Fortunately, it starts from 1 just like we did, so we don’t need to update the values in the <code>INSERT INTO book_author</code> statement. Now let’s fix the database:</p>

<pre><code>DELETE FROM book_author;
DELETE FROM authors;
</code></pre>

<p>Then run the above SQL query to restore the authors with their proper names, and then run the <code>INSERT INTO book_author</code> statement. That will get us back in business.</p>

<h3>Constructing our Query</h3>

<p>Now it’s time for the fun. The original SQL query we wrote to get the list of books was:</p>

<pre><code>SELECT isbn, title, rating FROM books;
</code></pre>

<p>Nothing unusual there. But to get at the authors, we need to join to <code>book_author</code> and from there to <code>authors</code>. Our first cut looks like this:</p>

<pre><code>SELECT b.isbn, b.title, b.rating, a.surname
  FROM books       b
  JOIN book_author ba ON b.isbn       = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id;
</code></pre>

<p>Which yields this data:</p>

<pre>
       isbn        |               title                | rating |   surname    
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 978&#x2d;1&#x2d;58720&#x2d;153&#x2d;0 | CCSP SNRS Exam Certification Guide |      5 | Bastien
 978&#x2d;1&#x2d;58720&#x2d;153&#x2d;0 | CCSP SNRS Exam Certification Guide |      5 | Nasseh
 978&#x2d;1&#x2d;58720&#x2d;153&#x2d;0 | CCSP SNRS Exam Certification Guide |      5 | Degu
 978&#x2d;0&#x2d;201&#x2d;63346&#x2d;7 | TCP/IP Illustrated, Volume 1       |      5 | Stevens
 978&#x2d;0&#x2d;13&#x2d;018380&#x2d;4 | Internetworking with TCP/IP Vol.1  |      4 | Comer
 978&#x2d;1&#x2d;56592&#x2d;243&#x2d;3 | Perl Cookbook                      |      5 | Christiansen
 978&#x2d;1&#x2d;56592&#x2d;243&#x2d;3 | Perl Cookbook                      |      5 | Torkington
 978&#x2d;0&#x2d;7357&#x2d;1201&#x2d;0 | Designing with Web Standards       |      5 | Zeldman
</pre>


<p>Good start, but note how we now have three rows for âCCSP SNRS Exam Certification Guideâ and two for âPerl Cookbookâ. We could of course modify our Perl code to look at the ISBN in each row and combine as appropriate, but it’s better to get the database to do that work, since it’s designed for that sort of thing. So let’s use an <a href="http://www.postgresql.org/docs/current/static/functions-aggregate.html" title="PostgreSQL Documentation: âAggregate Functionsâ">aggregate function</a> to combine the values over multiple rows into a single row. All we have to do is use the column that changes (<code>surname</code>) in an aggregate function and tell PostgreSQL to use the other columns to group rows into one. PostgreSQL 8.4 introduces a really nice aggregate function, <code>array_agg()</code>, for pulling a series of strings together into an array. Let’s put it to use:</p>

<pre><code>SELECT b.isbn, b.title, b.rating, array_agg(a.surname) as authors
  FROM books       b
  JOIN book_author ba ON b.isbn     = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id
 GROUP BY b.isbn, b.title, b.rating;
</code></pre>

<p>Now the output is:</p>

<pre>
       isbn        |               title                | rating |          authors         
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 978&#x2d;0&#x2d;201&#x2d;63346&#x2d;7 | TCP/IP Illustrated, Volume 1       |      5 | {Stevens}
 978&#x2d;0&#x2d;13&#x2d;018380&#x2d;4 | Internetworking with TCP/IP Vol.1  |      4 | {Comer}
 978&#x2d;1&#x2d;56592&#x2d;243&#x2d;3 | Perl Cookbook                      |      5 | {Christiansen,Torkington}
 978&#x2d;1&#x2d;58720&#x2d;153&#x2d;0 | CCSP SNRS Exam Certification Guide |      5 | {Bastien,Nasseh,Degu}
 978&#x2d;0&#x2d;7357&#x2d;1201&#x2d;0 | Designing with Web Standards       |      5 | {Zeldman}
</pre>

<p>Much better. We now have a single row for each book, and the authors are all grouped into a single column. Cool. But we can go one step further. Although we could use Perl to turn the array of author surnames into a comma-delimited string, there’s a PostgreSQL function for that, too: <code>array_to_string()</code>. Check it out:</p>

<pre><code>SELECT b.isbn, b.title, b.rating,
       array_to_string(array_agg(a.surname), ', ') as authors
  FROM books       b
  JOIN book_author ba ON b.isbn     = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id
 GROUP BY b.isbn, b.title, b.rating;
</code></pre>

<p>Now the rows will be:</p>

<pre>
       isbn        |               title                | rating |          authors          
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 978&#x2d;0&#x2d;201&#x2d;63346&#x2d;7 | TCP/IP Illustrated, Volume 1       |      5 | Stevens
 978&#x2d;0&#x2d;13&#x2d;018380&#x2d;4 | Internetworking with TCP/IP Vol.1  |      4 | Comer
 978&#x2d;1&#x2d;56592&#x2d;243&#x2d;3 | Perl Cookbook                      |      5 | Christiansen, Torkington
 978&#x2d;1&#x2d;58720&#x2d;153&#x2d;0 | CCSP SNRS Exam Certification Guide |      5 | Bastien, Nasseh, Degu
 978&#x2d;0&#x2d;7357&#x2d;1201&#x2d;0 | Designing with Web Standards       |      5 | Zeldman
</pre>


<h3>Create a Database View</h3>

<p>Cool! All the formatting work is done! But since it’s likely what we'll often need to fetch book titles along with their authors, let’s create an SQL view for this query. That way, we don’t have to write the same SQL in different places in the application: we can just use the view. So create a new file, <code>sql/002-books_with_authors.sql</code>, and add this SQL:</p>

<pre><code>CREATE VIEW books_with_authors AS
SELECT b.isbn, b.title, b.rating,
       array_to_string(array_agg(a.surname), ', ') as authors
  FROM books       b
  JOIN book_author ba ON b.isbn     = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id
 GROUP BY b.isbn, b.title, b.rating;
</code></pre>

<p>Now install this view in the database:</p>

<pre><code>psql -U postgres -d myapp -f sql/002-books_with_authors.sql
</code></pre>

<p>And now we can make use of the view any time we want and get the results of the full query. It’s time to do that in our controller. Edit <code>lib/MyApp/Controller/Books.pm</code> and change this line  in the <code>list</code> action:</p>

<pre><code>my $sth = $_-&gt;prepare('SELECT isbn, title, rating FROM books');
</code></pre>

<p>To:</p>

<pre><code>my $sth = $_-&gt;prepare(q{
    SELECT isbn, title, rating, authors FROM books_with_authors
});
</code></pre>

<p>The use of the <code>q{}</code> operator is a style I use for SQL queries in Perl code; you can use whatever style you like. Since this is a very short SQL statement (thanks to the view), it’s not really necessary to have it on multiple lines, but I like to be fairly consistent about this sort of thing.</p>

<p>The last thing we need to do is a a very simple change to the <code>list</code> template in <code>lib/MyApp/Templates/HTML/Books.pm</code>. In previous posts, I was referring to the non-existent “author” key in the each hash reference fetched from the database. In the new view, however, I've named that column “authors”. So change this line:</p>

<pre><code>cell { $book-&gt;{author} };
</code></pre>

<p>To</p>

<pre><code>cell { $book-&gt;{authors} };
</code></pre>

<p>And that’s it. Restart the server and reload <code>http://localhost:3000/books/list</code> and you should now see all of the books listed with their authors.</p>

<h3>Notes</h3>

<p>I think you can appreciate why, to a certain degree, I'm starting to think of the database as handling both the “M” and the “V” in “MVC”. It’s no mistake that the database object we created is known as a “view”. It was written in such a way that it not only expressed the relationship between books and authors in a compact but clear way, but it formatted the appropriate data for publishing on the site—all in a single, efficient query. All the Template::Declare view does is wrap it all up in the appropriate HTML.</p>

<p>PostgreSQL isn’t the only database to support feature such as this, by the way. All of the databases I've used support views, and many offer useful aggregate functions, as well. Among the <a href="http://dev.mysql.com/doc/refman/5.0/en/group-by-functions.html" title="MySQL Documentation: âGROUP BY (Aggregate) Functionsâ">MySQL aggregates</a>, for example, is <code>group_concat()</code>, which sort of combines the <code>array_to_string(array_agg())</code> PostgreSQL syntax into a single function. And I've <a href="http://www.justatheory.com/computers/databases/sqlite/custom_perl_aggregates.html" title="Just a Theory: âCustom Aggregates in Perlâ">personally written</a> a custom aggregate for SQLite in Perl. So although I use PostgreSQL for these examples and make use of its functionality, you can do much the same thing in most other databases.</p>

<p>Either way, I find this to be a lot less work than using an ORM or other abstraction layer between my app and the database. Frankly, SQL provides just the right level of abstraction.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/catalyst/sql-view-aggregate-magic.html">old layout</a>.</small></p>


