--- 
date: 2004-11-17T01:56:05Z
slug: foreign-key-triggers
title: Enforce Foreign Key Integrity in SQLite with Triggers
aliases: [/computers/databases/sqlite/foreign_key_triggers.html]
tags: [SQLite, SQL, database triggers]
---

<p>After some some Googling and experimentation, I've figured out how to
enforce foreign key constraints in SQLite. I got most of the code from Cody
Pisto's <a href="http://www.sqlite.org/contrib" title="SQLite Contributed files, including sqlite_fk.tgz, a utility for generating FK triggers for SQLite">sqlite_fk</a> utility. I couldn't get it to work, but the essential
code for the triggers was in its <em>fk.c</em> file, so I just borrowed from
that (public domain) code to figure it out.</p>

<p>Since I couldn't find documentation for this elsewhere on the Net (though
I'm sure it exists <em>somewhere</em>), I decided to just put an example here.
Interested? Read on!</p>

<p>Say you have these two table declarations:</p>

<pre>
create table foo (
  id INTEGER NOT NULL PRIMARY KEY
);

CREATE TABLE bar (
  id INTEGER NOT NULL PRIMARY KEY,
  foo_id INTEGER NOT NULL
         CONSTRAINT fk_foo_id REFERENCES a(id) ON DELETE CASCADE
);
</pre>

<p>Table <code>bar</code> has a foreign key reference to the primary key
column in the <code>foo</code> table. Although SQLite supports this syntax (as
well as named foreign key constraints), it ignores them. So if you want the
references enforced, you need to create triggers to do the job. Triggers were
added to SQLite version 2.5, so most users can take advantage of this
feature. Each constraint must have three triggers: one for <code>INSERT</code>s,
one for <code>UPDATES</code>s, and one for <code>DELETES</code>s. The
<code>INSERT</code> trigger looks like this:</p>

<pre>
CREATE TRIGGER fki_bar_foo_id
BEFORE INSERT ON bar
FOR EACH ROW BEGIN 
  SELECT CASE
     WHEN ((SELECT id FROM foo WHERE id = NEW.foo_id) IS NULL)
     THEN RAISE(ABORT, 'insert on table &quot;bar&quot; violates foreign key '
                || 'constraint &quot;fk_foo_id&quot;')
  END;
END;
</pre>

<p>(You can put the <code>RAISE</code> error string all on one line; I've
concatenated two lines to keep line lengths reasonable here.) If your foreign
key column is not <code>NOT NULL</code>, the trigger's <code>SELECT
CASE</code> clause needs to an extra case:</p>

<pre>
CREATE TRIGGER fki_bar_foo_id
BEFORE INSERT ON bar
FOR EACH ROW BEGIN 
   SELECT CASE
     WHEN ((new.foo_id IS NOT NULL)
           AND ((SELECT id FROM foo WHERE id = new.foo_id) IS NULL))
     THEN RAISE(ABORT, 'insert on table &quot;bar&quot; violates foreign key '
                || 'constraint &quot;fk_foo_id&quot;')
  END;
END;
</pre>

<p>The <code>UPDATE</code> statements are almost identical; if your foreign
key column is <code>NOT NULL</code>, then do this:</p>

<pre>
CREATE TRIGGER fku_bar_foo_id
BEFORE UPDATE ON bar
FOR EACH ROW BEGIN 
   SELECT CASE
     WHEN ((SELECT id FROM foo WHERE id = new.foo_id) IS NULL))
     THEN RAISE(ABORT, 'update on table &quot;bar&quot; violates foreign key '
                || 'constraint &quot;fk_foo_id&quot;')
  END;
END;
</pre>

<p>And if <code>NULL</code>s are allowed, do this:</p>

<pre>
CREATE TRIGGER fku_bar_foo_id
BEFORE UPDATE ON bar
FOR EACH ROW BEGIN 
   SELECT CASE
     WHEN ((new.foo_id IS NOT NULL)
           AND ((SELECT id FROM foo WHERE id = new.foo_id) IS NULL))
     THEN RAISE(ABORT, 'update on table &quot;bar&quot; violates foreign key '
                || 'constraint &quot;fk_foo_id&quot;')
  END;
END;
</pre>

<p>The <code>DELETE</code> trigger is, of course, the reverse of
the <code>INSERT</code> and <code>UPDATE</code> triggers, in that it
applies to the primary key table, rather than the foreign key table.
To whit, in our example, it watches for <code>DELETE</code>s on the
<code>foo</code> table:</p>

<pre>
CREATE TRIGGER fkd_bar_foo_id
BEFORE DELETE ON foo
FOR EACH ROW BEGIN 
  SELECT CASE
    WHEN ((SELECT foo_id FROM bar WHERE foo_id = OLD.id) IS NOT NULL)
    THEN RAISE(ABORT, 'delete on table &quot;foo&quot; violates foreign key '
               || ' constraint &quot;fk_foo_id&quot;')
  END;
END;
</pre>

<p>This trigger will prevent <code>DELETE</code>s on the <code>foo</code>
table when there are existing foreign key references in the <code>bar</code>
table. This is generally the default behavior in databases with referential
integrity enforcement, sometimes specified explicitly as <code>ON DELETE
RESTRICT</code>. But sometimes you want the deletes in the primary key table
to <q>cascade</q> to the foreign key tables. Such is what our example
declaration above specifies, and this is the trigger to to the job:</p>

<pre>
CREATE TRIGGER fkd_bar_foo_id
BEFORE DELETE ON foo
FOR EACH ROW BEGIN 
    DELETE from bar WHERE foo_id = OLD.id;
END;
</pre>

<p>Pretty simple, eh? The trigger support in SQLite is great for building your
own referential integrity checks. Hopefully, these examples will get you
started down the path of creating your own.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqlite/foreign_key_triggers.html">old layout</a>.</small></p>


