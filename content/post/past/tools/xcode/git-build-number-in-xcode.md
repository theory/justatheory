--- 
date: 2010-11-24T21:33:49Z
slug: git-build-number-in-xcode
title: Adding a Git SHA1 to your Xcode Project
aliases: [/computers/programming/cocoa/git-build-number-in-xcode.html]
tags: [Xcode, Git, Perl]
type: post
---

I found a [decent Perl script] for adding a Git SHA1 to an Xcode project last
week. However, since by day I’m actually a [Perl hacker], I couldn’t help
finessing it a bit. Here are the steps to add it to your project:

1.  Open your project settings (Project –\> Edit Project Settings) and in the
    “Build” tab, make sure that “Info.plist Output Encoding” is set to “xml”. I
    lost about an hour of fiddling before I realized that my plist file was
    binary, which of course couldn’t really be parsed by the simple Perl script.

2.  Edit your app’s Info.plist file. If you want the version to be the SHA1, set
    “Bundle Version” to “0x000”. I personally prefer to have a separate key for
    the SHA1, so I created the “LTGitSHA1” key and set its value to “0x000”.
    This is the placeholder value that will be replaced when your app runs.

3.  Right-click your target app and select Add –\> New Build Phase –\> New Run
    Script Build Phase. For the shell command, enter:

        /usr/bin/env perl -wpi -0777

4.  Paste this into the “Script” field:

        #!/usr/bin/env perl -wpi -0777
        # Xcode auto-versioning script for Subversion by Axel Andersson
        # Updated for git by Marcus S. Zarra and Matt Long
        # Refactored by David E. Wheeler.

        BEGIN {
            @ARGV = ("$ENV{BUILT_PRODUCTS_DIR}/$ENV{INFOPLIST_PATH}");
            ($sha1 = `git rev-parse --short HEAD`) =~ s/\s+$//;
        }

        s{0x000}{$sha1};

5.  Fetch the value in your code from your bundle, something like this:

        NSLog(
            @"SHA1: %@",
            [[[NSBundle mainBundle]infoDictionary]objectForKey:@"LTGitSHA1"]
        );

That’s it. If you want to use a placeholder other than “0x0000”, just change it
on the last line of the script.

  [decent Perl script]: http://www.cimgf.com/2008/04/13/git-and-xcode-a-git-build-number-script/
  [Perl hacker]: http://search.cpan.org/~dwheeler/
