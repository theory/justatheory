--- 
date: 2009-11-02T14:00:00Z
slug: catalyst-view-td
title: Create Catalyst Views with Template::Declare
aliases: [/computers/programming/perl/catalyst/catalyst-view-td.html]
tags: [Perl, Catalyst, Template::Declare, templating, MVC]
type: post
---

<p>Following up on last week’s
<a href="/computers/programming/perl/modules/template-declare-documented.html" title="Template Declare Explained">release</a> of
<a href="http://search.cpan.org/perldoc?Template::Declare" title="Template::Declare on CPAN">Template::Declare</a>
0.41, this week I'm pleased to announce the release of a new
<a href="http://www.catalystframework.org/">Catalyst</a> view class,
<a href="http://search.cpan.org/perldoc?Catalyst::View::TD" title="Catalyst::View::TD on CPAN">Catalyst::View::TD</a>.</p>

<p>Yes, I'm aware of
<a href="http://search.cpan.org/perldoc?Catalyst::View::Template::Declare">Catalyst::View::Template::Declare</a>.
As I <a href="/computers/programming/perl/modules/template-declare-documented.html" title="Template Declare Explained">mentioned</a>
last week, it doesn’t make very good use of Template::Declare. I don’t blame
<a href="http://blog.jrock.us/">jrock</a> for that, though; Template::Declare had very
poor documentation before 0.41. But now that it is properly documented and I
have a pretty solid grasp of how it works, I wanted to create a new Catalyst
View that could take proper advantage of its features.</p>

<p>If you're a Catalyst developer, chances are that you currently use
<a href="http://search.cpan.org/perldoc?Template" title="Template Toolkit on CPAN">Template Toolkit</a>
or <a href="http://search.cpan.org/perldoc?HTML::Mason" title="Mason on CPAN">Mason</a>
for your templating needs. So why should you consider
<a href="http://search.cpan.org/perldoc?Catalyst::View::TD" title="Catalyst::View::TD on CPAN">Catalyst::View::TD</a>
for your next project? How about:</p>

<ul>
<li>Feature-parity with <a href="http://search.cpan.org/perldoc?Catalyst::View::TT" title="Catalyst::View::TT">Catalyst::View::TT</a>, the view class for Template Toolkit</li>
<li>Includes a <code>myapp_create.pl</code> helper for creating new template classes.</li>
<li>Intuitive, easy-to-use HTML and XML templating in Perl</li>
<li>All templates loaded at server startup time (great for forking servers like mod_perl)</li>
<li>Template paths that correspond to Controller URIs.</li>
</ul>


<p>If you weren’t convinced by the first three points, that forth one is the
killer. It’s the reason I wrote a new view. But here’s an even better reason:
I'm going to show you exactly how to use it, right here in this blog post.</p>

<h3>A Simple Hello</h3>

<p>I'm borrowing from
<a href="http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics" title="Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics">chapter 3</a>
of the Catalyst tutorial. First, create a new app:</p>

<pre>
$ catalyst.pl MyApp
cd MyApp
</pre>

<p>Then update the list of plugins in <code>MyApp.pm</code>:</p>

<pre>
use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    StackTrace
/;
</pre>

<p>Now create a controller:</p>

<pre>
$ script/myapp_create.pl controller Books
</pre>

<p>Then edit it and add this controller (see
<a href="http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics" title="Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics">chapter 3</a>
if you need explanation about what this does):</p>

<pre>
sub list : Local {
    my ($self, $c) = @_;
    $c-&gt;stash-&gt;{books} = [];
    $c-&gt;stash-&gt;{template} = &#x27;/books/list&#x27;;
}
</pre>

<p>And now, create a view and a new template class:</p>

<pre>
$ script/myapp_create.pl view HTML TD
$ script/myapp_create.pl TDClass HTML::Books
</pre>

<p>Open <code>lib/MyApp/Templates/HTML/Books.pm</code> and add the <code>list</code> template:</p>

<pre>
my ($self, $args) = @_;
table {
    row {
        th { &#x27;Title&#x27;  };
        th { &#x27;Rating&#x27; };
        th { &#x27;Author&#x27; };
    };
    for my $book (@{ $args-&gt;{books} }) {
        row {
            cell { $book-&gt;{title}  };
            cell { $book-&gt;{rating} };
            cell { $book-&gt;{author} };
        };
    }
};
</pre>


<p>Then point your browser to http://localhost:3000/books/list. If you have
everything working so far, you should see a web page that displays nothing
other than our column headers for “Title”, “Rating”, and “Author(s)” — we
won’t see any books until we get the database and model working below.</p>

<h3>A Few Comments</h3>

<p>The first thing I want to draw your attention to in this example is that
<code>list</code> template. Isn’t it a thing of beauty? It’s so easy for Perl hackers to
read. Compare it to the TT example from the tutorial (with the comments
removed, just to be fair):</p>

<pre>
&lt;tr&gt;&lt;th&gt;Title&lt;/th&gt;&lt;th&gt;Rating&lt;/th&gt;&lt;th&gt;Author(s)&lt;/th&gt;&lt;/tr&gt;
[% FOREACH book IN books -%]
  &lt;tr&gt;
    &lt;td&gt;[% book.title %]&lt;/td&gt;
    &lt;td&gt;[% book.rating %]&lt;/td&gt;
    &lt;td&gt;&lt;/td&gt;
  &lt;/tr&gt;
[% END -%]
&lt;/table&gt;
</pre>

<p>I mean, which would <em>you</em> rather have to maintain? And this is an extremely
simple example. The comparison only becomes more stark when the HTML becomes
more complex.</p>

<p>The other thing I want to point out is the name of the template
class we created, <code>MyApp::Template::HTML::Books</code> and its
template, <code>list</code>. They correspond perfectly with the
controller, <code>MyApp::Controller::Books</code>, and its action
<code>list</code>. See the parity there? The URI for the action is
<code>/books/list</code>, and the template path, by coincidence is
also <code>/books/list</code>. Nice, huh? Thanks to this parity, you
can even remove the template specification in the controller, since by
default Catalyst will render a template with the same name as the
action:</p>

<pre>
sub list : Local {
    my ($self, $c) = @_;
    $c-&gt;stash-&gt;{books} = [];
}
</pre>

<p>This is the primary way in which
<a href="http://search.cpan.org/perldoc?Catalyst::View::TD" title="Catalyst::View::TD on CPAN">Catalyst::View::TD</a>
differs from its
<a href="http://search.cpan.org/perldoc?Catalyst::View::Template::Declare">predecessor</a>.
Whereas the latter would load all of the modules under the view’s namespace
and shove all of their templates into root path, the former imports templates
under paths that correspond to their class names. Hence the match with
controller names.</p>

<h3>Stay Tuned</h3>

<p>It was kind of fun to subvert the Catalyst tutorial for my nefarious purposes.
Maybe I'll keep it up with more blog posts in the coming weeks that continues
to do so. Not only will it let me show off how nice Template::Declare
templates can be, but it will let me continue my rant against ORMs as well.
Stay tuned.</p>
