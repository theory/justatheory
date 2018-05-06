--- 
date: 2007-07-19T18:08:06Z
slug: array-to-hash-one-liner
title: Array to Hash One-Liner
aliases: [/computers/programming/ruby/array_to_hash_one_liner.html]
tags: [Ruby, hashing]
---

<p>Programming in Ruby, I've badly missed Perl's list syntax, which, among other things, makes converting between arrays and hashes really easy. In Ruby I have forever been converting an array to a hash like this:</p>

<pre>
a = [ 1, 2, 3, 4, 5 ]
h = {}
a.each { |v| h[v] = v }
</pre>

<p>Of course, this is anything but concise. In Perl, I can just do this:</p>

<pre>
my @a = (1, 2, 3, 4, 5, 6);
my %h = map { $_ => $_ } @a;
</pre>

<p>Easy, huh? Well, I finally got fed up with the nasty hack in Ruby, did a little Googling, and figured out a way to do it in a single line:</p>

<pre>
a = [ 1, 2, 3, 4, 5, 6 ]
h = Hash[ *a.collect { |v| [ v, v ] }.flatten ]
</pre>

<p>Not quite as concise as the Perl version, and I have to construct a bunch of arrays that I then throw away with the call to <code>flatten</code>, but at least it's concise and, I think, clearer what it's doing. So I think I'll go with that.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/ruby/array_to_hash_one_liner.html">old layout</a>.</small></p>


