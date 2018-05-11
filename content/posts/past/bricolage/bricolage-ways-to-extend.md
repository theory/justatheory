--- 
date: 2004-06-03T01:22:00Z
slug: bricolage-ways-to-extend
title: How to Extend Bricolage 2.0
aliases: [/bricolage/design/ways_to_extend.html]
tags: [Bricolage, work]
---

<p>Going through the latest version of the Bricolage 2.0 technical specification, I can see at least six ways that developers will easily be able to extend Bricolage:</p>

<dl>
  <dt>Write a new task by subclassing Bricolage::Biz::Task</dt>
  <dd>A task can be designed to do just about anything to a single Bricolage object. Hell, you'd be able to look up other objects, too, so anything's possible. Tasks are run by scheduled jobs, event-triggered actions, or by distribution jobs.</dd>
  <dt>Create a new data type by subclassing Bricolage::Biz::Value and Bricolage::Biz::Type::Value</dt>
  <dd>We'll support quite a few different value types to start with, but we couldn't anticipate everything, so this'll be your chance!</dd>
  <dt>Create a new UI widget by subclassing Bricolage::Widget and Bricolage::Biz::Type::Widget</dt>
  <dd>Maybe your new value requires its own special widget. Or maybe you don't like the way the existing widgets handle other types of values. So write your own!</dd>
  <dt>Write a new distribution mover by subclassing Bricolage::Biz::Dist::Mover</dt>
  <dd>We'll start out with file system copy, SFTP, SFTP, and WebDAV distribution movers just as we have in Bricolage 1.8, but there's always room for more!</dd>
  <dt>Write a new authentication plugin by subclassing Bricolage::Util::Auth</dt>
  <dd>The built-in and LDAP-based authentication systems aren't doing it for you? You want to authenticate against a different database? Make it so!</dd>
  <dt>Write a new storage back-end by subclassing Bricolage::Store</dt>
  <dd>We'll have a PostgreSQL back-end from the start, and perhaps SQLite and/or MySQL. But here's your chance to get Bricolage running on FileMaker Pro just as you've always secretly desired!</dd>
</dl>

<p>So have fun with it! When it gets here. Want to help get get here? Subscribe to <a href="http://lists.sourceforge.net/mailman/listinfo/bricolage-devel">Bricolage-Devel</a> and chip in!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/design/ways_to_extend.html">old layout</a>.</small></p>


