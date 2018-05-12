--- 
date: 2006-02-23T19:04:29Z
slug: port-svn-notify-to-windows
title: Port SVN::Notify to Windows
aliases: [/computers/programming/perl/port_svn_notify_to_windows.html]
tags: [Perl, SVN::Notify, Subversion, Windows, process]
type: post
---

<p>So <a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> doesn't currently run on Windows. Why not? Well, because I wanted to do things as <q>rightly</q> as possible. In terms of efficiency, what that meant was, rather than slurping in whole chunks of data, such as diffs, from <em>svnlook</em>, I instead follows the guidance in <a href="http://search.cpan.org/dist/perl/pod/perlipc.pod#Safe_Pipe_Opens" title="Read about Safe Pipe Opens in the perlipc documentation">perlipc</a> to open a file handle pipe to <em>svnlook</em> and then read from it line-by-line. The method I wrote to create the pipe looks like this:</p>

<pre>
sub _pipe {
    my ($self, $mode) = (shift, shift);
    # Safer version of backtick (see perlipc(1)).
    local *PIPE;
    my $pid = open(PIPE, $mode);
    die &quot;Cannot fork: $!\n&quot; unless defined $pid;

    if ($pid) {
        # Parent process. Return the file handle.
        return *PIPE;
    } else {
        # Child process. Execute the commands.
        exec(@_) or die &quot;Cannot exec $_[0]: $!\n&quot;;
        # Not reached.
    }
}
</pre>

<p>The problem is that it doesn't work on Windows. perlipc says:</p>

<blockquote>
  <p>Note that these operations are full Unix forks, which means they may not be correctly implemented on alien systems. Additionally, these are not true multithreading. If you'd like to learn more about threading, see the modules file mentioned below in the SEE ALSO section.</p>
</blockquote>

<p>'Course, the SEE ALSO section doesn't have much of for <q>alien systems,</q> but I have a comment in my code that suggests that <a href="http://search.cpan.org/dist/libwin32/Process/Process.pm" title="Win32::Process on CPAN">Win32::Process</a> might do for Windows compatibility. But I honestly don't know.</p>

<p>So what's the best approach for me to port SVN::Notify to Windows while keeping file handle pipes around for efficiency? Anyone care to take a stab at it, with tests for Winows, and send me a patch?</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/port_svn_notify_to_windows.html">old layout</a>.</small></p>


