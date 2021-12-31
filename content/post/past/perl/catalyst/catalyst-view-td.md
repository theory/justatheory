--- 
date: 2009-11-02T14:00:00Z
slug: catalyst-view-td
title: Create Catalyst Views with Template::Declare
aliases: [/computers/programming/perl/catalyst/catalyst-view-td.html]
tags: [Perl, Catalyst, Template::Declare, Templating, MVC]
type: post
---

Following up on last week’s [release] of [Template::Declare] 0.41, this week I'm
pleased to announce the release of a new [Catalyst] view class,
[Catalyst::View::TD].

Yes, I'm aware of [Catalyst::View::Template::Declare]. As I [mentioned][release]
last week, it doesn’t make very good use of Template::Declare. I don’t blame
[jrock] for that, though; Template::Declare had very poor documentation before
0.41. But now that it is properly documented and I have a pretty solid grasp of
how it works, I wanted to create a new Catalyst View that could take proper
advantage of its features.

If you're a Catalyst developer, chances are that you currently use [Template
Toolkit] or [Mason] for your templating needs. So why should you consider
[Catalyst::View::TD] for your next project? How about:

-   Feature-parity with [Catalyst::View::TT], the view class for Template
    Toolkit
-   Includes a `myapp_create.pl` helper for creating new template classes.
-   Intuitive, easy-to-use HTML and XML templating in Perl
-   All templates loaded at server startup time (great for forking servers like
    mod\_perl)
-   Template paths that correspond to Controller URIs.

If you weren’t convinced by the first three points, that forth one is the
killer. It’s the reason I wrote a new view. But here’s an even better reason:
I'm going to show you exactly how to use it, right here in this blog post.

### A Simple Hello

I'm borrowing from [chapter 3] of the Catalyst tutorial. First, create a new
app:

    $ catalyst.pl MyApp
    cd MyApp

Then update the list of plugins in `MyApp.pm`:

```perl
use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    StackTrace
/;
```
Now create a controller:

    $ script/myapp_create.pl controller Books

Then edit it and add this controller (see [chapter 3] if you need explanation
about what this does):

```perl
sub list : Local {
    my ($self, $c) = @_;
    $c->stash->{books} = [];
    $c->stash->{template} = '/books/list';
}
```

And now, create a view and a new template class:

    $ script/myapp_create.pl view HTML TD
    $ script/myapp_create.pl TDClass HTML::Books

Open `lib/MyApp/Templates/HTML/Books.pm` and add the `list` template:

```perl
my ($self, $args) = @_;
table {
    row {
        th { 'Title'  };
        th { 'Rating' };
        th { 'Author' };
    };
    for my $book (@{ $args->{books} }) {
        row {
            cell { $book->{title}  };
            cell { $book->{rating} };
            cell { $book->{author} };
        };
    }
};
```

Then point your browser to http://localhost:3000/books/list. If you have
everything working so far, you should see a web page that displays nothing other
than our column headers for “Title”, “Rating”, and “Author(s)” — we won’t see
any books until we get the database and model working below.

### A Few Comments

The first thing I want to draw your attention to in this example is that `list`
template. Isn’t it a thing of beauty? It’s so easy for Perl hackers to read.
Compare it to the TT example from the tutorial (with the comments removed, just
to be fair):

``` html
<tr><th>Title</th><th>Rating</th><th>Author(s)</th></tr>
[% FOREACH book IN books -%]
    <tr>
    <td>[% book.title %]</td>
    <td>[% book.rating %]</td>
    <td></td>
    </tr>
[% END -%]
</table>
```

I mean, which would *you* rather have to maintain? And this is an extremely
simple example. The comparison only becomes more stark when the HTML becomes
more complex.

The other thing I want to point out is the name of the template class we
created, `MyApp::Template::HTML::Books` and its template, `list`. They
correspond perfectly with the controller, `MyApp::Controller::Books`, and its
action `list`. See the parity there? The URI for the action is `/books/list`,
and the template path, by coincidence is also `/books/list`. Nice, huh? Thanks
to this parity, you can even remove the template specification in the
controller, since by default Catalyst will render a template with the same name
as the action:

```perl
sub list : Local {
    my ($self, $c) = @_;
    $c->stash->{books} = [];
}
```

This is the primary way in which [Catalyst::View::TD] differs from its
[predecessor][Catalyst::View::Template::Declare]. Whereas the latter would load
all of the modules under the view’s namespace and shove all of their templates
into root path, the former imports templates under paths that correspond to
their class names. Hence the match with controller names.

### Stay Tuned

It was kind of fun to subvert the Catalyst tutorial for my nefarious purposes.
Maybe I'll keep it up with more blog posts in the coming weeks that continues to
do so. Not only will it let me show off how nice Template::Declare templates can
be, but it will let me continue my rant against ORMs as well. Stay tuned.

  [release]: /computers/programming/perl/modules/template-declare-documented.html
    "Template Declare Explained"
  [Template::Declare]: https://metacpan.org/pod/Template::Declare
    "Template::Declare on CPAN"
  [Catalyst]: http://www.catalystframework.org/
  [Catalyst::View::TD]: https://metacpan.org/pod/Catalyst::View::TD
    "Catalyst::View::TD on CPAN"
  [Catalyst::View::Template::Declare]: https://metacpan.org/pod/Catalyst::View::Template::Declare
  [jrock]: http://blog.jrock.us/
  [Template Toolkit]: https://metacpan.org/pod/Template
    "Template Toolkit on CPAN"
  [Mason]: https://metacpan.org/pod/HTML::Mason "Mason on CPAN"
  [Catalyst::View::TT]: https://metacpan.org/pod/Catalyst::View::TT
    "Catalyst::View::TT"
  [chapter 3]: https://metacpan.org/pod/Catalyst::Manual::Tutorial::03_MoreCatalystBasics
    "Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics"
