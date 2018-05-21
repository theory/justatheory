--- 
date: 2010-01-05T19:18:32Z
slug: enforce-set-of-postgres-values
title: Enforcing a Set of Values
aliases: [/computers/databases/postgresql/enforce-set-of-values.html]
tags: [Postgres, enums, SQL, data types]
type: post
---

### Enumerate Me

I love [enums]. They're a terrific way to quickly create self-documenting data
types that represent a set of values, and the nice thing is that the underlying
values are stored as integers, making them very space- and
performance-efficient. A typical example might be a workflow approval process
for publishing magazine articles. You create it like so:

``` postgres
CREATE TYPE article_states AS ENUM (
    'draft', 'copy', 'approved', 'published'
);
```

Nice: we now have a simple data type that’s self-documenting. An an important
feature of enums is that the ordering of values is the same as the declared
labels. For a workflow such as this, it makes a lot of sense, because the
workflow states are inherently ordered: “draft” comes before “copy” and so on.

Unfortunately, enums aren’t a panacea. I would use them all over the place if I
could, but, alas, the value-set data types I tend to need tend not to have
inherently ordered values other than the collation order of the text. For
example, say that we need a table describing people’s faces. Using an enum to
manage eye colors might look something like this:

``` postgres
CREATE TYPE eye_color AS ENUM ( 'blue', 'green', 'brown' );

CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    eye_color eye_color NOT NULL
);
```

Nice, huh? So let’s insert a few values and see what it looks like:

``` postgres
INSERT INTO faces (name, eye_color)
VALUES ('David', 'blue' ),
       ('Julie', 'green' ),
       ('Anna', 'blue' ),
       ('Noriko', 'brown' )
;
```

So let’s look at the data ordered by the enum:

    % SELECT name, eye_color FROM faces ORDER BY eye_color;
      name  | eye_color 
    --------+-----------
     David  | blue
     Anna   | blue
     Julie  | green
     Noriko | brown

Hrm. That’s not good. I forgot to put “green” after “brown” when I created the
enum. Oh, and I forgot the color “hazel”:

    % INSERT INTO faces (name, eye_color) VALUES ('Kat', 'hazel' );
    ERROR:  invalid input value for enum eye_color: "hazel"

Well, nice to know that it’s enforced, and that message is really helpful. But
the real problem is that we run into the inherent ordering of enum labels, and
now we need to adjust the enum to meet our needs. Here’s how to do it:

``` postgres
ALTER TABLE faces RENAME eye_color TO eye_color_tmp;
ALTER TABLE faces ALTER eye_color_tmp TYPE TEXT;
DROP TYPE eye_color;
CREATE TYPE eye_color AS ENUM ( 'blue', 'brown', 'green', 'hazel' );
ALTER TABLE faces ADD eye_color eye_color;
UPDATE faces SET eye_color = eye_color_tmp::eye_color;
ALTER TABLE faces ALTER eye_color SET NOT NULL;
ALTER TABLE faces DROP column eye_color_tmp;
```

Yikes! I have to rename the column, change its type to `TEXT`, drop the enum,
create a new enum, and then *copy all of the data* into the new column before
finally dropping the old column. If I have a lot of data, this will not be very
efficient, requiring that every single row be rewritten. Still, it *does* work:

    % INSERT INTO faces (name, eye_color) VALUES ('Kat', 'hazel' );
    % SELECT name, eye_color FROM faces ORDER BY eye_color;
      name  | eye_color 
    --------+-----------
     David  | blue
     Anna   | blue
     Noriko | brown
     Julie  | green
     Kat    | hazel

The upshot is that enums are terrific if you have a very well-defined set of
values that are inherently ordered (or where order is not important) and that
are extremely unlikely to change. Perhaps someday PostgreSQL will have a more
robust [`ALTER TYPE`] that allows enums to be more efficiently reorganized, but
even then it seems likely that re-ordering values will require a table rewrite.

### Lookup to Me

Another approach to handling a type as a set of values is to take advantage of
the relational model and create store the values in a table. Going with the
faces example, it looks like this:

``` postgres
CREATE TABLE eye_colors (
    eye_color TEXT PRIMARY KEY
);

INSERT INTO  eye_colors VALUES( 'blue' ), ('green'), ('brown' );

CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    eye_color TEXT REFERENCES eye_colors(eye_color)
);
```

We can use this table much as we did before:

``` postgres
INSERT INTO faces (name, eye_color)
VALUES ('David', 'blue' ),
       ('Julie', 'green' ),
       ('Anna', 'blue' ),
       ('Noriko', 'brown' )
;
```

And of course we can get the rows back properly ordered by `eye_color`, unlike
the original enum example:

    % SELECT name, eye_color FROM faces ORDER BY eye_color;
      name  | eye_color 
    ----+------
     David  | blue
     Anna   | blue
     Noriko | brown
     Julie  | green

Cool! But there are a couple of downsides. One is that you're adding a bit of
I/O overhead to every update. Most likely you won’t have very many values in the
`eye_colors` table, so given PostgreSQL’s caching, this isn’t a big deal. A
bigger deal is error handling:

    INSERT INTO eye_colors VALUES ('hazel');
    ERROR:  insert or update on table "faces" violates foreign key constraint "faces_eye_color_fkey"

That’s not an incredibly useful error message. One might ask, without knowing
the schema, what has an eye color has to do with a foreign key constraint? At
least looking at the tables can tell you a bit more:

    % \dt
              List of relations
     Schema |    Name    | Type  | Owner 
    ----+------+----+----
     public | eye_colors | table | david
     public | faces      | table | david

A quick look at the `eye_colors` table will tell you what’s going on, and you
can figure out that you just need to add a new row:

``` postgres
INSERT INTO eye_colors VALUES ('hazel');
INSERT INTO faces (name, eye_color) VALUES ('Kat', 'hazel' );
```

So it *is* self-documenting, but unlike enums it doesn’t do a great job of it.
Plus if you have a bunch of set-constrained value types, you can end up with a
whole slew of lookup tables. This can make it harder to sort the important
tables that contain actual business data from those that are just lookup tables,
because there is nothing inherent in them to tell the difference. You could put
them into a separate schema, of course, but still, it’s not exactly intuitive.

Given these downsides, I'm not a big fan of using lookup tables for managing
what is in fact a simple list of allowed values for a particular column unless
those values change frequently. So what else can we do?

### Constrain Me

A third approach is to use a table constraint, like so:

``` postgres
CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    eye_color TEXT NOT NULL,
    CONSTRAINT valid_eye_colors CHECK (
        eye_color IN ( 'blue', 'green', 'brown' )
    )
);
```

No lookup table, no inherent ENUM ordering. And in regular usage it works just
like the lookup table example. The usual `INSERT` and `SELECT` once again
yields:

    % SELECT name, eye_color FROM faces ORDER BY eye_color;
      name  | eye_color 
    ----+------
     David  | blue
     Anna   | blue
     Noriko | brown
     Julie  | green

The error message, however, is a bit more helpful:

    % SELECT name, eye_color FROM faces ORDER BY eye_color;
    ERROR:  new row for relation "faces" violates check constraint "valid_eye_colors"

A check constraint violation on `eye_color` is much more informative than a
foreign key constraint violation. The downside to a check constraint, however,
is that it’s not as self-documenting. You have to look at the entire table in
order to find the constraint:

    % \d faces
                                 Table "public.faces"
      Column   |  Type   |                        Modifiers                        
    ------+-----+-----------------------------
     face_id   | integer | not null default nextval('faces_face_id_seq'::regclass)
     name      | text    | not null default ''::text
     eye_color | text    | not null
    Indexes:
        "faces_pkey" PRIMARY KEY, btree (face_id)
    Check constraints:
        "valid_eye_colors" CHECK (eye_color = ANY (ARRAY['blue', 'green', 'brown']))

There it is at the bottom. Kind of tucked away there, eh? At least now we can
change it. Here’s how:

``` postgres
ALTER TABLE faces DROP CONSTRAINT valid_eye_colors;
ALTER TABLE faces ADD CONSTRAINT valid_eye_colors CHECK (
    eye_color IN ( 'blue', 'green', 'brown', 'hazel' )
);
```

Not as straight-forward as updating the lookup table, and much less efficient
(because PostgreSQL must validate that existing rows don’t violate the
constraint before committing the constraint). But it’s pretty simple and at
least doesn’t require the entire table be `UPDATE`d as with enums. For
occasional changes to the value list, a table scan is not a bad tradeoff. And of
course, once that’s done, it just works:

``` postgres
INSERT INTO eye_colors VALUES ('hazel');
INSERT INTO faces (name, eye_color) VALUES ('Kat', 'hazel' );
```

So this is almost perfect for our needs. Only poor documentation persists as an
issue.

### This is My Domain

To solve that problem, switch to domains. A [domain] is simply a custom data
type that inherits behavior from another data type and to which one or more
constraints can be added. It’s pretty simple to switch from the table constraint
to a domain:

``` postgres
CREATE DOMAIN eye_color AS TEXT
CONSTRAINT valid_eye_colors CHECK (
    VALUE IN ( 'blue', 'green', 'brown' )
);

CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    eye_color eye_color NOT NULL
);
```

Nice table declaration, eh? Very clean. Looks exactly like the enum example, in
fact. And it works as well as the table constraint:

    % SELECT name, eye_color FROM faces ORDER BY eye_color;
      name  | eye_color 
    ----+------
     David  | blue
     Anna   | blue
     Noriko | brown
     Julie  | green

A constraint violation is a bit more useful than with the table constraint:

    % SELECT name, eye_color FROM faces ORDER BY eye_color;
    ERROR:  value for domain eye_color violates check constraint "valid_eye_colors"

This points directly to the domain. It'd be nice if it mentioned the violating
value the way the enum error did, but at least we can look at the domain out
like so:

    \dD eye_color
                                                            List of domains
     Schema |   Name    | Type | Modifier |                                         Check                                          
    ----+------+---+-----+--------------------------------------------
     public | eye_color | text |          | CHECK (VALUE = ANY (ARRAY['blue', 'green', 'brown', 'hazel']))

None of the superfluous stuff about the entire table to deal with, just the
constraint, thank you very much. Changing it is just as easy as changing the
table constraint:

``` postgres
ALTER DOMAIN eye_color DROP CONSTRAINT valid_eye_colors;
ALTER DOMAIN eye_color ADD CONSTRAINT valid_eye_colors CHECK (
    VALUE IN ( 'blue', 'green', 'brown', 'hazel' )
);
```

Yep, you can alter domains just as you can alter tables. And of course now it
will work:

``` postgres
INSERT INTO eye_colors VALUES ('hazel');
INSERT INTO faces (name, eye_color) VALUES ('Kat', 'hazel' );
```

And as usual the data is well-ordered when we need it to be:

    % SELECT name, eye_color FROM faces ORDER BY eye_color;
      name  | eye_color 
    ----+------
     David  | blue
     Anna   | blue
     Noriko | brown
     Julie  | green
     Kat    | hazel

And as an added bonus, if you happened to need an eye color in another table,
you can just use the same domain and get all the proper semantics. Sweet!

### Color Me Happy

Someday I'd love to see support for a PostgreSQL feature like enums, but
allowing an arbitrary list of strings that are ordered by the contents of the
text rather than the order in which they were declared, and that’s efficient to
update. Maybe it could use integers for the underlying storage, too, and allow
values to be modified without a table rewrite. Such would be the ideal for this
use case. Hell, I'd find it much more useful than enums.

But domains get us pretty close to that without too much effort, so maybe it’s
not that important. I've tried all of the above approaches and discussed it
quite a lot with [my colleagues] before settling on domains, and I'm quite
pleased with it. The only caveat I'd have is that it’s not to be used lightly.
If the value set is likely to change fairly often (at least once a week, say),
then you'd be better off with the lookup table.

In short, I recommend:

-   For an inherently ordered set of values that’s extremely unlikely to ever
    change, use an enum.
-   For a set of values that won’t often change and has no inherent ordering,
    use a domain.
-   For a set of values that changes often, use a lookup table.

What do you use to constrain a column to a defined set of unordered values?

  [enums]: http://www.postgresql.org/docs/current/static/datatype-enum.html
    "PostgreSQL Documentation: Enumerated Types"
  [`ALTER TYPE`]: http://www.postgresql.org/docs/current/static/sql-altertype.html
    "PostgreSQL Documentation: ALTER TYPE"
  [domain]: http://www.postgresql.org/docs/current/static/sql-createdomain.html
    "PostgreSQL Documentation: CREATE DOMAIN"
  [my colleagues]: http://www.pgexperts.com/people.html "Meet the Experts"
