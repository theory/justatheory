--- 
date: 2012-05-31T21:20:42Z
slug: evolving-sqitch-plan
title: The Ever Evolving Sqitch Plan
aliases: [/computers/databases/evolving-sqitch-plan.html]
tags: [Sqitch, SQL, change management, VCS, database]
type: post
---

I’ve been working on the parser for the proposed new [deployment plan format],
and spent a day thinking it wasn’t going to work at all. But by the end of the
day yesterday, I was back on board with it. I think I’ve also figured out how to
eliminate the VCS dependency (and thus a whole level of complication). So first,
the plan format:

-   Names of things (steps and tags) cannot start or end in punctuation
    characters
-   `@` indicates a tag
-   `+` indicates a step to be deployed
-   `-` indicates a step to be reverted
-   `#` starts a comment
-   `:` indicates a required step
-   `!` indicates a conflicting step
-   `%` is for Sqitch directives

So, here’s an example derived from a [previous example][deployment plan format]:

    %plan-syntax-v1
    +roles
    +users_table
    +dr_evil
    @alpha

    # Some procedures.
    +add_user :roles :users_table
    +del_user :@alpha
    -dr_evil
    +upd_user :add_user !dr_evil
    @beta     # woo!

So we start with a directive for the version of the plan file (thanks for [the
suggestion], Tom Davis!). Then we have deployments of the `roles`,
`users_table`, and `dr_evil` steps. After that, it’s tagged as `alpha`.

Next, we have a comment, then the deployment of the `add_user` step. It requires
that the `roles` and `users_table` steps be deployed. Then we deploy `del_user`.
It requires all steps as of the `$alpha` tag. Next we revert the `dr_evil` step.
Why? Because the next line deploys `upd_user`, which conflicts with `dr_evil`
(and requires `add_user`). And finally, we tag it as `beta`.

There are a number of things I like about these changes:

-   Dependencies are spelled out in the plan file, rather than the deploy
    scripts. This allows the deploy scripts to have nothing special about them
    at all.

-   We now have a way to explicitly revert a step as part of the overall plan.
    This is useful for ensuring that conflicts can be dealt with.

-   We can deploy to any point in the plan by specifying a step:

        sqitch deploy add_user

    Or a tag:

        sqitch deploy @alpha

    For steps that are duplicated, we can disambiguate by specifying a tag:

        sqitch deploy dir_evil --as-of @alpha

    Naturally, this requires that a step not be repeated within the scope of a
    single tag.

Now, as for the VCS dependency, my impetus for this was to allow `Sqitch` to get
earlier versions of a particular deploy script, so that it could be modified in
place and redeployed to make changes inline, as described in [an earlier post].
However I’ve been troubled as to how to indicate in the plan where to look in
the VCS history for a particular copy of a file. Yesterday, I had an insight:
why do I need the earlier version of a particular deploy script at all? There
are two situations where it would be used, assuming a plan that mentions the
same step at two different points:

1.  To run it as it existed at the first point, and to run it the second time as
    it exists at *that* time.
2.  To run it in order to revert from the second point to the first.

As to the first, I could not think of a reason why that would be necessary. If
I’m bootstrapping a new database, and the changes in that file are idempotent,
is it really necessary to run the earlier version of the file at all? Maybe it
is, but I could not think of one.

The second item is the bit I wanted, and I realized (thanks in part to prompt
from [Peter van Hardenberg] while at PGCon) that I don’t need a VCS to get the
script as it was at the time it was deployed. Instead, all I have to do is
*store the script in the database as it was at the time it was run.* Boom,
reversion time travel without a VCS.

As an example, take the plan above. Say we have a database that has been
deployed all the way to `@beta`. Let’s add the `add_user` step again:

    %plan-syntax-v1
    +roles
    +users_table
    +dr_evil
    @alpha

    # Some procedures.
    +add_user :roles :users_table
    +del_user :@alpha
    -dr_evil
    +upd_user :add_user !dr_evil
    @beta     # woo!

    +crypto
    +add_user :roles :users_table :crypto
    @gamma

The last two lines are the new ones. At this point, the
`sql/deploy/add_user.sql` script has been modified to fix a bug that now
requires the `crypto` step. If we deploy to a new database, Sqitch will notice
that the same step is listed twice and apply it only once. This works because,
even though `add_user` is listed before `pg_crypto`, it is actually applied as
described in its second declaration. So the run order would be:

-   `crypto`
-   `add_user`
-   `del_user`
-   `upd_user`

Note that this works because `crypto` declares no dependencies itself. If it
did, it would be shuffled as appropriate. It would not work if it required, say,
`upd_user`, as that would create a circular dependency (`add_user` — `crypto` —
`upd_user` — `add_user`).

Now say we want to deploy the changes to the production database, which is
currently on `@beta`. That simply runs:

-   `crypto`
-   `add_user`

If something went wrong, and we needed to revert, all Sqitch has to do is to
read `add_user` from the database, *as it was deployed previously,* and run
that. This will return the `add_user` function to its previous state. So, no
duplication and no need for a VCS.

The one thing that scares me a bit is being able to properly detect circular
dependencies in the plan parser. I think it will be pretty straight-forward for
steps that require other steps. Less so for steps that require tags. Perhaps it
will just have to convert a tag into an explicit dependence on all steps prior
to that tag.

So, I think this will work. But I’m sure I must have missed something. If you
notice it please enlighten me in the comments. And thanks for reading this far!

  [deployment plan format]: /computers/databases/sqitch-plan.html
  [the suggestion]: /computers/databases/sqitch-plan.html#comment-537891454
  [an earlier post]: /computers/databases/sql-change-management-sans-redundancy.html
  [Peter van Hardenberg]: https://www.pgcon.org/2012/schedule/speakers/244.en.html
