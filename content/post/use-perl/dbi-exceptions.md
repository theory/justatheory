---
date: 2002-09-09T17:58:32Z
description: Features and issues with my Exception::Class::DBI module.
lastMod: 2022-10-02T22:39:29Z
slug: dbi-exceptions
tags:
  - use Perl
  - Perl
  - DBI
title: DBI Exceptions
---

A couple of weeks ago, I wrote and uploaded a new module to the CPAN,
[Exception::Class::DBI]. This module subclasses Dave Rolsky's great
Exception::Class module to provide DBI-specific exceptions for all you DBI users
out there. I've done my best to make it easy to use, too. Here's an example
cribbed from the synopsis:

``` perl
use DBI;
use Exception::Class::DBI;

my $dbh = DBI->connect( $data_source, $username, $auth,
                        { PrintError => 0,
                          RaiseError => 0,
                          HandleError => Exception::Class::DBI->handler
                        });

eval { $dbh->do($sql) };

if (my $ex = $@) {
    print STDERR "DBI Exception:\n";
    print STDERR "  Exception Type: ", ref $ex, "\n";
    print STDERR "  Error: ", $ex->error, "\n";
    print STDERR "  Err: ", $ex->err, "\n";
    print STDERR "  Errstr: " $ex->errstr, "\n";
    print STDERR "  State: ", $ex->state, "\n";
    my $ret = $ex->retval;
    $ret = 'undef' unless defined $ret;
    print STDERR "  Return Value: $ret\n";
}
```

Not too bad, eh? Unfortunately, there are a few issues. What the module does is
grab all of the relevant DBI attributes that it can. Unfortunately, however, not
all of the attributes are fully implemented by all drivers. Furthermore, DBI
doesn't provide default values for all of them.

However, I'm pulling together a list of all the issues I found with DBI
attributes, and when Tim Bunce returns from vacation in a week or so, I'll
submit them, along with all the patches I could figure out. I'll probably also
provide a test suite, too, just to try to keep things consistent going forward.

I'm also working on a patch to the DBI itself to have it throw class exceptions
whenever possible, too. Right now, it only throws object exceptions, but there
are a number of places where they could be thrown in a class context, too,
mainly during object construction (i.e., when calling `connect()`. We'll see how
that goes over.

In the meantime, feedback on the current implementation is more than welcome!

*Originally published [on use Perl;]*

  [Exception::Class::DBI]: http://search.cpan.org/dist/Exception-Class-DBI
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/7626/
    "use.perl.org journal of Theory: “DBI Exceptions”"
