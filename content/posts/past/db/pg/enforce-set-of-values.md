--- 
date: 2010-01-05T19:18:32Z
slug: enforce-set-of-values
title: Enforcing a Set of Values
aliases: [/computers/databases/postgresql/enforce-set-of-values.html]
tags: [Postgres, enums, SQL, data types]
---

<h3>Enumerate Me</h3>

<p>I love <a href="http://www.postgresql.org/docs/current/static/datatype-enum.html" title="PostgreSQL Documentation: Enumerated Types">enums</a>. They're a terrific way to quickly create self-documenting data types that represent a set of values, and the nice thing is that the underlying values are stored as integers, making them very space- and performance-efficient. A typical example might be a workflow approval process for publishing magazine articles. You create it like so:</p>

<pre>
CREATE TYPE article_states AS ENUM (
    &#x27;draft&#x27;, &#x27;copy&#x27;, &#x27;approved&#x27;, &#x27;published&#x27;
);
</pre>

<p>Nice: we now have a simple data type that’s self-documenting. An an important feature of enums is that the ordering of values is the same as the declared labels. For a workflow such as this, it makes a lot of sense, because the workflow states are inherently ordered: “draft” comes before “copy” and so on.</p>

<p>Unfortunately, enums aren’t a panacea. I would use them all over the place if I could, but, alas, the value-set data types I tend to need tend not to have inherently ordered values other than the collation order of the text. For example, say that we need a table describing people’s faces. Using an enum to manage eye colors might look something like this:</p>

<pre>
CREATE TYPE eye_color AS ENUM ( &#x27;blue&#x27;, &#x27;green&#x27;, &#x27;brown&#x27; );

CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT &#x27;&#x27;,
    eye_color eye_color NOT NULL
);
</pre>

<p>Nice, huh? So let’s insert a few values and see what it looks like:</p>

<pre>
INSERT INTO faces (name, eye_color)
VALUES (&#x27;David&#x27;, &#x27;blue&#x27; ),
       (&#x27;Julie&#x27;, &#x27;green&#x27; ),
       (&#x27;Anna&#x27;, &#x27;blue&#x27; ),
       (&#x27;Noriko&#x27;, &#x27;brown&#x27; )
;
</pre>

<p>So let’s look at the data ordered by the enum:</p>

<pre>
% SELECT name, eye_color FROM faces ORDER BY eye_color;
  name  | eye_color 
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 David  | blue
 Anna   | blue
 Julie  | green
 Noriko | brown
</pre>

<p>Hrm. That’s not good. I forgot to put “green” after “brown” when I created the enum. Oh, and I forgot the color “hazel”:</p>

<pre>
% INSERT INTO faces (name, eye_color) VALUES (&#x27;Kat&#x27;, &#x27;hazel&#x27; );
ERROR:  invalid input value for enum eye_color: &quot;hazel&quot;
</pre>

<p>Well, nice to know that it’s enforced, and that message is really helpful. But the real problem is that we run into the inherent ordering of enum labels, and now we need to adjust the enum to meet our needs. Here’s how to do it:</p>

<pre>
ALTER TABLE faces RENAME eye_color TO eye_color_tmp;
ALTER TABLE faces ALTER eye_color_tmp TYPE TEXT;
DROP TYPE eye_color;
CREATE TYPE eye_color AS ENUM ( 'blue', 'brown', 'green', 'hazel' );
ALTER TABLE faces ADD eye_color eye_color;
UPDATE faces SET eye_color = eye_color_tmp::eye_color;
ALTER TABLE faces ALTER eye_color SET NOT NULL;
ALTER TABLE faces DROP column eye_color_tmp;
</pre>

<p>Yikes! I have to rename the column, change its type to <code>TEXT</code>, drop the enum, create a new enum, and then <em>copy all of the data</em> into the new column before finally dropping the old column. If I have a lot of data, this will not be very efficient, requiring that every single row be rewritten. Still, it <em>does</em> work:</p>

<pre>
% INSERT INTO faces (name, eye_color) VALUES (&#x27;Kat&#x27;, &#x27;hazel&#x27; );
% SELECT name, eye_color FROM faces ORDER BY eye_color;
  name  | eye_color 
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 David  | blue
 Anna   | blue
 Noriko | brown
 Julie  | green
 Kat    | hazel
</pre>

<p>The upshot is that enums are terrific if you have a very well-defined set of values that are inherently ordered (or where order is not important) and that are extremely unlikely to change. Perhaps someday PostgreSQL will have a more robust <a href="http://www.postgresql.org/docs/current/static/sql-altertype.html" title="PostgreSQL Documentation: ALTER TYPE"><code>ALTER TYPE</code></a> that allows enums to be more efficiently reorganized, but even then it seems likely that re-ordering values will require a table rewrite.</p>

<h3>Lookup to Me</h3>

<p>Another approach to handling a type as a set of values is to take advantage of the relational model and create store the values in a table. Going with the faces example, it looks like this:</p>

<pre>
CREATE TABLE eye_colors (
    eye_color TEXT PRIMARY KEY
);

INSERT INTO  eye_colors VALUES( &#x27;blue&#x27; ), (&#x27;green&#x27;), (&#x27;brown&#x27; );

CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT &#x27;&#x27;,
    eye_color TEXT REFERENCES eye_colors(eye_color)
);
</pre>

<p>We can use this table much as we did before:</p>

<pre>
INSERT INTO faces (name, eye_color)
VALUES (&#x27;David&#x27;, &#x27;blue&#x27; ),
       (&#x27;Julie&#x27;, &#x27;green&#x27; ),
       (&#x27;Anna&#x27;, &#x27;blue&#x27; ),
       (&#x27;Noriko&#x27;, &#x27;brown&#x27; )
;
</pre>

<p>And of course we can get the rows back properly ordered by <code>eye_color</code>, unlike the original enum example:</p>

<pre>
% SELECT name, eye_color FROM faces ORDER BY eye_color;
  name  | eye_color 
&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;-
 David  | blue
 Anna   | blue
 Noriko | brown
 Julie  | green
</pre>

<p>Cool! But there are a couple of downsides. One is that you're adding a bit of I/O overhead to every update. Most likely you won’t have very many values in the <code>eye_colors</code> table, so given PostgreSQL’s caching, this isn’t a big deal. A bigger deal is error handling:</p>

<pre>
INSERT INTO eye_colors VALUES (&#x27;hazel&#x27;);
ERROR:  insert or update on table &quot;faces&quot; violates foreign key constraint &quot;faces_eye_color_fkey&quot;
</pre>

<p>That’s not an incredibly useful error message. One might ask, without knowing the schema, what has an eye color has to do with a foreign key constraint? At least looking at the tables can tell you a bit more:</p>

<pre>
% \dt
          List of relations
 Schema |    Name    | Type  | Owner 
&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;-+&#x2d;&#x2d;&#x2d;-
 public | eye_colors | table | david
 public | faces      | table | david
</pre>

<p>A quick look at the <code>eye_colors</code> table will tell you what’s going on, and you can figure out that you just need to add a new row:</p>

<pre>
INSERT INTO eye_colors VALUES (&#x27;hazel&#x27;);
INSERT INTO faces (name, eye_color) VALUES (&#x27;Kat&#x27;, &#x27;hazel&#x27; );
</pre>

<p>So it <em>is</em> self-documenting, but unlike enums it doesn’t do a great job of it. Plus if you have a bunch of set-constrained value types, you can end up with a whole slew of lookup tables. This can make it harder to sort the important tables that contain actual business data from those that are just lookup tables, because there is nothing inherent in them to tell the difference. You could put them into a separate schema, of course, but still, it’s not exactly intuitive.</p>

<p>Given these downsides, I'm not a big fan of using lookup tables for managing what is in fact a simple list of allowed values for a particular column unless those values change frequently. So what else can we do?</p>

<h3>Constrain Me</h3>

<p>A third approach is to use a table constraint, like so:</p>

<pre>
CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT &#x27;&#x27;,
    eye_color TEXT NOT NULL,
    CONSTRAINT valid_eye_colors CHECK (
        eye_color IN ( &#x27;blue&#x27;, &#x27;green&#x27;, &#x27;brown&#x27; )
    )
);
</pre>

<p>No lookup table, no inherent ENUM ordering. And in regular usage it works just like the lookup table example. The usual <code>INSERT</code> and <code>SELECT</code> once again yields:</p>

<pre>
% SELECT name, eye_color FROM faces ORDER BY eye_color;
  name  | eye_color 
&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;-
 David  | blue
 Anna   | blue
 Noriko | brown
 Julie  | green
</pre>

<p>The error message, however, is a bit more helpful:</p>

<pre>
% SELECT name, eye_color FROM faces ORDER BY eye_color;
ERROR:  new row for relation &quot;faces&quot; violates check constraint &quot;valid_eye_colors&quot;
</pre>

<p>A check constraint violation on <code>eye_color</code> is much more informative than a foreign key constraint violation. The downside to a check constraint, however, is that it’s not as self-documenting. You have to look at the entire table in order to find the constraint:</p>

<pre>
% \d faces
                             Table &quot;public.faces&quot;
  Column   |  Type   |                        Modifiers                        
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;-+&#x2d;&#x2d;&#x2d;&#x2d;-+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;-
 face_id   | integer | not null default nextval(&#x27;faces_face_id_seq&#x27;::regclass)
 name      | text    | not null default &#x27;&#x27;::text
 eye_color | text    | not null
Indexes:
    &quot;faces_pkey&quot; PRIMARY KEY, btree (face_id)
Check constraints:
    &quot;valid_eye_colors&quot; CHECK (eye_color = ANY (ARRAY[&#x27;blue&#x27;, &#x27;green&#x27;, &#x27;brown&#x27;]))
</pre>

<p>There it is at the bottom. Kind of tucked away there, eh? At least now we can change it. Here’s how:</p>

<pre>
ALTER TABLE faces DROP CONSTRAINT valid_eye_colors;
ALTER TABLE faces ADD CONSTRAINT valid_eye_colors CHECK (
    eye_color IN ( &#x27;blue&#x27;, &#x27;green&#x27;, &#x27;brown&#x27;, &#x27;hazel&#x27; )
);
</pre>

<p>Not as straight-forward as updating the lookup table, and much less efficient (because PostgreSQL must validate that existing rows don’t violate the constraint before committing the constraint). But it’s pretty simple and at least doesn’t require the entire table be <code>UPDATE</code>d as with enums. For occasional changes to the value list, a table scan is not a bad tradeoff. And of course, once that’s done, it just works:</p>

<pre>
INSERT INTO eye_colors VALUES (&#x27;hazel&#x27;);
INSERT INTO faces (name, eye_color) VALUES (&#x27;Kat&#x27;, &#x27;hazel&#x27; );
</pre>

<p>So this is almost perfect for our needs. Only poor documentation persists as an issue.</p>

<h3>This is My Domain</h3>

<p>To solve that problem, switch to domains. A <a href="http://www.postgresql.org/docs/current/static/sql-createdomain.html" title="PostgreSQL Documentation: CREATE DOMAIN">domain</a> is simply a custom data type that inherits behavior from another data type and to which one or more constraints can be added. It’s pretty simple to switch from the table constraint to a domain:</p>

<pre>
CREATE DOMAIN eye_color AS TEXT
CONSTRAINT valid_eye_colors CHECK (
    VALUE IN ( &#x27;blue&#x27;, &#x27;green&#x27;, &#x27;brown&#x27; )
);

CREATE TABLE faces (
    face_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT &#x27;&#x27;,
    eye_color eye_color NOT NULL
);
</pre>

<p>Nice table declaration, eh? Very clean. Looks exactly like the enum example, in fact. And it works as well as the table constraint:</p>

<pre>
% SELECT name, eye_color FROM faces ORDER BY eye_color;
  name  | eye_color 
&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;-
 David  | blue
 Anna   | blue
 Noriko | brown
 Julie  | green
</pre>

<p>A constraint violation is a bit more useful than with the table constraint:</p>

<pre>
% SELECT name, eye_color FROM faces ORDER BY eye_color;
ERROR:  value for domain eye_color violates check constraint &quot;valid_eye_colors&quot;
</pre>

<p>This points directly to the domain. It'd be nice if it mentioned the violating value the way the enum error did, but at least we can look at the domain out like so:</p>

<pre>
\dD eye_color
                                                        List of domains
 Schema |   Name    | Type | Modifier |                                         Check                                          
&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;-+&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 public | eye_color | text |          | CHECK (VALUE = ANY (ARRAY[&#x27;blue&#x27;, &#x27;green&#x27;, &#x27;brown&#x27;, &#x27;hazel&#x27;]))
</pre>

<p>None of the superfluous stuff about the entire table to deal with, just the constraint, thank you very much. Changing it is just as easy as changing the table constraint:</p>

<pre>
ALTER DOMAIN eye_color DROP CONSTRAINT valid_eye_colors;
ALTER DOMAIN eye_color ADD CONSTRAINT valid_eye_colors CHECK (
    VALUE IN ( &#x27;blue&#x27;, &#x27;green&#x27;, &#x27;brown&#x27;, &#x27;hazel&#x27; )
);
</pre>

<p>Yep, you can alter domains just as you can alter tables. And of course now it will work:</p>

<pre>
INSERT INTO eye_colors VALUES (&#x27;hazel&#x27;);
INSERT INTO faces (name, eye_color) VALUES (&#x27;Kat&#x27;, &#x27;hazel&#x27; );
</pre>

<p>And as usual the data is well-ordered when we need it to be:</p>

<pre>
% SELECT name, eye_color FROM faces ORDER BY eye_color;
  name  | eye_color 
&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;-
 David  | blue
 Anna   | blue
 Noriko | brown
 Julie  | green
 Kat    | hazel
</pre>

<p>And as an added bonus, if you happened to need an eye color in another table, you can just use the same domain and get all the proper semantics. Sweet!</p>

<h3>Color Me Happy</h3>

<p>Someday I'd love to see support for a PostgreSQL feature like enums, but allowing an arbitrary list of strings that are ordered by the contents of the text rather than the order in which they were declared, and that’s efficient to update. Maybe it could use integers for the underlying storage, too, and allow values to be modified without a table rewrite. Such would be the ideal for this use case. Hell, I'd find it much more useful than enums.</p>

<p>But domains get us pretty close to that without too much effort, so maybe it’s not that important. I've tried all of the above approaches and discussed it quite a lot with <a href="http://www.pgexperts.com/people.html" title="Meet the Experts">my colleagues</a> before settling on domains, and I'm quite pleased with it. The only caveat I'd have is that it’s not to be used lightly. If the value set is likely to change fairly often (at least once a week, say), then you'd be better off with the lookup table.</p>

<p>In short, I recommend:</p>

<ul>
<li>For an inherently ordered set of values that’s extremely unlikely to ever change, use an enum.</li>
<li>For a set of values that won’t often change and has no inherent ordering, use a domain.</li>
<li>For a set of values that changes often, use a lookup table.</li>
</ul>

<p>What do you use to constrain a column to a defined set of unordered values?</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/enforce-set-of-values.html">old layout</a>.</small></p>


