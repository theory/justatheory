--- 
date: 2004-11-17T01:56:05Z
slug: sqlite-foreign-key-triggers
title: Enforce Foreign Key Integrity in SQLite with Triggers
aliases: [/computers/databases/sqlite/foreign_key_triggers.html]
tags: [SQLite, SQL, Database Triggers]
type: post
---

After some some Googling and experimentation, I've figured out how to enforce
foreign key constraints in SQLite. I got most of the code from Cody Pisto's
[sqlite\_fk] utility. I couldn't get it to work, but the essential code for the
triggers was in its *fk.c* file, so I just borrowed from that (public domain)
code to figure it out.

Since I couldn't find documentation for this elsewhere on the Net (though I'm
sure it exists *somewhere*), I decided to just put an example here. Interested?
Read on!

Say you have these two table declarations:

``` sql
create table foo (
    id INTEGER NOT NULL PRIMARY KEY
);

CREATE TABLE bar (
    id INTEGER NOT NULL PRIMARY KEY,
    foo_id INTEGER NOT NULL
            CONSTRAINT fk_foo_id REFERENCES a(id) ON DELETE CASCADE
);
```

Table `bar` has a foreign key reference to the primary key column in the `foo`
table. Although SQLite supports this syntax (as well as named foreign key
constraints), it ignores them. So if you want the references enforced, you need
to create triggers to do the job. Triggers were added to SQLite version 2.5, so
most users can take advantage of this feature. Each constraint must have three
triggers: one for `INSERT`s, one for `UPDATES`s, and one for `DELETES`s. The
`INSERT` trigger looks like this:

``` sql
CREATE TRIGGER fki_bar_foo_id
BEFORE INSERT ON bar
FOR EACH ROW BEGIN 
    SELECT CASE
        WHEN ((SELECT id FROM foo WHERE id = NEW.foo_id) IS NULL)
        THEN RAISE(ABORT, 'insert on table "bar" violates foreign key '
                || 'constraint "fk_foo_id"')
    END;
END;
```

(You can put the `RAISE` error string all on one line; I've concatenated two
lines to keep line lengths reasonable here.) If your foreign key column is not
`NOT NULL`, the trigger's `SELECT CASE` clause needs to an extra case:

``` sql
CREATE TRIGGER fki_bar_foo_id
BEFORE INSERT ON bar
FOR EACH ROW BEGIN 
    SELECT CASE
        WHEN ((new.foo_id IS NOT NULL)
            AND ((SELECT id FROM foo WHERE id = new.foo_id) IS NULL))
        THEN RAISE(ABORT, 'insert on table "bar" violates foreign key '
                || 'constraint "fk_foo_id"')
    END;
END;
```

The `UPDATE` statements are almost identical; if your foreign key column is
`NOT NULL`, then do this:

``` sql
CREATE TRIGGER fku_bar_foo_id
BEFORE UPDATE ON bar
FOR EACH ROW BEGIN 
    SELECT CASE
        WHEN ((SELECT id FROM foo WHERE id = new.foo_id) IS NULL))
        THEN RAISE(ABORT, 'update on table "bar" violates foreign key '
                || 'constraint "fk_foo_id"')
    END;
END;
```

And if `NULL`s are allowed, do this:

``` sql
CREATE TRIGGER fku_bar_foo_id
BEFORE UPDATE ON bar
FOR EACH ROW BEGIN 
    SELECT CASE
        WHEN ((new.foo_id IS NOT NULL)
            AND ((SELECT id FROM foo WHERE id = new.foo_id) IS NULL))
        THEN RAISE(ABORT, 'update on table "bar" violates foreign key '
                || 'constraint "fk_foo_id"')
    END;
END;
```

The `DELETE` trigger is, of course, the reverse of the `INSERT` and `UPDATE`
triggers, in that it applies to the primary key table, rather than the foreign
key table. To whit, in our example, it watches for `DELETE`s on the `foo` table:

``` sql
CREATE TRIGGER fkd_bar_foo_id
BEFORE DELETE ON foo
FOR EACH ROW BEGIN 
    SELECT CASE
    WHEN ((SELECT foo_id FROM bar WHERE foo_id = OLD.id) IS NOT NULL)
    THEN RAISE(ABORT, 'delete on table "foo" violates foreign key '
                || ' constraint "fk_foo_id"')
    END;
END;
```

This trigger will prevent `DELETE`s on the `foo` table when there are existing
foreign key references in the `bar` table. This is generally the default
behavior in databases with referential integrity enforcement, sometimes
specified explicitly as `ON DELETE RESTRICT`. But sometimes you want the deletes
in the primary key table to “cascade” to the foreign key tables. Such is what
our example declaration above specifies, and this is the trigger to to the job:

``` sql
CREATE TRIGGER fkd_bar_foo_id
BEFORE DELETE ON foo
FOR EACH ROW BEGIN 
    DELETE from bar WHERE foo_id = OLD.id;
END;
```

Pretty simple, eh? The trigger support in SQLite is great for building your own
referential integrity checks. Hopefully, these examples will get you started
down the path of creating your own.

  [sqlite\_fk]: http://www.sqlite.org/contrib
    "SQLite Contributed files, including sqlite_fk.tgz, a utility for generating FK triggers for SQLite"
