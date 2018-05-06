--- 
date: 2006-05-20T04:57:10Z
slug: benchmarking-functions
title: Benchmarking PostgreSQL Functions
aliases: [/computers/databases/postgresql/benchmarking_functions.html]
tags: [Postgres, benchmarks, PL/pgSQL, PL/Perl, C]
---

<p><strong>Update 2006-05-19:</strong> <em>I realized that there was a nasty error in my
algorithm for determining the runtime of a function: It was only fetching the
milliseconds part of the runtime, without adding in seconds and minutes! This
led to getting negative runtimes then the milliseconds part of the end time was
less than the milliseconds part of the start time. Ugh. But with the help of
<code>yain</code> on IRC, I've switched to calculating the number of seconds by
converting the start and end times to epoch seconds (which have subsecond
precision in PostgreSQL, and now things are just dandy. While I was at it, I
reorganized the function so that it was a bit easier to read, by constructing
the created function in the order it would be executed, and fixed the caching
problem, as suggested by Aidan in a comment below.</em></p>

<p>Following <a
href="/computers/databases/postgresql/benchmarking_upc_validation.html"
title="Benchmarking UPC Validation">yesterday's post</a>, Klint Gore sent
me some PL/pgSQL code that might be useable as a benchmark function. Today
I took that code and ran with it.</p>

<p>The idea was to create a function like the
Perl <a href="http://search.cpan.org/dist/perl/lib/Benchmark.pm">Benchmark</a>
module's <code>timethese()</code> function. In the process, I found, with help
from <a href="http://blogs.ittoolbox.com/database/soup/"
title="&#x201c;Database Soup&#x201d; by Josh Berkus">Josh Berkus</a>, that
PL/pgSQL's <code>EXECUTE</code> statement has quite a lot of overhead, and the
amount of overhead per call is pretty random. The overhead resulted in pretty
inaccurate benchmark numbers, unfortunately.</p>

<p>At Josh's suggestion, I rewrote the function to just test each function
inline, rather than passing the function code as parameters. This time, the
results were dead on. So then I refactored the original benchmark function to
create its <em>own</em> benchmark function, inlining all of the code, and then
call that function. Almost higher order PL/pgSQL! Again the results were just
right, and so now I present it to you:</p>

<pre>
create type _benchmark as (
    code      text,
    runtime   real,
    corrected real
);

CREATE OR REPLACE FUNCTION benchmark(n INTEGER, funcs TEXT[])
RETURNS SETOF _benchmark AS $$
DECLARE
    code TEXT := &#x0027;&#x0027;;
    a    _benchmark;
BEGIN
    &#x002d;&#x002d; Start building the custom benchmarking function.
    code := $_$
        CREATE OR REPLACE FUNCTION _bench(n INTEGER)
        RETURNS SETOF _benchmark AS $__$
        DECLARE
            s TIMESTAMP;
            e TIMESTAMP;
            a RECORD;
            d numeric;
            res numeric;
            ret _benchmark;
        BEGIN
            &#x002d;&#x002d; Create control.
            s := timeofday();
            FOR a IN SELECT TRUE FROM generate_series( 1, $_$ || n || $_$ )
            LOOP
            END LOOP;
            e := timeofday();
            d := extract(epoch from e) - extract(epoch from s);
            ret := ROW( &#x0027;[Control]&#x0027;, d, 0 );
            RETURN NEXT ret;
 
$_$;
    &#x002d;&#x002d; Append the code to bench each function call.
    FOR i IN array_lower(funcs,1) .. array_upper(funcs, 1) LOOP
        code := code || &#x0027;
            s := timeofday();
            FOR a IN SELECT &#x0027; || funcs[i] || &#x0027; FROM generate_series( 1, &#x0027;
                || n || $__$ ) LOOP
            END LOOP;
            e := timeofday();
            res := extract(epoch from e) - extract(epoch from s);
            ret := ROW(
                $__$ || quote_literal(funcs[i]) || $__$,
                res, 
                res - d
            );
            RETURN NEXT ret;
$__$;
    END LOOP;

    &#x002d;&#x002d; Create the function.
    execute code || $_$
        END;
        $__$ language plpgsql;
$_$; 

    &#x002d;&#x002d; Now execute the function.
    FOR a IN EXECUTE &#x0027;SELECT * FROM _bench(&#x0027; || n || &#x0027;)&#x0027; LOOP
        RETURN NEXT a;
    END LOOP;

    &#x002d;&#x002d; Drop the function.
    DROP FUNCTION _bench(integer);
    RETURN;
END;
$$ language &#x0027;plpgsql&#x0027;;
</pre>

<p>You call the function like this:</p>

<pre>
try=# select * from benchmark(10000, ARRAY[
try(#     &#x0027;ean_substr(&#x0027;&#x0027;036000291452&#x0027;&#x0027;)&#x0027;,
try(#     &#x0027;ean_byte(&#x0027;&#x0027;036000291452&#x0027;&#x0027;)&#x0027;,
try(#     &#x0027;ean_c(&#x0027;&#x0027;036000291452&#x0027;&#x0027;)&#x0027;
try(# ]);
            code            | runtime   | corrected 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 [Control]                  | 0.0237451 |          0
 ean_substr(&#x0027;036000291452&#x0027;) |  0.497734 |   0.473989
 ean_byte(  &#x0027;036000291452&#x0027;) |  0.394456 |   0.370711
 ean_c(     &#x0027;036000291452&#x0027;) | 0.0277281 | 0.00398302
(4 rows)
</pre>

<p>Pretty slick, eh? The only downside was that, when the <code>DROP
FUNCTION</code> line was not commented out, the function would run
once, and then, the next time, I'd get this error:</p>

<pre>
ERROR:  cache lookup failed for function 17323
CONTEXT:  PL/pgSQL function &quot;benchmark&quot; line 49 at for over select rows
</pre>

<p>I have no idea why. So I just leave the function and let the
<code>CREATE OR REPLACE</code> take care of it.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/benchmarking_functions.html">old layout</a>.</small></p>


