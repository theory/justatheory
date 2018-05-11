--- 
date: 2004-06-18T05:11:18Z
slug: bricolage-module-build-args
title: Fun with Module::Build Argument Processing
aliases: [/bricolage/dev/module_build_args.html]
tags: [Bricolage, Module::Build]
---

<p>I've spend the better part of the last two days working on a custom
subclass of <code>Module::Build</code> to build Bricolage 2.0. It's going to be a lot nicer
than the nasty custom <em>Makefile</em> that Bricolage 1.x uses. The
reason I'm creating a custom subclass of <code>Module::Build</code> is to be able to do
a lot of the extra stuff that building Bricolage requires. Such as:</p>

<ul>
  <li>Copying configuration files from <em>conf/</em> into <em>blib</em></li>
  <li>Copying configuration files from <em>conf/</em> into <em>t</em> for testing</li>
  <li>Copying configuration files from <em>comp/</em> into <em>blib</em></li>
  <li>Modifying Bricolage::Util::Config to contain a hard-coded reference to the location of <em>bricolage.conf</em> once Bricolage has been installed</li>
  <li>Modifying the contents of <em>bricolage.conf</em> to reflect build options (forthcoming)</li>
  <li>Modifying the contents of <em>httpd.conf</em> to reflect build options (forthcoming)</li>
</ul>

<p>I'm sure there will be more as Bricolage develops (such as building the
database!), but this is enough for now. I've also been hacking on
<code>Module::Build</code> itself to add features I want. For example, I want users to be
able to pass options to <em>Build.PL</em> when they call it, so that it can do
silent installs. As it is, you can pass options now, but <code>Module::Build</code>'s option
processing lacks flexibility. For example, you can pass options like this:</p>

<pre>perl Build.PL opt1=val1 opt2=val2</pre>

<p>And <code>Module::Build</code> will store the options in a hash like this:</p>

<pre>{ &quot;opt1&quot; => &quot;val1&quot;,
  &quot;opt2&quot; => &quot;val2&quot; }</pre>

<p>It understands options that use <code>--</code>, too; This invocation</p>

<pre>perl Build.PL --opt1 val1 --opt2 val2</pre>

<p>produces the same hash. But be careful how you specify arguments! For
example, Modul::Build doesn't understand unary options or options that use
both <code>--</code> and <code>=></code>! To whit, this invocation</p>

<pre>perl Build.PL --loud --opt1=val1 --opt2=val2 --foobar</pre>

<p>Yields a hash like this:</p>

<pre>{ &quot;loud => &quot;--opt1=val1&quot;,
  &quot;opt2=val2&quot; => &quot;--foobar&quot; }</pre>

<p>Certainly not what I would expect! So to get great flexibility, I <a
href="http://sourceforge.net/mailarchive/message.php?msg_id=8747106"
title="SourceForge fails to make available my Module::Build/Getopt::Long
patch">sent a patch</a> to the <code>Module::Build</code> mail list adding a new parameter
to <code>new()</code>:
<code>get_options</code>. This is an array reference of options that will be
passed to <code>Getopt::Long::GetOptions()</code> before <code>Module::Build</code> parses
arguments. It stores the results in the same hash as Module::Build normally
does, and options not specified in <code>get_options</code> will be processed
by <code>Module::Build</code> just as before. But it gives a whole lot more control over
what gets grabbed. For example, if I were to try to get that last example to
do what I want, all I'd need to do is pass in the appropriate
<code>Getopt::Long</code> specs:</p>

<pre>my $build = Module::Build->new(
    module_name => &quot;Spangly&quot;,
    get_options => [ &quot;loud+&quot;, &quot;opt1=s&quot;, &quot;opt2=s&quot;, &quot;foobar&quot; ],
);</pre>

<p>Now, the hash yielded is:</p>

<pre>{ &quot;loud   => &quot;1&quot;,
  &quot;opt1&quot;   => &quot;val1&quot;,
  &quot;opt2&quot;   => &quot;val2&quot;,
  &quot;foobar&quot; => &quot;1&quot; }</pre>

<p>Isn't that nicer? And because the full suite of <code>Getopt::Long</code>
specification is supported, you can get even fancier:</p>

<pre>my $loud = 0;
my $build = Module::Build->new(
    module_name => &quot;Spangly&quot;,
    get_options => [ &quot;loud+&quot; => \$loud, &quot;foobar!&quot; ],
);</pre>

<p>Now this invocation:</p>

<pre>perl Build.PL --loud --loud --nofoobar</pre>

<p>...sets the <code>$loud</code>scalar to <code>2</code>, while the args hash
is simply <code>{ &quot;foobar&quot; => &quot;0&quot; }</code>. Cool, eh?</p>

<p>Now I've just been discussing the patch with Dave Rolsky on the mail list,
and he argues that, while this is a good idea in principal, he'd rather see a
data-structure based argument list rather than <code>Getopt::Long</code>'s
magical strings. Perhaps <code>Module::Build</code> will end up <q>Borging</q> some of the
ideas from <code>Getopt::Simple</code>. But either way, I think that better
argument processing is on the way for <code>Module::Build</code>.</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/dev/module_build_args.html">old layout</a>.</small></p>


