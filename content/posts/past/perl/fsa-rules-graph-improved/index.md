--- 
date: 2006-07-14T20:02:16Z
slug: fsa-rules-graph-improved
title: FSA::Rules Graphing Features Improved
aliases: [/computers/programming/perl/fsa_rules_graph_improved.html]
tags: [Perl, FSA::Rules, GraphViz, PNG, state machines]
---

<img src="/2006/07/fsa-rules-graph-improved/fsa_rules_sample.png" alt="FSA::Rules sample graph output" />

<p>I just released <a href="http://search.cpan.org/dist/FSA-Rules/" title="FSA::Rules on CPAN">FSA::Rules</a> 0.25. This version came about as I
returned to the module to handle setting up a PostgreSQL database and found
the graphics that it churned out, well, wanting. I wanted a decision tree, but
the graphics just had the names of the states for the nodes, and then long
question-like labels on the edges. What I wanted instead was for each node to
be a question (or a statement about what the node was doing), and for the
edges to be simple answers to those questions (or indicators as to the success
of the code run in a state).</p>

<p>So I added a new attribute to the state class, <code>label</code>. You can
use this attribute to say something more about the state. In my case, I used
it to store the question the state asks, or the description of the state's
activities. I then changed the code that creates the graph to use this
attribute in preference to the state name when creating node labels. The
result is a much more natural decision graph, as you see here</p>

<p>The release features a number of other goodies, including the elimination
of a dependence on the <code>Clone</code> module, and thus also a big memory
savings. There is now a lot more control over the format of graphs, too.
Enjoy!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/fsa_rules_graph_improved.html">old layout</a>.</small></p>


