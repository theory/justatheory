--- 
date: 2012-08-20T22:36:57Z
slug: sqitch-depend-on-it
title: "Sqitch: Depend On It!"
aliases: [/computers/databases/sqitch-depend-on-it.html]
tags: [Sqitch, SQL, Change Management]
type: post
---

[Sqitch v0.90] dropped last week (updated to v0.902 today). The focus of this
release of the “sane database change management” app was cross-project
dependencies. [Jim Nasby] first put the idea for this feature into my head, and
then I discovered that our first Sqitch-using project at [work] needs it, so
blame them.

### Depend On It

Earlier versions of Sqitch allow you to declare dependencies on other changes
within a project. For example, if your project has a change named `users_table`,
you can create a new change that requires it like so:

    sqitch add --requires users_table widgets_table

As of v0.90, you can also require a change from *different* Sqitch project. Say
that you have a project that installs a bunch of utility functions, and that you
want to require it in your current Sqitch project. To do so, just prepend the
project name to the name of the change you want to require:

    sqitch add --requires utils:uuidgen widgets_table

When you go to deploy your project, Sqitch will not deploy the `widgets_table`
change if the `uuidgen` change from the `utils` project is not already present.

Sqitch discriminates projects simply by name, as required since v0.80. When you
initialize a new Sqitch project, you have to declare its name, too:

    siqtch init --name utils

I’ve wondered a bit as to whether that was sufficient. Within a small
organization, it’s probably no big deal, as there is unlikely to be much
namespace overlap. But thinking longer term, I could foresee folks developing
and distributing interdependent open-source Sqitch projects. And without a
central name registry, conflicts are likely to pop up. To a certain degree, the
risks can be minimized by [comparing project URIs], but that works only for
project registration, not dependency specification. But perhaps it’s enough.
Thoughts?

### It’s All Relative

Next up I plan to implement the [SQLite] support and the [bundle command]. But
first, I want to support relative change specifications. Changes have an order,
both in the plan and as deployed to the database. I want to be able to specify
relative changes, kind of like you can specify relative commits in Git. So, if
you want to revert just one change, you could say something like this:

    sqitch revert HEAD^

And that would revert one change. I also think the ability to specify later
changes might be useful. So if you wanted to deploy to the change *after* change
`foo`, you could say something like:

    sqitch deploy foo+

You can use `^` or `+` any number of times, or specify numbers for them. These
would both revert three changes:

    sqitch revert HEAD^^^
    sqitch revert HEAD^3

I like `^` because of its use in Git, although perhaps `~` is more appropriate
(Sqitch does not have concepts of branching or multiple parent changes). But `+`
is not a great complement. Maybe `-` and `+` would be better, if a bit less
familiar? Or maybe there is a better complement to `^` or `~` I haven’t thought
of? (I don’t want to use characters that have special meaning in the shell, like
`<>`, if I can avoid it.) Suggestions greatly appreciated.

### Oops

A discovered a bug late in the development of v0.90. Well, not so much a bug as
an oversight: Sqitch does not validate dependencies in the `revert` command.
That means it’s possible to revert a change without error when some other change
depends on it. Oops. Alas, [fixing this issue is not exactly trivial], but it’s
something I will have to give attention to soon. While I’m at it, I will
probably make [dependency failures fail earlier]. Watch for those fixes soon.

### And You?

Still would love help getting a [`dzil` plugin to build Local::TextDomain l01n
files]. I suspect this would take a knowledgable Dist::Zilla user a couple of
hours to do. (And thanks to [@notbenh] and [@RJBS] for getting Sqitch on
Dist::Zilla!) And if anyone really wanted to dig into Sqitch, Implementing a
[`bundle` command][bundle command] would be a great place to start.

Or just give it a try! You can install it from CPAN with `cpan App::Sqitch`.
Read [the tutorial] for an overview of what Sqitch is and how it works. Thanks!

  [Sqitch v0.90]: https://metacpan.org/release/App-Sqitch
  [Jim Nasby]: https://www.linkedin.com/in/decibel/ "Jim Nasby on LinkedIn"
  [work]: https://iovation.com/
  [comparing project URIs]: https://github.com/theory/sqitch/issues/38
  [SQLite]: https://sqlite.org/
  [bundle command]: https://github.com/theory/sqitch/issues/14
  [fixing this issue is not exactly trivial]: https://github.com/theory/sqitch/issues/36
  [dependency failures fail earlier]: https://github.com/theory/sqitch/issues/39
  [`dzil` plugin to build Local::TextDomain l01n files]: https://github.com/theory/sqitch/issues/34
  [@notbenh]: https://twitter.com/notbenh
  [@RJBS]: http://rjbs.manxome.org/
  [the tutorial]: https://metacpan.org/module/sqitchtutorial
