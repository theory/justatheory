--- 
date: 2004-06-16T00:03:18Z
slug: bricolage-uml-diagram
title: Bricolage 2.0 UML Diagram
aliases: [/bricolage/design/uml_diagram.html]
tags: [Bricolage, UML, OmniGraffle, PDF, design]
type: post
---

<p>I've just finished updating the <a href="https://svn.bricolage.cc/design-docs/trunk/Bricolage2/UML/Bricolage.pdf" title="The Bricolage 2.0 UML Diagram">UML diagram</a> for the design of Bricolage 2.0. It's not completely comprehensive, mainly because the lines would start criss-crossing all over the place and no one would never be able to make any sense of it, including me! Notably, I've left out the links to Bricolage::Biz::Site, Bricolage::Biz::Class, Bricolage::Party::Person::User, and Bricolage::Party::Person::Contributor. But it's pretty clear how they hook up if you study the classes, since they contain the appropriate <code>*_guid</code> attributes. And that's all those of us who will be writing Bricolage will need.</p>

<p>I'm happy to get this largely done. The <a href="http://svn.bricolage.cc/design-docs/trunk/Bricolage2/TechnicalSpec.pod">technical specification</a> is also largely complete. I'm going to fill in a bit on Bricolage::Client::CLI right now, but otherwise, it will probably be stable for a while. It will change of course, because it's not completely comprehensive, and there will be things that I haven't thought about as I'm starting to code. But that's probably a ways off, as there is quite a lot to get going with right now.</p>

<p>I'm not sure if I'll update the <a href="http://svn.bricolage.cc/design-docs/trunk/Bricolage2/FunctionalSpec.pod">functional specification</a> anytime soon. It's <em>really</em> out of date, but would take up quite a lot of time to rewrite, and for what benefit I'm not really sure at this point. The technical spec contains most of the information I need. Perhaps it will be time to update the functional spec once the API is nearing completeness and I start really working on the UI.</p>

<p>In the meantime, it's time to get back to hacking!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/design/uml_diagram.html">old layout</a>.</small></p>


