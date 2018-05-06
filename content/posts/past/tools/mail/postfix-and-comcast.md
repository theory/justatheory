--- 
date: 2009-03-04T01:05:22Z
slug: postfix-and-comcast
title: Getting Postfix to Send Mail From a Comcast Network
aliases: [/computers/mail/postfix-and-comcast.html]
tags: [Tools, mail, Postfix, sendmail, Comcast]
---

<p>Since I moved to Comcast a while back, I have not received emails from this
blog server telling me that comments have been left. This is a drag because
spam comments can pile up for a while before I think to go looking for them
and delete them. So today I took the time to figure out how to get Postfix to
send mail through the Comcast server. Kudos
to <a href="http://www.kclug.org/pipermail/kclug/2008-February/032558.html"
title="Comcast and Postfix">Kclug mail list post</a> by “Lucas,” which
explains the issue in very simple terms. The key is to tell Postfix to relay
mail through the Comcast mail server on port 587 (which is the correct port
for Comcast to use for their users to send mail) and to use your Comcast.net
username and password to connect. So I put this in my <code>main.cf</code>:</p>

<pre>
relayhost = [smtp.comcast.net]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl/passwd
smtp_sasl_security_options =
</pre>

<p>Then, following the instructions
in <a href="http://freelock.com/kb/Postfix_relayhost" title="Postfix
relayhost">this Freelock Knowledge Base article</a>, I put this in
my <code>passwd</code> file:</p>

<pre>
smtp.comcast.net    myusername:some_password
</pre>

<p>I actually had to contact Comcast to get my username and password, since I
had never used the Comast mail server or other services before. But they gave
it to me without problem. Then I just ran this and was good to go:</p>

<pre>
chown root:root /etc/postfix/sasl/passwd;
chmod 600 /etc/postfix/sasl/passwd
postmap /etc/postfix/sasl/passwd 
postfix reload
</pre>

<p>And now maybe someone else will stumble upon this blog entry when they're
Googling for a solution and get the help they need, too. No doubt I'll be
looking for it again in a year or so, the way things go.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/mail/postfix-and-comcast.html">old layout</a>.</small></p>


