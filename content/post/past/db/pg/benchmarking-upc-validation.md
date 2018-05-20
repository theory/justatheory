--- 
date: 2006-05-17T05:25:14Z
slug: benchmarking-upc-validation
title: Benchmarking UPC Validation
aliases: [/computers/databases/postgresql/benchmarking_upc_validation.html]
tags: [Postgres, PL/pgSQL, PL/Perl, EAN]
type: post
---

Just to follow up on my query about [validating UPC codes in PL/pgSQL], Klint
Gore sent me a private email demonstrating that treating the UPC code as a
binary string performed better than my substringing approach. I modified his
version to work like the others, but it looked to me like the performance was
about the same. They were just too close for me to really be able to tell.

What I needed was a way to run the queries a whole bunch of times to see the
real difference. I asked on `#postgresql`, and `dennisb` suggested a simple
brute-force approach:

    select foo(42) FROM generate_series (1, 10000);

So that's what I did. The functions I tested were:

-   A refinement of my original substring solution:

        CREATE OR REPLACE FUNCTION ean_substr (
            TEXT
        ) RETURNS boolean AS $$
        DECLARE
            offset integer := 0;
            -- Support UPCs.
            ean   TEXT    := CASE WHEN length($1) = 12 THEN
               '0' || $1
            ELSE
               $1
            END;
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
                 + substring(ean,  3 + offset, 1)::integer
                 + substring(ean,  5 + offset, 1)::integer
                 + substring(ean,  7 + offset, 1)::integer
                 + substring(ean,  9 + offset, 1)::integer
                 + substring(ean, 11 + offset, 1)::integer
            -- Compare to the checksum.
            ) % 10 = substring(ean, 12 + offset, 1)::integer;
        END;
        $$ LANGUAGE plpgsql;
            

-   A looping version, based on the comment from Adrian Klaver in the [original
    post][validating UPC codes in PL/pgSQL]:

        CREATE OR REPLACE FUNCTION ean_loop(
            TEXT
        ) RETURNS boolean AS $$
        DECLARE
            total INTEGER := 0;
            -- Support UPCs.
            ean   TEXT    := CASE WHEN length($1) = 12 THEN
               '0' || $1
            ELSE
               $1
            END;
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
            FOR i IN 3..11 LOOP
                total := total + substring(ean, i, 1)::INTEGER;
                i := i + 1;
            END LOOP;

            -- Compare to the checksum.
            RETURN 10 - total % 10
                = substring(ean, 13, 1)::INTEGER;
        END;
        $$ LANGUAGE 'plpgsql';
            

-   A PL/Perl version for Josh and Ovid:

        CREATE OR REPLACE FUNCTION ean_perl (
            TEXT
        ) RETURNS boolean AS $_$
            my $ean = length $_[0] == 12 ? "0$_[0]" : $_[0];
            # Make sure we really have an EAN.
            return 'false' unless $ean =~ /^\d{13}$/;
            my @nums = split '', shift;
            return 10 - (
                # Sum even numerals.
                (   (   $nums[1] + $nums[3] + $nums[5]
                        + $nums[7] + $nums[9] + $nums[11]
                    ) * 3 # Multiply total by 3.
                # Add odd numerals except for checksum (12).
                ) + $nums[2] + $nums[4] + $nums[6] + $nums[8]
                  + $nums[10]
            # Compare to the checksum.
            ) % 10 == $nums[11] ? 'true' : 'false';
        $_$ LANGUAGE plperl;
            

-   And finally, the new version using a byte string:

        CREATE OR REPLACE FUNCTION ean_byte (
           arg TEXT
        ) RETURNS boolean AS $$
        DECLARE
            -- Convert to BYTEA; support UPCs.
            ean BYTEA := CASE WHEN length($1) = 12 THEN
                '0' || $1
            ELSE
                $1
            END;
        BEGIN
            -- Make sure we really have an EAN.
            IF arg !~ '^\\d{12,13}$' THEN RETURN FALSE; END IF;

            RETURN 10 - (
                (
                    -- Sum even numerals.
                    get_byte(ean,  2) - 48
                  + get_byte(ean,  4) - 48
                  + get_byte(ean,  6) - 48
                  + get_byte(ean,  8) - 48
                  + get_byte(ean, 10) - 48
                  + get_byte(ean, 12) - 48
                 ) * 3 -- Multiply total by 3.
                 -- Add odd numerals except for checksum (13).
                 + get_byte(ean,  3) - 48
                 + get_byte(ean,  7) - 48
                 + get_byte(ean,  5) - 48
                 + get_byte(ean,  9) - 48
                 + get_byte(ean, 11) - 48
            -- Compare to the checksum.
            ) % 10  = get_byte(ean, 12) - 48;
        END;
        $$ LANGUAGE plpgsql;
            

And then I ran the benchmarks:

    try=# \timing
    Timing is on.
    try=# \o /dev/null
    try=# select ean_substr('036000291452')
    try-# FROM generate_series (1, 10000);
    Time: 488.743 ms
    try=# select ean_loop('036000291452')
    try-# FROM generate_series (1, 10000);
    Time: 881.553 ms
    try=# select ean_perl('036000291452')
    try-# FROM generate_series (1, 10000);
    Time: 540.962 ms
    try=# select ean_byte('036000291452')
    try-# FROM generate_series (1, 10000);
    Time: 395.124 ms

So the binary approach is the clear winner here, being 23.69% faster than my
substring approach, 36.91% faster than the Perl version, and 2.23 times faster
(123.11%) than the looping approach. So I think I'll go with that.

Meanwhile, I'm pleased to have this simple benchmarking tool in my arsenal for
future PostgreSQL function development.

  [validating UPC codes in PL/pgSQL]: /computers/databases/postgresql/plpgsql_upc_validation.html
    "Validating UPCs with PL/pgSQL"
