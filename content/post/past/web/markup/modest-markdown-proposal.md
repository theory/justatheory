--- 
date: 2009-02-18T18:22:48Z
slug: modest-markdown-proposal
title: A Modest Proposal for Markdown Definition Lists
aliases: [/computers/markup/modest-markdown-proposal.html]
tags: [Web, Markdown, markup]
type: post
---

I realize that greater minds than mind have likely given a lot of thought to how
best to implement a “natural” syntax for definition lists in [Markdown]. The
best I’ve seen, however, is that implemented by [PHP Markdown Extra], which is
also supported by [MultiMarkdown]. Given the prevalence of these two libraries,
I’m assuming that the syntax become the de-facto standard for definition lists
in Markdown. But, to my mind at least, it leaves something to be desired. Here’s
an extended example, taken from the PHP Markdown Extra documentation, including
multiple definitions, multiple paragraphs, and nested formatting (lists, code
block):

    Term 1

      : This is a definition with two paragraphs. Lorem ipsum 
        dolor sit amet, consectetuer adipiscing elit. Aliquam 
        hendrerit mi posuere lectus.

        Vestibulum enim wisi, viverra nec, fringilla in, laoreet
        vitae, risus.

      : Second definition for term 1, also wrapped in a paragraph
        because of the blank line preceding it.

    Term 2

      : This definition has a code block, a blockquote and a list.

            code block.

        > block quote
        > on two lines.

        1.  first list item
        2.  second list item

This format has a lot going for it, in that it covers most of the requirements
for definition lists. In particular, it allows a term to have multiple
definitions, or for multiple terms to share a definition, and for a definition
to have multiple paragraphs, nested lists, code blocks, and other formatting.
There’s only one problem with it, as far as I’m concerned: I would *never* write
a definition list like this in an email.

I started thinking about alternates, first by thinking about how I *would* write
a definition list in plain text. It would likely be something like this:

    Term 1
    &#xz002d;&#xz002d;&#xz002d;&#xz002d;&#xz002d;&#xz002d;
      This is a definition with two paragraphs. Lorem ipsum 
      dolor sit amet, consectetuer adipiscing elit. Aliquam 
      hendrerit mi posuere lectus.

      Vestibulum enim wisi, viverra nec, fringilla in, laoreet
      vitae, risus.

      Second definition for term 1, also wrapped in a paragraph
      because of the blank line preceding it.

    Term 2
    &#xz002d;&#xz002d;&#xz002d;&#xz002d;&#xz002d;&#xz002d;
      This definition has a code block, a blockquote and a list.

          code block.

      > block quote
      > on two lines.

      1.  first list item
      2.  second list item

This is much more like what I’ve actually written in the past. From the point of
view of Markdown, however, there are precedents that make it problematic,
namely:

1.  The underline for the terms is already used for secondary headers
2.  Lists with multiple paragraphs need to be indented four spaces or one tab
    (never mind that this can [cause conflicts with code blocks following
    lists])
3.  There is no way to tell whether the paragraphs for a given term constitute a
    single definition with multiple paragraphs, multiple definitions, or some
    combination.

This last item never would have occurred to me, since I have never used more
than one definition per term, but have often used multiple paragraphs in a
single definition. However, when I think about the literal use of
definitions--you know, to define a term, I think about a dictionary, which of
course will offer many definitions for a single term. So clearly, there needs to
be a way to distinguish definitions from paragraphs.

So I started thinking about it some more, trying to figure out why I don’t like
the PHP Markdown Extra syntax, since it solves this problem by using “:” to
identify a term. But then it hit me: Definitions are just a list, and the “:” is
the bullet that identifies a list item. PHP Markdown Extra actually reinforces
this interpretation, since it in all ways makes definitions conform with basic
list syntax. This is a good symmetry and easy to remember.

So why do I hate the syntax? Once I realized this bit about the list, I
immediately knew what I hated about it: “:” is a shitty bullet. As a native
speaker and writer of American English, I no doubt bring my cultural biases to
the table, but I would *never* use a colon at the beginning of something, only
at the end. It just doesn’t belong there, hanging out in space. It’s too subtle,
conveys no meaning that I can see, and thus have no obvious mnemonics to make it
memorable.

So I started hunting around my keyboard for an alternate, and stumbled almost at
once on the tilde, “\~”. Consider this example, which in all ways is just like
the PHP Markdown Extra syntax, except that the colon is replaced with a tilde:

    Term 1:

      ~ This is a definition with two paragraphs. Lorem ipsum 
        dolor sit amet, consectetuer adipiscing elit. Aliquam 
        hendrerit mi posuere lectus.

        Vestibulum enim wisi, viverra nec, fringilla in, laoreet
        vitae, risus.

      ~ Second definition for term 1, also wrapped in a paragraph
        because of the blank line preceding it.

    Term 2:

      ~ This definition has a code block, a blockquote and a list.

            code block.

        > block quote
        > on two lines.

        1.  first list item
        2.  second list item

Well, *okay* I did add the trailing colon to the terms, but that’s just more
natural to me, and could be optional. But otherwise, it’s the tilde that’s
different. This to me is *much* more natural. I’d be perfectly willing to write
a definition list in email messages this way (and I think I will from now on).
It works well with shorter definition lists, too, of course:

    Apple:
      ~ Pomaceous fruit of plants of the genus Malus in the family Rosaceae.
      ~ An american computer company.

    Orange:
      ~ The fruit of an evergreen tree of the genus Citrus.

See how nice that is? So, you might ask, why the tilde rather than the colon? As
I said before, the colon doesn’t look right out there in front, it’s not a
“natural” way to write definitions because it’s not a natural choice for a
bullet. The tilde, however, is perfectly comfortable hanging out at the
beginning of a line as a bullet, resembling as it does the dash, already used
for unordered lists in Markdown. Furthermore, it’s already used in dictionaries.
According to [Wikipedia], “The swung dash is often used in dictionaries to
represent a word that was mentioned before and is understood, to save space.”
Not an exact parallel, but at least the tilde’s cousin the swung dash has to do
with definitions! Not only that, but in mathematics, according to Wikipedia
again, the tilde “is often used to denote an equivalence relation between two
objects.” That works: a definition is a series of words that define a term; that
is, they are a kind of equivalent!

So I would like to modestly propose to the Markdown community that the PHP
Markdown Extra definition list syntax be adopted as a standard with this one
change. What do you think?

  [Markdown]: http://daringfireball.net/projects/markdown/
    "Daring Fireball: Markdown"
  [PHP Markdown Extra]: http://michelf.com/projects/php-markdown/extra/#def-list
    "PHP Markdown Extra: Definition Lists"
  [MultiMarkdown]: http://fletcherpenney.net/multimarkdown/users_guide/multimarkdown_syntax_guide/#definitionlists
    "MultiMarkdown Syntax Guide: Definition Lists"
  [cause conflicts with code blocks following lists]: http://six.pairlist.net/pipermail/markdown-discuss/2009-February/001440.html
  [Wikipedia]: https://en.wikipedia.org/wiki/Tilde "Wikipedia: “Tilde”"
