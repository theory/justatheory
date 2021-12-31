--- 
date: 2006-05-20T04:55:46Z
slug: postgres-ean-validation
title: Corrected PostgreSQL EAN Functions
aliases: [/computers/databases/postgresql/ean_validation.html]
tags: [Postgres, EAN, UPCs, PL/pgSQL, C, Perl, PL/Perl]
type: post
---

**Update:** *I updated the benchmarks based on the fixed version of my
[benchmarking function].*

In doing a bit more reading about EAN codes, I realized that my [previous][]
[attempts] to write a validating function for UPC and EAN codes had a
significant error: they would only properly validate EAN codes if the first
numeral was 0! So I went back and fixed them all, and present them here for
posterity.

-   The substring solution:

    ``` postgres
    CREATE OR REPLACE FUNCTION ean_substr (
        TEXT
    ) RETURNS boolean AS $$
    DECLARE
        offset integer := 0;
        -- Support UPCs.
        ean   TEXT    := CASE WHEN length($1) = 12 THEN '0' || $1 ELSE $1 END;
    BEGIN
        -- Make sure we really have an EAN.
        IF ean !~ '^\\d{13}$' THEN RETURN FALSE; END IF;

        RETURN 10 - (
            (
                -- Sum even numerals.
                substring(ean,  2 + offset, 1)::integer
                + substring(ean,  4 + offset, 1)::integer
                + substring(ean,  6 + offset, 1)::integer
                + substring(ean,  8 + offset, 1)::integer
                + substring(ean, 10 + offset, 1)::integer
                + substring(ean, 12 + offset, 1)::integer
            ) * 3 -- Multiply total by 3.
            -- Add odd numerals except for checksum (13).
            + substring(ean,  1 + offset, 1)::integer
            + substring(ean,  3 + offset, 1)::integer
            + substring(ean,  5 + offset, 1)::integer
            + substring(ean,  7 + offset, 1)::integer
            + substring(ean,  9 + offset, 1)::integer
            + substring(ean, 11 + offset, 1)::integer
        -- Compare to the checksum.
        ) % 10 = substring(ean, 13 + offset, 1)::integer;
    END;
    $$ LANGUAGE 'plpgsql' immutable;
    ```

-   The looping solution:

    ``` postgres
    CREATE OR REPLACE FUNCTION ean_loop(
        TEXT
    ) RETURNS boolean AS $$
    DECLARE
        total INTEGER := 0;
        -- Support UPCs.
        ean   TEXT    := CASE WHEN length($1) = 12 THEN '0' || $1 ELSE $1 END;
    BEGIN
        -- Make sure we really have an EAN.
        IF ean !~ '^\\d{13}$' THEN RETURN FALSE; END IF;

        -- Sum even numerals.
        FOR i IN 2..12 LOOP
            total := total + substring(ean, i, 1)::INTEGER;
            i := i + 1;
        END LOOP;

        -- Multiply total by 3.
        total := total * 3;

        -- Add odd numerals except for checksum (13).
        FOR i IN 1..11 LOOP
            total := total + substring(ean, i, 1)::INTEGER;
            i := i + 1;
        END LOOP;

        -- Compare to the checksum.
        RETURN 10 - total % 10 = substring(ean, 13, 1)::INTEGER;
    END;
    $$ LANGUAGE 'plpgsql' immutable;
    ```

-   The `BYTEA` solution:

    ``` postgres
    CREATE OR REPLACE FUNCTION ean_byte (
        arg TEXT
    ) RETURNS boolean AS $$
    DECLARE
        -- Convert to BYTEA; support UPCs.
        ean BYTEA := CASE WHEN length($1) = 12 THEN '0' || $1 ELSE $1 END;
    BEGIN
        -- Make sure we really have an EAN.
        IF arg !~ '^\\d{12,13}$' THEN RETURN FALSE; END IF;

        RETURN 10 - (
            (
                -- Sum odd numerals.
                get_byte(ean,  1) - 48
                + get_byte(ean,  3) - 48
                + get_byte(ean,  5) - 48
                + get_byte(ean,  7) - 48
                + get_byte(ean,  9) - 48
                + get_byte(ean, 11) - 48
            ) * 3 -- Multiply total by 3.
            -- Add even numerals except for checksum (12).
            + get_byte(ean,  0) - 48
            + get_byte(ean,  2) - 48
            + get_byte(ean,  4) - 48
            + get_byte(ean,  6) - 48
            + get_byte(ean,  8) - 48
            + get_byte(ean, 10) - 48
        -- Compare to the checksum.
        ) % 10 = get_byte(ean, 12) - 48;
        
    END;
    $$ LANGUAGE plpgsql immutable;
    ```

-   The PL/Perl solution:

    ``` postgres
    CREATE OR REPLACE FUNCTION ean_perl (
        TEXT
    ) RETURNS boolean AS $_$
        my $ean = length $_[0] == 12 ? "0$_[0]" : $_[0];
        # Make sure we really have an EAN.
        return 'false' unless $ean =~ /^\d{13}$/;
        my @nums = split '', $ean;
        return 10 - (
            # Sum even numerals.
            (   (   $nums[1] + $nums[3] + $nums[5] + $nums[7] + $nums[9]
                        + $nums[11]
                ) * 3 # Multiply total by 3.
            # Add odd numerals except for checksum (12).
            ) + $nums[0] + $nums[2] + $nums[4] + $nums[6] + $nums[8] + $nums[10]
        # Compare to the checksum.
        ) % 10 == $nums[12] ? 'true' : 'false';
    $_$ LANGUAGE plperl immutable;
    ```

-   The C solution (thanks StuckMojo!):

    ``` c
    #include <string.h>
    #include "postgres.h"
    #include "fmgr.h"

    Datum ean_c(PG_FUNCTION_ARGS);

    PG_FUNCTION_INFO_V1(ean_c);

    Datum ean_c(PG_FUNCTION_ARGS) {

        char *ean;
        text *arg = PG_GETARG_TEXT_P(0);
        int  arglen = VARSIZE(arg) - VARHDRSZ;
        bool ret = false;

        /* Validate the easy stuff: 12 or 13 digits. */
        if ((arglen != 12 && arglen != 13) || 
            strspn(VARDATA(arg), "0123456789") != arglen) {
            PG_RETURN_BOOL(ret);
        }

        /* Support UPCs. */
        if (arglen == 12) {
            ean = (char *) palloc(13);
            ean[0] = '0';
            memcpy(&ean[1], VARDATA(arg), arglen);
        } else {
            ean = (char *) palloc(arglen);
            memcpy(ean, VARDATA(arg), arglen);
        }

        ret = 10 - (
                /* Sum even numerals and multiply total by 3. */
                (  ean[1] - '0' + ean[3] - '0' + ean[5]  - '0' 
                    + ean[7] - '0' + ean[9] - '0' + ean[11] - '0') * 3
                /* Add odd numerals except for checksum (12). */
                + ean[0] - '0' + ean[2] - '0' + ean[4]  - '0'
                + ean[6] - '0' + ean[8] - '0' + ean[10] - '0'
            /* Compare to the checksum. */
            ) % 10 == ean[12] - '0';

        PG_RETURN_BOOL(ret);
    }
    ```        

And here are the benchmarks for them (without `immutable`):

    try=# select * from benchmark(100000, ARRAY[
    try(#     'ean_substr(''4007630000116'')',
    try(#     'ean_loop(  ''4007630000116'')',
    try(#     'ean_byte(  ''4007630000116'')',
    try(#     'ean_perl(  ''4007630000116'')',
    try(#     'ean_c(     ''4007630000116'')'
    try(# ]);
                code             | runtime  |    rate     | corrected | corrected_rate 
    -----------------------------+----------+-------------+-----------+----------------
     [Control]                   | 0.257728 | 388006.17/s |  0.257728 | 388006.17/s
     ean_substr('4007630000116') |  5.07296 | 19712.37/s  |   4.81523 | 20767.44/s
     ean_loop(  '4007630000116') |  9.18085 | 10892.24/s  |   8.92312 | 11206.84/s
     ean_byte(  '4007630000116') |   3.9248 | 25479.02/s  |   3.66707 | 27269.73/s
     ean_perl(  '4007630000116') |   5.5062 | 18161.33/s  |   5.24848 | 19053.15/s
     ean_c(     '4007630000116') | 0.285376 | 350415.10/s |  0.027648 | 3616901.80/s
    (6 rows)

Enjoy!

  [benchmarking function]: {{% ref "/post/past/db/pg/benchmarking-functions" %}}
    "Benchmarking PostgreSQL Functions"
  [previous]: {{% ref "/post/past/db/pg/plpgsql-upc-validation" %}}
    "Validating UPCs with PL/pgSQL"
  [attempts]: {{% ref "/post/past/db/pg/benchmarking-upc-validation" %}}
    "Benchmarking UPC Validation"
