--- 
date: 2005-12-07T05:19:09Z
slug: insert-execution-order-problem
title: Issues with INSERT Execution Ordering
aliases: [/computers/databases/postgresql/insert_execution_order_problem.html]
tags: [Postgres, SQL, RDBMS, database triggers]
---

<p>My latest experiments in my never-ending quest to move as much object/relational mapping into the database as possible has yielded more hacks to work around database features. This time, the problem is that I have two classes, <code>Simple</code> and <code>Extend</code>, where I want the latter to <em>extend</em> the former (hence its name). This is a little different from inheritance, in that, internally, an <code>Extend</code> just references a single <code>Simple</code> object, but externally, it just has a single interface, where attributes of a <code>Simple</code> object are just attributes of an <code>Extend</code> object. The benefit here is that I can have multiple <code>Extend</code> objects that reference the same <code>Simple</code> object&#x2014;something you can't do with simple inheritance</p>

<p>Now, how I wanted to implement this in the database is where the <code>extend</code> view has all of the columns from the <code>_simple</code> table and the <code>_extend</code> table. That's pretty simple. It looks like this:</p>

<pre>
CREATE SEQUENCE seq_kinetic;

CREATE TABLE _simple (
    id INTEGER NOT NULL DEFAULT NEXTVAL(&#x0027;seq_kinetic&#x0027;),
    uuid UUID NOT NULL DEFAULT UUID_V4(),
    state INTEGER NOT NULL DEFAULT 1,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE _extend (
    id INTEGER NOT NULL DEFAULT NEXTVAL(&#x0027;seq_kinetic&#x0027;),
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
</pre>

<p>Pretty simple, right? Well, I like to put <code>RULE</code>s on <code>VIEW</code>s like this, so that I can just use the <code>VIEW</code> for <code>INSERT</code>s, <code>UPDATE</code>s, AND <code>DELETES</code>s. For now I'm just going to talk about the <code>INSERT</code> <code>RULE</code>s for this this view, as they are where the trouble came in.</p>

<p>Why the plural, <code>RULE</code>s? Well, what I wanted was to have two behaviors on insert, depending on the value of the <code>simple__id</code> column. If it's <code>NOT NULL</code>, it should assume that it references an existing record in the <code>_simple</code> table, <code>UPDATE</code> it, and then <code>INSERT</code> into the <code>_extend</code> table. If it's <code>NULL</code>, however, then it should <code>INSERT</code> into both the <code>_simple</code> table and the <code>_extend</code> table. What I came up with looked like this:</p>

<pre>
CREATE RULE insert_extend AS
ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
  INSERT INTO _simple (id, uuid, state, name, description)
  VALUES (NEXTVAL(&#x0027;seq_kinetic&#x0027;), UUID_V4(), NEW.simple__state, NEW.name,
          NEW.description);

  INSERT INTO _extend (id, uuid, state, simple_id)
  VALUES (NEXTVAL(&#x0027;seq_kinetic&#x0027;), COALESCE(NEW.uuid, UUID_V4()), NEW.state,
          CURRVAL(&#x0027;seq_kinetic&#x0027;));
);

CREATE RULE extend_extend AS
ON INSERT TO extend WHERE NEW.simple__id IS NOT NULL DO INSTEAD (
  UPDATE _simple
  SET    state = COALESCE(NEW.simple__state, state),
         name  = COALESCE(NEW.name, name),
         description = COALESCE(NEW.description, description)
  WHERE  id = NEW.simple__id;

  INSERT INTO _extend (id, uuid, state, simple_id)
  VALUES (NEXTVAL(&#x0027;seq_kinetic&#x0027;), COALESCE(NEW.uuid, UUID_V4()),
          NEW.state, NEW.simple__id);
);

CREATE RULE insert_extend_dummy AS
ON INSERT TO extend DO INSTEAD NOTHING;
</pre>

<p>That third <code>RULE</code> is required, as a <code>VIEW</code> must have an unconditional <code>DO INSTEAD</code> <code>RULE</code>. The second <code>RULE</code> also works, for those situations where I want to to <q>extend</q> a <code>Simple</code> object into an <code>Extend</code> object. It's that first rule that's causing problems, when no <code>Simple</code> object yet exists and I need to create it. When I try to <code>INSERT</code> with <code>simple__id</code> set to <code>NULL</code>, I get an error. Can you guess what it is? Let me not keep you on the edge or your seat:</p>

<pre>
kinetic=# INSERT INTO EXTEND (simple__id, name) VALUES (NULL, &#x0027;Four&#x0027;);
ERROR:  insert or update on table &quot;_extend&quot; violates foreign key constraint &quot;fk_simple_id&quot;
DETAIL:  Key (simple_id)=(22) is not present in table &quot;_simple&quot;.
</pre>

<p>Why's that? Well, it turns out that <code>NEXTVAL(&#x0027;seq_kinetic&#x0027;)</code> is executed twice, once for the <code>id</code> in the <code>_simple</code> table, and once for the <code>id</code> in the <code>_extend</code> table. But by the time <code>CURRVAL(&#x0027;seq_kinetic&#x0027;)</code> is called to reference the value inserted into the <code>_simple</code> table, it the value has already been fetched from the sequence for insertion into the <code>_extend</code> table. So of course, it fails, because the current value in the sequence is not in the <code>_simple</code> table at all.</p>

<p>At first, I thought that this might be an order of execution problem with the <code>INSERT</code> statement, so I tried this:</p>

<pre>
CREATE RULE insert_extend AS
ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
  INSERT INTO _simple (id, uuid, state, name, description)
  VALUES (NEXTVAL(&#x0027;seq_kinetic&#x0027;), UUID_V4(), NEW.simple__state, NEW.name,
          NEW.description);

  INSERT INTO _extend (simple_id, id, uuid, state)
  VALUES (CURRVAL(&#x0027;seq_kinetic&#x0027;), NEXTVAL(&#x0027;seq_kinetic&#x0027;),
          COALESCE(NEW.uuid, UUID_V4()), NEW.state);
);
</pre>

<p>Unfortunately, that yielded the same error. So if the order of the columns in the <code>INSERT</code> statement didn't define the execution order, what did? Well, a little research helped me to figure it out: It's the order of the columns in the table, as this example demonstrates:</p>

<pre>
test=# CREATE SEQUENCE s;
CREATE SEQUENCE
test=# CREATE TABLE a (a0 int, a1 int, a2 int, a3 int);
CREATE TABLE
test=# INSERT INTO a (a3, a2, a0, a1) VALUES (NEXTVAL(&#x0027;s&#x0027;), NEXTVAL(&#x0027;s&#x0027;),
test=# NEXTVAL(&#x0027;s&#x0027;), NEXTVAL(&#x0027;s&#x0027;));
INSERT 0 1
test=# SELECT * FROM a;
 a0 | a1 | a2 | a3 
&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;
  1 |  2 |  3 |  4
(1 row)
</pre>

<p>Even though the values from the sequence were inserted into the columns by the <code>INSERT</code> statement in a more or less random order, they ended up being inserted into the table in the order in which they were declared in the <code>CREATE TABLE</code> statement.</p>

<p>Damn SQL!</p>

<p>So what's the solution to this? Well, I came up with three. The first, and perhaps simplest, is to use two sequences instead of one:</p>

<pre>
CREATE RULE insert_extend AS
ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
  INSERT INTO _simple (id, uuid, state, name, description)
  VALUES (NEXTVAL(&#x0027;seq_kinetic&#x0027;), UUID_V4(), NEW.simple__state, NEW.name,
          NEW.description);

  INSERT INTO _extend (id, uuid, state, simple_id)
  VALUES (NEXTVAL(&#x0027;seq_kinetic_alt&#x0027;), COALESCE(NEW.uuid, UUID_V4()), NEW.state,
          CURRVAL(&#x0027;seq_kinetic&#x0027;));
);
</pre>

<p>This works very well, and if you have separate sequences for each table, this is what you would do. But I want to use just one sequence for every primary key in the database, so as to prevent any possibility of duplicates. I could use two mutually exclusive sequences, one for odd numbers and the other for even numbers:</p>

<pre>
CREATE SEQUENCE seq_kinetic_odd INCREMENT BY 2;
CREATE SEQUENCE seq_kinetic_odd INCREMENT BY 2 START WITH 2;
</pre>

<p>But then I have to keep track of which sequence I'm using where. If I just use the <q>even</q> sequence for this special case (which may be rare), then I'm essentially throwing out half the numbers in the sequence. And I like things to be somewhat orderly, and the skipping of even or odd values would annoy me when I had to work with the database. Yeah, I'm a freak.</p>

<p>The solution I've currently worked out is to create a PL/pgSQL function that can keep track of the sequence numbers ahead of time, and just call it from the <code>RULE</code>:</p>

<pre>
CREATE FUNCTION insert_extend(NEWROW extend) RETURNS VOID AS &#x0027;
  DECLARE
     _first_id  integer := NEXTVAL(&#x0027;&#x0027;seq_kinetic&#x0027;&#x0027;);
     _second_id integer := NEXTVAL(&#x0027;&#x0027;seq_kinetic&#x0027;&#x0027;);
  BEGIN
  INSERT INTO _simple (id, uuid, state, name, description)
  VALUES (_first_id, UUID_V4(), NEWROW.simple__state, NEWROW.name,
          NEWROW.description);

  INSERT INTO _extend (id, uuid, state, simple_id)
  VALUES (_second_id, COALESCE(NEWROW.uuid, UUID_V4()), NEWROW.state, _first_id);
  END;
&#x0027; LANGUAGE plpgsql VOLATILE;
    
CREATE RULE insert_extend AS
ON INSERT TO extend WHERE NEW.simple__id IS NULL DO INSTEAD (
  SELECT insert_extend(NEW);
);
</pre>

<p>This approach works pretty nicely, and doesn't add much more code than my original solution with the ordering problem. I think I'll keep it.</p>

<p>One other solution is to use a <code>TRIGGER</code> instead of a rule, but in truth, it would amount to nearly the same thing:</p>

<pre>
CREATE FUNCTION insert_extend() RETURNS trigger AS &#x0027;
  DECLARE
     _first_id  integer := NEXTVAL(&#x0027;&#x0027;seq_kinetic&#x0027;&#x0027;);
     _second_id integer := NEXTVAL(&#x0027;&#x0027;seq_kinetic&#x0027;&#x0027;);
  BEGIN
  INSERT INTO _simple (id, uuid, state, name, description)
  VALUES (_first_id, UUID_V4(), NEW.simple__state, NEW.name, NEW.description);

  INSERT INTO _extend (id, uuid, state, simple_id)
  VALUES (_second_id, COALESCE(NEW.uuid, UUID_V4()), NEW.state, _first_id);
  END;
&#x0027; LANGUAGE plpgsql;

CREATE TRIGGER insert_extend BEFORE UPDATE ON extend
FOR EACH ROW EXECUTE PROCEDURE insert_extend();
</pre>

<p>Um, but looking at it now (I just now typed it up, I haven't tested it), I don't think it'd work, because you can't put a condition on a rule. On the other hand, I could use it to combine the three rules I have (two conditional and mutually exclusive, one that does nothing) into a single trigger:</p>

<pre>
CREATE FUNCTION insert_extend() RETURNS trigger AS &#x0027;
  DECLARE
     _first_id  integer;
     _second_id integer;
  BEGIN
    IF NEW.simple__id IS NULL THEN
      _first_id  := NEXTVAL(&#x0027;&#x0027;seq_kinetic&#x0027;&#x0027;);
      _second_id := NEXTVAL(&#x0027;&#x0027;seq_kinetic&#x0027;&#x0027;);

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
&#x0027; LANGUAGE plpgsql;</pre>

<p>Hrm. That just might be the best way to go, period. Thoughts? Have I missed some other obvious solution?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/insert_execution_order_problem.html">old layout</a>.</small></p>


