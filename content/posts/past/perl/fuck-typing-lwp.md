--- 
date: 2010-05-27T16:37:15Z
slug: fuck-typing-lwp
title: Fuck Typing LWP
aliases: [/computers/programming/perl/fuck-typing-lwp.html]
tags: [Perl, LWP, fuck typing, Composition, programming]
---

<p>I'm working on a project that fetches various files from the Internet via LWP. I wanted to make sure that I was a polite user, such that my app would pay attention to <code>Last-Modified/If-Modified-Since</code> and <code>ETag/If-None-Match</code> headers. And in most contexts I also want to respect the <code>robots.txt</code> file on the hosts to which I'm sending requests. So I was very interested to read <a href="http://www.modernperlbooks.com/mt/2010/05/are-objects-black-blocks-or-toolkits.html">chromatic’s hack</a> for this very issue. I happily implemented two classes for my app, MyApp::UA, which inherits from <a href="http://search.cpan.org/perldoc?LWP::UserAgent::WithCache">LWP::UserAgent::WithCache</a>, and MyApp::UA::Robot, which inherits from MyApp::UA but changes LWP::UserAgent::WithCache to inherit from <a href="http://search.cpan.org/perldoc?LWP::RobotUA">LWP::UARobot</a>:</p>

<pre>
@LWP::UserAgent::WithCache::ISA = (&#x0027;LWP::RobotUA&#x0027;);
</pre>

<p>So far so good, right? Well, no. What I didn’t think about, stupidly, is that by changing LWP::UserAgent::WithCache’s base class, I was doing so globally. So now both MyApp::UA and MyApp::UA::Robot were getting the LWP::RobotUA behavior. Urk.</p>

<p>So my work around is to use a little <a href="/computers/programming/methodology/fuck-typing.html">fuck typing</a> to ensure that MyApp::UA::Robot has the robot behavior but MyApp::UA does not. Here’s what it looks like (<strong>BEWARE:</strong> black magic ahead!):</p>

<pre>
package MYApp::UA::Robot;

use 5.12.0;
use utf8;
use parent 'MyApp::UA';
use LWP::RobotUA;

do {
    # Import the RobotUA interface. This way we get its behavior without
    # having to change LWP::UserAgent::WithCache&#x0027;s inheritance.
    no strict &#x0027;refs&#x0027;;
    while ( my ($k, $v) = each %{&#x0027;LWP::RobotUA::&#x0027;} ) {
        *{$k} = *{$v}{CODE} if *{$v}{CODE} &amp;&amp; $k ne &#x0027;new&#x0027;;
    }
};

sub new {
    my ($class, $app) = (shift, shift);
    # Force RobotUA configuration.
    local @LWP::UserAgent::WithCache::ISA = (&#x0027;LWP::RobotUA&#x0027;);
    return $class-&gt;SUPER::new(
        $app,
        delay =&gt; 1, # be very nice -- max one hit per minute.
    );
}
</pre>

<p>The <code>do</code> block is where I do the fuck typing. It iterates over all the symbols in LWP::RobotUA, inserts a reference to all subroutines into the current package. Except for <code>new</code>, which I implement myself. This is so that I can keep my inheritance from MyApp::UA intact. But in order for it to properly configure the LWP::RobotUA interface, <code>new</code> must temporarily fool Perl into thinking that LWP::UserAgent::WithCache inherits from LWP::RobotUA.</p>

<p>Pure evil, right? Wait, it gets worse. I've also overridden LWP::RoboUA’s <code>host_wait</code> method, because if it’s the second request to a given host, I don’t want it to sleep (the first request is for the <code>robots.txt</code>, and I see no reason to sleep after that). So I had to modify the <code>do</code> block to skip both <code>new</code> and <code>host_wait</code>:</p>

<pre>
    while ( my ($k, $v) = each %{&#x0027;LWP::RobotUA::&#x0027;} ) {
        *{$k} = *{$v}{CODE} if *{$v}{CODE} &amp;&amp; $k !~ /^(?:new|host_wait)$/;
    }
</pre>

<p>If I “override” any other LWP::RobotUA methods, I'll need to remember to add them to that regex. Of course, since I'm not actually inheriting from LWP::RobotUA, in order to dispatch to its <code>host_wait</code> method, I can’t use <code>SUPER</code>, but must dispatch directly:</p>

<pre>
sub host_wait {
    my ($self, $netloc) = @_;
    # First visit is for robots.txt, so let it be free.
    return if !$netloc || $self-&gt;no_visits($netloc) &lt; 2;
    $self-&gt;LWP::RobotUA::host_wait($netloc);
}
</pre>

<p>Ugly, right? Yes, I am an evil bastard. “Fuck typing” is right, yo! At least it’s all encapsulated.</p>

<p>This just reinforces <a href="http://www.modernperlbooks.com/mt/2010/05/are-objects-black-blocks-or-toolkits.html">chromatic’s message</a> in my mind. I'd sure love to see LWP reworked to use <a href="http://search.cpan.org/~rgarcia/perl-5.10.0/lib/UNIVERSAL.pm#$obj-%3EDOES(_ROLE_">roles</a>!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/fuck-typing-lwp.html">old layout</a>.</small></p>


