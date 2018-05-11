--- 
date: 2004-06-09T17:23:10Z
slug: bricolage-perl-org-auth-woes
title: Perl.org Subversion Authentication Woes
aliases: [/bricolage/svn/perl_org_auth_woes.html]
tags: [Bricolage, Subversion]
---

<p>It looks like the Perl.org authentication system that handles authentication for <code>svn.bricolage.cc</code> doesn't properly cache an authentication token. Robert discovered this when a very large merge I was working on from the rev_1_8 branch of Bricolage to trunk was hanging and then timing out on me. The problem was that it was disconnecting from the MySQL server. Odd. At any rate, Robert switched over to an auth system that doesn't use MySQL so that I could do the merge and then the commit. This morning, he restored the original auth system. I shouldn't often have to do such a big merge or commit in Bricolage, so hopefully it won't come up again, but it sure was annoying there for a while.</p>

<p>So for my fellow Bricolage developers who thought that the auth system was down: Sorry, it's back now. And the trunk is fully updated with all of the changes to rev_1_8, which means that new development in the trunk can begin again in earnest.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/svn/perl_org_auth_woes.html">old layout</a>.</small></p>


