--- 
date: 2005-11-15T06:00:37Z
slug: bricolage-permissions-design
title: TKP Permissions Design
aliases: [/bricolage/permissions_design.html]
tags: [Bricolage, TKP, Kineticode]
type: post
---

So, I'm thinking of implementing permissions in the Kinetic Platform differently
than they're implemented in Bricolage. Bricolage has a number of fixed
permissions: READ, EDIT, RECALL, CREATE, PUBLISH, and DENY. These permissions
are cumulative, so that if you have EDIT permission, it implies READ, and if you
have CREATE, it implies RECALL, EDIT, and READ.

This design was based on Windows NT permissions (roughly), and has worked
reasonably, well, but is annoying for various reasons. The most serious drawback
is that it's difficult to understand. I always tell people who need to manage
Bricolage permissions to read [Bric::Security], and then read six more times.
But aside from the impenetrability of the current permissions design, it's also
difficult to add new permissions: where should they fit into the hierarchy? This
is what happened with RECALL and PUBLISH, which were added in a later version of
Bricolage. To this day, it's a bit confusing to some that, with RECALL
permission, you can RECALL a story but not CREATE one.

So I'm looking around for other permissions patterns. Unix is nice, in that
READ, WRITE, and EXECUTE permissions are all entirely independent, and apply to
three classes of objects (file owner, file group, everyone). But Unix only needs
to worry about files; Kinetic applications will have many more objects for which
permissions will need to be specified. [RT] uses discreet permissions with names
like “AdminQueue”, “CommentOnTicket”, “CreateTicket”, and “StealTicket” to be
applied to every user or group. This strikes me as somewhat more useful, since
the permissions are much more descriptive and can be targeted to particular
objects. In fact, the permission names even indicate to what types of objects
permissions apply!

So I'm thinking of leaving the cumulative permissions model behind and switching
to more descriptive, discreet, and potentially numerous permissions. I'm not,
however particularly fond of RT's approach of storing the permissions as strings
in the database. Now, I could keep them as numbers, where each permission has
its own unique number. This is similar to how Bricolage permissions work. Only
I'd have to always use [List::MoreUtil]'s `any()` function to see if a
permission was in a list.

For example, say that an object had permissions with the numbers 1, 2, 5, 8, 12,
49, and 50. If these were stored in an array, then every time I had to check
permissions, the `can_do()` function would have to search through those numbers:

    sub can_do {
        my ($self, $to_check) = @_;
        my $perms = $self->perms;
        return any { $_ == $to_check } @$perms;
    }

This isn't the most efficient approach, unfortunately. If there are a lot of
numbers, and you were always checking one that was towards the end of the list
of permissions, it'd always take a long time. So, an alternate approach--one
that conveniently works well with discreet permissions--is to use powers of two
for the permissions numbers: 1, 2, 4, 8, 16, 32, 64, 128, 256, and so on. Then,
for a given object, these can just be stored in a single number that's created
by bit-wise `OR`ing them together: `1 | 2 | 8 | 16`. Fortunately, PostgreSQL has
a nice [aggregate function] for this, `bit_or()`. (I'll have to [create my own]
for SQLite.) Anyway, then the `can_do()` function becomes much simpler and more
efficient:

    sub can_do {
        my ($self, $to_check) = @_;
        return $self->perms & $to_check;
    }

If the value of `$to_check` was in the list bit-`OR`ed into their permissions
number, it will be returned; otherwise, 0 will be returned. Not bad, eh?

So anyway, I'm soliciting feedback. Are discreet permissions better than
cumulative permissions? And if so, are bit-wise `OR`ed numbers the best way to
represent an object ACLs?

  [Bric::Security]: http://www.bricolage.cc/docs/current/api/Bric::Security
    "Read the Bric::Security documentation on the Bricolage site"
  [RT]: http://www.bestpractical.com/rt/ "RT Request Tracker"
  [List::MoreUtil]: http://search.cpan.org/dist/List-MoreUtils/
    "List::MoreUtils on CPAN"
  [aggregate function]: http://www.postgresql.org/docs/current/interactive/functions-aggregate.html
    "PostgreSQL Aggregate Functions"
  [create my own]: /computers/databases/sqlite/custom_perl_aggregates.html
    "SQLite Custom Aggregates in Perl"
