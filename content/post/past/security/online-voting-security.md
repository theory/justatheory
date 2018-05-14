--- 
date: 2006-02-06T18:15:55Z
slug: online-voting-security
title: How Does One Protect Online Ballot Box Stuffing?
aliases: [/computers/security/online_voting_security.html]
tags: [security, voting, elections, ballot box stuffing]
type: post
---

<p>I need to set up an online voting system. It needs to be more robust than a simple polling system, in order, primarily, to prevent ballot box stuffing. Of course I realize that it's impossible to prevent ballot box stuffing by a determined individual, but what I want to prevent is scripted attacks and denial of service attacks. The features I've come up with so far to prevent attacks are:</p>

<ul>
  <li>Require site registration. You must be a registered user of the site in order to vote in an election, and of course, you can vote only once.</li>
  <li>Ignore votes when cookies are disabled, although make it look like a successful submission.</li>
  <li>Update result statistics periodically, rather than after every vote. This will make it difficult for an exploiter to tell if his votes are being counted.</li>
  <li>Use a <a href="https://en.wikipedia.org/wiki/Captcha" title="Wikipedia explains CAPTCHA">CAPTCHA</a> to prevent scripted voting.</li>
  <li>Send a new digest hidden in every request that must be sent back and checked against a server-side session in order to prevent <q>curl</q> attacks.</li>
  <li>Log IP addresses for all votes. These can be checked later if ballot box stuffing is suspected (though we'll have to ignore it if many users are behind a proxy server).</li>
</ul>

<p>Of course someone behind a well-known proxy server who wants to repeatedly create a new user account using different email addresses and deleting his cookies before every vote could do <em>some</em> ballot box stuffing, but I think that the above features will minimize the risk. But I'm sure I'm forgetting things. What other steps should I take?</p>

<p>Leave a comment to let me know.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/security/online_voting_security.html">old layout</a>.</small></p>


