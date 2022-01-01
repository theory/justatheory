--- 
date: 2009-03-04T01:05:22Z
slug: postfix-and-comcast
title: Getting Postfix to Send Mail From a Comcast Network
aliases: [/computers/mail/postfix-and-comcast.html]
tags: [Tools, Mail, Postfix, Sendmail, Comcast]
type: post
---

Since I moved to Comcast a while back, I have not received emails from this blog
server telling me that comments have been left. This is a drag because spam
comments can pile up for a while before I think to go looking for them and
delete them. So today I took the time to figure out how to get Postfix to send
mail through the Comcast server. Kudos to [Kclug mail list post] by “Lucas,”
which explains the issue in very simple terms. The key is to tell Postfix to
relay mail through the Comcast mail server on port 587 (which is the correct
port for Comcast to use for their users to send mail) and to use your
Comcast.net username and password to connect. So I put this in my `main.cf`:

    relayhost = [smtp.comcast.net]:587
    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = hash:/etc/postfix/sasl/passwd
    smtp_sasl_security_options =

Then, following the instructions in [this Freelock Knowledge Base article], I
put this in my `passwd` file:

    smtp.comcast.net    myusername:some_password

I actually had to contact Comcast to get my username and password, since I had
never used the Comast mail server or other services before. But they gave it to
me without problem. Then I just ran this and was good to go:

    chown root:root /etc/postfix/sasl/passwd;
    chmod 600 /etc/postfix/sasl/passwd
    postmap /etc/postfix/sasl/passwd 
    postfix reload

And now maybe someone else will stumble upon this blog entry when they're
Googling for a solution and get the help they need, too. No doubt I'll be
looking for it again in a year or so, the way things go.

  [Kclug mail list post]: https://www.kclug.org/pipermail/kclug/2008-February/032558.html
    "Comcast and Postfix"
  [this Freelock Knowledge Base article]: https://www.freelock.com/kb/postfix-relayhost
    "Postfix relayhost"
