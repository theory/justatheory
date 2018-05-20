--- 
date: 2005-11-22T23:01:35Z
slug: unique-relative-another-table
title: How to Ensure Unique Values Relative to a Column in Another Table
aliases: [/computers/databases/postgresql/unique_relative_another_table.html]
tags: [Postgres, database triggers, PL/pgSQL]
type: post
---

I recently came across a need to ensure that the value of a column in one table
is unique relative to the value of a column in another table. This came about
through my use of views to represent object-oriented inheritance relationships
in PostgreSQL. For example, say I have a parent class, “Person”, and its
subclass, “User.” The `person` table is quite straight-forward:

    CREATE TABLE person (
      id INTEGER NOT NULL PRIMARY KEY SERIAL,
      first_name TEXT,
      last_name  TEXT,
      state      INTEGER
    );

I use a combination of a table and a view to represent the User class while
keeping all of the data nicely denormalized:

    CREATE TABLE person_usr (
        id INTEGER NOT NULL PRIMARY KEY REFERENCES person (id),
        username TEXT,
        password TEXT
    );

    CREATE VIEW usr AS
    SELECT p.id AS id, p.first_name AS first_name, p.last_name AS last_name,
           p.state AS state, u.username AS username, u.password AS password
    FROM   person p, usr u
    WHERE  p.id = u.id;

So to maintain things, I write rules on the `usr` view to execute `INSERT`,
`UPDATE`, and `DELETE` queries against the `person` and `person_usr` tables as
appropriate.

Now, say that I have a business requirement to allow there to be duplicate
usernames for users provided that only one is not “deleted.” Whether a user
object is active, inactive, or deleted is determined by the value in its `state`
attribute, which is stored in the `person` table. The value of the `state`
attribute can be “1” for active, “0” for inactive, and “-1” for deleted. So how
can I ensure, in the database, that this rule is followed?

Well, if the `state` and `username` columns were in a single table, this is very
easy in PostgreSQL: just create a partial unique index:

    CREATE UNIQUE INDEX udx_usr_unique
    ON usr(username)
    WHERE state > -1;

This does the trick beautifully, and is nice and compact. However, my OO design
has the User class inheriting from Person, so I have the `username` column in
one table and the `state` column in another. At first, I thought that I could
still use a partial unique index, something like this:

    CREATE UNIQUE INDEX udx_usr_unique
    ON usr(username)
    WHERE id IN (SELECT id FROM person WHERE state > -1);

Unfortunately, as of PostgreSQL 8.1, the PostgreSQL documentation states:

> The expression used in the WHERE clause may refer only to columns of the
> underlying table, but it can use all columns, not just the ones being indexed.
> Presently, subqueries and aggregate expressions are also forbidden in WHERE.
> The same restrictions apply to index fields that are expressions.

D'oh!

So I had to figure out another method. `CHECK` constraints cannot reference
another table, either. So I was left with triggers. It's ugly and verbose, but
it appears to do the trick. Here is the recipe:

    CREATE FUNCTION cki_usr_username_unique() RETURNS trigger AS '
      BEGIN
        /* Lock the relevant records in the parent and child tables. */
        PERFORM true
        FROM    person_usr, person
        WHERE   person_usr.id = person.id AND username = NEW.username FOR UPDATE;
        IF (SELECT true
            FROM   usr
            WHERE  id <> NEW.id AND username = NEW.username AND usr.state > -1
            LIMIT 1
        ) THEN
            RAISE EXCEPTION ''duplicate key violates unique constraint "ck_person_usr_username_unique"'';
        END IF;
        RETURN NEW;
      END;
    ' LANGUAGE plpgsql;

    CREATE TRIGGER cki_usr_username_unique BEFORE INSERT ON person_usr
        FOR EACH ROW EXECUTE PROCEDURE cki_usr_username_unique();

    CREATE FUNCTION cku_usr_username_unique() RETURNS trigger AS '
      BEGIN
        IF (NEW.username <> OLD.username) THEN
            /* Lock the relevant records in the parent and child tables. */
            PERFORM true
            FROM    person_usr, person
            WHERE   person_usr.id = person.id AND username = NEW.username FOR UPDATE;
            IF (SELECT true
                FROM   usr
                WHERE  id <> NEW.id AND username = NEW.username AND usr.state > -1
                LIMIT 1
            ) THEN
                RAISE EXCEPTION ''duplicate key violates unique constraint "ck_person_usr_username_unique"'';
            END IF;
        END IF;
        RETURN NEW;
      END;
    ' LANGUAGE plpgsql;

    CREATE TRIGGER cku_usr_username_unique BEFORE UPDATE ON person_usr
        FOR EACH ROW EXECUTE PROCEDURE cku_usr_username_unique();

    CREATE FUNCTION ckp_usr_username_unique() RETURNS trigger AS '
      BEGIN
        IF (NEW.state > -1 AND OLD.state < 0
            AND (SELECT true FROM person_usr WHERE id = NEW.id)
           ) THEN
            /* Lock the relevant records in the parent and child tables. */
            PERFORM true
            FROM    person_usr, person
            WHERE   person_usr.id = person.id
                    AND username = (SELECT username FROM person_usr WHERE id = NEW.id)
            FOR UPDATE;

            IF (SELECT COUNT(username)
                FROM   person_usr
                WHERE username = (SELECT username FROM person_usr WHERE id = NEW.id)
            ) > 1 THEN
                RAISE EXCEPTION ''duplicate key violates unique constraint "ck_person_usr_username_unique"'';
            END IF;
        END IF;
        RETURN NEW;
      END;
    ' LANGUAGE plpgsql;

    CREATE TRIGGER ckp_usr_username_unique BEFORE UPDATE ON person
        FOR EACH ROW EXECUTE PROCEDURE ckp_usr_username_unique();

Why am I locking rows? To prevent some other transaction from changing another
row to create username conflicts. For example, while I might be changing a
username to “foo” for one record, an existing record with that username but its
`state` set to -1 might be getting activated in a separate transaction. So gotta
try to prevent that. Josh Berkus pointed out that issue in an earlier iteration
of the triggers.

Anyway, am I on crack here? Isn't there a simpler way to do this sort of thing?
And if not, have I really got the race conditions all eliminated with the row
locks?

**Update:** In further testing, I discovered that the `SELECT ... FOR UPDATE`
was failing on views with the error “ERROR: no relation entry for relid 7”. I
have no idea what that means, but I found that it didn't happen when I selected
against the tables directly. So I've updated the functions above to reflect that
change. I've also fixed a few pastos as pointed out in the comments.
