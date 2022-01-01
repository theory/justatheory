--- 
date: 2007-02-19T17:18:55Z
slug: rsnapshot-and-launchd
title: Configuring rsnapshot and launchd on Mac OS X
aliases: [/computers/os/macosx/rsnapshot_and_launchd.html]
tags: [macOS, Backups, rsnapshot, rsync, launchd]
type: post
---

Just a few quick notes on how I set up `launchd` to run `rsnapshot` to backup my
new iMac. The configurations I made are based on Kenn Christ's [blog entry].

1.  Installed the rsnapshot port:

        sudo port install rsnapshot

2.  Changed */opt/local/etc/rsnapshot.conf* as follows:

        snapshot_root   /Volumes/Demiterra/Backup/
        #interval   hourly  6
        rsync_long_args --delete --numeric-ids --relative --delete-excluded -extended-attributes
        exclude *.cpan*
        link_dest   1
        #backup /home/      localhost/
        #backup /etc/       localhost/
        #backup /usr/local/ localhost/
        backup  /Users/     

    Note that I've commented out hourly backups and the default backup
    directories. I'm using the *Backups* subdirectory on a [My Book] half
    terabyte drive that I picked up at Costco for $220. Your configuration may
    of course differ.

3.  Tested it by manually running:

        sudo /opt/local/bin/rsnapshot daily

4.  Created hourly, daily, weekly, and monthly `launchd` plist files for
    `rsnapshot`. The hourly one runs every six hours and I threw it in just for
    completeness. You can download them all from [here]. Just put them into
    */Library/LaunchDaemons* and run:

        sudo launchctl load -w /Library/LaunchDaemons/org.rsnapshot.periodic-*.plist

And that's it. Enjoy!

  [blog entry]: http://www.inmostlight.org/2006/03/easy-backups-with-rsnapshot
    "Easy backups with rsnapshot"
  [My Book]: https://en.wikipedia.org/wiki/Western_Digital_My_Book
    "Wikipedia: Western Digital My Book™ Premium Edition™"
  [here]: {{% link "/downloads/rsnapshot_launchd_plists.tar.gz" %}}
    "Download my rsnapshot launchd plist files"
