--- 
date: 2005-11-22T23:01:35Z
slug: unique-relative-another-table
title: How to Ensure Unique Values Relative to a Column in Another Table
aliases: [/computers/databases/postgresql/unique_relative_another_table.html]
tags: [Postgres, database triggers, PL/pgSQL]
type: post
---

<p>I recently came across a need to ensure that the value of a column in one table is unique relative to the value of a column in another table. This came about through my use of views to represent object-oriented inheritance relationships in PostgreSQL. For example, say I have a parent class, <q>Person</q>, and its subclass, <q>User.</q> The <code>person</code> table is quite straight-forward:</p>

<pre>
CREATE TABLE person (
  id INTEGER NOT NULL PRIMARY KEY SERIAL,
  first_name TEXT,
  last_name  TEXT,
  state      INTEGER
);
</pre>

<p>I use a combination of a table and a view to represent the User class while keeping all of the data nicely denormalized:</p>

<pre>
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
</pre>

<p>So to maintain things, I write rules on the <code>usr</code> view to execute <code>INSERT</code>, <code>UPDATE</code>, and <code>DELETE</code> queries against the <code>person</code> and <code>person_usr</code> tables as appropriate.</p>

<p>Now, say that I have a business requirement to allow there to be duplicate usernames for users provided that only one is not <q>deleted.</q> Whether a user object is active, inactive, or deleted is determined by the value in its <code>state</code> attribute, which is stored in the <code>person</code> table. The value of the <code>state</code> attribute can be <q>1</q> for active, <q>0</q> for inactive, and <q>-1</q> for deleted. So how can I ensure, in the database, that this rule is followed?</p>

<p>Well, if the <code>state</code> and <code>username</code> columns were in a single table, this is very easy in PostgreSQL: just create a partial unique index:</p>

<pre>
CREATE UNIQUE INDEX udx_usr_unique
ON usr(username)
WHERE state &gt; -1;
</pre>

<p>This does the trick beautifully, and is nice and compact. However, my OO design has the User class inheriting from Person, so I have the <code>username</code> column in one table and the <code>state</code> column in another. At first, I thought that I could still use a partial unique index, something like this:</p>

<pre>
CREATE UNIQUE INDEX udx_usr_unique
ON usr(username)
WHERE id IN (SELECT id FROM person WHERE state &gt; -1);
</pre>

<p>Unfortunately, as of PostgreSQL 8.1, the PostgreSQL documentation states:</p>

<blockquote cite="http://www.postgresql.org/docs/8.1/interactive/sql-createindex.html">
<p>The expression used in the WHERE clause may refer only to columns of the underlying table, but it can use all columns, not just the ones being indexed. Presently, subqueries and aggregate expressions are also forbidden in WHERE. The same restrictions apply to index fields that are expressions.</p>
</blockquote>

<p>D'oh!</p>

<p>So I had to figure out another method. <code>CHECK</code> constraints cannot reference another table, either. So I was left with triggers. It's ugly and verbose, but it appears to do the trick. Here is the recipe:</p>

<pre>
CREATE FUNCTION cki_usr_username_unique() RETURNS trigger AS &#x0027;
  BEGIN
    /* Lock the relevant records in the parent and child tables. */
    PERFORM true
    FROM    person_usr, person
    WHERE   person_usr.id = person.id AND username = NEW.username FOR UPDATE;
    IF (SELECT true
        FROM   usr
        WHERE  id &lt;&gt; NEW.id AND username = NEW.username AND usr.state &gt; -1
        LIMIT 1
    ) THEN
        RAISE EXCEPTION &#x0027;&#x0027;duplicate key violates unique constraint &quot;ck_person_usr_username_unique&quot;&#x0027;&#x0027;;
    END IF;
    RETURN NEW;
  END;
&#x0027; LANGUAGE plpgsql;

CREATE TRIGGER cki_usr_username_unique BEFORE INSERT ON person_usr
    FOR EACH ROW EXECUTE PROCEDURE cki_usr_username_unique();

CREATE FUNCTION cku_usr_username_unique() RETURNS trigger AS &#x0027;
  BEGIN
    IF (NEW.username &lt;&gt; OLD.username) THEN
        /* Lock the relevant records in the parent and child tables. */
        PERFORM true
        FROM    person_usr, person
        WHERE   person_usr.id = person.id AND username = NEW.username FOR UPDATE;
        IF (SELECT true
            FROM   usr
            WHERE  id &lt;&gt; NEW.id AND username = NEW.username AND usr.state &gt; -1
            LIMIT 1
        ) THEN
            RAISE EXCEPTION &#x0027;&#x0027;duplicate key violates unique constraint &quot;ck_person_usr_username_unique&quot;&#x0027;&#x0027;;
        END IF;
    END IF;
    RETURN NEW;
  END;
&#x0027; LANGUAGE plpgsql;

CREATE TRIGGER cku_usr_username_unique BEFORE UPDATE ON person_usr
    FOR EACH ROW EXECUTE PROCEDURE cku_usr_username_unique();

CREATE FUNCTION ckp_usr_username_unique() RETURNS trigger AS &#x0027;
  BEGIN
    IF (NEW.state &gt; -1 AND OLD.state &lt; 0
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
            RAISE EXCEPTION &#x0027;&#x0027;duplicate key violates unique constraint &quot;ck_person_usr_username_unique&quot;&#x0027;&#x0027;;
        END IF;
    END IF;
    RETURN NEW;
  END;
&#x0027; LANGUAGE plpgsql;

CREATE TRIGGER ckp_usr_username_unique BEFORE UPDATE ON person
    FOR EACH ROW EXECUTE PROCEDURE ckp_usr_username_unique();
</pre>
 
<p>Why am I locking rows? To prevent some other transaction from changing another row to create username conflicts. For example, while I might be changing a username to <q>foo</q> for one record, an existing record with that username but its <code>state</code> set to -1 might be getting activated in a separate transaction. So gotta try to prevent that. Josh Berkus pointed out that issue in an earlier iteration of the triggers.</p>

<p>Anyway, am I on crack here? Isn't there a simpler way to do this sort of thing? And if not, have I really got the race conditions all eliminated with the row locks?</p>

<p><strong>Update:</strong> In further testing, I discovered that the <code>SELECT ... FOR UPDATE</code> was failing on views with the error <q>ERROR:  no relation entry for relid 7</q>. I have no idea what that means, but I found that it didn't happen when I selected against the tables directly. So I've updated the functions above to reflect that change. I've also fixed a few pastos as pointed out in the comments.</p>
<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/unique_relative_another_table.html">old layout</a>.</small></p>


