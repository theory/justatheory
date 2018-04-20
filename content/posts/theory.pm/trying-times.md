--- 
date: 2013-07-26T15:20:00Z
title: Trying Times
url: /exceptions/2013/07/26/trying-times/
tags: [Perl]
---

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
years[^1]. Many Perl hackers put [Try::Tiny] to work to circumvent these
shortcomings:

``` perl
try {
    foo();
} catch {
    # Inspect $_…
};
```

Alas, Try::Tiny introduces its own idiosyncrasies, particularly its use of
subroutine references rather than blocks. While a necessity of a pure-Perl
implementation, it prevents `return`ing from the calling context. One must
work around this deficiency by [checking return values]:

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

I can't tell you how often this quirk burns me.

<!-- more -->

Sadly, there is a deeper problem then syntax: Just what, exactly, is an
exception? How does one determine the exceptional condition, and what can be
done about it? It might be a string. The string might be localized. It might
be an [Exception::Class] object, or a [Throwable] object, or a simple array
reference. Or any other value a Perl scalar can hold. This lack of specificity
requires careful handling of exceptions:

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

Not every exception handler requires so many conditions, but I have certainly
exercised all these approaches. Usually my exception handlers accrete
condition as users report new, unexpected errors.

That's not all. My code frequently requires parsing information out of a
string error. Here's an example from [PGXN::Manager]:

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

When [JSON] throws an exception on invalid JSON, the code must catch that
exception to show the user. The user cares not at all what file threw the
exception, nor the line number. The code must *strip that stuff out* before
passing the original message off to a localizing error method.

Gross.

It's time to end this. A forthcoming post will propose a plan for adding
proper exception handling to the core Perl language, including exception
objects and an official `try`/`catch` syntax.

<!-- notes -->

[^1]: In fairness much of the `$@` pain has been addressed [in Perl 5.14].
[Try::Tiny]: https://metacpan.org/module/Try::Tiny
[checking return values]: http://stackoverflow.com/a/10366209/79202
[Exception::Class]: https://metacpan.org/module/Exception::Class
[Throwable]: https://metacpan.org/module/Throwable
[PGXN::Manager]: https://github.com/pgxn/pgxn-manager/
[JSON]: https://metacpan.org/module/JSON
[in Perl 5.14]: https://metacpan.org/module/JESSE/perl-5.14.0/pod/perldelta.pod#Exception-Handling
