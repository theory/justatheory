--- 
date: 2004-06-04T00:39:23Z
slug: rewrite-rules
title: Blosxom Rewrite Rules
aliases: [/computers/internet/weblogs/blosxom/rewrite_rules.html]
tags: [Meta, Blosxom, mod_rewrite]
type: post
---

<p>I finally got my <code>mod_rewrite</code> rules working for Blosxom, so now it finally looks like I have a real site! The problem was that <code>%{REQUEST_FILE}</code> wasn't actually the full file name on the file system, but the request URI! I have no idea why, but once I figured out this problem I was able get 'round it by using <code>%{DOCUMENT_ROOT}%{REQUEST_URI}</code>. So now my configuration looks like this:</p>

<pre>&lt;VirtualHost *&gt;
  DocumentRoot /usr/local/www/doc_roots/justatheory
  ServerAdmin david@justatheory.com
  ServerName justatheory.com
  ServerAlias www.justatheory.com
  CustomLog /usr/local/www/logs/access_log.justatheory combined
  &lt;Directory /usr/local/www/doc_roots/justatheory&gt;
    AddHandler cgi-script .cgi
    Options +ExecCGI
  &lt;/Directory&gt;
  RewriteEngine on
  RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-f
  RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-d
  RewriteRule ^/(.*)$ /blosxom.cgi/$1 [L,QSA]
&lt;/VirtualHost&gt;
</pre>

<p>And all is well. Now, if only I could get the <code>meta</code> plugin working properly...</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/internet/weblogs/blosxom/rewrite_rules.html">old layout</a>.</small></p>


