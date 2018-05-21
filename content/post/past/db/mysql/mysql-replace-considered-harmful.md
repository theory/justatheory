--- 
date: 2005-03-17T22:30:55Z
slug: mysql-replace-considered-harmful
title: MySQL's REPLACE Considered Harmful
aliases: [/computers/databases/mysql/replace_considered_harmful.html]
tags: [MySQL, Postgres, SQLite, SQL, goto]
type: post
---

So we've set up a client with an online poll application using MySQL. Polls are
created in Bricolage, and when they're published, rather than writing data to
files, the template writes data to the MySQL database. PHP code on the front-end
server then uses the database records to manage the polls.

On the recommendation of one of my colleagues, I was using the MySQL [`REPLACE`]
statement to insert and update poll answers in the database. At first, this
seemed like a cool idea. All I had to do was create a unique index on the
`story_id` and `ord` (for answer order) columns and I was set. Any time someone
reordered the answers or changed their wording in Bricolage, the `REPLACE`
statement would change the appropriate records and just do the right thing.

Or so I thought.

Come the day after the launch of the new site, I get a complaint from the
customer that the percentage spread between the answers doesn't add up to 100%.
After some investigation, I realized that the `poll_results` table is using the
ID of each question to identify the votes submitted by readers. This makes
sense, of course, and is excellent relational practice, but I have overlooked
the fact that `REPLACE` essentially replaces rows every time it is used. This
means that even when a poll answer hasn't changed, it gets a new ID. Yes, that's
right, its primary key value was changing. Yow!

Now we might have caught this earlier, but the database was developed on MySQL
3.23.58 and, as is conventional among MySQL developers, there were no foreign
key constraints. So the poll results were still happily pointing to non-existent
records. So a poll might appear to have 800 votes, but the percentages might be
counted for only 50 votes. Hence the problem with the percentages not adding up
to 100% (nowhere near it, in fact).

Fortunately, the production application is on a MySQL 4.1 server, so I made a
number of changes to correct this issue:

-   Added foreign key constraints
-   Exploited a little-known (mis)feature of Bricolage to store primary keys for
    all poll answers (and questions, for that matter)
-   Switched from `REPLACE` to `INSERT`, `UPDATE`, and `DELETE` statements using
    the primary keys

I also started using transactions when making all these updates when a poll is
published so that changes are always atomic. Now it works beautifully.

But the lesson learned is that `REPLACE` is a harmful construct. Yes, it was my
responsibility to recognize that it would create new rows and therefore new
primary keys. But any construct that changes primary keys should be stricken
from any database developer's toolbox. The fact that MySQL convention omits the
use of foreign key constraints makes this a particularly serious issue that can
appear to have mysterious consequences.

So my advice to you, gentle reader, is *don't use it.*

  [`REPLACE`]: http://dev.mysql.com/doc/mysql/en/replace.html
    "Documentation for the MySQL REPLACE statement"
