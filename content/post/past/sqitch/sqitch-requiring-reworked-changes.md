--- 
date: 2013-07-17T15:12:20Z
slug: sqitch-requiring-reworked-changes
title: Requiring Reworked Sqitch Changes
aliases: [/computers/databases/sqitch-requiring-reworked-changes.html]
tags: [Sqitch]
type: post
---

I recently discovered a mildly annoying [bug] in [Sqitch], the Git-inspired
database schema change management app I’ve been working on for the past year.
One of its key features is the ability to “rework” changes. For example, if you
have a change that defines a function `change_password()`, and discover sometime
after release that it has a bug (maybe the hashing algorithm is too weak), you
can “rework” it – essentially modify it in place – and save some headaches.
Check out the “In Place Changes” section of the ([PostgreSQL], [SQLite],
[Oracle], or [MySQL] (coming soon) tutorials for detailed examples of how it
works.

The bug was about what happens when one adds a new change that depends on a
reworked change, but just specifies it by name, such as `change_password`:

    sqitch add meow --requires change_password

This added the change fine, but at deploy time, Sqitch complained that there
were multiple instances of a change in the database. Of course, that’s true,
because `change_password` will have been deployed twice: once for the original
version, and the second time for the reworked version. This was inconsistent
with how it looked up changes in the plan, where it would just return the first
instance of a change in the plan. So I [changed it] so that dependency lookups
in the database also return the first instance of the change. I believe this
makes sense, because if you require `change_password`, without specifying which
instance you want, you probably want *any* instance, starting with the earliest.

But what if you actually need to require a specific instance of a reworked
change? Let’s say your plan looks like this:

    users
    widgets
    change_pass
    sleep
    @v1.0

    work_stuff
    change_pass [change_pass@v1.0]

The third change is `change_pass`, and it has been reworked in the sixth change
(requiring the previous version, as of the `@v1.0` tag). If you want to require
*any* instance of `change_pass`, you specify it as in the previous example. But
what if there were changes in the reworked version that you require? You might
try to require it as-of the symbolic tag `@HEAD`:

    sqitch add meow --requires change_password@HEAD

This means, “Require the last instance of `change_password` in the plan.” And
that would workâ€¦until you reworked it again, then it would be updated to point
at the newer instance. Sqitch will choke on that, because you can’t require
changes that appear *later* in the plan.

So what we have to do instead is add a *new* tag after the second instance of
`change_pass`:

    sqitch tag rehash

Now the plan will look like this:

    users
    widgets
    change_pass
    sleep
    @v1.0

    work_stuff
    change_pass [change_pass@v1.0]
    @rehash

Now we can identify exactly the instance we need by specifying that tag:

    sqitch add meow --requires change_password@rehash

Meaning “The instance of `change_password` as of `@rehash`.” If what you really
needed was the first version, you can specify the tag that follows it:

    sqitch add meow --requires change_password@v1.0

Which, since it is the first instance is the same as specifying no tag at all.
But if there were, say, four instances of `change_pass`, you can see how it
might be important to use tags to specify specific instances for dependencies.

For what it’s worth, this is how to get around the [original bug][bug]
referenced above: just specify *which* instance of the change to require by
using a tag that follows that instance, and the error should go away.

  [bug]: https://github.com/theory/sqitch/issues/103
  [Sqitch]: https://sqitch.org/
  [PostgreSQL]: https://metacpan.org/module/sqitchtutorial#In-Place-Changes
  [SQLite]: https://metacpan.org/module/sqitchtutorial-sqlite#In-Place-Changes
  [Oracle]: https://metacpan.org/module/sqitchtutorial-oracle#In-Place-Changes
  [MySQL]: https://metacpan.org/module/sqitchtutorial-mysql#In-Place-Changes
  [changed it]: https://github.com/theory/sqitch/compare/edcd84a...f501e88
