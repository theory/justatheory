--- 
date: 2007-02-19T17:18:55Z
slug: rsnapshot-and-launchd
title: Configuring rsnapshot and launchd on Mac OS X
aliases: [/computers/os/macosx/rsnapshot_and_launchd.html]
tags: [macOS, backups, rsnapshot, rsync, launchd]
type: post
---

<p>Just a few quick notes on how I set up <code>launchd</code> to run <code>rsnapshot</code> to backup my new iMac. The configurations I made are based on Kenn Christ's <a href="http://www.inmostlight.org/2006/03/easy-backups-with-rsnapshot" title="Easy backups with rsnapshot">blog entry</a>.</p>

<ol>
  <li>
    <p>Installed the rsnapshot port:</p>
    <pre>sudo port install rsnapshot</pre>
  </li>

  <li>
    <p>Changed <em>/opt/local/etc/rsnapshot.conf</em> as follows:</p>
    <pre>
snapshot_root	/Volumes/Demiterra/Backup/
#interval	hourly	6
rsync_long_args	--delete --numeric-ids --relative --delete-excluded -extended-attributes
exclude	*.cpan*
link_dest	1
#backup	/home/		localhost/
#backup	/etc/		localhost/
#backup	/usr/local/	localhost/
backup	/Users/		
</pre>
    <p>Note that I've commented out hourly backups and the default backup directories. I'm using the <em>Backups</em> subdirectory on a <a href="http://www.wdc.com/en/products/Products.asp?DriveID=224" title="Western Digital My Book™ Premium Edition™">My Book</a> half terabyte drive that I picked up at Costco for $220. Your configuration may of course differ.</p>
  </li>

  <li>
    <p>Tested it by manually running:</p>
    <pre>sudo /opt/local/bin/rsnapshot daily</pre>
  </li>

  <li>
    <p>Created hourly, daily, weekly, and monthly <code>launchd</code> plist files for <code>rsnapshot</code>. The hourly one runs every six hours and I threw it in just for completeness. You can download them all from <a href="/downloads/rsnapshot_launchd_plists.tar.gz" title="Download my rsnapshot launchd plist files">here</a>. Just put them into <em>/Library/LaunchDaemons</em> and run:</p>
    <pre>sudo launchctl load -w /Library/LaunchDaemons/org.rsnapshot.periodic-*.plist</pre>
  </li>
</ol>

<p>And that's it. Enjoy!</p>
<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/os/macosx/rsnapshot_and_launchd.html">old layout</a>.</small></p>


