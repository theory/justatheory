--- 
date: 2009-11-04T14:00:00Z
slug: catalyst-template-declare-wrapper
title: Create a Template::Declare Wrapper
aliases: [/computers/programming/perl/catalyst/template-declare-wrapper.html]
tags: [Perl, Catalyst, Template::Declare, MVC, Template Toolkit]
type: post
---

Next in my ongoing [series] of posts on using Catalyst with Template::Declare
and DBIx::Connector, we pick up again in chapter 3 to [create a wrapper for the
view]. I added the wrapper support to [Template::Declare] over a year ago, and
while the idea is sound, the interface makes it feel like it’s bolted on. See if
you agree with me.

Returning to the MyApp project, open `lib/MyApp/Templates/HTML.pm` and implement
a wrapper like so:

```perl
use Sub::Exporter -setup => { exports => [qw(wrapper) ] };

create_wrapper wrapper => sub {
    my ($code, $c, $args) = @_;
    xml_decl { 'xml', version => '1.0' };
    outs_raw '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" '
            . '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">';
    html {
        head {
            title { $args->{title} || 'My Catalyst App!' };
            link {
                rel is 'stylesheet';
                href is $c->uri_for('/static/css/main.css' );
            };

        };

        body {
            div {
                id is 'header';
                # Your logo can go here.
                img {
                    src is $c->uri_for('/static/images/btn_88x31_powered.png');
                };
                # Page title.
                h1 { $args->{title} || $c->config->{name} };
            }; # end header.

            div {
                id is 'bodyblock';
                div {
                    id is 'menu';
                    h3 { 'Navigation' };
                    ul {
                        li {
                            a {
                                href is $c->uri_for('/books/list');
                                'Home';
                            };
                        };
                        li {
                            a {
                                href is $c->uri_for('/');
                                title is 'Catalyst Welcome Page';
                                'Welcome';
                            };
                        };
                    };
                }; # end menu

                div {
                    id is 'content';
                    # Status and error messages.
                    if (my $msg = $args->{status_msg}) {
                        span { class is 'message'; $msg };
                    }
                    if (my $err = $args->{error_msg}) {
                        span { class is 'error'; $err };
                    }

                    # Output the template contents.
                    $code->($args);
                }; # end content

            }; # end bodyblock
        };
    };
};
```

This looks like more work than it is because of the copious use of whitespace
I've used. Personally, I find the pure Perl syntax easier to read than the mix
of HTML and TT syntax in the Template Toolkit wrapper. Anyway, this is a nearly
direct port of the Template Toolkit wrapper from the tutorial. Template::Declare
wrappers expect at least one argument: a code reference that will output the
content of the main template. You can see it used here near the end of the code,
with the line `$code->($args)`.

Unfortunately, Template::Declare doesn’t make such wrappers easily available to
templates. So we have to add the `Sub::Exporter` line at the top to export the
wrapper function it creates, named `wrapper`.

Next, open up `lib/MyApp/Templates/HTML/Books.pm` and edit the `list` template
to take advantage of the wrapper. The new code looks like this:

```perl
use MyApp::Templates::HTML 'wrapper';

template list => sub {
    my ($self, $args) = @_;
    wrapper {
        table {
            row {
                th { 'Title'  };
                th { 'Rating' };
                th { 'Author' };
            };
            my $sth = $args->{books};
            while (my $book = $sth->fetchrow_hashref) {
                row {
                    cell { $book->{title}  };
                    cell { $book->{rating} };
                    cell { $book->{author} };
                };
            };
        };
    } $self->c, $args;
};
```

First we import the `wrapper` function from MyApp::Templates::HTML, and then we
simply use it to wrap the contents of our template. Note that the context object
and template arguments must be passed on to the wrapper; they're not provided to
the wrapper by Template::Declare. That’s something else I'd like to adjust.

In the meantime, contrary to the tutorial, I don’t think the template should set
the title of the page. It seems to me that’s more the responsibility of the
controller. So while this template could easily add a `title` key to the `$args`
hash before passing it on to the wrapper, I recommend editing the `list` action
in MyApp::Controller::Books instead:

```perl
sub list : Local {
    my ($self, $c) = @_;
    my $stash = $c->stash;
    $stash->{title} = 'Book List';
    $stash->{books} = $c->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT isbn, title, rating FROM books');
        $sth->execute;
        $sth;
    });
}
```

So, with the wrapper in place, let’s create the stylesheet the wrapper uses:

    $ mkdir root/static/css

Then open `root/static/css/main.css` and add the following content:

``` css
#header {
    text-align: center;
}
#header h1 {
    margin: 0;
}
#header img {
    float: right;
}
#footer {
    text-align: center;
    font-style: italic;
    padding-top: 20px;
}
#menu {
    font-weight: bold;
    background-color: #ddd;
    float: left;
    padding: 0 0 50% 5px;
}
#menu ul {
    margin: 0;
    padding: 0;
    list-style: none;
    font-weight: normal;
    background-color: #ddd;
    width: 100px;
}
#content {
    margin-left: 120px;
}
.message {
    color: #390;
}
.error {
    color: #f00;
}
```

Now restart the app as usual and reload the books list at
`http://localhost:3000/books/list`. You should now see a nicely formatted page
with the navigation and header stuff, as well as the book list. You can change
the CSS and the wrapper to modify the overall look of your site, and then use
the wrapper in all of your page request templates to get the same look and feel
across your site.

While this works, I'm not satisfied with the overall interface for
Template::Declare wrappers. The need to explicitly export them and pass
arguments is annoying. Maybe the [Jifty] guys have some other approach that
works better. But if not, I'll likely go back to the drawing board on wrappers
and see how they can be made better.

Next up: More database fun!

  [series]: /tags/catalyst/ "Just a Theory: “Catalyst”"
  [create a wrapper for the view]: https://metacpan.org/pod/Catalyst::Manual::Tutorial::03_MoreCatalystBasics#CREATE_A_WRAPPER_FOR_THE_VIEW
    "Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics"
  [Template::Declare]: https://metacpan.org/pod/Template::Declare
    "Template::Declare on CPAN"
  [Jifty]: http://jifty.org/
