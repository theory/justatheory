--- 
date: 2011-05-10T21:12:11Z
slug: dbix-connector-catch
title: DBIx::Connector Exception Handling Design
aliases: [/computers/programming/perl/modules/dbix-connector-catch.html]
tags: [Perl, Databases, DBIx::Connector, Exception Handling, DBI]
type: post
---

In response to a [bug report], I removed the documentation suggesting that one
use the `catch` function exported by [Try::Tiny] to specify an
exception-handling function to the [DBIx::Connector] execution methods. When I
wrote those docs, Try::Tiny's `catch` method just returned the subroutine. It
was later changed to return an object, and that didn't work very well. It seemed
a much better idea not to depend on an external function that could change its
behavior when there is no direct dependency on Try::Tiny in DBIx::Connector. I
removed that documentation in 0.43. So instead of this:

``` perl
$conn->run(fixup => sub {
    ...
}, catch {
    ...
});
```

It now recommends this:

``` perl
$conn->run(fixup => sub {
    ...
}, catch => sub {
    ...
});
```

Which frankly is better balanced anyway.

But in discussion with Mark Lawrence in [the ticket][bug report], it has become
clear that there's a bit of a design problem with this approach. And that
problem is that there is no `try` keyword, only `catch`. The `fixup` in the
above example does not `try`, but the inclusion of the `catch` *implicitly*
makes it behave like `try`. That also means that if you use the default mode
(which can be set via the [`mode` method]), then there will usually be no
leading keyword, either. So we get something like this:

``` perl
$conn->run(sub {
    ...
}, catch => sub {
    ...
});
```

So it starts with a `sub {}` and no `fixup` keyword, but there is a `catch`
keyword, which implicitly wraps that first `sub {}` in a `try`-like context. And
aesthetically, it's unbalanced.

So I'm trying to decide what to do about these facts:

-   The `catch` implicitly makes the first sub be wrapped in a `try`-type
    context but without a `try`-like keyword.
-   If one specifies no mode for the first sub but has a `catch`, then it looks
    unbalanced.

At one level, I'm beginning to think that it was a mistake to add the
exception-handling code at all. Really, that should be the domain of another
module like Try::Tiny or, better, the language. In that case, the example would
become:

``` perl
use Try::Tiny;
try {
    $conn->run(sub {
        ...
    });
} catch {
    ....
}
```

And maybe that really should be the recommended approach. It seems silly to have
replicated most of Try::Tiny inside DBIx::Connector just to cut down on the
number of anonymous subs and indentation levels. The latter can be got round
with some semi-hinky nesting:

``` perl
try { $conn->run(sub {
    ...
}) } catch {
    ...
}
```

Kind of ugly, though. The whole reason the `catch` stuff was added to
DBIx::Connector was to make it all nice and integrated (as discussed [here]).
But perhaps it was not a valid tradeoff. I'm not sure.

So I'm trying to decide how to solve these problems. The options as I see them
are:

1.  Add another keyword to use before the first sub that means "the default
    mode". I'm not keen on the word "default", but it would look something like
    this:

    ``` perl
    $conn->run(default => sub {
        ...
    }, catch => sub {
        ...
    });
    ```

    This would provide the needed balance, but the `catch` would still
    implicitly execute the first sub in a `try` context. Which isn't a great
    idea.

2.  Add a `try` keyword. So then one could do this:

    ``` perl
    $conn->run(try => sub {
        ...
    }, catch => sub {
        ...
    });
    ```

    This makes it explicit that the first sub executes in a `try` context. I'd
    also have to add companion `try_fixup`, `try_ping`, and `try_no_ping`
    keywords. Which are ugly. And furthermore, if there *was* no `try` keyword,
    would a `catch` be ignored? That's what would be expected, but it changes
    the current behavior.

3.  Deprecate the `try`/`catch` stuff in DBIx::Connector and eventually remove
    it. This would simplify the code and leave the responsibility for exception
    handling to other modules where it's more appropriate. But it would also be
    at the expense of formatting; it's just a little less aesthetically pleasing
    to have the `try`/`catch` stuff outside the method calls. But maybe it's
    just more appropriate.

I'm leaning toward \#3, but perhaps might do \#1 anyway, as it'd be nice to be
more explicit and one would get the benefit of the balance with `catch` blocks
for as long as they're retained. But I'm not sure yet. I want your feedback on
this. How do you want to use exception-handling with DBIx::Connector? Leave me a
comment here or on [the ticket].

  [bug report]: http://rt.cpan.org/Ticket/Display.html?id=65196
  [Try::Tiny]: http://search.cpan.org/perldoc?Try::Tiny
  [DBIx::Connector]: http://search.cpan.org/perldoc?DBIx::Connector
  [`mode` method]: http://search.cpan.org/dist/DBIx-Connector/lib/DBIx/Connector.pm#mode
  [here]: https://github.com/theory/dbix-connector/issues/3
  [the ticket]: https://rt.cpan.org/Ticket/Display.html?id=65196
