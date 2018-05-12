--- 
date: 2005-11-15T06:00:37Z
slug: bricolage-permissions-design
title: TKP Permissions Design
aliases: [/bricolage/permissions_design.html]
tags: [Bricolage, TKP, Kineticode]
type: post
---

<p>So, I'm thinking of implementing permissions in the Kinetic Platform differently than they're implemented in Bricolage. Bricolage has a number of fixed permissions: READ, EDIT, RECALL, CREATE, PUBLISH, and DENY. These permissions are cumulative, so that if you have EDIT permission, it implies READ, and if you have CREATE, it implies RECALL, EDIT, and READ.</p>

<p>This design was based on Windows NT permissions (roughly), and has worked reasonably, well, but is annoying for various reasons. The most serious drawback is that it's difficult to understand. I always tell people who need to manage Bricolage permissions to read <a href="http://www.bricolage.cc/docs/current/api/Bric::Security" title="Read the Bric::Security documentation on the Bricolage site">Bric::Security</a>, and then read six more times. But aside from the impenetrability of the current permissions design, it's also difficult to add new permissions: where should they fit into the hierarchy? This is what happened with RECALL and PUBLISH, which were added in a later version of Bricolage. To this day, it's a bit confusing to some that, with RECALL permission, you can RECALL a story but not CREATE one.</p>

<p>So I'm looking around for other permissions patterns. Unix is nice, in that READ, WRITE, and EXECUTE permissions are all entirely independent, and apply to three classes of objects (file owner, file group, everyone). But Unix only needs to worry about files; Kinetic applications will have many more objects  for which permissions will need to be specified. <a href="http://www.bestpractical.com/rt/" title="RT Request Tracker">RT</a> uses discreet permissions with names like <q>AdminQueue</q>, <q>CommentOnTicket</q>, <q>CreateTicket</q>, and <q>StealTicket</q> to be applied to every user or group. This strikes me as somewhat more useful, since the permissions are much more descriptive and can be targeted to particular objects. In fact, the permission names even indicate to what types of objects permissions apply!</p>

<p>So I'm thinking of leaving the cumulative permissions model behind and switching to more descriptive, discreet, and potentially numerous permissions. I'm not, however particularly fond of RT's approach of storing the permissions as strings in the database. Now, I could keep them as numbers, where each permission has its own unique number. This is similar to how Bricolage permissions work. Only I'd have to always use <a href="http://search.cpan.org/dist/List-MoreUtils/" title="List::MoreUtils on CPAN">List::MoreUtil</a>'s <code>any()</code> function to see if a permission was in a list.</p>

<p>For example, say that an object had permissions with the numbers 1, 2, 5, 8, 12, 49, and 50. If these were stored in an array, then every time I had to check permissions, the <code>can_do()</code> function would have to search through those numbers:</p>

<pre>
sub can_do {
    my ($self, $to_check) = @_;
    my $perms = $self->perms;
    return any { $_ == $to_check } @$perms;
}
</pre>

<p>This isn't the most efficient approach, unfortunately. If there are a lot of numbers, and you were always checking one that was towards the end of the list of permissions, it'd always take a long time. So, an alternate approach--one that conveniently works well with discreet permissions--is to use powers of two for the permissions numbers: 1, 2, 4, 8, 16, 32, 64, 128, 256, and so on. Then, for a given object, these can just be stored in a single number that's created by bit-wise <code>OR</code>ing them together: <code>1 | 2 | 8 | 16</code>. Fortunately, PostgreSQL has a nice <a href="http://www.postgresql.org/docs/current/interactive/functions-aggregate.html" title="PostgreSQL Aggregate Functions">aggregate function</a> for this, <code>bit_or()</code>. (I'll have to <a href="/computers/databases/sqlite/custom_perl_aggregates.html" title="SQLite Custom Aggregates in Perl">create my own</a> for SQLite.) Anyway, then the <code>can_do()</code> function becomes much simpler and more efficient:</p>

<pre>
sub can_do {
    my ($self, $to_check) = @_;
    return $self->perms &amp; $to_check;
}
</pre>

<p>If the value of <code>$to_check</code> was in the list bit-<code>OR</code>ed into their permissions number, it will be returned; otherwise, 0 will be returned. Not bad, eh?</p>

<p>So anyway, I'm soliciting feedback. Are discreet permissions better than cumulative permissions? And if so, are bit-wise <code>OR</code>ed numbers the best way to represent an object ACLs?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/permissions_design.html">old layout</a>.</small></p>


