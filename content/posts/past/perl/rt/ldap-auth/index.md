--- 
date: 2004-12-01T06:47:50Z
slug: ldap-auth
title: New LDAP Auth Module for RT
aliases: [/computers/programming/perl/rt/ldap_auth.html]
tags: [Perl, RT, LDAP, Request Tracker, LdapOverlay, Net::LDAP, TLS]
---

<p>I grabbed the <a href="http://wiki.bestpractical.com/index.cgi?LdapOverlay" title="LdapOverlay page in the RT Wiki">LdapOverlay</a> solution for using an LDAP server to authenticate against <a href="http://www.bestpractical.com/rt/" title="RT by Best Practical">Request Tracker</a> today in my continuing efforts to use LDAP for single sign-on for all Kineticode resources. It worked great, but I wanted a couple more things out of it, namely TLS communications with the LDAP server (so that all communications are encrypted), and authentication only for members of a certain LDAP group.</p>

<p>So I refactored LdapOverlay and added these features. You can download it from <a href="/2004/12/ldap-auth/User_Local.pm.ldap" title="My Revision of LdapOverlay">here</a>. Just set the <code>$LdapTLS</code> variable in your <code>RT_SiteConfig</code> module to a true value to use TLS (but be sure that you also have <a href="http://search.cpan.org/dist/Net_SSLeay.pm/" title="Net::SSLeay on CPAN">Net::SSLeay</a> installed!). If you want to allow only members of a certain LDAP group to authenticate to RT, set the DN of the group in the <code>$LdapGroup</code> variable, and set the name of the member attribute (usually <q>uniqueMember</q>) in the <code>$LdapGroupAttribute</code> variable.</p>

<p>Enjoy!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/rt/ldap_auth.html">old layout</a>.</small></p>


