--- 
date: 2009-10-30T23:59:48Z
slug: parse-pg-acls-with-pg-priv
title: Pg::Priv Hits CPAN (Thanks Etsy!)
aliases: [/computers/databases/postgresql/parse-pg-acls-with-pg-priv.html]
tags: [Postgres, ACLs, Etsy, Perl, Pg::Priv]
type: post
---

Earlier this year, I was working on an administrative utility for [Etsy] that
validates PostgreSQL database permissions. Of course, in order to verify that
permissions were correct or needed updating, I had to have a way to examine
PostgreSQL ACLs, which are arrays made of of strings that look like this:

``` perl
my $acl = [
    'miriam=arwdDxt/miriam',
    '=r/miriam',
    'admin=arw/miriam',
];
```

So following [the documentation], I wrote a module that iterates over an ACL,
parses each privilege string, and returns an object describing it. Using it is
pretty easy. If you wanted to see what the permissions looked like on all the
tables in a database, you could do it like so:

``` perl
#!/usr/bin/perl -w
use strict;
use warnings;
use DBI;
use Pg::Priv;

my $dbname = shift or die "Usage: $0 dbname\n";

my $dbh = DBI->connect("dbi:Pg:dbname=$dbname", 'postgres', '');
my $sth = $dbh->prepare(
    q{SELECT relname, relacl FROM pg_class WHERE relkind = 'r'}
);

$sth->execute;
print "Permissions for $dbname:\n";
while (my $row = $sth->fetchrow_hashref) {
    print "  Table $row->{relname}:\n";
    for my $priv ( Pg::Priv->parse_acl( $row->{relacl} ) ) {
        print '    ', $priv->by, ' granted to ', $priv->to, ': ',
            join( ', ', $priv->labels ), $/;
    }
}
```

And here's what the output looks like:

    Permissions for bric:
      Table media__output_channel:
        postgres granted to postgres: UPDATE, SELECT, INSERT, TRUNCATE, REFERENCE, DELETE, TRIGGER
        postgres granted to bric: UPDATE, SELECT, INSERT, DELETE
      Table media_uri:
        postgres granted to postgres: UPDATE, SELECT, INSERT, TRUNCATE, REFERENCE, DELETE, TRIGGER
        postgres granted to bric: UPDATE, SELECT, INSERT, DELETE
      Table media_fields:
        postgres granted to postgres: UPDATE, SELECT, INSERT, TRUNCATE, REFERENCE, DELETE, TRIGGER

There are a bunch of utility methods to make it pretty simple to examine
PostgreSQL privileges.

And now, I'm pleased to announce the release yesterday of [Pg::Priv]. My thanks
to Etsy for agreeing to the release, and particularly to [Chad Dickerson] for
championing it. This module is a little thing compared to some things I've seen
open-sourced by major players, but even the simplest utilities can save folks
mountains of time. I hope you find Pg::Priv useful.

  [Etsy]: http://www.etsy.com/
  [the documentation]: http://www.postgresql.org/docs/current/static/sql-grant.html#SQL-GRANT-NOTES
    "PostgreSQL: “GRANT — Notes”"
  [Pg::Priv]: http://search.cpan.org/perldoc?Pg::Priv "Pg::Priv on CPAN"
  [Chad Dickerson]: http://chaddickerson.com/
