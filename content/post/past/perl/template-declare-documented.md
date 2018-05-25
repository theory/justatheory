--- 
date: 2009-10-30T05:09:18Z
slug: template-declare-documented
title: Template::Declare Explained
aliases: [/computers/programming/perl/modules/template-declare-documented.html]
tags: [Perl, Templating, Template::Declare, Mixins]
type: post
---

Today, [Sartak] uploaded a new version of [Template::Declare]. Why should you
care? Well, in addition to the [nice templating syntax], the new version
features *complete documentation*. For everything.

This came about because I was trying to understand Template::Declare, with its
occasional mentioning of “mixins” and “paths” and “roots,” and I just wasn’t
getting it out of the [existing documentation]. Much of my confusion stemmed
from how [Catalyst::View::Template::Declare] used Template::Declare. So I
started peppering [Jesse] with questions and offering to fill in some gaps in
the docs, and he was foolish enough to give me a commit bit.

I was particularly interested in the `import_templates` and `alias` methods.
There was no documentation, and though there were tests, the two methods were so
similar that I could barely tell the difference. I also wasn’t sure what the
point was, though I had ideas. So I asked a bunch of [questions] and, through
the discussion, I started to put the pieces together. I wrote more tests, and
started refactoring things. I'd write some code, rename things, move them
around, combine things, and then see who screamed. Jesse and Sartak were happy
to run the Jifty test suite and even, I think, some [Best Practical] internal
stuff to see what I broke. And then I'd think I got things just right and they
would punch holes in it again.

But it finally came together, I understood what the methods were trying to do,
and I documented the shit out of it. Then Sartak would copy-edit my docs,
verifying my interpretations, and help me to understand where I got things
wrong.

The new version features a glossary (useful for users of other templating
packages) and extended examples that demonstrate XUL output, postprocessing,
inheritance, and wrappers. And, most importantly, an explanation of aliasing
(think delegation) and mixins (using the new name for `import_templates`:
`mix`). I greatly appreciate the time the BPS team took to answer my noobish
questions. And their patience as I ripped things apart and built them up again.
The result is that, in addition to being better documented, the new version’s
`alias` method creates build much better-performing and less memory-intensive
aliases.

So why was I doing all this? Well, [Catalyst::View::Template::Declare] never
seemed quite right to me. And in my discussions with the Jifty guys, it seemed
clear that its use of Template::Declare was [trying to alias] kinda sorta, but
not really. So as I tried to understand aliasing, I realized that a new view
class was needed for catalyst. So I endeavored to really understand the features
of Template::Declare so that I could do it right.

More news on that soon.

The upshot is that you have pretty nice control over mixing and aliasing
Template::Declare templates into paths. For example, if you have this template
class:

``` perl
package MyApp::Templates::Util;
use base 'Template::Declare';
use Template::Declare::Tags;

template header => sub {
    my ($self, $args) = @_;
    head { title {  $args->{title} } };
};

template footer => sub {
    div {
        id is 'fineprint';
        p { 'Site contents licensed under a Creative Commons License.' }
    };
};
```

You can mix those templates into your primary template class like so:

``` perl
package MyApp::Templates::Main;
use base 'Template::Declare';
use Template::Declare::Tags;
use MyApp::Template::Util;
mix MyApp::Template::Util under '/util';

template content => sub {
    show '/util/header';
    body {
        h1 { 'Hello world' };
        show '/util/footer';
    };
};
```

See how I've used the mixed in `header` and `footer` templates by referring to
them under the `/util` path? This gives the invocation of the other templates
the feel of calling [Mason] components or invoking [Template Toolkit] templates.
You can use these templates like so:

``` perl
Template::Declare->init( dispatch_to => ['MyApp::Templates::Main'] );
print Template::Declare->show('/content');
```

So `MyApp::Templates::Main`’s templates are in the “/” directory, so to speak,
while the `MyApp::Templates::Util`’s templates are in the “/utils” subdirectory.
Pretty cool, eh?

So with this understanding in place, I had a much better feel for
Template::Declare, and could better think of it in normal templating terms. Now
I'm *this* much closer to my ideal Catalyst development environment. More soon.

  [Sartak]: http://blog.sartak.org/
  [Template::Declare]: http://search.cpan.org/perldoc?Template::Declare
    "Template::Declare on CPAN"
  [nice templating syntax]: /computers/programming/perl/xml-generation.html
    "Just a Theory: “Generating XML in Perl”"
  [existing documentation]: http://search.cpan.org/~sartak/Template-Declare-0.40/lib/Template/Declare.pm
    "Template::Declare 0.40"
  [Catalyst::View::Template::Declare]: http://search.cpan.org/perldoc?Catalyst::View::Template::Declare
    "Catalyst::View::Template::Declare on CPAN"
  [Jesse]: http://blog.fsck.com "Massively Parallel Procrastination"
  [questions]: http://lists.jifty.org/pipermail/jifty-devel/2009-September/002161.html
  [Best Practical]: http://www.bestpractical.com/
  [trying to alias]: http://lists.jifty.org/pipermail/jifty-devel/2009-September/002162.html
  [Mason]: http://search.cpan.org/perldoc?HTML::Mason " on CPAN"
  [Template Toolkit]: http://search.cpan.org/perldoc?Template
    "Template Toolkit on CPAN"
