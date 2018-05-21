--- 
date: 2004-12-01T06:47:50Z
slug: rt-ldap-auth
title: New LDAP Auth Module for RT
aliases: [/computers/programming/perl/rt/ldap_auth.html]
tags: [Perl, RT, LDAP, Request Tracker, LdapOverlay, Net::LDAP, TLS]
type: post
---

I grabbed the [LdapOverlay] solution for using an LDAP server to authenticate
against [Request Tracker] today in my continuing efforts to use LDAP for single
sign-on for all Kineticode resources. It worked great, but I wanted a couple
more things out of it, namely TLS communications with the LDAP server (so that
all communications are encrypted), and authentication only for members of a
certain LDAP group.

So I refactored LdapOverlay and added these features. You can download it from
[here]. Just set the `$LdapTLS` variable in your `RT_SiteConfig` module to a
true value to use TLS (but be sure that you also have [Net::SSLeay] installed!).
If you want to allow only members of a certain LDAP group to authenticate to RT,
set the DN of the group in the `$LdapGroup` variable, and set the name of the
member attribute (usually “uniqueMember”) in the `$LdapGroupAttribute` variable.

Enjoy!

  [LdapOverlay]: http://wiki.bestpractical.com/index.cgi?LdapOverlay
    "LdapOverlay page in the RT Wiki"
  [Request Tracker]: http://www.bestpractical.com/rt/ "RT by Best Practical"
  [here]: /2004/12/ldap-auth/User_Local.pm.ldap "My Revision of LdapOverlay"
  [Net::SSLeay]: http://search.cpan.org/dist/Net_SSLeay.pm/
    "Net::SSLeay on CPAN"
