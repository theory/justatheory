--- 
date: 2009-11-04T14:00:00Z
slug: template-declare-wrapper
title: Create a Template::Declare Wrapper
aliases: [/computers/programming/perl/catalyst/template-declare-wrapper.html]
tags: [Perl, Catalyst, Template::Declare, MVC, Template Toolkit]
type: post
---

<p>Next in my ongoing <a href="/computers/programming/perl/catalyst%20title=" title="Just a Theory: âCatalystâ">series</a> of posts on using Catalyst with Template::Declare and DBIx::Connector, we pick up again in chapter 3 to <a href="http://search.cpan.org/perldoc?Catalyst::Manual::Tutorial::03_MoreCatalystBasics#CREATE_A_WRAPPER_FOR_THE_VIEW" title="Catalyst Tutorial - Chapter 3: More Catalyst Application Development Basics">create a wrapper for the view</a>. I added the wrapper support to <a href="http://search.cpan.org/perldoc?Template::Declare" title="Template::Declare on CPAN">Template::Declare</a> over a year ago, and while the idea is sound, the interface makes it feel like it’s bolted on. See if you agree with me.</p>

<p>Returning to the MyApp project, open <code>lib/MyApp/Templates/HTML.pm</code> and implement a wrapper like so:</p>

<pre>
use Sub::Exporter -setup => { exports => [qw(wrapper) ] };

create_wrapper wrapper => sub {
    my ($code, $c, $args) = @_;
    xml_decl { &#x27;xml&#x27;, version =&gt; &#x27;1.0&#x27; };
    outs_raw &#x27;&lt;!DOCTYPE html PUBLIC &quot;-//W3C//DTD XHTML 1.0 Strict//EN&quot; &#x27;
           . &#x27;&quot;http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd&quot;&gt;&#x27;;
    html {
        head {
            title { $args-&gt;{title} || &#x27;My Catalyst App!&#x27; };
            link {
                rel is &#x27;stylesheet&#x27;;
                href is $c-&gt;uri_for(&#x27;/static/css/main.css&#x27; );
            };

        };

        body {
            div {
                id is &#x27;header&#x27;;
                # Your logo can go here.
                img {
                    src is $c-&gt;uri_for(&#x27;/static/images/btn_88x31_powered.png&#x27;);
                };
                # Page title.
                h1 { $args-&gt;{title} || $c-&gt;config-&gt;{name} };
            }; # end header.

            div {
                id is &#x27;bodyblock&#x27;;
                div {
                    id is &#x27;menu&#x27;;
                    h3 { &#x27;Navigation&#x27; };
                    ul {
                        li {
                            a {
                                href is $c-&gt;uri_for(&#x27;/books/list&#x27;);
                                &#x27;Home&#x27;;
                            };
                        };
                        li {
                            a {
                                href is $c-&gt;uri_for(&#x27;/&#x27;);
                                title is &#x27;Catalyst Welcome Page&#x27;;
                                &#x27;Welcome&#x27;;
                            };
                        };
                    };
                }; # end menu

                div {
                    id is &#x27;content&#x27;;
                    # Status and error messages.
                    if (my $msg = $args-&gt;{status_msg}) {
                        span { class is &#x27;message&#x27;; $msg };
                    }
                    if (my $err = $args-&gt;{error_msg}) {
                        span { class is &#x27;error&#x27;; $err };
                    }

                    # Output the template contents.
                    $code-&gt;($args);
                }; # end content

            }; # end bodyblock
        };
    };
};
</pre>

<p>This looks like more work than it is because of the copious use of whitespace I've used. Personally, I find the pure Perl syntax easier to read than the mix of HTML and TT syntax in the Template Toolkit wrapper. Anyway, this is a nearly direct port of the Template Toolkit wrapper from the tutorial. Template::Declare wrappers expect at least one argument: a code reference that will output the content of the main template. You can see it used here near the end of the code, with the line <code>$code-&gt;($args)</code>.</p>

<p>Unfortunately, Template::Declare doesn’t make such wrappers easily available to templates. So we have to add the <code>Sub::Exporter</code> line at the top to export the wrapper function it creates, named <code>wrapper</code>.</p>

<p>Next, open up <code>lib/MyApp/Templates/HTML/Books.pm</code>  and edit the <code>list</code> template to take advantage of the wrapper. The new code looks like this:</p>

<pre>
use MyApp::Templates::HTML &#x27;wrapper&#x27;;

template list =&gt; sub {
    my ($self, $args) = @_;
    wrapper {
        table {
            row {
                th { &#x27;Title&#x27;  };
                th { &#x27;Rating&#x27; };
                th { &#x27;Author&#x27; };
            };
            my $sth = $args-&gt;{books};
            while (my $book = $sth-&gt;fetchrow_hashref) {
                row {
                    cell { $book-&gt;{title}  };
                    cell { $book-&gt;{rating} };
                    cell { $book-&gt;{author} };
                };
            };
        };
    } $self-&gt;c, $args;
};
</pre>


<p>First we import the <code>wrapper</code> function from MyApp::Templates::HTML, and then we simply use it to wrap the contents of our template. Note that the context object and template arguments must be passed on to the wrapper; they're not provided to the wrapper by Template::Declare. That’s something else I'd like to adjust.</p>

<p>In the meantime, contrary to the tutorial, I don’t think the template should set the title of the page. It seems to me that’s more the responsibility of the controller. So while this template could easily add a <code>title</code> key to the <code>$args</code> hash before passing it on to the wrapper, I recommend editing the <code>list</code> action in MyApp::Controller::Books instead:</p>

<pre>
sub list : Local {
    my ($self, $c) = @_;
    my $stash = $c-&gt;stash;
    $stash-&gt;{title} = &#x27;Book List&#x27;;
    $stash-&gt;{books} = $c-&gt;conn-&gt;run(fixup =&gt; sub {
        my $sth = $_-&gt;prepare(&#x27;SELECT isbn, title, rating FROM books&#x27;);
        $sth-&gt;execute;
        $sth;
    });
}
</pre>

<p>So, with the wrapper in place, let’s create the stylesheet the wrapper uses:</p>

<pre>
$ mkdir root/static/css
</pre>

<p>Then open <code>root/static/css/main.css</code> and add the following content:</p>

<pre>
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
</pre>

<p>Now restart the app as usual and reload the books list at <code>http://localhost:3000/books/list</code>. You should now see a nicely formatted page with the navigation and header stuff, as well as the book list. You can  change the CSS and the wrapper to modify the overall look of your site, and then use the wrapper in all of your page request templates to get the same look and feel across your site.</p>

<p>While this works, I'm not satisfied with the overall interface for Template::Declare wrappers. The need to explicitly export them and pass arguments is annoying. Maybe the <a href="http://jifty.org/">Jifty</a> guys have some other approach that works better. But if not, I'll likely go back to the drawing board on wrappers and see how they can be made better.</p>

<p>Next up: More database fun!</p>
