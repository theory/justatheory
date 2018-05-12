--- 
date: 2006-05-12T17:16:55Z
slug: plpgsql-upc-validation
title: Validating UPCs with PL/pgSQL
aliases: [/computers/databases/postgresql/plpgsql_upc_validation.html]
tags: [Postgres, UPCs, EAN, PL/pgSQL]
type: post
---

<p>So I wanted to write a PL/pgSQL function to
validate <a href="https://en.wikipedia.org/wiki/UPC_code" title="Wikipedia: UPC">UPC codes</a>. The rules for validation are:</p>

<ul>
  <li>The UPC must consist of 12 or 13 numerals</li>
  <li>The last numeral is a checksum for the previous 11 numerals</li>
  <li>The checksum is calculated as follows:
    <ul>
      <li>Add the digits in the odd-numbered positions in the string and
      multiply by three</li>
      <li>Add in the digits in the even-numbered positions</li>
      <li>Subtract the result from the next-higher multiple of ten.</li>
    </ul>
  </li>
</ul>

<p>It took me a few minutes to whip up this implementation in Perl:</p>

<pre>
use List::Util qw(sum);

sub validate_upc {
    my $upc = shift;
    my @nums = split $upc;
    shift @nums if @nums == 13; # Support EAN codes.
    die &quot;$upc is not a valid UPC&quot; if @upc != 12;
    10 - (  sum( @nums[0,2,4,6,8,10] ) * 3
          + sum( @nums[1,3,5,7,9] )
    ) % 10 == $nums[11];
}
</pre>

<p>Trying to do the same thing in PL/pgSQL was harder, mainly because I
couldn't find an easy way to split a string up into its individual characters.
<code>string_to_array()</code> seems ideal, but don't follow the same rules as
Perl when it comes to the empty string:</p>

<pre>
try=% select string_to_array(&#x0027;123&#x0027;, &#x0027;&#x0027;);
 string_to_array
 &#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 {123}
(1 row)
</pre>

<p>Bummer. So I had to fall back on individual calls
to <code>substring()</code>, instead:</p>

<pre>
CREATE OR REPLACE FUNCTION validate_upc (
upc text
) RETURNS boolean AS $$
DECLARE
    offset integer := 0;
BEGIN
    IF char_length(upc) = 13 THEN
        offset := 1;
    ELSIF char_length(upc) &lt;&gt; 12 THEN
        RAISE EXCEPTION &#x0027;% is not a valid UPC&#x0027;, upc;
    END IF;

    IF 10 - (
        (
            substring(upc,  1 + offset, 1)::integer
          + substring(upc,  3 + offset, 1)::integer
          + substring(upc,  5 + offset, 1)::integer
          + substring(upc,  7 + offset, 1)::integer
          + substring(upc,  9 + offset, 1)::integer
          + substring(upc, 11 + offset, 1)::integer
         ) * 3
         + substring(upc,  2 + offset, 1)::integer
         + substring(upc,  4 + offset, 1)::integer
         + substring(upc,  6 + offset, 1)::integer
         + substring(upc,  8 + offset, 1)::integer
         + substring(upc, 10 + offset, 1)::integer
         ) % 10  = substring(upc, 12 + offset, 1)::integer
    THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE plpgsql;
</pre>

<p>This works, and seems pretty fast, but I'm wondering if there isn't an
easier way to do this in PL/pgSQL. Do you know of one? Leave me a comment.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/plpgsql_upc_validation.html">old layout</a>.</small></p>


