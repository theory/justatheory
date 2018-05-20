--- 
date: 2006-02-23T19:04:29Z
slug: port-svn-notify-to-windows
title: Port SVN::Notify to Windows
aliases: [/computers/programming/perl/port_svn_notify_to_windows.html]
tags: [Perl, SVN::Notify, Subversion, Windows, process]
type: post
---

So [SVN::Notify] doesn't currently run on Windows. Why not? Well, because I
wanted to do things as “rightly” as possible. In terms of efficiency, what that
meant was, rather than slurping in whole chunks of data, such as diffs, from
*svnlook*, I instead follows the guidance in [perlipc] to open a file handle
pipe to *svnlook* and then read from it line-by-line. The method I wrote to
create the pipe looks like this:

    sub _pipe {
        my ($self, $mode) = (shift, shift);
        # Safer version of backtick (see perlipc(1)).
        local *PIPE;
        my $pid = open(PIPE, $mode);
        die "Cannot fork: $!\n" unless defined $pid;

        if ($pid) {
            # Parent process. Return the file handle.
            return *PIPE;
        } else {
            # Child process. Execute the commands.
            exec(@_) or die "Cannot exec $_[0]: $!\n";
            # Not reached.
        }
    }

The problem is that it doesn't work on Windows. perlipc says:

> Note that these operations are full Unix forks, which means they may not be
> correctly implemented on alien systems. Additionally, these are not true
> multithreading. If you'd like to learn more about threading, see the modules
> file mentioned below in the SEE ALSO section.

'Course, the SEE ALSO section doesn't have much of for “alien systems,” but I
have a comment in my code that suggests that [Win32::Process] might do for
Windows compatibility. But I honestly don't know.

So what's the best approach for me to port SVN::Notify to Windows while keeping
file handle pipes around for efficiency? Anyone care to take a stab at it, with
tests for Winows, and send me a patch?

  [SVN::Notify]: http://search.cpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
  [perlipc]: http://search.cpan.org/dist/perl/pod/perlipc.pod#Safe_Pipe_Opens
    "Read about Safe Pipe Opens in the perlipc documentation"
  [Win32::Process]: http://search.cpan.org/dist/libwin32/Process/Process.pm
    "Win32::Process on CPAN"
