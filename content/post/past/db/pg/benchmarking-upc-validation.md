--- 
date: 2006-05-17T05:25:14Z
slug: benchmarking-upc-validation
title: Benchmarking UPC Validation
aliases: [/computers/databases/postgresql/benchmarking_upc_validation.html]
tags: [Postgres, PL/pgSQL, PL/Perl, EAN]
type: post
---

<p>Just to follow up on my query about
<a href="/computers/databases/postgresql/plpgsql_upc_validation.html"
title="Validating UPCs with PL/pgSQL">validating UPC codes in PL/pgSQL</a>,
Klint Gore sent me a private email demonstrating that treating the UPC code as
a binary string performed better than my substringing approach. I modified his
version to work like the others, but it looked to me like the performance was
about the same. They were just too close for me to really be able to tell.</p>

<p>What I needed was a way to run the queries a whole bunch of times to see
the real difference. I asked on <code>#postgresql</code>, and
<code>dennisb</code> suggested a simple brute-force approach:</p>

<pre>select foo(42) FROM generate_series (1, 10000);</pre>

<p>So that's what I did. The functions I tested were:</p>

<ul>
  <li>
    <p>A refinement of my original substring solution:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_substr (
    TEXT
) RETURNS boolean AS $$
DECLARE
    offset integer := 0;
    &#x002d;&#x002d; Support UPCs.
    ean   TEXT    := CASE WHEN length($1) = 12 THEN
       &#x0027;0&#x0027; || $1
    ELSE
       $1
    END;
BEGIN
    &#x002d;&#x002d; Make sure we really have an EAN.
    IF ean !~ &#x0027;^\\d{13}$&#x0027; THEN RETURN FALSE; END IF;

    RETURN 10 &#x002d; (
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
         + substring(ean,  3 + offset, 1)::integer
         + substring(ean,  5 + offset, 1)::integer
         + substring(ean,  7 + offset, 1)::integer
         + substring(ean,  9 + offset, 1)::integer
         + substring(ean, 11 + offset, 1)::integer
    &#x002d;&#x002d; Compare to the checksum.
    ) % 10 = substring(ean, 12 + offset, 1)::integer;
END;
$$ LANGUAGE plpgsql;
    </pre>
  </li>

  <li>
    <p>A looping version, based on the comment from Adrian Klaver in the
      <a href="/computers/databases/postgresql/plpgsql_upc_validation.html"
         title="Validating UPCs with PL/pgSQL">original post</a>:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_loop(
    TEXT
) RETURNS boolean AS $$
DECLARE
    total INTEGER := 0;
    &#x002d;&#x002d; Support UPCs.
    ean   TEXT    := CASE WHEN length($1) = 12 THEN
       &#x0027;0&#x0027; || $1
    ELSE
       $1
    END;
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
    FOR i IN 3..11 LOOP
        total := total + substring(ean, i, 1)::INTEGER;
        i := i + 1;
    END LOOP;

    &#x002d;&#x002d; Compare to the checksum.
    RETURN 10 &#x002d; total % 10
        = substring(ean, 13, 1)::INTEGER;
END;
$$ LANGUAGE &#x0027;plpgsql&#x0027;;
    </pre>
  </li>

  <li>
    <p>A PL/Perl version for Josh and Ovid:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_perl (
    TEXT
) RETURNS boolean AS $_$
    my $ean = length $_[0] == 12 ? "0$_[0]" : $_[0];
    # Make sure we really have an EAN.
    return &#x0027;false&#x0027; unless $ean =~ /^\d{13}$/;
    my @nums = split &#x0027;&#x0027;, shift;
    return 10 &#x002d; (
        # Sum even numerals.
        (   (   $nums[1] + $nums[3] + $nums[5]
                + $nums[7] + $nums[9] + $nums[11]
            ) * 3 # Multiply total by 3.
        # Add odd numerals except for checksum (12).
        ) + $nums[2] + $nums[4] + $nums[6] + $nums[8]
          + $nums[10]
    # Compare to the checksum.
    ) % 10 == $nums[11] ? &#x0027;true&#x0027; : &#x0027;false&#x0027;;
$_$ LANGUAGE plperl;
    </pre>
  </li>

  <li>
    <p>And finally, the new version using a byte string:</p>
    <pre>
CREATE OR REPLACE FUNCTION ean_byte (
   arg TEXT
) RETURNS boolean AS $$
DECLARE
    &#x002d;&#x002d; Convert to BYTEA; support UPCs.
    ean BYTEA := CASE WHEN length($1) = 12 THEN
        &#x0027;0&#x0027; || $1
    ELSE
        $1
    END;
BEGIN
    &#x002d;&#x002d; Make sure we really have an EAN.
    IF arg !~ &#x0027;^\\d{12,13}$&#x0027; THEN RETURN FALSE; END IF;

    RETURN 10 &#x002d; (
        (
            &#x002d;&#x002d; Sum even numerals.
            get_byte(ean,  2) &#x002d; 48
          + get_byte(ean,  4) &#x002d; 48
          + get_byte(ean,  6) &#x002d; 48
          + get_byte(ean,  8) &#x002d; 48
          + get_byte(ean, 10) &#x002d; 48
          + get_byte(ean, 12) &#x002d; 48
         ) * 3 &#x002d;&#x002d; Multiply total by 3.
         &#x002d;&#x002d; Add odd numerals except for checksum (13).
         + get_byte(ean,  3) &#x002d; 48
         + get_byte(ean,  7) &#x002d; 48
         + get_byte(ean,  5) &#x002d; 48
         + get_byte(ean,  9) &#x002d; 48
         + get_byte(ean, 11) &#x002d; 48
    &#x002d;&#x002d; Compare to the checksum.
    ) % 10  = get_byte(ean, 12) &#x002d; 48;
END;
$$ LANGUAGE plpgsql;
    </pre>
  </li>
</ul>

<p>And then I ran the benchmarks:</p>

<pre>
try=# \timing
Timing is on.
try=# \o /dev/null
try=# select ean_substr(&#x0027;036000291452&#x0027;)
try-# FROM generate_series (1, 10000);
Time: 488.743 ms
try=# select ean_loop(&#x0027;036000291452&#x0027;)
try-# FROM generate_series (1, 10000);
Time: 881.553 ms
try=# select ean_perl(&#x0027;036000291452&#x0027;)
try-# FROM generate_series (1, 10000);
Time: 540.962 ms
try=# select ean_byte(&#x0027;036000291452&#x0027;)
try-# FROM generate_series (1, 10000);
Time: 395.124 ms
</pre>

<p>So the binary approach is the clear winner here, being 23.69% faster than
my substring approach, 36.91% faster than the Perl version, and 2.23 times
faster (123.11%) than the looping approach. So I think I'll go with that.</p>

<p>Meanwhile, I'm pleased to have this simple benchmarking tool in my arsenal
for future PostgreSQL function development.</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/benchmarking_upc_validation.html">old layout</a>.</small></p>


