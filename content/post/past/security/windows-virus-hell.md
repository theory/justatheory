--- 
date: 2005-08-21T21:09:22Z
slug: windows-virus-hell
title: Windows Virus Hell
aliases: [/computers/policy/windows_virus_hell.html]
tags: [Security, Viruses, Windows, Linux, CBL, Win32Mimail, NAT, SMTP, Port, Mail, Email, PHP]
type: post
---

So to finish up development and testing of [Test.Harness.Browser] in IE 6 last
week, I rebooted my Linux server (the one running justatheory.com) into Windows
98, got everything working, and rebooted back into Linux. I felt that the hour
or two's worth of downtime for my site was worth it to get the new version of
Test.Simple out, and although I had ordered a new Dell, didn't want to wait for
it. And it worked great; I'm very pleased with Test.Simple 0.20.

But then, in unrelated news, I released [Bricolage 1.9.0], the first development
release towards Bricolage 1.10, which I expect to ship next month. One of the
things I'm most excited about in this release is the new PHP templating support.
So on [George Schlossnagle]'s advice, I sent an email to webmaster@php.net. It
bounced. It was late on Friday, and I'm so used to bounces being problems on the
receiving end, that I simply forwarded it to George with the comment, “What
the?” and went to fix dinner for company.

Then this morning I asked George, via IM, if he'd received my email. He hadn't.
I sent it again; no dice. So he asked me to paste the bounce, and as I did so,
looked at it more carefully. It had this important tidbit that I'd failed to
notice before:

    140.211.166.39 failed after I sent the message.
    Remote host said: 550-5.7.1 reject content [xbl]
    550 See http://master.php.net/mail/why.php?why=SURBL

“That's curious,” I thought, and went to read the page in question. It said I
likely had a domain name in my email associated with a blacklisted IP address.
Well, there were only two domain names in that email, bricolage.cc and
justatheory.com, and I couldn't see how either one of them could have been
identified as a virus host. But sure enough, a quick search of the [CBL
database] revealed that the IP address for justatheory.com—and therefore my
entire home LAN— had been blacklisted. I couldn't imagine why; at first I
thought maybe it was because of past instances of blog spam appearing here, but
then George pointed out that the listing had been added on August 18. So I
thought back…and realized that was just when I was engaging in my JavaScript
debugging exercise.

**Bloody Windows!**

So I took steps to correct the problem:

1.  Update my router's firmware. I've been meaning to do that for a while,
    anyway, and was hoping to get some new firewall features. Alas, no, but
    maybe I'll be able to connect to a virtual PPTP network the next time I need
    to.

2.  Blocked all outgoing traffic from any computer on my LAN on port 25. I send
    email through my ISP, but use port 587 because I found in the last year that
    I couldn't send mail on port 25 on some networks I've visited (such as in
    hotels). Now I know why: so that no network users inadvertently send out
    viruses from their Windows boxes! I'd rather just prevent certain hosts (my
    Windows boxen) from sending on port 25, but the router's NAT is not that
    sophisticated. So I have to block them all.

3.  Rebooted the server back into Windows 98 and installed and ran Norton
    AntiVirus. This took forever, but found and fixed two instances of
    WIN32Mimail.l@mm and removed a spyware package.

4.  Rebooted back into Linux and cleared my IP address from the blacklist
    databases. I don't expect to *ever* use that box for Windows again, now that
    I have the new Dimension.

The new box comes with Windows XP SP 2 and the Symantec tools, so I don't expect
it to be a problem, especially since it can't use port 25. But this is a PITA,
and I really feel for the IT departments that have to deal with this shit day in
and day out.

What I don't understand is how I got this virus, since I haven't used Windows 98
in this computer in a long time. How long? Here's a clue: When I clicked the
link in Norton AntiVirus to see more information on WIN32Mimail.l@mm, Windows
launched my default browser: Netscape Communicator! In addition, I don't think
I've used this box to check email since around 2000, and I *never* click on
attachments from unknown senders, and *never* *.exe* or *.scr* files at all (my
mail server automatically rejects incoming mail with such attachments, and has
for at least a year).

But anyway, it's all cleaned up now, and I've un-blacklisted my IP, so my emails
should be deliverable again. But I'm left wondering what can be done about this
problem. It's easy for me to feel safe using my Mac, Linux, and FreeBSD boxes,
but, really, what keeps the Virus and worm writers from targeting them? Nothing,
right? Furthermore, what's to stop the virus and worm writers from using port
587 to send their emails? Nothing, right? Once they do start using 587—and I'm
sure they will—how will anyone be able to send mail to an SMTP server on one
network from another network? Because you know that once 587 becomes a problem,
network admins will shut down that port, too.

So what's to be done about this? How can one successfully send mail to a server
not on your local network? How will business people be able to send email
through their corporate servers from hotel networks? I can see only a few
options:

-   Require them to use a mail server on the local network. They'll have to
    reconfigure their mail client to use it, and then change it back when they
    get back to the office. What a PITA. This might work out all right if there
    was some sort of DNS-like service for SMTP servers, but then there would
    then be nothing to prevent the virus software from using it, either.
-   You can't. You have to authenticate onto the other network using a VPN. Lots
    of companies rely on this approach already, but smaller companies that don't
    have the IT resources to set up a VPN are SOL. And folks just using their
    ISPs are screwed, too.
-   Create a new email protocol that's inherently secure. This would require a
    different port, some sort of negotiation and authentication process, and a
    way for the hosting network to know that it's cool to use. But this probably
    wouldn't work, either, because then the virus software can also connect via
    such a protocol to a server that's friendly to it, right?

None of these answers is satisfactory. I guess I'll have to set up an
authenticating SMTP server and a VPN for Kineticode once port 587 starts getting
blocked. Anyone else got any brilliant solutions to this problem?

  [Test.Harness.Browser]: {{% ref "/post/past/js/test-simple-0.20.md" %}}
    "Test.Simple 0.20 Released"
  [Bricolage 1.9.0]: {{% ref "/post/past/bricolage/bricolage-1.9.0.md" %}}
  [George Schlossnagle]: http://www.schlossnagle.org/~george/blog/
    "George Schlossnagle's Blog"
  [CBL database]: http://cbl.abuseat.org/lookup.cgi
    "Search the CBL blacklisting database"
