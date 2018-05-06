--- 
date: 2006-05-20T04:55:46Z
slug: ean-validation
title: Corrected PostgreSQL EAN Functions
aliases: [/computers/databases/postgresql/ean_validation.html]
tags: [Postgres, EAN, UPCs, PL/pgSQL, C, Perl, PL/Perl]
---

<p><strong>Update:</strong><em> I updated the benchmarks based on the fixed version
of my <a
href="http://www.justatheory.com/computers/databases/postgresql/benchmarking_functions.html"
title="Benchmarking PostgreSQL Functions">benchmarking function</a>.</em></p>

<p>In doing a bit more reading about EAN codes, I realized that my <a
href="http://www.justatheory.com/computers/databases/postgresql/plpgsql_upc_validation.html"
title="Validating UPCs with PL/pgSQL">previous</a> <a
href="http://www.justatheory.com/computers/databases/postgresql/benchmarking_upc_validation.html"
title="Benchmarking UPC Validation">attempts</a> to write a validating function
for UPC and EAN codes had a significant error: they would only properly validate
EAN codes if the first numeral was 0! So I went back and fixed them all, and
present them here for posterity.</p>

<ul>
  <li>
    <p>The substring solution:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_substr (
    TEXT
) RETURNS boolean AS $$
DECLARE
    offset integer := 0;
    &#x002d;&#x002d; Support UPCs.
    ean   TEXT    := CASE WHEN length($1) = 12 THEN &#x0027;0&#x0027; || $1 ELSE $1 END;
BEGIN
    &#x002d;&#x002d; Make sure we really have an EAN.
    IF ean !~ &#x0027;^\\d{13}$&#x0027; THEN RETURN FALSE; END IF;

    RETURN 10 - (
        (
          &#x002d;&#x002d; Sum even numerals.
            substring(ean,  2 + offset, 1)::integer
          + substring(ean,  4 + offset, 1)::integer
          + substring(ean,  6 + offset, 1)::integer
          + substring(ean,  8 + offset, 1)::integer
          + substring(ean, 10 + offset, 1)::integer
          + substring(ean, 12 + offset, 1)::integer
         ) * 3 &#x002d;&#x002d; Multiply total by 3.
         &#x002d;&#x002d; Add odd numerals except for checksum (13).
         + substring(ean,  1 + offset, 1)::integer
         + substring(ean,  3 + offset, 1)::integer
         + substring(ean,  5 + offset, 1)::integer
         + substring(ean,  7 + offset, 1)::integer
         + substring(ean,  9 + offset, 1)::integer
         + substring(ean, 11 + offset, 1)::integer
    &#x002d;&#x002d; Compare to the checksum.
    ) % 10 = substring(ean, 13 + offset, 1)::integer;
END;
$$ LANGUAGE &#x0027;plpgsql&#x0027; immutable;
    </pre>
  </li>

  <li>
    <p>The looping solution:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_loop(
    TEXT
) RETURNS boolean AS $$
DECLARE
    total INTEGER := 0;
    &#x002d;&#x002d; Support UPCs.
    ean   TEXT    := CASE WHEN length($1) = 12 THEN &#x0027;0&#x0027; || $1 ELSE $1 END;
BEGIN
    &#x002d;&#x002d; Make sure we really have an EAN.
    IF ean !~ &#x0027;^\\d{13}$&#x0027; THEN RETURN FALSE; END IF;

    &#x002d;&#x002d; Sum even numerals.
    FOR i IN 2..12 LOOP
        total := total + substring(ean, i, 1)::INTEGER;
        i := i + 1;
    END LOOP;

    &#x002d;&#x002d; Multiply total by 3.
    total := total * 3;

    &#x002d;&#x002d; Add odd numerals except for checksum (13).
    FOR i IN 1..11 LOOP
        total := total + substring(ean, i, 1)::INTEGER;
        i := i + 1;
    END LOOP;

    &#x002d;&#x002d; Compare to the checksum.
    RETURN 10 - total % 10 = substring(ean, 13, 1)::INTEGER;
END;
$$ LANGUAGE &#x0027;plpgsql&#x0027; immutable;
    </pre>
  </li>

  <li>
    <p>The <code>BYTEA</code> solution:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_byte (
   arg TEXT
) RETURNS boolean AS $$
DECLARE
    &#x002d;&#x002d; Convert to BYTEA; support UPCs.
    ean BYTEA := CASE WHEN length($1) = 12 THEN &#x0027;0&#x0027; || $1 ELSE $1 END;
BEGIN
    &#x002d;&#x002d; Make sure we really have an EAN.
    IF arg !~ &#x0027;^\\d{12,13}$&#x0027; THEN RETURN FALSE; END IF;

    RETURN 10 - (
        (
            &#x002d;&#x002d; Sum odd numerals.
            get_byte(ean,  1) - 48
          + get_byte(ean,  3) - 48
          + get_byte(ean,  5) - 48
          + get_byte(ean,  7) - 48
          + get_byte(ean,  9) - 48
          + get_byte(ean, 11) - 48
         ) * 3 &#x002d;&#x002d; Multiply total by 3.
         &#x002d;&#x002d; Add even numerals except for checksum (12).
         + get_byte(ean,  0) - 48
         + get_byte(ean,  2) - 48
         + get_byte(ean,  4) - 48
         + get_byte(ean,  6) - 48
         + get_byte(ean,  8) - 48
         + get_byte(ean, 10) - 48
    &#x002d;&#x002d; Compare to the checksum.
    ) % 10 = get_byte(ean, 12) - 48;
    
END;
$$ LANGUAGE plpgsql immutable;
    </pre>
  </li>

  <li>
    <p>The PL/Perl solution:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_perl (
    TEXT
) RETURNS boolean AS $_$
    my $ean = length $_[0] == 12 ? &quot;0$_[0]&quot; : $_[0];
    # Make sure we really have an EAN.
    return &#x0027;false&#x0027; unless $ean =~ /^\d{13}$/;
    my @nums = split &#x0027;&#x0027;, $ean;
    return 10 - (
        # Sum even numerals.
        (   (   $nums[1] + $nums[3] + $nums[5] + $nums[7] + $nums[9]
                    + $nums[11]
            ) * 3 # Multiply total by 3.
        # Add odd numerals except for checksum (12).
        ) + $nums[0] + $nums[2] + $nums[4] + $nums[6] + $nums[8] + $nums[10]
    # Compare to the checksum.
    ) % 10 == $nums[12] ? &#x0027;true&#x0027; : &#x0027;false&#x0027;;
$_$ LANGUAGE plperl immutable;
    </pre>
  </li>

  <li>
    <p>The C solution (thanks StuckMojo!):</p>
    <pre>
#include &lt;string.h&gt;
#include &quot;postgres.h&quot;
#include &quot;fmgr.h&quot;

Datum ean_c(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(ean_c);

Datum ean_c(PG_FUNCTION_ARGS) {

    char *ean;
    text *arg = PG_GETARG_TEXT_P(0);
    int  arglen = VARSIZE(arg) - VARHDRSZ;
    bool ret = false;

    /* Validate the easy stuff: 12 or 13 digits. */
    if ((arglen != 12 &amp;&amp; arglen != 13) || 
        strspn(VARDATA(arg), &quot;0123456789&quot;) != arglen) {
        PG_RETURN_BOOL(ret);
    }

    /* Support UPCs. */
    if (arglen == 12) {
        ean = (char *) palloc(13);
        ean[0] = &#x0027;0&#x0027;;
        memcpy(&amp;ean[1], VARDATA(arg), arglen);
    } else {
        ean = (char *) palloc(arglen);
        memcpy(ean, VARDATA(arg), arglen);
    }

    ret = 10 - (
            /* Sum even numerals and multiply total by 3. */
            (  ean[1] - &#x0027;0&#x0027; + ean[3] - &#x0027;0&#x0027; + ean[5]  - &#x0027;0&#x0027; 
             + ean[7] - &#x0027;0&#x0027; + ean[9] - &#x0027;0&#x0027; + ean[11] - &#x0027;0&#x0027;) * 3
            /* Add odd numerals except for checksum (12). */
            + ean[0] - &#x0027;0&#x0027; + ean[2] - &#x0027;0&#x0027; + ean[4]  - &#x0027;0&#x0027;
            + ean[6] - &#x0027;0&#x0027; + ean[8] - &#x0027;0&#x0027; + ean[10] - &#x0027;0&#x0027;
        /* Compare to the checksum. */
        ) % 10 == ean[12] - &#x0027;0&#x0027;;

   PG_RETURN_BOOL(ret);
}
    </pre>
  </li>
</ul>

<p>And here are the benchmarks for them (without <code>immutable</code>):</p>

<pre>
try=# select * from benchmark(100000, ARRAY[
try(#     &#x0027;ean_substr(&#x0027;&#x0027;4007630000116&#x0027;&#x0027;)&#x0027;,
try(#     &#x0027;ean_loop(  &#x0027;&#x0027;4007630000116&#x0027;&#x0027;)&#x0027;,
try(#     &#x0027;ean_byte(  &#x0027;&#x0027;4007630000116&#x0027;&#x0027;)&#x0027;,
try(#     &#x0027;ean_perl(  &#x0027;&#x0027;4007630000116&#x0027;&#x0027;)&#x0027;,
try(#     &#x0027;ean_c(     &#x0027;&#x0027;4007630000116&#x0027;&#x0027;)&#x0027;
try(# ]);
            code             | runtime  |    rate     | corrected | corrected_rate 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 [Control]                   | 0.257728 | 388006.17/s |  0.257728 | 388006.17/s
 ean_substr(&#x0027;4007630000116&#x0027;) |  5.07296 | 19712.37/s  |   4.81523 | 20767.44/s
 ean_loop(  &#x0027;4007630000116&#x0027;) |  9.18085 | 10892.24/s  |   8.92312 | 11206.84/s
 ean_byte(  &#x0027;4007630000116&#x0027;) |   3.9248 | 25479.02/s  |   3.66707 | 27269.73/s
 ean_perl(  &#x0027;4007630000116&#x0027;) |   5.5062 | 18161.33/s  |   5.24848 | 19053.15/s
 ean_c(     &#x0027;4007630000116&#x0027;) | 0.285376 | 350415.10/s |  0.027648 | 3616901.80/s
(6 rows)
</pre>

<p>Enjoy!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/ean_validation.html">old layout</a>.</small></p>


