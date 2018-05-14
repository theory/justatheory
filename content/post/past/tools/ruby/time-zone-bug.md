--- 
date: 2007-08-29T19:06:14Z
slug: time-zone-bug
title: Ruby Time Object Time Zone Bug
aliases: [/computers/programming/ruby/time_zone_bug.html]
tags: [Ruby, time zones]
type: post
---

<p><a href="http://rubyforge.org/tracker/?func=detail&amp;atid=1698&amp;aid=6368&amp;group_id=426" title="[ ruby-Bugs-6368 ] Time Changes Zones">This is disappointing</a>.</p>

<p>To summarize, Ruby's <code>Time</code> class has a bug in its <code>zone</code> method. The example is simple:</p>

<pre>
tz = ENV[&#x0027;TZ&#x0027;]
ENV[&#x0027;TZ&#x0027;] = &#x0027;Africa/Luanda&#x0027;
t = Time.now
puts t.zone
ENV[&#x0027;TZ&#x0027;] = &#x0027;Australia/Lord_Howe&#x0027;
puts t.zone
</pre>

<p>This outputs:</p>

<pre>
WAT
WAT
</pre>

<p>So far so good. But look what happens when I add a single line to the program, <code>foo = t.to_s</code>:</p>

<pre>
tz = ENV[&#x0027;TZ&#x0027;]
ENV[&#x0027;TZ&#x0027;] = &#x0027;Africa/Luanda&#x0027;
t = Time.now
puts t.zone
ENV[&#x0027;TZ&#x0027;] = &#x0027;Australia/Lord_Howe&#x0027;
foo = t.to_s
puts t.zone
</pre>

<p>The result changes:</p>

<pre>
WAT
LHST
</pre>

<p>This is clearly wrong. Changing the <code>$TZ</code> environment variable and stringifying the object should not change the underlying value of any of the object's attributes. The <code>Time</code> object should remember the value of the time zone when it is initialized, and should never change.</p>

<p>Unfortunately, The Ruby core developers (or at least the owner of the bug report) feel that, since <code>Time</code> relies on the system C API, and since time zones are a PITA, it's not worth it to change this behavior. The downside, however, is that you cannot rely on <code>Time</code> zones to ever be correct unless you're very, very careful.</p>

<p>Personally, in my subclass of <code>Time</code>, I took care of stashing the time zone at object instantiation as a workaround for this bug. It seemed reasonable to me, and I was just surprised that the idea was rejected by the Ruby developers.</p>

<p>What do you think?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/ruby/time_zone_bug.html">old layout</a>.</small></p>


