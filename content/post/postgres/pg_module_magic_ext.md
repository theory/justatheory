---
title: "Postgres Extensions: Use PG_MODULE_MAGIC_EXT"
slug: pg_module_magic_ext
date: 2025-05-29T22:09:22Z
lastMod: 2025-05-29T22:09:22Z
description: |
  Details for extension authors for how to use the new `PG_MODULE_MAGIC_EXT`
  macro introduced in PostgreSQL 18.
tags: [Postgres, Extensions, PG_MODULE_MAGIC_EXT]
type: post
---

A quick note for PostgreSQL extension maintainers: PostgreSQL 18 introduces a
new macro: `PG_MODULE_MAGIC_EXT`. Use it to name and version your modules.
Where your module `.c` file likely has:

```c
PG_MODULE_MAGIC;
```

Or:

```c
#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif
```

Change it to something like:

```c
#ifdef PG_MODULE_MAGIC_EXT
PG_MODULE_MAGIC_EXT(.name = "module_name", .version = "1.2.3");
#else
PG_MODULE_MAGIC;
#endif
```

Replace the name of your module and the version as appropriate. Note that
`PG_MODULE_MAGIC` was added in Postgres 8.2; if for some reason your module
still supports earlier versions, use a nested `#ifdef` to conditionally
execute it:

```c
#ifdef PG_MODULE_MAGIC_EXT
PG_MODULE_MAGIC_EXT(.name = "module_name", .version = "1.2.3");
#else
#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif
#endif
```

If you manage the module version in your `Makefile`, as the [PGXN Howto
suggests], consider renaming the `.c` file to `.c.in` and changing the
`Makefile` like so:

*   Replace `.version = "1.2.3"` with `.version = "__VERSION__"`

*   Add `src/$(EXTENSION).c` to `EXTRA_CLEAN`

*   Add this `make` target:

    ```
    src/$(EXTENSION).c: src/$(EXTENSION).c.in
    	sed -e 's,__VERSION__,$(EXTVERSION),g' $< > $@
    ```

*   If you use Git, add `/src/*.c` to `.gitignore`

For an example of this pattern, see [semver@3526789].

That's all!

  [PGXN Howto suggests]: https://manager.pgxn.org/howto#neworder
  [semver@3526789]: https://github.com/theory/pg-semver/commit/3526789
