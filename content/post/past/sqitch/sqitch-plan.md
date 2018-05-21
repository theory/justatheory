--- 
date: 2012-05-22T21:31:46Z
slug: sqitch-plan
title: "Sqitch Update: The Plan"
aliases: [/computers/databases/sqitch-plan.html]
tags: [Sqitch, SQL, databases, VCS, Git]
type: post
---

I gave my first presentation on Sqitch at [PGCon] last week. The slides are [on
Slideshare] and [the PGCon site]. It came together at the last minute,
naturally. I was not able to pay as close attention to PGCon sessions as I would
have liked, as I was doing last minute hacking to get the `deploy` command
working on PostgreSQL, and then writing the slides (which are based on [the
tutorial]). I was pleased with the response, given that this is very much a
project that is still under heavy development and available only as a very very
early alpha. There was great discussion and feedback afterward, which I
appreciate.

A number of folks offered to help, too. For that I am grateful. I’ve started a
list of [to-dos] to give folks a starting point. Please fork and hack! Find me
on \#sqitch on Freenode for questions/comments/discussion.

But back to the guts. As a result of the work on the `deploy` command, as well
as thinking about how I and my co-workers do database development with Git, I am
starting to revise how I think about the deployment plan. You see, I personally
often make a *lot* of changes to a deployment script as I develop a database,
generally over many commits and even many days or weeks. If I were to then rely
on the Git history to do deployments, it would probably work, but there might be
ten times as many deployments as I actually need, just to get it from zero to
release state. I had originally thought that using `sqitch bundle --tags-only`
to create a bundle with a written plan would get around this, as it would write
a plan file with only VCS tags for Sqitch tags, rather than every commit. That
might be okay for releases, but still not great for the developers, such as
myself, who will be using Sqitch as part of the development process all day
long.

So now I’m thinking more that Sqitch should rely on an explicit plan file (which
was to be the preferred method, if it existed, all along) rather than VCS
history. That is, the plan file would be required, and a new command,
`sqitch plan`, will allow one to interactively add steps and tags to it. It
would also make it easier for the developer to hand-edit, as appropriate, so as
not to rely on a funky Git history.

So I’m toying with changing the plan format, which up until now looked likes
this:

    [alpha]
    foo
    bar
    init

    [beta]
    users
    insert_user
    delete_user
    update_user

    [gamma]
    widgets
    insert_widget

Each item in brackets is a tag, and each item below is a deployment step (which
corresponds to a script) that is part of that tag. So if you deployed to the
`beta` tag, it would deploy all the way up to `update_user` step. You could only
specify tags for deployment, and either all the steps for a given tag succeeded
or they failed. When you added a step, it was added to the most recent tag.

I came up with this approach by [playing with `git log`]. But now I’m starting
to think that it should feel a bit more gradual, where steps are added and a tag
is applied to a certain step. Perhaps a format like this:

    foo
    bar
    init
    @alpha

    users
    insert_user
    delete_user
    update_user
    @beta

    widgets
    insert_widget

With this approach, one could deploy or revert to any step or tag. And a tag is
just added to a particular step. So if you deployed to `@beta`, it would run all
the steps through `update_user`, as before. But you could also update all,
deploy through `insert_widget`, and then the current deployed point in the
database would not have a tag (could perhaps use a symbolic tag, `HEAD`?).

I like this because it feels a bit more VCS-y. It also makes it easier to add
steps to the plan without worrying about tagging before one was ready. And
adding steps and tags can be automated by a `sqitch plan` command pretty easily.

So the plan file becomes the canonical source for deployment planning, and is
required. What we’ve lost, however, is the ability to use the same step name at
different points in the plan, and to get the proper revision of the step by
traveling back in VCS history for it. (Examples of what I mean are covered in [a
previous post], as well as the aforementioned [presentation][the PGCon site].)
However, I think that we can still do that by *complementing* the plan with VCS
history.

For example, take this plan:

    foo
    bar
    init
    @alpha

    users
    insert_user
    delete_user
    update_user
    @beta

    insert_user
    update_user
    @gamma

Note how `insert_user` and `update_user` repeat. Normally, this would not be
allowed. But *if* the plan is in a VCS, and *if* that VCS has tags corresponding
to the tags, *then* we might allow it: when deploying, each step would be
deployed at the point in time of the tag that follows it. In other words:

-   `foo`, `bar`, and `init` would be deployed as of the `alpha` tag.
-   `users`, `insert_user`, `delete_user`, and `update_user` would be deployed
    as they were as of the `beta` tag.
-   `insert_user` and `update_user` would again be deployed, this time as of the
    `gamma` tag.

This is similar to what I’ve described before, in terms of where in VCS history
steps are read from. But whereas before I was using the VCS history to derive
the plan, I am here reversing things, requiring an explicit plan and using its
hints (tags) to pull stuff from the VCS history as necessary.

I think this could work. I am not sure if I would require that all tags be
present, or only those necessary to resolve duplications (both approaches feel a
bit magical to me, though I haven’t tried it yet, either). The latter would
probably be more forgiving for users. And overall, I think the whole approach is
less rigid, and more likely to allow developers to work they way they are used
to working.

But I could be off my rocker entirely. What do *you* think? I want to get this
right, please, if you have an opinion here, let me have it!

  [PGCon]: http://pgcon.org/
  [on Slideshare]: https://www.slideshare.net/justatheory/sqitch-pgconsimple-sql-change-management-with-sqitch
  [the PGCon site]: https://www.pgcon.org/2012/schedule/events/479.en.html
  [the tutorial]: http://search.cpan.org/dist/App-Sqitch/lib/sqitchtutorial.pod
  [to-dos]: https://github.com/theory/sqitch/issues?labels=todo&page=1&state=open
  [playing with `git log`]: /computers/databases/vcs-sql-change-management.html
  [a previous post]: /computers/databases/sql-change-management-sans-redundancy.html
