--- 
date: 2009-06-03T21:15:43Z
slug: doomed-to-reinvent
title: Doomed To Reinvent
aliases: [/computers/programming/methodology/doomed-to-reinvent.html]
tags: [Programming, Doom, SQL, LISP, HTML, Drupal, PHP]
type: post
---

There's an old saying, “Whoever doesn't understand *X* is doomed to reinvent
it.”*X* can stand for any number of things. The other day, I was pointing out
that such is the case for [ORM developers]. Take [ActiveRecord], for example. As
I demonstrated in a [2007 Presentation], because ActiveRecord doesn't support
simple things like aggregates or querying against functions or changing how
objects are identified, you have to fall back on using its `find_by_sql()`
method to actually run the SQL, or using [fuck typing] to force ActiveRecord to
do what you want. There are only two ways to get around this: Abandon the ORM
and just use SQL, or keep improving the ORM until it has, in effect, reinvented
SQL. Which would you choose?

I was thinking about this as I was hacking on a Drupal installation for a
client. The design spec called for the comment form to be styled in a very
specific way, with image submit buttons. Drupal has this [baroque interface] for
building forms: essentially an array of arrays. Each element of the array is a
form element, unless it's markup. Or something. I can't really make heads or
tails of it. What's important is that there are a limited number of form
elements you can create, and as of Drupal 5, ***image* isn't fucking one of
them!**.

Now, as a software developer, I can understand this. I sometimes overlook a
feature when implementing some code. But the trouble is: why have some bizarre
data structure to represent a subset of HTML when you have something that
already works: it's called **HTML**. Drupal, it seems, is doomed to reinvent
HTML.

So just as I have often had to use `find_by_sql()` as the fallback to get
ActiveRecord to fetch the data I want, as opposed to what it thinks I want, I
had to fallback on the Drupal form data structure's ability to accept embedded
HTML like so:

``` ruby
$form['submit_stuff'] = array(
  '#weight' => 20,
  '#type'   => 'markup',
  '#value'  => '<div class="form-submits">'
              . '<label></label><p class="message">(Maximum 3000 characters)</p>'
              . '<div class="btns">'
              . '<input type="image" value="Preview comment" name="op" src="preview.png" />'
              . '<img width="1" height="23" src="divider.png" />'
              . '<input type="image" value="Post comment" name="op" src="post.png" />'
              . '</div></div>',
);
```

Dear god, *why?* I understand that you can create images using an array in
Drupal 6, but I fail to understand why it was *ever* a problem. Just give me a
templating environment where I can write the fucking HTML myself. Actually,
Drupal already has one, it's called *PHP!*. Please don't make me deal with this
weird hierarchy of arrays, it's just a bad reimplementation of a subset of HTML.

I expect that there actually *is* some way to get what I want, even in Drupal 5,
as I'm doing some templating for comments and pages and whatnot. But that should
be the default IMHO. The weird combining of code and markup into this
hydra-headed data structure (and don't even get me started on the need for the
`#weight` key to get things where I want them) is just *so* unnecessary.

In short, if it ain't broke, don't *reinvent it!*

\</rant\>

  [ORM developers]: {{% ref "/post/past/db/celko-at-yapc" %}}
    "Learn Mad Database Skillz at YAPC::NA 2009"
  [ActiveRecord]: https://api.rubyonrails.org/classes/ActiveRecord/Base.html
    "Rails API: ActiveRecord::Base"
  [2007 Presentation]: https://vimeo.com/4098876
    "Ruby on Rails for PostgreSQL Enthusiasts"
  [fuck typing]: {{% ref "/post/past/programming/fuck-typing" %}}
    "Fuck Typing"
  [baroque interface]: https://api.drupal.org/api/drupal/developer%21topics%21forms_api.html/5.x
    "Forms API Quickstart Guide"
