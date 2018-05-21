--- 
date: 2012-05-26T00:18:02Z
slug: sqitch-dependencies
title: "Sqitch: Where to Define Dependencies?"
aliases: [/computers/databases/sqitch-dependencies.html]
tags: [Sqitch, SQL, databases]
type: post
---

I’ve been hard at work the last couple of days working on the new plan file
format. It looks like this:

    roles
    users_table
    @alpha

    # Some procedures.
    add_user
    del_user
    upd_user
    @beta     # woo!

The new code parses this, finding all steps and tags, and can rewrite the file
exactly how it read it, including blank lines and comments. All of this is
toward [requiring a plan file] and depending less on the VCS. I’ve also just
added methods for adding new steps and tags to the plan. In doing so, made sure
that all dependencies properly resolve, and throw an error if they don’t.
Dependencies will then be written at the top of the deployment file like so:

    -- :requires: roles
    -- :requires: users_table

The plan parser is smart enough to parse these out of the files when parsing the
plan, so it’s easy for the user to add dependencies just by editing the deploy
file.

As I was working on this, I realized that that may not be necessary. Since the
plan file will now be required, we could instead specify dependencies in the
plan file. Maybe something like this:

    roles
    users_table
    @alpha

    # Some procedures.
    add_user +roles +users_table
    del_user +@alpha
    upd_user +add_user -dr_evil
    @beta     # woo!

The idea is that required steps and tags could be specified on the same line as
the named step with preceding plus signs. Conflicting steps and tags could be
specified with a preceding minus sign. Here, the `add_user` step requires the
`roles` and `users_table` steps. The `del_user` step requires the `@alpha` tag.
And the `upd_user` step requires the `add_user` step but conflicts with the
`dr_evil` step.

There are a couple of upsides to this:

-   Dependencies are specified all in once place.
-   Plan parsing is much faster, because it no longer has to also parse every
    deploy script.
-   There is no need for any special syntax in the deploy scripts, which could
    theoretically conflict with some database-specific script formatting (a
    stretch, I realize).

But there are also downsides:

-   Changing dependencies would require editing the plan file directly.
-   The appearance of the plan file is someone more obscure.
-   It’s more of a PITA to edit the plan file.
-   Adding commands to change dependencies in the plan file might be tricky.

But I am thinking that the advantages might outweigh the disadvantages.
Thoughts?

  [requiring a plan file]: /computers/databases/sqitch-plan.html
