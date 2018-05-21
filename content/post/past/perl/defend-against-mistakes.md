--- 
date: 2010-05-19T17:45:57Z
description: I'm not sure I want to get into the business of defending against programmer mistakes in DBIx::Connector module. What do you think?
slug: defend-against-programmer-mistakes
title: Defend Against Programmer Mistakes?
aliases: [/computers/programming/perl/defend-against-mistakes.html]
tags: [Perl, DBIx::Connector]
type: post
---

I get email:

> Hey David,
>
> I ran in to an issue earlier today in production that, while it is an error in
> my code, [DBIx::Connector] could easily handle the issue better. Here's the
> use case:
>
>     package Con;
>     use Moose;
>     sub txn {
>         my ($self, $code) = @_;
>         my @ret;
>         warn "BEGIN EVAL\n";
>         eval{ @ret = $code->() };
>         warn "END EVAL\n";
>         die "DIE: $@" if $@;
>         return @ret;
>     }
>     package main;
>     my $c = Con->new();
>     foreach (1..2) {
>         $c->txn(sub{ next; });
>     }
>
> The result of this is:
>
>     BEGIN EVAL
>     Exiting subroutine via next at test.pl line 16.
>     Exiting eval via next at test.pl line 16.
>     Exiting subroutine via next at test.pl line 16.
>     BEGIN EVAL
>     Exiting subroutine via next at test.pl line 16.
>     Exiting eval via next at test.pl line 16.
>     Exiting subroutine via next at test.pl line 16.
>
> This means that any code after the eval block is not executed. And, in the
> case of DBIx::Connector, means the transaction is not committed or rolled
> back, and the next call to is `txn()` mysteriously combined with the previous
> `txn()` call. A quick fix for this is to just add a curly brace in to the
> eval:
>
>     eval{ { @ret = $code->() } };
>
> Then the results are more what we'd expect:
>
>     BEGIN EVAL
>     Exiting subroutine via next at test.pl line 16.
>     END EVAL
>     BEGIN EVAL
>     Exiting subroutine via next at test.pl line 16.
>     END EVAL
>
> I've fixed my code to use `return;` instead of `next;`, but I think this would
> be a useful fix for DBIx::Connector so that it doesn't act in such an
> unexpected fashion when the developer accidentally calls next.

The fix here is pretty simple, but I'm not sure I want to get into the business
of defending against programmer mistakes like this in [DBIx::Connector] or any
module.

What do you think?

  [DBIx::Connector]: http://search.cpan.org/perldoc?DBIx::Connector
