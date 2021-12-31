--- 
date: 2010-04-28T00:14:07Z
slug: execute-sql-on-connect
title: Execute SQL Code on Connect
aliases: [/computers/databases/postgresql/execute-on-select.html]
tags: [Postgres, Perl, Ruby, Ruby on Rails, Catalyst, DBI, PL/Perl]
type: post
---

I’ve been writing a fair bit of [PL/Perl] for a client, and one of the things
I’ve been doing is eliminating a ton of duplicate code by [creating utility
functions] in the `%_SHARED` hash. This is great, as long as the code that
creates those functions gets executed at the beginning of every database
connection. So I put the utility generation code into a single function, called
`prepare_perl_utils()`. It looks something like this:

``` plpgsql
CREATE OR REPLACE FUNCTION prepare_perl_utils(
) RETURNS bool LANGUAGE plperl IMMUTABLE AS $$
    # Don't bother if we've already loaded.
    return 1 if $_SHARED{escape_literal};

    $_SHARED{escape_literal} = sub {
        $_[0] =~ s/'/''/g; $_[0] =~ s/\\/\\\\/g; $_[0];
    };

    # Create other code refs in %_SHARED…
$$;
```

So now all I have to do is make sure that all the client’s apps execute this
function as soon as they connect, so that the utilities will all be loaded up
and ready to go. Here’s how I did it.

First, for the Perl app, I just took advantage of the [DBI]’s [callbacks] to
execute the SQL I need when the DBI connects to the database. That link might
not work just yet, as the DBI’s callbacks have only just been documented and
that documentation appears only in dev releases so far. Once 1.611 drops, the
link should work. At any rate, the use of callbacks I’m exploiting here has been
in the DBI since 1.49, which was released in November 2005.

The approach is the same as I’ve [described before][]: Just specify the
`Callbacks` parameter to `DBI->connect`, like so:

``` perl
my $dbh = DBI->connect_cached($dsn, $user, $pass, {
    PrintError     => 0,
    RaiseError     => 1,
    AutoCommit     => 1,
    Callbacks      => {
        connected => sub { shift->do('SELECT prepare_perl_utils()' },
    },
});
```

That’s it. The `connected` method is a no-op in the DBI that gets called to
alert subclasses that they can do any post-connection initialization. Even
without a subclass, we can take advantage of it to do our own initialization.

It was a bit trickier to make the same thing happen for the client’s [Rails]
app. Rails, alas, provides no on-connection callbacks. So we instead have to
monkey-patch Rails to do what we want. With some help from “dfr\|mac” on
\#rubyonrails (I haven’t touched Rails in 3 years!), I got it worked down to
this:

``` ruby
class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
    def initialize_with_perl_utils(*args)
    returning(initialize_without_perl_utils(*args)) do
        execute('SELECT prepare_perl_utils()')
    end
    end
    alias_method_chain :initialize, :perl_utils
end
```

Basically, we overpower the PostgreSQL adapter’s `initialize` method and have it
call `initialize_with_perl_utils` before it returns. It’s a neat trick; if
you’re going to practice [fuck typing], `alias_method_chain` makes it about as
clean as can be, albeit a little too magical for my tastes.

Anyway, recorded here for posterity (my blog is my other brain!).

  [PL/Perl]: https://www.postgresql.org/docs/current/static/plperl.html
  [creating utility functions]: http://www.depesz.com/index.php/2008/08/01/writing-sprintf-and-overcoming-limitations-in-plperl/
  [DBI]: http://dbi.perl.org/
  [callbacks]: https://metacpan.org/dist/DBI/DBI.pm#Callbacks_(hash_ref)
  [described before]: {{% ref "/post/past/perl/dbi-connect-cached-hack" %}}
  [Rails]: http://rubyonrails.org/
  [fuck typing]: {{% ref "/post/past/programming/fuck-typing" %}}
