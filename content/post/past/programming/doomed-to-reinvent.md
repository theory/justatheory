--- 
date: 2009-06-03T21:15:43Z
slug: doomed-to-reinvent
title: Doomed To Reinvent
aliases: [/computers/programming/methodology/doomed-to-reinvent.html]
tags: [Programming, doom, SQL, LISP, HTML, Drupal, PHP]
type: post
---

<p>There's an old saying, “Whoever doesn't understand <em>X</em> is doomed to reinvent it.”<em>X</em> can stand for any number of things. The other day, I was pointing out that
  such is the case for <a href="/computers/databases/celko-at-yapc.html" title="Learn Mad Database Skillz at YAPC::NA 2009">ORM developers</a>. Take <a href="http://api.rubyonrails.org/classes/ActiveRecord/Base.html" title="Rails API: ActiveRecord::Base">ActiveRecord</a>, for example. As I demonstrated in a <a href="https://www.vimeo.com/4098876" title="Ruby on Rails for PostgreSQL Enthusiasts">2007 Presentation</a>, because ActiveRecord doesn't support simple things like aggregates or querying against functions or changing how objects are identified, you have to fall back on using its <code>find_by_sql()</code> method to actually run the SQL, or using <a href="/computers/programming/methodology/fuck-typing.html" title="Fuck Typing">fuck typing</a> to force ActiveRecord to do what you want. There are only two ways to get around this: Abandon the ORM and just use SQL, or keep improving the ORM until it has, in effect, reinvented SQL. Which would you choose?</p>

<p>I was thinking about this as I was hacking on a Drupal installation for a client. The design spec called for the comment form to be styled in a very specific way, with image submit buttons. Drupal has this <a href="http://api.drupal.org/api/file/developer/topics/forms_api.html/5" title="Forms API Quickstart Guide">baroque interface</a> for building forms: essentially an array of arrays. Each element of the array is a form element, unless it's markup. Or something. I can't really make heads or tails of it. What's important is that there are a limited number of form elements you can create, and as of Drupal 5, <strong><em>image</em> isn't fucking one of them!</strong>.</p>

<p>Now, as a software developer, I can understand this. I sometimes overlook a feature when implementing some code. But the trouble is: why have some bizarre data structure to represent a subset of HTML when you have something that already works: it's called <strong>HTML</strong>.  Drupal, it seems, is doomed to reinvent HTML.</p>

<p>So just as I have often had to use <code>find_by_sql()</code> as the fallback to get ActiveRecord to fetch the data I want, as opposed to what it thinks I want, I had to fallback on the Drupal form data structure's ability to accept embedded HTML like so:</p>

<pre>
$form[&#x0027;submit_stuff&#x0027;] = array(
  &#x0027;#weight&#x0027; =&gt; 20,
  &#x0027;#type&#x0027;   =&gt; &#x0027;markup&#x0027;,
  &#x0027;#value&#x0027;  =&gt; &#x0027;&lt;div class="form-submits"&gt;'
             . &#x0027;&lt;label&gt;&lt;/label&gt;&lt;p class="message"&gt;(Maximum 3000 characters)&lt;/p&gt;&#x0027;
             . &#x0027;&lt;div class="btns"&gt;&#x0027;
             . &#x0027;&lt;input type="image" value="Preview comment" name="op" src="preview.png" /&gt;&#x0027;
             . &#x0027;&lt;img width="1" height="23" src="divider.png" /&gt;&#x0027;
             . &#x0027;&lt;input type="image" value="Post comment" name="op" src="post.png" /&gt;&#x0027;
             . &#x0027;&lt;/div&gt;&lt;/div&gt;&#x0027;,
);
</pre>

<p>Dear god, <em>why?</em> I understand that you can create images using an array in Drupal 6, but I fail to understand why it was <em>ever</em> a problem. Just give me a templating environment where I can write the fucking HTML myself. Actually, Drupal already has one, it's called <em>PHP!</em>. Please don't make me deal with this weird hierarchy of arrays, it's just a bad reimplementation of a subset of HTML.</p>

<p>I expect that there actually <em>is</em> some way to get what I want, even in Drupal 5, as I'm doing some templating for comments and pages and whatnot. But that should be the default IMHO. The weird combining of code and markup into this hydra-headed data structure (and don't even get me started on the need for the <code>#weight</code> key to get things where I want them) is just <em>so</em> unnecessary.</p>

<p>In short, if it ain't broke, don't <em>reinvent it!</em></p>

<p>&lt;/rant&gt;</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/methodology/doomed-to-reinvent.html">old layout</a>.</small></p>


