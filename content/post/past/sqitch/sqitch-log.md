--- 
date: 2012-07-12T17:33:12Z
slug: sqitch-log
title: Sqitch’s Log
aliases: [/computers/databases/sqitch-log.html]
tags: [Sqitch, SQL, Databases, Change Management]
type: post
---

Just uploaded Sqitch [v0.70] and [v0.71]. The big change is the introduction of
the `log` command, which allows one to view the deployment history in a
database. All events are logged and searchable, including deploys, failed
deploys, and reverts. Unlike most other database migration systems, Sqitch has
the whole history, so even if you revert back to the very beginning, there is
still a record of everything that happened.

I stole most of the interface for [the `log` command] from [`git-log`],
including:

-   Colorized output
-   Searching against change and committer names via regular expressions
-   A variety of formatting options (“full”, “long”, “medium”, “oneline”, etc.)
-   Extensible formatting with [`printf`-style codes]

Here are a couple of examples searching [the tutorial]’s test database:

<pre class="chroma"><code>&gt; sqitch -d flipr_test log -n 3
On database flipr_test
<span class="ld">Deploy 18d7aab59bd0c914a561dc324b1da5549605c376</span>
Name:   change_pass
Date:   2012-07-07 13:26:30 +0200

<span class="ld">Deploy 87b4e131897ec370d78be177a3f91fdc877a2515</span>
Name:   insert_user
Date:   2012-07-07 13:26:30 +0200

<span class="ld">Deploy 20d9af30b97a3071dce12d91665dcd6237265d60</span>
Name:   pgcrypto
Date:   2012-07-07 13:26:30 +0200
</code></pre>

```
> sqitch -d flipr_test log -n 6 --format oneline --abbrev 7
On database flipr_test
18d7aab deploy change_pass
87b4e13 deploy insert_user
20d9af3 deploy pgcrypto
540359a deploy delete_flip
d4dce7d deploy insert_flip
b715d73 deploy flips
```

<pre class="chroma"><code>
&gt; sqitch -d flipr_test log -n 4 --event revert --event fail --format \
'format:%a %eed %{blue}C%{6}h%{reset}C - %c%non %{cldr:YYYY-MM-dd}d at %{cldr:h:mm a}d%n' 
On database flipr_test
theory reverted <span class="kp">9df095</span> - appuser
on 2012-07-07 at 1:26 PM

theory reverted <span class="kp">9df095</span>9d078b - users
on 2012-07-07 at 1:26 PM

theory reverted <span class="kp">9df095</span>131e25 - insert_user
on 2012-07-07 at 1:26 PM

theory reverted <span class="kp">9df095</span>02c559 - change_pass
on 2012-07-07 at 1:26 PM
</code></pre>

I’m pretty happy with this. Not sure how much it will be used, but it works
great!

  [v0.70]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.70-TRIAL
  [v0.71]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.71-TRIAL
  [the `log` command]: https://github.com/theory/sqitch/blob/master/lib/sqitch-log.pod
  [`git-log`]: http://git-scm.com/docs/git-log
  [`printf`-style codes]: https://github.com/theory/sqitch/blob/master/lib/sqitch-log.pod#formats
  [the tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod
