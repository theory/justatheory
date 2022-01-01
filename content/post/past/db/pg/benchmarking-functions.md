--- 
date: 2006-05-20T04:57:10Z
slug: benchmarking-functions
title: Benchmarking PostgreSQL Functions
aliases: [/computers/databases/postgresql/benchmarking_functions.html]
tags: [Postgres, Benchmarks, PL/pgSQL, PL/Perl, C]
type: post
---

**Update 2006-05-19:** *I realized that there was a nasty error in my algorithm
for determining the runtime of a function: It was only fetching the milliseconds
part of the runtime, without adding in seconds and minutes! This led to getting
negative runtimes then the milliseconds part of the end time was less than the
milliseconds part of the start time. Ugh. But with the help of `yain` on IRC,
I've switched to calculating the number of seconds by converting the start and
end times to epoch seconds (which have subsecond precision in PostgreSQL, and
now things are just dandy. While I was at it, I reorganized the function so that
it was a bit easier to read, by constructing the created function in the order
it would be executed, and fixed the caching problem, as suggested by Aidan in a
comment below.*

Following [yesterday's post], Klint Gore sent me some PL/pgSQL code that might
be useable as a benchmark function. Today I took that code and ran with it.

The idea was to create a function like the Perl [Benchmark] module's
`timethese()` function. In the process, I found, with help from [Josh Berkus],
that PL/pgSQL's `EXECUTE` statement has quite a lot of overhead, and the amount
of overhead per call is pretty random. The overhead resulted in pretty
inaccurate benchmark numbers, unfortunately.

At Josh's suggestion, I rewrote the function to just test each function inline,
rather than passing the function code as parameters. This time, the results were
dead on. So then I refactored the original benchmark function to create its
*own* benchmark function, inlining all of the code, and then call that function.
Almost higher-order PL/pgSQL! Again the results were just right, and so now I
present it to you:

``` plpgsql
create type _benchmark as (
    code      text,
    runtime   real,
    corrected real
);

CREATE OR REPLACE FUNCTION benchmark(n INTEGER, funcs TEXT[])
RETURNS SETOF _benchmark AS $$
DECLARE
    code TEXT := '';
    a    _benchmark;
BEGIN
    -- Start building the custom benchmarking function.
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
            -- Create control.
            s := timeofday();
            FOR a IN SELECT TRUE FROM generate_series( 1, $_$ || n || $_$ )
            LOOP
            END LOOP;
            e := timeofday();
            d := extract(epoch from e) - extract(epoch from s);
            ret := ROW( '[Control]', d, 0 );
            RETURN NEXT ret;
$_$;
    -- Append the code to bench each function call.
    FOR i IN array_lower(funcs,1) .. array_upper(funcs, 1) LOOP
        code := code || '
            s := timeofday();
            FOR a IN SELECT ' || funcs[i] || ' FROM generate_series( 1, '
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

    -- Create the function.
    execute code || $_$
        END;
        $__$ language plpgsql;
$_$;

    -- Now execute the function.
    FOR a IN EXECUTE 'SELECT * FROM _bench(' || n || ')' LOOP
        RETURN NEXT a;
    END LOOP;

    -- Drop the function.
    DROP FUNCTION _bench(integer);
    RETURN;
END;
$$ language 'plpgsql';
```

You call the function like this:

``` postgres
try=# select * from benchmark(10000, ARRAY[
try(#     'ean_substr(''036000291452'')',
try(#     'ean_byte(''036000291452'')',
try(#     'ean_c(''036000291452'')'
try(# ]);
            code            | runtime   | corrected 
----------------------------+-----------+-----------
    [Control]                  | 0.0237451 |          0
    ean_substr('036000291452') |  0.497734 |   0.473989
    ean_byte(  '036000291452') |  0.394456 |   0.370711
    ean_c(     '036000291452') | 0.0277281 | 0.00398302
(4 rows)
```

Pretty slick, eh? The only downside was that, when the `DROP FUNCTION` line was
not commented out, the function would run once, and then, the next time, I'd get
this error:

    ERROR:  cache lookup failed for function 17323
    CONTEXT:  PL/pgSQL function "benchmark" line 49 at for over select rows

I have no idea why. So I just leave the function and let the `CREATE OR REPLACE`
take care of it.

  [yesterday's post]: {{% ref "/post/past/db/pg/benchmarking-upc-validation" %}}
    "Benchmarking UPC Validation"
  [Benchmark]: https://metacpan.org/pod/Benchmark
  [Josh Berkus]: https://www.databasesoup.com "“Database Soup” by Josh Berkus"
