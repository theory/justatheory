--- 
date: 2005-12-07T05:19:09Z
slug: insert-execution-order-problem
title: Issues with INSERT Execution Ordering
aliases: [/computers/databases/postgresql/insert_execution_order_problem.html]
tags: [Postgres, SQL, RDBMS, database triggers]
type: post
---

My latest experiments in my never-ending quest to move as much object/relational
mapping into the database as possible has yielded more hacks to work around
database features. This time, the problem is that I have two classes, `Simple`
and `Extend`, where I want the latter to *extend* the former (hence its name).
This is a little different from inheritance, in that, internally, an `Extend`
just references a single `Simple` object, but externally, it just has a single
interface, where attributes of a `Simple` object are just attributes of an
`Extend` object. The benefit here is that I can have multiple `Extend` objects
that reference the same `Simple` object—something you can't do with simple
inheritance

Now, how I wanted to implement this in the database is where the `extend` view
has all of the columns from the `_simple` table and the `_extend` table. That's
pretty simple. It looks like this:

    CREATE SEQUENCE seq_kinetic;

    CREATE TABLE _simple (
        id INTEGER NOT NULL DEFAULT NEXTVAL('seq_kinetic'),
        uuid UUID NOT NULL DEFAULT UUID_V4(),
        state INTEGER NOT NULL DEFAULT 1,
        name TEXT NOT NULL,
        description TEXT
    );

    CREATE TABLE _extend (
        id INTEGER NOT NULL DEFAULT NEXTVAL('seq_kinetic'),
        uuid UUID NOT NULL DEFAULT UUID_V4(),
        state INTEGER NOT NULL DEFAULT 1,
        simple_id INTEGER NOT NULL
    );

    CREATE VIEW extend AS
      SELECT _extend.id AS id, _extend.uuid AS uuid, _extend.state AS state,
             _extend.simple_id AS simple__id, simple.uuid AS simple__uuid,
             simple.state AS simple__state, simple.name AS name,
             simple.description AS description
      FROM   _extend, simple
      WHERE  _extend.simple_id = simple.id;

Pretty simple, right? Well, I like to put `RULE`s on `VIEW`s like this, so that
I can just use the `VIEW` for `INSERT`s, `UPDATE`s, AND `DELETES`s. For now I'm
just going to talk about the `INSERT` `RULE`s for this this view, as they are
where the trouble came in.

Why the plural, `RULE`s? Well, what I wanted was to have two behaviors on
insert, depending on the value of the `simple__id` column. If it's `NOT NULL`,
it should assume that it references an existing record in the `_simple` table,
`UPDATE` it, and then `INSERT` into the `_extend` table. If it's `NULL`,
however, then it should `INSERT` into both the `_simple` table and the `_extend`
table. What I came up with looked like this:

    CREATE RULE insert_extend AS
    ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
      INSERT INTO _simple (id, uuid, state, name, description)
      VALUES (NEXTVAL('seq_kinetic'), UUID_V4(), NEW.simple__state, NEW.name,
              NEW.description);

      INSERT INTO _extend (id, uuid, state, simple_id)
      VALUES (NEXTVAL('seq_kinetic'), COALESCE(NEW.uuid, UUID_V4()), NEW.state,
              CURRVAL('seq_kinetic'));
    );

    CREATE RULE extend_extend AS
    ON INSERT TO extend WHERE NEW.simple__id IS NOT NULL DO INSTEAD (
      UPDATE _simple
      SET    state = COALESCE(NEW.simple__state, state),
             name  = COALESCE(NEW.name, name),
             description = COALESCE(NEW.description, description)
      WHERE  id = NEW.simple__id;

      INSERT INTO _extend (id, uuid, state, simple_id)
      VALUES (NEXTVAL('seq_kinetic'), COALESCE(NEW.uuid, UUID_V4()),
              NEW.state, NEW.simple__id);
    );

    CREATE RULE insert_extend_dummy AS
    ON INSERT TO extend DO INSTEAD NOTHING;

That third `RULE` is required, as a `VIEW` must have an unconditional
`DO INSTEAD` `RULE`. The second `RULE` also works, for those situations where I
want to to “extend” a `Simple` object into an `Extend` object. It's that first
rule that's causing problems, when no `Simple` object yet exists and I need to
create it. When I try to `INSERT` with `simple__id` set to `NULL`, I get an
error. Can you guess what it is? Let me not keep you on the edge or your seat:

    kinetic=# INSERT INTO EXTEND (simple__id, name) VALUES (NULL, 'Four');
    ERROR:  insert or update on table "_extend" violates foreign key constraint "fk_simple_id"
    DETAIL:  Key (simple_id)=(22) is not present in table "_simple".

Why's that? Well, it turns out that `NEXTVAL('seq_kinetic')` is executed twice,
once for the `id` in the `_simple` table, and once for the `id` in the `_extend`
table. But by the time `CURRVAL('seq_kinetic')` is called to reference the value
inserted into the `_simple` table, it the value has already been fetched from
the sequence for insertion into the `_extend` table. So of course, it fails,
because the current value in the sequence is not in the `_simple` table at all.

At first, I thought that this might be an order of execution problem with the
`INSERT` statement, so I tried this:

    CREATE RULE insert_extend AS
    ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
      INSERT INTO _simple (id, uuid, state, name, description)
      VALUES (NEXTVAL('seq_kinetic'), UUID_V4(), NEW.simple__state, NEW.name,
              NEW.description);

      INSERT INTO _extend (simple_id, id, uuid, state)
      VALUES (CURRVAL('seq_kinetic'), NEXTVAL('seq_kinetic'),
              COALESCE(NEW.uuid, UUID_V4()), NEW.state);
    );

Unfortunately, that yielded the same error. So if the order of the columns in
the `INSERT` statement didn't define the execution order, what did? Well, a
little research helped me to figure it out: It's the order of the columns in the
table, as this example demonstrates:

    test=# CREATE SEQUENCE s;
    CREATE SEQUENCE
    test=# CREATE TABLE a (a0 int, a1 int, a2 int, a3 int);
    CREATE TABLE
    test=# INSERT INTO a (a3, a2, a0, a1) VALUES (NEXTVAL('s'), NEXTVAL('s'),
    test=# NEXTVAL('s'), NEXTVAL('s'));
    INSERT 0 1
    test=# SELECT * FROM a;
     a0 | a1 | a2 | a3 
    ----+----+----+----
      1 |  2 |  3 |  4
    (1 row)

Even though the values from the sequence were inserted into the columns by the
`INSERT` statement in a more or less random order, they ended up being inserted
into the table in the order in which they were declared in the `CREATE TABLE`
statement.

Damn SQL!

So what's the solution to this? Well, I came up with three. The first, and
perhaps simplest, is to use two sequences instead of one:

    CREATE RULE insert_extend AS
    ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
      INSERT INTO _simple (id, uuid, state, name, description)
      VALUES (NEXTVAL('seq_kinetic'), UUID_V4(), NEW.simple__state, NEW.name,
              NEW.description);

      INSERT INTO _extend (id, uuid, state, simple_id)
      VALUES (NEXTVAL('seq_kinetic_alt'), COALESCE(NEW.uuid, UUID_V4()), NEW.state,
              CURRVAL('seq_kinetic'));
    );

This works very well, and if you have separate sequences for each table, this is
what you would do. But I want to use just one sequence for every primary key in
the database, so as to prevent any possibility of duplicates. I could use two
mutually exclusive sequences, one for odd numbers and the other for even
numbers:

    CREATE SEQUENCE seq_kinetic_odd INCREMENT BY 2;
    CREATE SEQUENCE seq_kinetic_odd INCREMENT BY 2 START WITH 2;

But then I have to keep track of which sequence I'm using where. If I just use
the “even” sequence for this special case (which may be rare), then I'm
essentially throwing out half the numbers in the sequence. And I like things to
be somewhat orderly, and the skipping of even or odd values would annoy me when
I had to work with the database. Yeah, I'm a freak.

The solution I've currently worked out is to create a PL/pgSQL function that can
keep track of the sequence numbers ahead of time, and just call it from the
`RULE`:

    CREATE FUNCTION insert_extend(NEWROW extend) RETURNS VOID AS '
      DECLARE
         _first_id  integer := NEXTVAL(''seq_kinetic'');
         _second_id integer := NEXTVAL(''seq_kinetic'');
      BEGIN
      INSERT INTO _simple (id, uuid, state, name, description)
      VALUES (_first_id, UUID_V4(), NEWROW.simple__state, NEWROW.name,
              NEWROW.description);

      INSERT INTO _extend (id, uuid, state, simple_id)
      VALUES (_second_id, COALESCE(NEWROW.uuid, UUID_V4()), NEWROW.state, _first_id);
      END;
    ' LANGUAGE plpgsql VOLATILE;
        
    CREATE RULE insert_extend AS
    ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
      SELECT insert_extend(NEW);
    );

This approach works pretty nicely, and doesn't add much more code than my
original solution with the ordering problem. I think I'll keep it.

One other solution is to use a `TRIGGER` instead of a rule, but in truth, it
would amount to nearly the same thing:

    CREATE FUNCTION insert_extend() RETURNS trigger AS '
      DECLARE
         _first_id  integer := NEXTVAL(''seq_kinetic'');
         _second_id integer := NEXTVAL(''seq_kinetic'');
      BEGIN
      INSERT INTO _simple (id, uuid, state, name, description)
      VALUES (_first_id, UUID_V4(), NEW.simple__state, NEW.name, NEW.description);

      INSERT INTO _extend (id, uuid, state, simple_id)
      VALUES (_second_id, COALESCE(NEW.uuid, UUID_V4()), NEW.state, _first_id);
      END;
    ' LANGUAGE plpgsql;

    CREATE TRIGGER insert_extend BEFORE UPDATE ON extend
    FOR EACH ROW EXECUTE PROCEDURE insert_extend();

Um, but looking at it now (I just now typed it up, I haven't tested it), I don't
think it'd work, because you can't put a condition on a rule. On the other hand,
I could use it to combine the three rules I have (two conditional and mutually
exclusive, one that does nothing) into a single trigger:

    CREATE FUNCTION insert_extend() RETURNS trigger AS '
      DECLARE
         _first_id  integer;
         _second_id integer;
      BEGIN
        IF NEW.simple__id IS NULL THEN
          _first_id  := NEXTVAL(''seq_kinetic'');
          _second_id := NEXTVAL(''seq_kinetic'');

          INSERT INTO _simple (id, uuid, state, name, description)
          VALUES (_first_id, UUID_V4(), NEW.simple__state, NEW.name, NEW.description);

          INSERT INTO _extend (id, uuid, state, simple_id)
          VALUES (_second_id, COALESCE(NEW.uuid, UUID_V4()), NEW.state, _first_id);
        ELSE
          UPDATE _simple
          SET    state = COALESCE(NEW.simple__state, state),
                 name  = COALESCE(NEW.name, name),
                 description = COALESCE(NEW.description, description)
          WHERE  id = NEW.simple__id;

          INSERT INTO _extend (id, uuid, state, simple_id)
          VALUES (NEXTVAL('seq_kinetic'), COALESCE(NEW.uuid, UUID_V4()),
                  NEW.state, NEW.simple__id);
        END IF;
      END;
    ' LANGUAGE plpgsql;

Hrm. That just might be the best way to go, period. Thoughts? Have I missed some
other obvious solution?
