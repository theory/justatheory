--- 
date: 2012-08-02T14:08:28Z
slug: sqitch-more-you
title: "Sqitch v0.80: Now With More You"
aliases: [/computers/databases/sqitch-more-you.html]
tags: [Sqitch, SQL, Change Management, You, Databases]
type: post
---

Last night, I uploaded [Sqitch v0.80], the latest dev release of the simple
database change management system I’ve been working on. I’m kind of stunned by
the sheer number of changes in this release, given that the interface has not
changed much. Mainly, there’s more *you* in this version. That is, [like Git],
the first thing you’ll want to do after installing Git is tell it who you are:

    > sqitch config --user user.name 'Marge N. O’Vera'
    > sqitch config --user user.email 'marge@example.com'

This information is now recorded for every change added to a project plan, as
well as every commit to the database (deploys, reverts, and failures). If you
don’t tell Sqitch who you are, it will try to guess, but you might not like who
it finds.

Changes and tags now also require a note to be associated with them, kind of
like a Git commit message. This allows a bit more context to be provided about a
change or tag, since the name may not be sufficient. All of this is recorded in
the plan file, which makes it harder to edit by hand, since the lines are so
much longer now. An example:

    %syntax-version=1.0.0-b1
    %project=flipr
    %uri=https://github.com/theory/sqitch-intro/

    appuser 2012-08-01T15:04:13Z Marge N. O’Vera <marge@example.com> # App database user with limited permissions.
    users [:appuser] 2012-08-01T15:36:00Z Marge N. O’Vera <marge@example.com> # Creates table to track our users.
    insert_user [:users :appuser] 2012-08-01T15:41:17Z Marge N. O’Vera <marge@example.com> # Creates a function to insert a user.
    change_pass [:users :appuser] 2012-08-01T15:41:46Z Marge N. O’Vera <marge@example.com> # Creates a function to change a user password.
    @v1.0.0-dev1 2012-08-01T15:48:04Z Marge N. O’Vera <marge@example.com> # Tag v1.0.0-dev1.

But each change and tag is still on a single line, so it’s not too bad if you
absolutely must edit it. Still, I expect to discourage that in favor of adding
more commands for manipulating it ([adding and removing dependencies], changing
the note, etc.).

Given all this data, the output of the [`log` command] has expanded quite a lot.
Here’s an example from [the tutorial]’s [example project][]:

<pre class="chroma"><code>On database flipr_test
<span class="gi">Deploy 7ad1cc6d1706c559dceb3101e7c21786dc7d7b4c</span>
Name:      change_pass
Committer: Marge N. O’Vera <marge@example.com>
Date:      2012-08-01 22:20:54 +0200

    Change change_pass to use pgcrypto.

<span class="gi">Deploy 799ecd26730a684cf02a889c30371a0af55150cc</span>
Name:      insert_user
Committer: Marge N. O’Vera <marge@example.com>
Date:      2012-08-01 22:20:54 +0200

    Change insert_user to use pgcrypto.

<span class="kp">Revert 799ecd26730a684cf02a889c30371a0af55150cc</span>
Name:      insert_user
Committer: Marge N. O’Vera <marge@example.com>
Date:      2012-08-01 22:20:52 +0200

    Change insert_user to use pgcrypto.

<span class="kp">Revert 7ad1cc6d1706c559dceb3101e7c21786dc7d7b4c</span>
Name:      change_pass
Committer: Marge N. O’Vera <marge@example.com>
Date:      2012-08-01 22:20:52 +0200

    Change change_pass to use pgcrypto.

<span class="gi">Deploy 7ad1cc6d1706c559dceb3101e7c21786dc7d7b4c</span>
Name:      change_pass
Committer: Marge N. O’Vera <marge@example.com>
Date:      2012-08-01 22:20:46 +0200

    Change change_pass to use pgcrypto.

<span class="gi">Deploy 799ecd26730a684cf02a889c30371a0af55150cc</span>
Name:      insert_user
Committer: Marge N. O’Vera <marge@example.com>
Date:      2012-08-01 22:20:46 +0200

    Change insert_user to use pgcrypto.
</code></pre>

Note the use of color to identify the event type: green for deploys and blue for
reverts. Failures appear in red. Not sure I like it yet, but I think it might be
useful. We’ll see.

Back to the plan. Notice that it now also includes pragmas for a project name
and URI. Those lines again:

    %syntax-version=1.0.0-b1
    %project=flipr
    %uri=https://github.com/theory/sqitch-intro/

The project name is required when [initializing a Sqitch project], but the URI
is optional (at least for now). The point of these data points is double:

-   The project name is used (along with the current timestamp and your name and
    email address) when hashing changes and tags to generate IDs. This ensures
    that the IDs are likely to be globally unique.
-   In the future, you will be able to declare cross-project dependencies.

The second point is the more important. The plan is to require the name of a
project before the `:` in a dependency. For example, if I wanted to require the
`insert_user` change from the “flipr” project plan above, I would declare it as
`flipr:insert_user`. Sqitch will then know to check for it. I will be adding
this pretty soon, since it requires some database changes and we’re going to
need it at work. The need for database changes is also why v0.80 is still a dev
release. (However I don’t expect the plan format to change beyond this tweak to
dependency specification.)

Beyond that, next steps include:

-   Creating an RPM targeting [work]’s servers. This will probably not be
    public, though I might add the spec file to the public project.
-   Starting to use Sqitch for some work projects. This will be the first
    real-world use, which I deem essential for proving the technology. I hope
    that it does not lead to any more radical redesigns. :–)
-   Implement the SQLite interface to iron out any kinks in the engine API.
-   [Switch to Dist::Zilla] for building the distribution. I would love a
    volunteer to help with this; I expect it to be simple for someone
    well-versed in Dist::Zilla.
-   Add support for localization. Sqitch already uses [Locale::TextDomain]
    throughout, so it’s localization-ready. We just need the tools put in place
    as described in [the dzil ticket][Switch to Dist::Zilla]. Again, I would
    love help with this.
-   [Implement the Bundle command]. Should be pretty simple, since, for now at
    least, all it does is copy files and directories.
-   [Add VCS integration]. This is less important than it once was, but will
    still help a lot when working with Sqitch within a VCS. The bundle command
    would also need to be updated, once this work was done.

But even with all that, I think that Sqitch is finally ready for some serious
tire-kicking. To get started, skim [the tutorial] and take it for a spin
(install it by running `cpan DWHEELER/App-Sqitch-0.80-TRIAL.tar.gz`). Let me
know what you like, what you don’t like, and let’s have a discussion about it.

Oh, and for discussions, where should I set up a mail list? Google Groups?
Someplace else?

  [Sqitch v0.80]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.80-TRIAL
  [like Git]: https://help.github.com/articles/set-up-git
  [adding and removing dependencies]: https://github.com/theory/sqitch/issues/29
  [`log` command]: https://github.com/theory/sqitch/blob/master/lib/sqitch-log.pod
  [the tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod
  [example project]: https://github.com/theory/sqitch-intro
  [initializing a Sqitch project]: https://github.com/theory/sqitch/blob/master/lib/sqitch-init.pod
  [work]: http://iovation.com/
  [Switch to Dist::Zilla]: https://github.com/theory/sqitch/issues/17
  [Locale::TextDomain]: https://metacpan.org/module/Locale::TextDomain
  [Implement the Bundle command]: https://github.com/theory/sqitch/issues/14
  [Add VCS integration]: https://github.com/theory/sqitch/issues/25
