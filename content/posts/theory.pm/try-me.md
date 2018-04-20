--- 
date: 2013-07-22T11:31:00Z
title: Try Me
url: /syntax/2013/07/22/try-me/

categories: [syntax]
---

Context
-------

Exception handling is a bit of a pain in Perl. Traditionally, we use
`eval {}`:

``` perl
eval {
    foo();
}
if (my $err = $@) {
    # Inspect $err…
}
```

The use of the `if` block is a bit unfortunate; worse is the use of the global
`$@` variable, which has inflicted unwarranted pain on developers over the
years[^1]. Many Perl hackers like to use [Try::Tiny] to work around these
shortcomings:

[^1]: In fairness much of the `$@` pain has been addressed [in Perl 5.14](https://metacpan.org/module/JESSE/perl-5.14.0/pod/perldelta.pod#Exception-Handling).
[Try::Tiny]: https://metacpan.org/module/Try::Tiny

``` perl
try {
    foo();
} catch {
    # Inspect $_…
}
```

Alas, Try::Tiny introduces its own idiosyncrasies, the primary one being that
it uses subroutine references rather than blocks, which prevents `returning`
from the calling context. One must work around this deficiency by [checking
return values](http://stackoverflow.com/a/10366209/79202):

``` perl
my $rv = try {
   f();
} catch {
   # …
};

if (!$rv) {
   return;
}
```

I can't tell you the number of times I've been burned by this quirk.

Still, there is a worse problem then the syntax: Just what, exactly, is the
exception? How does one determine the exceptional condition, and what can one
do about it? It might be a string. The string might be localized. It might be
an [Exception::Class] object, or a [Throwable] object, or a simple array
reference. Or any other value a Perl scalar can hold. This lack of specificity
requires one to be very careful when handling exceptions:

[Exception::Class]: https://metacpan.org/module/Exception::Class
[Throwable]: https://metacpan.org/module/Throwable

``` perl
if (my $err = $@) {
    if (ref $err) {
        if (eval { $err->isa('Exception::Class') }) {
            if ( $err->isa('SomeException') ) {
                # …
            } elsif ( $err->isa('SomeException') ) {
                # …
            } else {
                # …
            }
        } elsif (eval { $err->DOES('Throwable') }) {
            # …
        } elsif ( ref $err eq 'ARRAY') {
            # …
        }
    } else {
        if ( $err =~ /DBI/ ) {
            # …
        } elsif ( $err =~ /cannot open '([^']+)'/ ) {
            # …
        }
    }
}

```

One does not usually do this all in a single exception handler, but I assure
you that I have taken all these approaches. Usually my exception handlers
accrete conditionals as new, unexpected errors have been reported.

That's not all. A more frequent requirement in my code is to parse information
out of a string error. Here's an example from [PGXN::Manager]:

[PGXN::Manager]: https://github.com/pgxn/pgxn-manager/

``` perl
try {
    $self->distmeta(decode_json scalar $member->contents );
} catch {
    my $f = quotemeta __FILE__;
    (my $err = $_) =~ s/\s+at\s+$f.+//ms;
    $self->error([
        'Cannot parse JSON from “[_1]”: [_2]',
        $member->fileName,
        $err
    ]);
    return;
} or return;

return $self;
```

[JSON] throws an exception on invalid JSON, and I need to catch that exception
to show the user. The user does not care what file the exception was in, nor
the line number, so I have to *strip that stuff out* before passing the
original message off to a localizing error method.

[JSON]: https://metacpan.org/module/JSON

Gross.

It's time to end this.

Proposal
--------

I propose that a new [feature] be added to Perl 5: "try". It should do a few
things:

[feature]: https://metacpan.org/module/feature

* Add true `try` blocks.
* Add either `catch` blocks like [TryCatch] and [Try::Tiny], or `CATCH` blocks
  that live inside `try` blocks like [in Perl 6]. The exception should be passed
  either via a lexical `$_` variable.
* Introduces a new class, X, or X::Base, that is the base class for exception
  objects.

[TryCatch]: https://metacpan.org/module/TryCatch
[in Perl 6]: http://feather.perl6.nl/syn/S04.html#Exception_handlers

A new core class and a some new syntax is the easy part, thanks to Perl's
[feature] functionality. The devil is in the details, but I suspect that few
would quibble with this proposal, as it eliminates both the global `$@` and
the deficiencies of Try::Tiny.

The more important thing the "try" feature should do is to change the
functionality of `die`. Two ideas:

1. Have `die` convert *all* values passed to it to true exception objects
   derived from X::Base. The original value passed to `die` would be available
   via an attribute as well as in a string context (via [overload]).
   
   I think it would be worth it to try this on the first pass and see how well
   it smokes. If the string overloading is sufficient to prevent most of CPAN
   from choking, declare it a win and ignore the next idea.

2. Have `die` record the original value and pass it to exception handlers as
   usual, but automatically convert it to an X::Base-derived object before
   executing a `CATCH` (or `catch`) OP. I don't know if this is possible, or
   if it would be too inefficient, but it should allow existing
   exception-handling code to continue to work unmodified in most cases.
   On the other hand, it might be too magical.

[overload]: https://metacpan.org/module/overload

It might also be worthwhile to ship a few subclasses of X::Base and upgrade
all in-core exceptions to use them, perhaps inspired by [autodie::exception].

[autodie::exception]: https://metacpan.org/module/autodie::exception

``` perl
try {
    $self->distmeta(decode_json scalar $member->contents );
    return $self;
     CATCH {
        $self->error([
            'Cannot parse JSON from “[_1]”: [_2]',
            $member->fileName,
            $_->message
        ]);
        return;
    }
}
```
