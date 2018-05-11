--- 
date: 2006-05-05T22:09:22Z
slug: higher-order-plpgsql
title: Higher Order PL/pgSQL
aliases: [/computers/databases/postgresql/higher_order_plpgsql.html]
tags: [Postgres, PL/pgSQL, Higher Order Perl, recursion, Fibonacci Sequence, algorithms]
---

<p>Well, it's not <em>really</em> higher order PL/pgSQL, since the language
doesn't
support <a href="https://en.wikipedia.org/wiki/Closure_%28computer_science%29"
title="Wikipedia: Closure (computer science)">closures</a>, as far as I know.
But I have been working on a series of articles
for <a href="http://www.onlamp.com/onlamp/general/database.csp"
title="O'Reilly Database Articles">O'Reilly Databases</a> site, drawing
inspiration from Mark Jason Dominus's
<a href="http://hop.perl.plover.com/"><cite>Higher-Order Perl</cite></a>, and specifically
using the Fibonacci sequence to create example PL/pgSQL functions. It turns
out that, while the Fibonacci sequence may not be of much use in day-to-day
database work, it makes for great pedagogy. And I learned a fair bit along the
way, as well.</p>

<p>So the initial, naïve implementation of a Fibonacci calculate in PL/pgSQL,
using recursion, is quite straight-forward:</p>

<pre>
CREATE OR REPLACE FUNCTION fib (
    fib_for int
) RETURNS integer AS $$
BEGIN
    IF fib_for &lt; 2 THEN
        RETURN fib_for;
    END IF;
    RETURN fib(fib_for - 2) + fib(fib_for - 1);
END;
$$ LANGUAGE plpgsql;
</pre>

<p>Pretty simple, right? The <q>$$</q>, by the way, is PL/pgSQL
dollar-quoting, which prevents me from having to escape single quotes in the
function body (when the function body has them, that is!). of course, this is
as slow in PL/pgSQL as it would be in any other language:</p>

<pre>
try=% explain analyze select fib(26);
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Total runtime: 3772.315 ms
</pre>

<p>Pretty sad, right? So then I added memoization. In PL/pgSQL, this is as
simple as using a table for the cache:</p>

<pre>
CREATE TABLE fib_cache (
     num integer PRIMARY KEY,
     fib integer NOT NULL
);

CREATE OR REPLACE FUNCTION fib_cached(
    fib_for int
) RETURNS integer AS $$
DECLARE
    ret integer;
BEGIN
    if fib_for &lt; 2 THEN
        RETURN fib_for;
    END IF;

    SELECT INTO ret fib
    FROM   fib_cache
    WHERE  num = fib_for;

    IF ret IS NULL THEN
        ret := fib_cached(fib_for - 2) + fib_cached(fib_for - 1);
        INSERT INTO fib_cache (num, fib)
        VALUES (fib_for, ret);
    END IF;
    RETURN ret;

END;
$$ LANGUAGE plpgsql;
</pre>

<p>This gets me a big performance boost:</p>

<pre>
try=% explain analyze select fib_cached(26);
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Total runtime: 50.889 ms

try=% explain analyze select fib_cached(26);
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Total runtime: 2.249 ms
</pre>

<p>So even before any sequence numbers have been calculated it's a big win,
and after they've been calculated, it is of course even better.</p>

<p>So then, following Dominus's lead, I set about refactoring the original,
recursive version with tail call elimination. Here's what I came up with:</p>

<pre>
CREATE OR REPLACE FUNCTION fib_stacked(
    n integer
) RETURNS integer AS $$
DECLARE
    fib_for integer := n;
    branch  integer := 0;
    ret     integer := 0;
    s1      integer := 0;
    stack   integer[][] := ARRAY[ARRAY[0, 0, 0]];
    bound   integer := 1;
BEGIN
    LOOP
        IF fib_for &lt; 2 THEN
            ret := fib_for;
        ELSE
            IF branch = 0 THEN
                WHILE fib_for >= 2 LOOP
                    stack = array_cat(stack, ARRAY[1, 0, fib_for]);
                    fib_for := fib_for - 1;
                END LOOP;
                ret := fib_for;
            ELSIF branch = 1 THEN
                stack = array_cat(stack, ARRAY[2, ret, fib_for]);
                fib_for := fib_for - 2;
                branch  := 0;
                CONTINUE;
            ELSIF branch = 2 THEN
                ret := ret + s1;
            END IF;
        END IF;

        bound := array_upper(stack, 1);
        IF bound &lt;= 1 THEN
            RETURN ret;
        END IF;

        SELECT INTO branch,          s1,              fib_for
                    stack[bound][1], stack[bound][2], stack[bound][3];
        SELECT INTO stack stack[1:bound-1][1:3];
    END LOOP;
    RETURN ret;
END;
$$ LANGUAGE plpgsql;
</pre>

<p> It took me <em>forever</em> to figure out how to do it, primarily because
arrays in PostgreSQL are quite limited, in the sense that, while can add to
them, you cannot remove from them! Hence the <code>SELECT INTO</code> to
reassign to <var>stack</var> at the end of the loop. That syntax constructs a
completely new, smaller array and assigns it to <var>stack</var>. Ick. Another
problem is that PL/pgSQL does not like an empty multidimensional array; hence
the initial assignment to <var>stack</var> in the <code>DECLARE</code> block.
I then have to remember that the array always has at least one item in it, and
respond accordingly. It didn't much help that SQL arrays start at 1 rather
than 0.</p>

<p>But the big surprise to me was just how badly this function performed:</p>

<pre>
try=% explain analyze select fib_stacked(26);
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Total runtime: 30852.697 ms
</pre>

<p>Yow! So I don't think that's the best approach. But I did figure out
another approach, based on an example I saw in <cite>Agile Web Development
with Rails</cite>. It's a very simple loop-based approach:</p>

<pre>
CREATE OR REPLACE FUNCTION fib_fast(
    fib_for int
) RETURNS integer AS $$
DECLARE
    ret integer := 0;
    nxt integer := 1;
    tmp integer;
BEGIN
    FOR num IN 1..fib_for LOOP
        tmp := ret;
        ret := nxt;
        nxt := tmp + nxt;
    END LOOP;

    RETURN ret;
END;
$$ LANGUAGE plpgsql;
</pre>

<p>This one works the best of all:</p>

<pre>
try=# explain analyze select fib_fast(26);
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Total runtime: 0.326 ms
</pre>

<p>Sweet! I was left wondering why this algorithm wasn't used in
<cite>HOP</cite>, but then realized that it probably didn't fit in with
Dominus's pedagogical goals. But it was an interesting learning experience for
me all the same.</p>

<p>Look for the first of my articles to be published 2006-5-10.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/higher_order_plpgsql.html">old layout</a>.</small></p>


