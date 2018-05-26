--- 
date: 2009-02-27T00:38:32Z
slug: markdown-table-rfc
title: "RFC: A Simple Markdown Table Format"
aliases: [/computers/markup/markdown-table-rfc.html]
tags: [Web, Markdown, Proposals, RFC, MultiMarkdown, PHP Markdown Extra, Postgres, psql, MySQL, SQLite]
type: post
---

I've been thinking about markdown tables a bit lately. I've had in mind to
follow up on my [definition list proposal] with a second proposal for the
creation and editing of simple tables in Markdown. For better or for worse, an
[aside on the markdown-discuss mail list] led to a [longish thread] about a
syntax for continuing lines in tables (not to mention a long aside on the use of
monospaced fonts, but I digress), wherein I realized, after an [open-minded
post] from [MultiMarkdown]'s Fletcher Penney, that I needed to set to working up
this request for comments sooner rather than later.

### Requirements

All of which is to say that this blog entry is a request for comments on a
proposed sytnax for simple tables in Markdown. The requirements for such a
feature, to my thinking, are:

-   Simple tables only
-   Formatting should be implicit
-   Support for a simple caption
-   Support for representing column headers
-   Support for left, right, and center alignment
-   Support for multicolumn cells
-   Support for empty cells
-   Support for multiline (wrapping) cells
-   Support for multiple table bodies
-   Support for inline Markdown (spans, lists, etc.)
-   Support for all features (if not syntax) of [MultiMarkdown tables].

By “simple tables” in that first bullet, I mean that they should look good in 78
character-wide monospaced plain text. Anything more complicated should just be
done in XHTML. My goal is to be able to handle the vast majority of simple
cases, not to handle every kind of table. That's not to say that one won't be
able to use the syntax to create more complicated tables, just that it might not
be appropriate to do so, and many more advanced features of tables will just
have to be done in XHTML.

And by “implicit formatting” in the second bullet, I mean that the syntax should
use the bare minimum number of punctuation characters to provide hints about
formatting. Another way to think about it is that formatting hints should be
completely invisible to a casual reader of the Markdown text.

Most of the rest of the requirements I borrowed from
[MultiMarkdown][MultiMarkdown tables], with the last bullet thrown in just to
cover anything I might have missed. The MultiMarkdown syntax appears to be a
superset of the [PHP Markdown Extra syntax], so that's covered, too.

### Prior Art: Databases

When I think about the display of tables in plain text, the first piece of prior
art I think of is the output from command-line database clients. Database
developers have been thinking about tables since, well, the beginning, so it
makes sense to see what they're doing. So I wrote a bit of SQL and ran it in
three databases. The SQL builds a table with an integer, a short name, a textual
description, and a decimal number. Here's the code:

``` postgres
CREATE TEMPORARY TABLE widgets (
    id          integer,
    name        text,
    description text,
    price       numeric(6,2)
);

INSERT INTO widgets VALUES( 1, 'gizmo', 'Takes care of the doohickies', 1.99);
INSERT INTO widgets VALUES( 2, 'doodad', 'Collects *gizmos*', 23.8);
INSERT INTO widgets VALUES( 10, 'dojigger', 'Handles:
* gizmos
* doodads
* thingamobobs', 102.98);
INSERT INTO widgets VALUES(1024, 'thingamabob', 'Self-explanatory, no?', 0.99);

SELECT * FROM widgets;
```

My goal here was to see how the database client would format a variety of data
formats, as well as a textual column (“description”) with newlines in it (and a
Markdown list, no less!), as the newlines will force the output to appear on
multiple lines for a single row. This is one of the features that is missing
from the existing Markdown implementations, which all require that the text all
be on a single line.

The first database client in which I ran this code was [psql 8.3], the
interactive terminal for [PostgreSQL 8.3]. Its output looks like this:

      id  |    name     |         description          | price  
    ------+-------------+------------------------------+--------
        1 | gizmo       | Takes care of the doohickies |   1.99
        2 | doodad      | Collects *gizmos*            |  23.80
       10 | dojigger    | Handles:                     | 102.98
                        : * gizmos                       
                        : * doodads                      
                        : * thingamobobs                 
     1024 | thingamabob | Self-explanatory, no?        |   0.99

As you can see, PostgreSQL properly right-aligned the integer and numeric
columns. It also has a very nice syntax for demonstrating continuing lines for a
given column: the colon. The colon is really nice here because it looks kind of
like a broken pipe character, which is an excellent mnemonic for a string of
text that *breaks* over multiple lines. Really, this is just a very nice output
format overall.

The next database client I tried was [mysql 5.0], the command-line client for
[MySQL 5.0][1]. Its output looks like this:

    +------+-------------+--------------------------------------------+--------+
    | id   | name        | description                                | price  |
    +------+-------------+--------------------------------------------+--------+
    |    1 | gizmo       | Takes care of the doohickies               |   1.99 | 
    |    2 | doodad      | Collects *gizmos*                          |  23.80 | 
    |   10 | dojigger    | Handles:
    * gizmos
    * doodads
    * thingamobobs | 102.98 | 
    | 1024 | thingamabob | Self-explanatory, no?                      |   0.99 | 
    +------+-------------+--------------------------------------------+--------+

Once again we have very good alignment of the numeric data types. Furthermore,
MySQL uses exactly the same syntax as PostgreSQL to represent the separation
between column headers and column rows, although the PostgreSQL version is a bit
more minimalist. The MySQL version just hast a little more *stuff* in it

Where the MySQL version fails, however, is in the representation of the
continuing lines for the “dojigger” row. First of all, it set the width of the
“description” column to the longest value in that column, but since that longest
value includes newlines, it actually ends up being much too long—much longer
than PostgreSQL's representation of the same column. And second, as a symptom of
that problem, nothing special is done with the wrapped lines. The newlines are
simply output like any other character, with no attempt to line up the column.
This has the side effect of orphaning the price for the “dojiggger” after the
last line of the continuing description. So its alignment is shot, too.

To be fair, PostgreSQL's display featured almost exactly the same handling of
continuing columns prior to version 8.2. But I do think that their solution
featuring the colons is a good one.

The last database client I tried was [SQLite 3.6]. This client is the most
different of all. I set `.header ON` and `.mode column` and got this output:

    id          name        description                   price     
    ----------  ----------  ----------------------------  ----------
    1           gizmo       Takes care of the doohickies  1.99      
    2           doodad      Collects *gizmos*             23.8      
    10          dojigger    Handles:
    * gizmos
    * doodads
      102.98    
    1024        thingamabo  Self-explanatory, no?         0.99      

I don't think this is at all useful for Markdown.

### Prior Art: MultiMarkdown

Getting back to Markdown now, here is the MultiMarkdown syntax, borrowed from
the documentation:

    |             |          Grouping           ||
    First Header  | Second Header | Third Header |
     ------------ | :-----------: | -----------: |
    Content       |          *Long Cell*        ||
    Content       |   **Cell**    |         Cell |

    New section   |     More      |         Data |
    And more      |            And more          |
    [Prototype table]

There are a few interesting features to this syntax, including support for
multiple lines of headers, multicolumn cells alignment queues, and captions. I
like nearly everything about this syntax, except for two things:

1.  There is no support for multiline cell values.
2.  The explicit alignment queues are, to my eye, distracting.

The first issue can be solved rather nicely with PostgreSQL's use of the colon
to indicate continued lines. I think it could even optionally use colons to
highlight all rows in the output, not just the continuing one, as [suggested by
Benoit Perdu] on the markdown-discuss list:

      id  |    name     |         description          | price  
    ------+-------------+------------------------------+--------
        1 | gizmo       | Takes care of the doohickies |   1.99
        2 | doodad      | Collects *gizmos*            |  23.80
       10 | dojigger    | Handles:                     | 102.98
          :             : * gizmos                     : 
          :             : * doodads                    : 
          :             : * thingamobobs               : 
     1024 | thingamabob | Self-explanatory, no?        |   0.99

I think I prefer the colon only in front of the continuing cell, but see no
reason why both couldn't be supported.

The second issue is a bit more subtle. My problem with the alignment hints,
embodied by the colons in the header line, is that to the reader of the
plain-text Markdown they fill no obvious purpose, but are provided purely for
the convenience of the parser. In my opinion, if there is some part of the
Markdown syntax that provides no obvious meaning to the user, it should be
omitted. I take this point of view not only for my own selfish purposes, which
are, of course, many and rampant, but from John Gruber's original design goal
for Markdown, which was:

> The overriding design goal for Markdown’s formatting syntax is to make it as
> readable as possible. The idea is that a Markdown-formatted document should be
> publishable as-is, as plain text, without looking like it’s been marked up
> with tags or formatting instructions. While Markdown’s syntax has been
> influenced by several existing text-to-HTML filters, the single biggest source
> of inspiration for Markdown’s syntax is the format of plain text email.

To me, those colons are formatting instructions. So, how else could we support
alignment of cells but with formatting instructions? Why, by formatting the
cells themselves, of course. Take a look again at the PostgreSQL and MySQL
outputs. both simply align values in their cells. There is absolutely no reason
why a decent parser couldn't do the same on a cell-by-cell basis if the table
Markdown follows these simple rules:

-   For a left-aligned cell, the content should have no more than one space
    between the pipe character that precedes it, or the beginning of the line.
-   For a right-aligned cell, the content should have no more than one space
    between itself and the pipe character that succeeds it, or the end of the
    line.
-   For a centered cell, the content should have at least two characters between
    itself and both its left and right borders.
-   If a cell has one space before and one space after its content, it is
    assumed to be left-aligned unless the cell that precedes it or, in the case
    of the first cell, the cell that succeeds it, is right-aligned.

What this means, in effect, is that you can create tables wherein you line
things up for proper display with a proportional font and, in general, the
Markdown parser will know what you mean. A quick example, borrowing from the
PostgreSQL output:

      id  |    name     |         description          |  price  
    ------+-------------+------------------------------+--------
        1 | gizmo       | Takes care of the doohickies |   1.99 
        2 | doodad      | Collects *gizmos*            |  23.80 
       10 | dojigger    | Handles stuff                | 102.98 
     1024 | thingamabob | Self-explanatory, no?        |   0.99 

The outcome for this example is that:

-   The table headers are all center-aligned, because they all have 2 or more
    spaces on each side of their values
-   The contents of the “id” column are all right-aligned. This includes 1024,
    which ambiguously has only one space on each side of it, so it makes the
    determination based on the preceding line.
-   The contents of the “name” column are all left-aligned. This includes
    “thingamabob”, which ambiguously has only one space on each side of it, so
    it makes the determination based on the preceding line.
-   The contents of the “description” column are also all left-aligned. This
    includes first row, which ambiguously has only one space on each side of it,
    so it makes the determination based on the *succeeding* line.
-   And finally, the contents of the “price” column are all right-aligned. This
    includes 102.98, which ambiguously has only one space on each side of it, so
    it makes the determination based on the preceding line.

And that's it. The alignments are perfectly clear to the parser and highly
legible to the reader. No further markup is required.

### Proposed Syntax

So, with this review, I'd like to propose the following syntax. It is inspired
largely by a combination of PostgreSQL and MySQL's output, as well as by
MultiMarkdown's syntax.

-   A table row is identifiable by the use of one or more pipe (`|`) characters
    in a line of text, aside from those found in a literal span (backticks).
-   Table headers are identified as a table row with the immediately-following
    line containing only `-`, `|`, `+`, `:`or spaces. (This is the same as the
    MultiMarkdown syntax, but with the addition fo the plus sign.)
-   Columns are separated by `|`, except on the header underline, where they may
    optionally be separated by `+`, and on continuing lines (see next point).
-   Lines that continue content from one or more cells from a previous line must
    use `:` to separate cells with continued content. The content of such cells
    must line up with the cell width on the first line, determined by the number
    of spaces (tabs won't work). They may optionally demarcate all cells on
    continued lines, or just the cells that contain continued content.
-   Alignment of cell content is to be determined on a cell-by-cell basis, with
    reference to the same cell on the preceding or succeeding line as necessary
    to resolve ambiguities.
-   To indicate that a cell should span multiple columns, there should be
    additional pipes (`|`) at the end of the cell, as in MultiMarkdown. If the
    cell in question is at the end of the row, then of course that means that
    pipes are not optional at the end of that row.
-   You can use normal Markdown markup within the table cells, including
    multiline formats such as lists, as long as they are properly indented and
    denoted by colons on succeeding lines.
-   Captions are optional, but if present must be at the beginning of the line
    immediately preceding or following the table, start with `[` and end with
    `]`, as in MultiMarkdown. If you have a caption before and after the table,
    only the first match will be used.
-   If you have a caption, you can also have a label, allowing you to create
    anchors pointing to the table, as in MultiMarkdown. If there is no label,
    then the caption acts as the label.
-   Cells may not be empty, except as represented by the appropriate number of
    space characters to match the width of the cell in all rows.
-   As in MultiMarkdown. You can create multiple `<tbody>` tags within a table
    by having a single empty line between rows of the table.

Sound like a lot? Well, if you're acquainted with MultiMarkdown's syntax, it's
essentially the same, but with these few changes:

-   Implicit cell alignment
-   Cell content continuation
-   Stricter use of space, for proper alignment in plain text (which all of the
    MultiMarkdown examples I've seen tend to do anyway)
-   Allow `+` to separate columns in the header-demarking lines
-   A table does not have to start right at the beginning of a line

I think that, for purposes of backwards compatibility, we could still allow the
use of `:` in the header lines to indicate alignment, thus also providing a
method to override implicit alignment in those rare cases where you really need
to do so. I think that the only other change I would make is to eliminate the
requirement that the first row be made the table header row if now header line
is present. But that's a gimme, really.

Taking the original MultiMarkdown example and rework it with these changes
yields:

    |               |            Grouping            ||
    +---------------+---------------------------------+
    | First Header  |  Second Header  |  Third Header |
    +---------------+-----------------+---------------+
    | Content       |           *Long Cell*          ||
    : continued     :                                ::
    : content       :                                ::
    | Content       |    **Cell**     |          Cell |
    : continued     :                 :               :
    : content       :                 :               :

    | New section   |      More       |          Data |
    | And more      |             And more           ||
     [Prototype table]

### Comments?

I think I've gone on long enough here, especially since it ultimately comes down
to some refinements to the MultiMarkdown syntax. Ultimately, what I'm trying to
do here is to push MultiMarkdown to be just a *bit* more Markdownish (by which I
mean that it's more natural to read as plain text), as well as to add a little
more support for some advanced features. The fact that I'll be able to
cut-and-paste the output from my favorite database utilities is a handy bonus.

As it happens, John Gruber today [posted a comment] to the markdown-discuss mail
list in which he says (not for the first time, I expect):

> A hypothetical official table syntax for Markdown will almost certainly look
> very much, if not exactly, like Michel's table syntax in PHP Markdown Extra.

I hope that he finds this post in that vein, as my goals here were to embrace
the PHP Markdown Extra and MultiMarkdown formats, make a few tweaks, and see
what people think, with an eye toward contributing toward a (currently
hypothetical) official table syntax.

So what do you think? Please leave a comment, or comment on the
[markdown-discuss] list, where I'll post a synopsis of my proposal and a link to
this entry. What have I missed? What mistakes have I made? What do you like?
What do you hate? Please do let me know.

Thanks!

  [definition list proposal]: /computers/markup/modest-markdown-proposal.html
    "A Modest Proposal for Markdown Definition Lists"
  [aside on the markdown-discuss mail list]: http://six.pairlist.net/pipermail/markdown-discuss/2009-February/001471.html
    "markdown-discuss: “Re: A Modest Definition List Proposal”"
  [longish thread]: http://six.pairlist.net/pipermail/markdown-discuss/2009-February/001472.html
    "markdown-discuss: A preliminary discussion of tables with continuing lines"
  [open-minded post]: http://six.pairlist.net/pipermail/markdown-discuss/2009-February/001485.html
    "markdown-discuss: Fletcher Penney is open to a modified table  syntax"
  [MultiMarkdown]: http://fletcherpenney.net/multimarkdown/ "MultiMarkdown"
  [MultiMarkdown tables]: http://fletcherpenney.net/multimarkdown/users_guide/multimarkdown_syntax_guide/#tables
    "MultiMarkdown Syntax Guide: Tables"
  [PHP Markdown Extra syntax]: http://michelf.com/projects/php-markdown/extra/#table
  [psql 8.3]: http://www.postgresql.org/docs/8.3/static/app-psql.html
    "psql -- PostgreSQL interactive terminal"
  [PostgreSQL 8.3]: http://www.postgresql.org/docs/8.3/ "PostgreSQL 8.3 documentation"
  [mysql 5.0]: http://dev.mysql.com/doc/refman/5.0/en/mysql.html
    "mysql — The MySQL Command-Line Tool"
  [1]: http://dev.mysql.com/doc/refman/5.0/en/ "MySQL 5.0 Reference Manual"
  [SQLite 3.6]: http://sqlite.org/docs.html "SQLite Documentation"
  [suggested by Benoit Perdu]: http://six.pairlist.net/pipermail/markdown-discuss/2009-February/001472.html
  [posted a comment]: http://six.pairlist.net/pipermail/markdown-discuss/2009-February/001510.html
  [markdown-discuss]: http://six.pairlist.net/mailman/listinfo/markdown-discuss
    "Subscribe to the markdown-discuss list or read the archives"
