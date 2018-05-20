--- 
date: 2009-04-09T20:03:11Z
slug: list-all-svn-committers
title: List All Subversion Committers
aliases: [/computers/tricks/list-all-svn-committers.html]
tags: [Subversion, Git]
type: post
---

In preparation for migrating a large Subversion repository to GitHub, I needed
to get a list of all of the Subversion committers throughout history, so that I
could create a file mapping them to Git users. Here's how I did it:

    svn log --quiet http://svn.example.com/ \
    | grep '^r' | awk '{print $3}' | sort | uniq > committers.txt

Now I just have edit `committers.txt` and I have my mapping file.
