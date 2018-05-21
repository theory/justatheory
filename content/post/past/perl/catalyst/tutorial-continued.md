--- 
date: 2009-11-03T14:00:00Z
slug: catalyst-tutorial-continued
title: Catalyst with DBIx::Connector and Template::Declare
aliases: [/computers/programming/perl/catalyst/tutorial-continued.html]
tags: [Perl, Catalyst, DBIx::Connector, Template::Declare, Postgres]
type: post
---

Following up on my [post] yesterday introducing [Catalyst::View::TD], today I'd
like to continue with the next step in [chapter 3] of the Catalyst tutorial. The
twist here is that I'm going to use [PostgreSQL] for the database back-end and
start introducing some database best practices. I'm also going to make use of my
[DBIx::Connector] module to interact with the database.

### Create the Database

Picking up with the [database creation] section of the tutorial, the first
change I'd like to make is to use a [natural key] for the books table. All books
have unique identifiers, known as ISBNs, so creating a [surrogate key] (the
typical `id` column in ORM-managed applications) is redundant. One of the nice
things about PostgreSQL is that it ships with a contributed library, [isn],
which validates ISBN and other international identifiers. So we use this contrib
module (usually included in package-installed PostgreSQL servers) for the
primary key for books. If you need to install it from source, it’s pretty easy:

    cd postgresql-8.4.1/contrib/isn
    make
    make install

Ideally I'd use a natural key for the authors table too, but despite [some
attempts] to create universal identifiers for authors, nothing has really caught
on as far as I know. So I'll just stick to a surrogate key for now.

First step: create the database and install isn if it’s not already included in
the template database:

    createdb -U postgres myapp
    psql -U postgres -d myapp -f /usr/local/pgsql/share/contrib/isn.sql

The `isn.sql` file may be somewhere else on your system. Now let’s create the
database. Create `sql/001-books.sql` in the `MyApp` directory and paste this
into it:

    BEGIN;

    CREATE TABLE books (
        isbn   ISBN13   PRIMARY KEY,
        title  TEXT     NOT NULL DEFAULT '',
        rating SMALLINT NOT NULL DEFAULT 0 CHECK (rating BETWEEN 0 AND 5)
    );

    CREATE TABLE authors (
        id         BIGSERIAL PRIMARY KEY,
        surname    TEXT NOT NULL DEFAULT '',
        given_name TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE book_author (
        isbn       ISBN13 REFERENCES books(isbn),
        author_id  BIGINT REFERENCES authors(id),
        PRIMARY KEY (isbn, author_id)
    );

    INSERT INTO books
    VALUES ('1587201534',        'CCSP SNRS Exam Certification Guide', 5),
           ('978-0201633467',    'TCP/IP Illustrated, Volume 1',       5),
           ('978-0130183804',    'Internetworking with TCP/IP Vol.1',  4),
           ('978-1-56592-243-3', 'Perl Cookbook',                      5),
           ('978-0735712010',    'Designing with Web Standards',       5)
    ;

    INSERT INTO authors
    VALUES (1, 'Greg',      'Bastien'),
           (2, 'Sara',      'Nasseh'),
           (3, 'Christian', 'Degu'),
           (4, 'Richard',   'Stevens'),
           (5, 'Douglas',   'Comer'),
           (6, 'Tom',       'Christiansen'),
           (7, 'Nathan',    'Torkington'),
           (8, 'Jeffrey',   'Zeldman')
    ;

    INSERT INTO book_author
    VALUES ('1587201534',        1),
           ('1587201534',        2),
           ('1587201534',        3),
           ('978-0201633467',    4),
           ('978-0130183804',    5),
           ('978-1-56592-243-3', 6),
           ('978-1-56592-243-3', 7),
           ('978-0735712010',    8)
    ;

    COMMIT;

Yeah, I Googled for the ISBNs for those books. I found the ISBN-13 number for
most of them, but it handles the old ISBN-10 format, too, automatically
upgrading it to ISBN-13. I also added a `CHECK` constraint for the `rating`
column, to be sure that the value is always `BETWEEN 0 AND 5`. I also like to
include default values where it’s sensible to do so, and that syntax for
inserting multiple rows at once is pretty nice to have.

Go ahead and run this against your database:

    psql -U postgres -d myapp -f sql/001-books.sql

Now if you connect to the server, you should be able to query things like so:

    $ psql -U postgres myapp
    psql (8.4.1)
    Type "help" for help.

    myapp=# select * from books;
           isbn        |               title                | rating 
    -------------------+------------------------------------+--------
     978-1-58720-153-0 | CCSP SNRS Exam Certification Guide |      5
     978-0-201-63346-7 | TCP/IP Illustrated, Volume 1       |      5
     978-0-13-018380-4 | Internetworking with TCP/IP Vol.1  |      4
     978-1-56592-243-3 | Perl Cookbook                      |      5
     978-0-7357-1201-0 | Designing with Web Standards       |      5
    (5 rows)

### Setup the Database Connection

Great! The database is set. Now we need a way for the app to talk to it. I've
not yet decided how I'm going to integrate [DBIx::Connector] into a Catalyst
model class; maybe I'll figure it out as I write these posts. But since my
mantra is â€œthe database *is* the model,â€? for now I won’t bother with a model
at all. Instead, I'll create a simple accessor in `MyApp` so we can easily get
at the database connection wherever we need it. To do that, add these lines to
`lib/MyApp.pm`:

    use Moose;
    use DBIx::Connector;
    use Exception::Class::DBI;

    has conn => (is => 'ro', lazy => 1, default => sub {
        DBIx::Connector->new( 'dbi:Pg:dbname=myapp', 'postgres', '', {
            PrintError     => 0,
            RaiseError     => 0,
            HandleError    => Exception::Class::DBI->handler,
            AutoCommit     => 1,
            pg_enable_utf8 => 1,
        });
    });

We load [Moose] to get the `has` keyword, the officially sanctioned interface
for defining attributes in Catalyst classes. Then I use that keyword to create
the `conn` attribute. This attribute is read-only and has a DBIx::Connector
object for its default value. The nice thing about this is that the
DBIx::Connector object won’t be instantiated until it’s actually needed, and
then it will be kept forever. We never have to do anything else to use it.

Oh, and I like to make sure that text data coming back from PostgreSQL is
properly encoded as UTF-8, and I like to use [Exception::Class::DBI] to turn DBI
errors into exception objects.

Now it’s time to update our controller and template to fetch actual data from
the database. Edit `lib/MyApp/Controller/Books.pm` and change the `list` method
to:

    sub list : Local {
        my ($self, $c) = @_;
        $c->stash->{books} = $c->conn->run(fixup => sub {
            my $sth = $_->prepare('SELECT isbn, title, rating FROM books');
            $sth->execute;
            $sth;
        });
    }

All we're doing here is creating a statement handle for the query, executing the
query, and storing the statement handle in the stash. Now we need to update the
template to use the statement handle. Open up
`lib/MyApp/Templates/HTML/Books.pm` and change the `list` template to:

    template list => sub {
        my ($self, $args) = @_;
        table {
            row {
                th { 'Title'  };
                th { 'Rating' };
                th { 'Author' };
            };
            my $sth = $args->{books};
            while (my $book = $sth->fetchrow_hashref) {
                row {
                    cell { $book->{title}  };
                    cell { $book->{rating} };
                    cell { $book->{author} };
                };
            };
        };
    };

All we do is fetch each row from the statement handle and output it. The only
thing that’s changed is the use of the statement handle as an iterator rather
than an array reference.

And now we're set! Restart your server with `script/myapp_server.pl` and point
your browser at `http://localhost:3000/books/list`. Now you should see the book
titles and ratings, though the authors still aren’t present. We'll fix that in a
later post.

### Takeaway

The takeaway from this post: Use PostgreSQL’s support for custom data types to
create validated natural keys for your data, and use a stable, persistent
database connection to talk directly to the database. No need for an ORM here,
as the [DBI] provides a very Perlish access to a very capable [DSL] for models
called SQL.

More soon.

  [post]: /computers/programming/perl/catalyst/catalyst-view-td.html
    "Create Catalyst Views with Template::Declare"
  [Catalyst::View::TD]: http://search.cpan.org/perldoc?Catalyst::View::TD
    "Catalyst::View::TD on CPAN"
  [chapter 3]: http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics
    "Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics"
  [PostgreSQL]: http://www.postgresql.org/
    "PostgreSQL: The world's most advanced open source database"
  [DBIx::Connector]: http://search.cpan.org/perldoc?DBIx::Connector
    "DBIx::Connector on CPAN"
  [database creation]: http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics#CREATE_A_SQLITE_DATABASE
    "Create a SQLite Database"
  [natural key]: https://en.wikipedia.org/wiki/Natural_key
    "Wikipedia: “Natural Key”"
  [surrogate key]: https://en.wikipedia.org/wiki/Surrogate_key
    "Wikipedia: “Surrogate Key”"
  [isn]: http://www.postgresql.org/docs/current/static/isn.html
    "PostgreSQL Documentation: “isn”"
  [some attempts]: http://dlist.sir.arizona.edu/1716/
    "The Universal Author Identifier System (UAI_Sys)"
  [Moose]: http://search.cpan.org/perldoc?Moose "Moose on CPAN"
  [Exception::Class::DBI]: http://search.cpan.org/perldoc?Exception::Class::DBI
    "Exception::Class::DBI on CPAN"
  [DBI]: http://search.cpan.org/perldoc?DBI "The DBI on CPAN"
  [DSL]: https://en.wikipedia.org/wiki/Domain-specific_language
    "Wikipedia: “Domain-Specific Language”"
