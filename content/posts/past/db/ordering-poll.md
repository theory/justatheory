--- 
date: 2006-04-20T16:36:27Z
slug: ordering-poll
title: What Name Do You Use for an Order Column?
aliases: [/computers/databases/ordering_poll.html]
tags: [databases, SQL, database]
---

<p>Quick poll.</p>

<p>Say that you have a join table mapping blog entries to tags, and you want the tags to be ordered for each entry. The table might look something like this:</p>

<pre>
CREATE TABLE entry_join_tag (
  entry_id integer REFERENCES entry(id)
                   ON UPDATE CASCADE
                   ON DELETE CASCADE,
  tag_id   integer REFERENCES tag(id)
                   ON UPDATE CASCADE
                   ON DELETE CASCADE,
  ord       smallint,
  PRIMARY KEY (entry_id, tag_id)
);
</pre>

<p>It's the <code>ord</code> column I'm talking about here, wherein to order tags for each blog entry, you'd do a select like this:</p>

<pre>
SELECT entry_id, tag_id
FROM   entry_join_tag
ORDER BY entry_id, ord;
</pre>

<p>So my question is this: What name do you typically give to the ordering column, since <q>order</q> itself isn't available in SQL (it's a reserved word, of course). Some of the options I can think of:</p>

<ul>
  <li>ord</li>
  <li>ordr</li>
  <li>seq</li>
  <li>place</li>
  <li>rank</li>
  <li>tag_ord</li>
  <li>tag_order</li>
  <li>tag_place</li>
  <li>tag_rank</li>
  <li>tag_seq</li>
</ul>

<p>Leave a comment to let me know. Thanks!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/ordering_poll.html">old layout</a>.</small></p>


