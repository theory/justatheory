--- 
date: 2009-10-21T17:37:48Z
slug: dbix-connector-updated
title: DBIx::Connector Updated
aliases: [/computers/programming/perl/modules/dbix-connector-updated.html]
tags: [Perl, DBIx::Connector, DBI, database, connectivity, transactions]
---

<p>After much gnashing of teeth, heated arguments with @robkinon and @mst,
lots of deep thesaurus spelunking, and three or four iterations, I finally
came up with an an improved API
for <a href="http://search.cpan.org/perldoc?DBIx::Connector"
title="DBIx::Connector on CPAN">DBIx::Connector</a> that I believe is
straight-forward and easy to explain.</p>

<p>Following up on
my <a href="/computers/programming/perl/modules/dbix-connector-methods.html"
title="Suggest Method Names for DBIx::Connector">post</a> last week, I
explored, oh I dunno, a hundred different terms for the various methods? I've
never spent so much time
on <a href="http://www.thesaurus.com/">thesaurus.com</a> in my life. Part of
what added to the difficulty was that @mst seemed to think that there should
actually be three modes for each block method: one that pings, one that
doesn't, and one that tries again if a block dies and the connection is down.
So I went from six to nine methods with that assertion.</p>

<p>What I finally came up with was to name the three basic methods <code>run()</code>,
<code>txn_run()</code>, and <code>svp_run()</code>, and these would neither
ping nor retry in the event of failure. Then I added variations on these
methods that would ping and that would try to fix failures. I called these
“ping runs” and “fixup runs,” respectively. It was the latter term, “fixup,”
that had been so hard for me to nail down, as “retry” seemed to say that the
method was a retry, while “fixup” more accurately reflects that the method
would try to fix up the connection in the event of a failure.</p>

<p>Once I'd implemented this interface, I now had nine methods:</p>

<ul>
  <li><code>run()</code></li>
  <li><code>txn_run()</code></li>
  <li><code>svp_run()</code></li>
  <li><code>ping_run()</code></li>
  <li><code>txn_ping_run()</code></li>
  <li><code>svp_ping_run()</code></li>
  <li><code>fixup_run()</code></li>
  <li><code>txn_fixup_run()</code></li>
  <li><code>svp_fixup_run()</code></li>
</ul>

<p>This worked great. Then I went about documenting it. Jesus Christ what a
pain! I realized that all these similarly-named methods would require a lot of
explanation. I duly wrote up said explanation, and just wasn't happy with it.
It just felt to me like all the explanation made it too difficult to decide
what methods to use and when. Such confusion would make the module less likely
to be used -- and certainly less likely to be used efficiently.</p>

<p>So I went back to the API drawing board and, reflecting on @robkinyon's
browbeating about decorating methods and @mst's coming to that conclusion as
well, I finally came up with just three methods:</p>

<ul>
  <li><code>run()</code></li>
  <li><code>txn()</code></li>
  <li><code>svp()</code></li>
</ul>

<p>For any one of these, you can call it by passing a block, of course:</p>

<pre>
$conn-&gt;txn( sub { $_->do(&#x0027;SELECT some_function()&#x0027;) } );
</pre>

<p>In addition, you can now have any one of them run in one of three
modes: the default (no ping), “ping”, or “fixup”:</p>

<pre>
$conn-&gt;txn( fixup => sub { $_->do(&#x0027;SELECT some_function()&#x0027;) } );
</pre>

<p>It's <em>much</em> easier to explain the three methods in terms of how the
block is transactionally encapsulated, as that's the only difference between
them. Once that's understood, it's pretty easy to explain how to change the
“connection mode” of each by passing in a leading string. It even looks pretty
nice. I'm really happy with this</p>

<p>One thing that increased the difficulty in coming up with this API was that
@mst felt that by default the methods should neither ping nor try to fix up a
failure. I was resistant to this because it's not
how <a href="http://search.cpan.org/perldoc?Apache::DBI"
title="Apache::DBI on CPAN">Apache::DBI</a> or
<a href="http://search.cpan.org/perldoc?DBI#connect_cached"
title="DBI on CPAN"><code>connect_cached()</code></a> work: they always ping.
It turns out that <a href="http://search.cpan.org/perldoc?DBIx::Class"
title="DBIx::Class on CPAN">DBIx::Class</a> doesn't cache connections
at all. I thought it had. Rather, it creates a connection and simply hangs
onto it as a scalar variable. It handles the connection for as long as it's in
scope, but includes no magic global caching. This reduces the action-at-a-distance
issues common with caching while maintaining proper <code>fork</code>- and
thread-safety.</p>

<p>At this point, I took a baseball bat to my desk.</p>

<p>Figuratively, anyway. I did at least unleash a mountain of curses upon @mst
and various family relations. Because it took me a few minutes to see it: It
turns out that DBIx::Class is right to do it this way. So I ripped out the
global caching from DBIx::Connector, and suddenly it made much more sense not
to ping by default -- just as you wouldn't ping if you created a DBI handle
yourself.</p>

<p>DBIx::Connector is no longer a caching layer over the DBI. It's now
a <em>proxy</em> for a connection. That's it. There is no magic, no implicit
behavior, so it's easier to use. And because it ensures <code>fork</code>- and
thread-safety, you can instantiate a connector and hold onto it for whenever
you need it, unlike using the DBI itself.</p>

<p>And one more thing: I also added a new method, <code>with()</code>. For
those who always want to use the same connection mode, you can use this method
to create a proxy object that has a different default mode. (Yes, a proxy for
a proxy for a database handle. Whatever!) Use it like this:</p>

<pre>
$conn-&gt;with(&#x0027;fixup&#x0027;)-&gt;run( sub { ... } );
</pre>

<p>And if you always want to use the same mode, hold onto the proxy instead of
the connection object:</p>

<pre>
my $proxy = DBIx::Connector-&gt;(@args)->with(&#x0027;fixup&#x0027;);

# later ...
$proxy-&gt;txn( sub { ... } ); # always in fixup mode
</pre>

<p>So while fixup mode is no longer the default,
as <a href="https://rt.cpan.org/Ticket/Display.html?id=47005"
title="RT #47005: txn_do should provide a way to disable retry">Tim
requested</a>, but it can optionally be made the default, as DBIx::Class
requires. The <code>with()</code> method will also be the place to add other
global behavioral modifications, such as
DBIx::Class's <code>auto_savepoint</code> feature.</p>

<p>So for those of you who were interested in the first iteration of this
module, my apologies for changing things so dramatically in this release
(ripping out the global caching, deprecating methods, adding a new block
method API, etc.). But I think that, for all the pain I went through to come
up with the new API -- all the arguing on IRC, all the thesaurus spelunking --
that this is a really good API, easy to explain and understand, and easy to
use. And I don't expect to change it again. I might improve exceptions (use
objects instead of strings?) add block method exception handling (perhaps
adding a <code>catch</code> keyword?), but the basics are finally nailed down
and here to stay.</p>

<p>Thanks to @mst, @robkinyon, and @ribasushi, in particular, for bearing with
me and continuing to hammer on me when I was being dense.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/dbix-connector-updated.html">old layout</a>.</small></p>


