--- 
date: 2004-06-04T00:39:23Z
slug: rewrite-rules
title: Blosxom Rewrite Rules
aliases: [/computers/internet/weblogs/blosxom/rewrite_rules.html]
tags: [Meta, Blosxom, mod_rewrite]
type: post
---

I finally got my `mod_rewrite` rules working for Blosxom, so now it finally
looks like I have a real site! The problem was that `%{REQUEST_FILE}` wasn't
actually the full file name on the file system, but the request URI! I have no
idea why, but once I figured out this problem I was able get 'round it by using
`%{DOCUMENT_ROOT}%{REQUEST_URI}`. So now my configuration looks like this:

    <VirtualHost *>
      DocumentRoot /usr/local/www/doc_roots/justatheory
      ServerAdmin david@justatheory.com
      ServerName justatheory.com
      ServerAlias www.justatheory.com
      CustomLog /usr/local/www/logs/access_log.justatheory combined
      <Directory /usr/local/www/doc_roots/justatheory>
        AddHandler cgi-script .cgi
        Options +ExecCGI
      </Directory>
      RewriteEngine on
      RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-f
      RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-d
      RewriteRule ^/(.*)$ /blosxom.cgi/$1 [L,QSA]
    </VirtualHost>

And all is well. Now, if only I could get the `meta` plugin working properly...
