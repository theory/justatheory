--- 
date: 2014-02-09T13:58:00Z
link: http://www.modernperlbooks.com/mt/2014/02/managing-sqitch-with-make.html
title: Managing Sqitch with Make
aliases: [/sqitch/2014/02/09/managing-sqitch-with-make/]
tags: [Sqitch, make, chromatic]
type: post
---

chromatic:

> This saves me a few dozen keystrokes and a few seconds every time I make a
> database change. If that sounds trivial to you, good. A few keystrokes and a
> few seconds *are* trivial. My brainpower *isn't* trivial. Those keystrokes
> and seconds mean the difference between staying in the zone and fumbling
> around trying to remember commands I don't use all day every day. They save
> me minutes every time I use them, if you count the friction of switching
> between "How do I do this in Sqitch again? What's the directory layout here?"
> and "What was I really working on?"

Nice application of a `Makefile` to eliminate boilerplate. A couple of notes, though:

Nice post. A couple comments and questions:

* As of Sqitch v0.990, you can pass the `--open-editor` option to the `add`
  command to have the new files opened in your editor.

* If you want to add a pgTAP test with a new change, see [this post].

* What is the call to `sqitch status` for? Since its output just goes to
  `/dev/null`, I don't understand the point.

* Also as of v0.990, you can [specify Sqitch targets]. The `-d`, `-u`, and
  other options then override values in the target URI.

* I *really* want to get Sqitch to [better understand and work with VCSs]. An
  example would be to have it automatically `git add` files created by
  `sqitch add`. Another might be a Git config setting pointing to the Sqitch
  config file. Alas, I don't know when I will have the tuits to work on that.

Lots of room for growth and improvement in Sqitch going forward. You post provides more food for thought.

[this post]: /sqitch/2014/01/13/templating-tests-with-sqitch/ "Templating Tests with Sqitch"
[specify Sqitch targets]: /sqitch/2014/01/09/sqitch-on-target/ "Sqitch on Target"
[better understand and work with VCSs]: https://github.com/theory/sqitch/issues/25 "Add VCS Integration to Sqitch"
