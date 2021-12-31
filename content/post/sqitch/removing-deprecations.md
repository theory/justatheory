---
title: "Removing Sqitch Deprecations"
date: 2018-12-30T20:43:02Z
lastMod: 2018-12-30T20:43:02Z
description: A list of deprecated Sqitch features and code paths I propose to remove ahead of the release of v1.0.
tags: [Sqitch, Deprecations, Proposals]
type: post
---

Ahead of the release of Sqitch v1.0 sometime in 2019, I’d like to remove all the
deprecated features and code paths. Before I do, I want to get a sense of the
impact of such removals. So here’s a comprehensive list of the deprecations
currently in Sqitch, along with details on their replacements, warnings, and
updates. If the removal of any of these items would create challenges for your
use Sqitch, [get in touch].

What would be removed:

*   The core configuration and directory-specification options and attributes:

    + `--engine`
    + `--registry`
    + `--client`
    + `--top-dir`, `top_dir`
    + `--deploy-dir`, `deploy_dir`
    + `--revert-dir`, `revert_dir`
    + `--verify-dir`, `verify_dir`

    The preferred solution is configuration values at the target, engine, or
    core level (settable via the options on the `target`, `engine`, and `init`
    commands, or via the `config` command).

    But I admit that there are no overriding options for the directory
    configurations in the deploy/revert/verify/rebase/checkout commands. And
    I've used `--top-dir` quite a lot myself! Perhaps those should be added
    first. If we were to add those, I think it'd be okay to remove the core
    options --- especially if I ever get around to merging options to allow both
    core and command options to be specified before or after the command name.

*   The `@FIRST` and `@LAST` symbolic tags, which were long-ago supplanted by
    the more Git-like `@ROOT` and `@HEAD`, and warnings have been emitted for at
    least some of their uses for six years now.

*   Engine configuration under `core.$engine`. This configuration was supplanted
    by `engine$engine` four years ago, and came with warnings, and a fix via the
    `sqitch engine update-config` action. That action would also go away.

*   The core database connection options:

    + --db-host
    + --db-port
    + --db-username
    + --db-name

    These options were supplanted by database URIs over four years ago. At that time, they were adapted to override parts of target URIs. For example, if you have a target URI of `db:pg://db.example.com/flipr`, you can specify that target, but then also pass `--db-name` to just change the database name part of the URI. I've found this occasionally useful, but I don't think the complexity of the implementation is worth it.

*   The old target options, which were renamed "change" targets back when the
    term "target" was adopted to refer to databases rather than changes. Sqitch
    has emitted warnings for five years when the old names were used:

    + The `--onto-target` and `--upto-target` options on `rebase` were renamed
      `--onto-change` and `--upto-change`.
    + The `--to-target` and `--target` options on `deploy` and `revert` were
      renamed `--to-change`.
    + The `--from-target` and `--to-target` options on `verify` were renamed
      `--from-change` and `--to-change`.

*   The script-generation options on the `add` command were [deprecated four
    years ago] in favor of `--with` and `--without` options, with warnings for
    the old usages:

    + `--deploy` became `--with deploy`
    + `--revert` became `--with revert`
    + `--verify` became `--with verify`
    + `--no-deploy` became `--without deploy`
    + `--no-revert` became `--without revert`
    + `--no-verify` became `--without verify`

    The same change replaced the template-specification options with a single
    `--use` option:

    + `--deploy-template $path` became `--use deploy=$path`
    + `--revert-template $path` became `--use revert=$path`
    + `--verify-template $path` became `--use verify=$path`

    The corresponding config variables, `add.deploy_template`,
    `add.revert_template`, and `add.verify_template` were replaced with a config
    section, `add.templates`. No warnings were issued for the old names, though.

*   The `set-*` actions on the `engine` and `target` commands were replaced
    three years ago ([engine change], [target change]) with a single `alter`
    action, with warnings, and able to be passed multiple times:

    + `set-target` became `alter target`
    + `set-uri` became `alter uri`
    + `set-registry` became `alter registry`
    + `set-client` became ` alter client`
    + `set-top-dir` became `alter top-dir`
    + `set-plan-file` became `alter plan-file`
    + `set-deploy-dir` became `alter deploy-dir`
    + `set-revert-dir` became `alter revert-dir`
    + `set-verify-dir` became `alter verify-dir`
    + `set-extension` became `alter extension`

*   The data hashed to create change IDs was modified [six years ago]. At that
    time, code was added to update old change IDs in Postgres databases; no
    other engines were around at the time.

If removing any of these features would cause trouble for you or the organizations you know to be using Sqitch, please [get in touch].

  [get in touch]: {{% ref "/about" %}} "About Just a Theory"
  [deprecated four years ago]: https://github.com/sqitchers/sqitch/commit/12468f694
  [engine change]: https://github.com/sqitchers/sqitch/commit/a2db9a294
  [target change]: https://github.com/sqitchers/sqitch/commit/f72990310
  [six years ago]: https://github.com/sqitchers/sqitch/commit/af71fe67e
