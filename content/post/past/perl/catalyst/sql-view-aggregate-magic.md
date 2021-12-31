--- 
date: 2009-11-05T14:00:00Z
slug: sql-view-aggregate-magic
title: "My Catalyst Tutorial: Add Authors to the View"
aliases: [/computers/programming/perl/catalyst/sql-view-aggregate-magic.html]
tags: [Perl, Catalyst, Template::Declare, Databases, DBI, Postgres, SQL]
type: post
---

Another post in my ongoing [series] of posts on using Catalyst with
Template::Declare and DBIx::Connector. This will be the last post covering
material from [chapter 3], I promise. This is a fun one, though, because we
continue to use this really nice [DSL] called “SQL,” which I think is more
expressive than an ORM would be.

To whit, the next task is to add the missing list of authors to the book list.
The thing is, the more I work with databases, the more I'm inclined to think
about them not only as the “M” in “[MVC]”, but also the “V”. I'll show you what
I mean.

### A Quick Fix

But first, a diversion. In the [second post] in this series, I created an SQL
statement to insert book authors, but I made a mistake: the values for surnames
and given names were reversed. Oops. Furthermore, I included explicit author
IDs, even though the `id` column uses a sequence for it’s default value. So
first we need to fix these issues. Change the `INSERT INTO authors` statement in
`sql/001-books.sql` to:

``` postgres
INSERT INTO authors (surname, given_name)
VALUES ('Bastien',      'Greg'),
       ('Nasseh',       'Sara'),
       ('Degu',         'Christian'),
       ('Stevens',      'Richard'),
       ('Comer',        'Douglas'),
       ('Christiansen', 'Tom'),
       ('Torkington',   'Nathan'),
       ('Zeldman',      'Jeffrey')
;
```

This time, we're letting the sequence populate the `id` column. Fortunately, it
starts from 1 just like we did, so we don’t need to update the values in the
`INSERT INTO book_author` statement. Now let’s fix the database:

``` postgres
DELETE FROM book_author;
DELETE FROM authors;
```

Then run the above SQL query to restore the authors with their proper names, and
then run the `INSERT INTO book_author` statement. That will get us back in
business.

### Constructing our Query

Now it’s time for the fun. The original SQL query we wrote to get the list of
books was:

``` postgres
SELECT isbn, title, rating FROM books;
```

Nothing unusual there. But to get at the authors, we need to join to
`book_author` and from there to `authors`. Our first cut looks like this:

``` postgres
SELECT b.isbn, b.title, b.rating, a.surname
  FROM books       b
  JOIN book_author ba ON b.isbn       = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id;
```

Which yields this data:

           isbn        |               title                | rating |   surname    
    -------------------+------------------------------------+--------+--------------
     978-1-58720-153-0 | CCSP SNRS Exam Certification Guide |      5 | Bastien
     978-1-58720-153-0 | CCSP SNRS Exam Certification Guide |      5 | Nasseh
     978-1-58720-153-0 | CCSP SNRS Exam Certification Guide |      5 | Degu
     978-0-201-63346-7 | TCP/IP Illustrated, Volume 1       |      5 | Stevens
     978-0-13-018380-4 | Internetworking with TCP/IP Vol.1  |      4 | Comer
     978-1-56592-243-3 | Perl Cookbook                      |      5 | Christiansen
     978-1-56592-243-3 | Perl Cookbook                      |      5 | Torkington
     978-0-7357-1201-0 | Designing with Web Standards       |      5 | Zeldman

Good start, but note how we now have three rows for â€œCCSP SNRS Exam
Certification Guideâ€? and two for â€œPerl Cookbookâ€?. We could of course
modify our Perl code to look at the ISBN in each row and combine as appropriate,
but it’s better to get the database to do that work, since it’s designed for
that sort of thing. So let’s use an [aggregate function] to combine the values
over multiple rows into a single row. All we have to do is use the column that
changes (`surname`) in an aggregate function and tell PostgreSQL to use the
other columns to group rows into one. PostgreSQL 8.4 introduces a really nice
aggregate function, `array_agg()`, for pulling a series of strings together into
an array. Let’s put it to use:

``` postgres
SELECT b.isbn, b.title, b.rating, array_agg(a.surname) as authors
  FROM books       b
  JOIN book_author ba ON b.isbn     = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id
 GROUP BY b.isbn, b.title, b.rating;
```

Now the output is:

           isbn        |               title                | rating |          authors         
    -------------------+------------------------------------+--------+--------------------------
     978-0-201-63346-7 | TCP/IP Illustrated, Volume 1       |      5 | {Stevens}
     978-0-13-018380-4 | Internetworking with TCP/IP Vol.1  |      4 | {Comer}
     978-1-56592-243-3 | Perl Cookbook                      |      5 | {Christiansen,Torkington}
     978-1-58720-153-0 | CCSP SNRS Exam Certification Guide |      5 | {Bastien,Nasseh,Degu}
     978-0-7357-1201-0 | Designing with Web Standards       |      5 | {Zeldman}

Much better. We now have a single row for each book, and the authors are all
grouped into a single column. Cool. But we can go one step further. Although we
could use Perl to turn the array of author surnames into a comma-delimited
string, there’s a PostgreSQL function for that, too: `array_to_string()`. Check
it out:

``` postgres
SELECT b.isbn, b.title, b.rating,
       array_to_string(array_agg(a.surname), ', ') as authors
  FROM books       b
  JOIN book_author ba ON b.isbn     = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id
 GROUP BY b.isbn, b.title, b.rating;
```

Now the rows will be:

           isbn        |               title                | rating |          authors          
    -------------------+------------------------------------+--------+--------------------------
     978-0-201-63346-7 | TCP/IP Illustrated, Volume 1       |      5 | Stevens
     978-0-13-018380-4 | Internetworking with TCP/IP Vol.1  |      4 | Comer
     978-1-56592-243-3 | Perl Cookbook                      |      5 | Christiansen, Torkington
     978-1-58720-153-0 | CCSP SNRS Exam Certification Guide |      5 | Bastien, Nasseh, Degu
     978-0-7357-1201-0 | Designing with Web Standards       |      5 | Zeldman

### Create a Database View

Cool! All the formatting work is done! But since it’s likely what we'll often
need to fetch book titles along with their authors, let’s create an SQL view for
this query. That way, we don’t have to write the same SQL in different places in
the application: we can just use the view. So create a new file,
`sql/002-books_with_authors.sql`, and add this SQL:

``` postgres
CREATE VIEW books_with_authors AS
SELECT b.isbn, b.title, b.rating,
       array_to_string(array_agg(a.surname), ', ') as authors
  FROM books       b
  JOIN book_author ba ON b.isbn     = ba.isbn
  JOIN authors     a  ON ba.author_id = a.id
 GROUP BY b.isbn, b.title, b.rating;
```

Now install this view in the database:

    psql -U postgres -d myapp -f sql/002-books_with_authors.sql

And now we can make use of the view any time we want and get the results of the
full query. It’s time to do that in our controller. Edit
`lib/MyApp/Controller/Books.pm` and change this line in the `list` action:

``` perl
my $sth = $_->prepare('SELECT isbn, title, rating FROM books');
```

To:

``` perl
my $sth = $_->prepare(q{
    SELECT isbn, title, rating, authors FROM books_with_authors
});
```

The use of the `q{}` operator is a style I use for SQL queries in Perl code; you
can use whatever style you like. Since this is a very short SQL statement
(thanks to the view), it’s not really necessary to have it on multiple lines,
but I like to be fairly consistent about this sort of thing.

The last thing we need to do is a a very simple change to the `list` template in
`lib/MyApp/Templates/HTML/Books.pm`. In previous posts, I was referring to the
non-existent “author” key in the each hash reference fetched from the database.
In the new view, however, I've named that column “authors”. So change this line:

``` perl
cell { $book->{author} };
```

To

``` perl
cell { $book->{authors} };
```

And that’s it. Restart the server and reload `http://localhost:3000/books/list`
and you should now see all of the books listed with their authors.

### Notes

I think you can appreciate why, to a certain degree, I'm starting to think of
the database as handling both the “M” and the “V” in “MVC”. It’s no mistake that
the database object we created is known as a “view”. It was written in such a
way that it not only expressed the relationship between books and authors in a
compact but clear way, but it formatted the appropriate data for publishing on
the site—all in a single, efficient query. All the Template::Declare view does
is wrap it all up in the appropriate HTML.

PostgreSQL isn’t the only database to support feature such as this, by the way.
All of the databases I've used support views, and many offer useful aggregate
functions, as well. Among the [MySQL aggregates], for example, is
`group_concat()`, which sort of combines the `array_to_string(array_agg())`
PostgreSQL syntax into a single function. And I've [personally written] a custom
aggregate for SQLite in Perl. So although I use PostgreSQL for these examples
and make use of its functionality, you can do much the same thing in most other
databases.

Either way, I find this to be a lot less work than using an ORM or other
abstraction layer between my app and the database. Frankly, SQL provides just
the right level of abstraction.

  [series]: {{% link "/tags/catalyst" %}} "Just a Theory: “Catalyst”"
  [chapter 3]: http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics
    "Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics"
  [DSL]: https://en.wikipedia.org/wiki/Domain-specific_language
    "Wikipedia: “Domain-Specific Language”"
  [MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
    "Wikipedia: “Model-view-controller”"
  [second post]: /computers/programming/perl/catalyst/tutorial-continued.html
  [aggregate function]: https://www.postgresql.org/docs/current/static/functions-aggregate.html
    "PostgreSQL Documentation: “Aggregate Functions”"
  [MySQL aggregates]: http://dev.mysql.com/doc/refman/5.0/en/group-by-functions.html
    "MySQL Documentation: “GROUP BY (Aggregate) Functions“"
  [personally written]: http://www.justatheory.com/computers/databases/sqlite/custom_perl_aggregates.html
    "Just a Theory: “Custom Aggregates in Perl”"
