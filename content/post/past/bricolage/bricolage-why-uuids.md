--- 
date: 2005-11-15T23:11:24Z
slug: bricolage-why-uuids
title: Why Bricolage documents have UUIDs
aliases: [/bricolage/why_uuids.html]
tags: [Bricolage, UUIDs, SQL, URI]
type: post
---

<p>Some time ago, I decided that all objects in Bricolage 2 would have <a href="https://en.wikipedia.org/wiki/Universally_Unique_Identifier" title="Universally Unique Identifier as explained by Wikipedia">Universally Unique Identifiers</a>, also known as <q>UUIDs.</q> A UUID is guaranteed to be universally unique, never to be generated again by the same or any other system now or in the future. As anyone using Bricolage knows, all stories and media already have IDs, so why have UUIDs, as well? How does their purpose differ?</p>

<p>Well, first of all, the existing IDs are not really identifiers. What they are, instead, are <a href="https://en.wikipedia.org/wiki/Primary_key" title="Primary Keys as explained by Wikipedia">primary keys</a>. However, a primary key should ideally be a <a href="https://en.wikipedia.org/wiki/Surrogate_key" title="Surrogate Keys as explained by Wikipedia">surrogate key</a>, meaning that it has <strong>no other meaning outside of identifying a single database row.</strong> Sometimes you can use an <q><a href="http://www.bcarter.com/intsurr1.htm" title="Intelligent Versus Surrogate Keys">intelligent key</a>,</q> meaning an attribute of the object being stored (such as a user login), for the primary key. But the problem with intelligent keys is that, should their values ever be changed (say a user's name changes and company login name conventions dictate that the login must be changed to represent the new name), all foreign key references will be broken. It is therefore easier, and more <em>agile,</em> to use a surrogate key with no inherent meaning to the object with which it is associated.</p>

<p>Now, once you start using an object ID that is actually a surrogate key for something other than identifying a row in a database, you <em>add new meaning</em> to it. At that point, it is no longer a surrogate. In Bricolage, this comes up when users want to use IDs for story URIs. At that point, the ID is no longer just a primary key identifying a database row, but it is also an object identifier. What happens if that identifier changes? Well, in general, it won't, so you'd be safe to use it for both purposes. But sometimes it does.</p>

<p>When? Some Bricolage users have decided to upgrade to a newer version of Bricolage by setting up the new version on a different server, exporting their data from the old server, and then importing it into the new. This can work reasonably well, but it has what may be an unintended side-effect for those who use the ID in the URI: all objects will get new primary keys when they're inserted into the new system.</p>

<p><em>What?</em> you cry! Yes, that's right. Because the ID is used solely to identify a row in a database, when you insert an existing object into a new database, it gets stored in a new row. It therefore gets a new ID, and your URIs suddenly start to 404. Ouch.</p>

<p>The solution to this problem is to give Bricolage objects a universally unique identifier that can work anywhere, that means nothing other than <q>this is a unique identifier for this object,</q> and which are guaranteed not to change when you move an object from one system to another. Happily, the UUID standard exists for just this sort of thing. You are free to use a story's UUID in its URI without having to worry about it ever changing. IDs may change, but you don't have to worry about those.</p>

<p>For these reason, the forthcoming Bricolage 1.10.0 has added UUIDs to story and media objects, these being the objects most in need of UUIDs, and they are available for use in URIs. Looking to the future, the Kinetic Platform, currently under development and the platform to which Bricolage 2.0 will be ported, never exposes the primary key IDs <em>at all</em>. There is only the UUID for referencing objects externally. I judge this a very good thing.</p>
