--- 
date: 2012-04-06T02:08:40Z
slug: sqitch-draft
title: ''
aliases: [/computers/databases/sqitch-draft.html]
tags: [Sqitch, SQL, migrations, database, VCS, Git]
type: post
---

<p>Back in January, I <a href="/computers/databases/simple-sql-change-management.html">wrote</a> <a href="/computers/databases/vcs-sql-change-management.html">three</a> <a href="/computers/databases/sql-change-management-sans-redundancy.html">posts</a> outlining some ideas I had about a straight-forward, sane way of managing SQL change management. The idea revolved around specifying scripts to deploy and revert in a plan file, and generating that plan file from VCS history. I still feel pretty good about the ideas there, and <a href="http://iovation.com/">work</a> has agreed to let me write it and open-source it. Here is the first step making it happen. I call it “Sqitch.”</p>

<p>Why “Sqitch”? Think of it as SQL changes with Git stuck in the middle. Of course I expect to support VCSs other than Git (probably Subversion and Mercurial, though I am not sure yet), but since Git is what I now have the most familiarity with, I thought it kind of fun to kind of reference a VCS in the name, if only obliquely.</p>

<p>This week, I <a href="https://github.com/theory/sqitch">started work on it</a>. My first task is to outline a draft for the interface. Sqitch will be a command-line tool, primarily. The remainder of this post contains the documentation for the draft interface. Thoughts and feedback would be greatly appreciated, especially if you think I've overlooked anything! I do want to keep features pretty minimal for now, though, to build up a solid core to be built on later. But other than that, your criticism is greatly desired.</p>

<p>Next up, I will probably write a tutorial, just so I can make my way through some real-life(ish) examples and notice if I missed anything else. Besides, <a href="https://www.pgcon.org/2012/schedule/events/479.en.html">I'm going to need the tutorial myself</a>! Watch for that next week.</p>

<p>Thanks!</p>

<hr />


<h3 id="Name">Name</h3>

<p>Sqitch - VCS-powered SQL change management</p>

<h3 id="Synopsis">Synopsis</h3>

<pre><code>sqitch [&lt;options&gt;] &lt;command&gt; [&lt;command-options&gt;] [&lt;args&gt;]</code></pre>

<h3 id="Description">Description</h3>

<p>Sqitch is a VCS-aware SQL change management application. What makes it different from your typical <a href="http://search.cpan.org/perldoc?Module::Build::DB">migration</a>-<a href="http://search.cpan.org/perldoc?DBIx::Migration">style</a> approaches? A few things:</p>

<dl>

<dt>No opinions</dt>
<dd>

<p>Sqitch is not integrated with any framework, ORM, or platform. Rather, it is a standalone change management system with no opinions on your database or development choices.</p>

</dd>
<dt>Native scripting</dt>
<dd>

<p>Changes are implemented as scripts native to your selected database engine. Writing a <a href="http://postgresql.org/">PostgreSQL</a> application? Write SQL scripts for <a href="http://www.postgresql.org/docs/current/static/app-psql.html"><code>psql</code></a>. Writing a <a href="http://mysql.com/">MySQL</a>-backed app? Write SQL scripts for <a href="http://dev.mysql.com/doc/refman/5.6/en/mysql.html"><code>mysql</code></a>.</p>

</dd>
<dt>VCS integration</dt>
<dd>

<p>Sqitch likes to use your VCS history to determine in what order to execute changes. No need to keep track of execution order, your VCS already tracks information sufficient for Sqitch to figure it out for you.</p>

</dd>
<dt>Dependency resolution</dt>
<dd>

<p>Deployment steps can declare dependencies on other deployment steps. This ensures proper order of execution, even when you&#39;ve committed changes to your VCS out-of-order.</p>

</dd>
<dt>No numbering</dt>
<dd>

<p>Change deployment is managed either by maintaining a plan file or, more usefully, your VCS history. As such, there is no need to number your changes, although you can if you want. Sqitch does not care what you name your changes.</p>

</dd>
<dt>Packaging</dt>
<dd>

<p>Using your VCS history for deployment but need to ship a tarball or RPM? Easy, just have Sqitch read your VCS history and write out a plan file with your change scripts. Once deployed, Sqitch can use the plan file to deploy the changes in the proper order.</p>

</dd>
<dt>Reduced Duplication</dt>
<dd>

<p>If you&#39;re using a VCS to track your changes, you don&#39;t have to duplicate entire change scripts for simple changes. As long as the changes are <a href="https://en.wikipedia.org/wiki/Idempotence">idempotent</a>, you can change your code directly, and Sqitch will know it needs to be updated.</p>

</dd>
</dl>

<h4 id="Terminology">Terminology</h4>

<dl>

<dt><code>step</code></dt>
<dd>

<p>A named unit of change. A step name must be used in the file names of its corresponding deployment and a reversion scripts. It may also be used in a test script file name.</p>

</dd>
<dt><code>tag</code></dt>
<dd>

<p>A known deployment state with a list one or more steps that define the tag. A tag also implies that steps from previous tags in the plan have been applied. Think of it is a version number or VCS revision. A given point in the plan may have one or more tags.</p>

</dd>
<dt><code>state</code></dt>
<dd>

<p>The current state of the database. This is represented by the most recent tag or tags deployed. If the state of the database is the same as the most recent tag, then it is considered &quot;up-to-date&quot;.</p>

</dd>
<dt><code>plan</code></dt>
<dd>

<p>A list of one or more tags and associated steps that define the order of deployment execution. Sqitch reads the plan to determine what steps to execute to change the database from one state to another. The plan may be represented by a <a href="#Plan-File">&quot;Plan File&quot;</a> or by VCS history.</p>

</dd>
<dt><code>deploy</code></dt>
<dd>

<p>The act of deploying database changes to reach a tagged deployment point. Sqitch reads the plan, checks the current state of the database, and applies all the steps necessary to change the state to the specified tag.</p>

</dd>
<dt><code>revert</code></dt>
<dd>

<p>The act of reverting database changes to reach an earlier tagged deployment point. Sqitch checks the current state of the database, reads the plan, and applies reversion scripts for all steps to return the state to an earlier tag.</p>

</dd>
</dl>

<h3 id="Options">Options</h3>

<pre><code>-p --plan-file  FILE    Path to a deployment plan file.
-e --engine     ENGINE  Database engine.
-c --client     PATH    Path to the engine command-line client.
-d --db-name    NAME    Database name.
-u --username   USER    Database user name.
-h --host       HOST    Database server host name.
-n --port       PORT    Database server port number.
   --sql-dir    DIR     Path to directory with deploy and revert scripts.
   --deploy-dir DIR     Path to directory with SQL deployment scripts.
   --revert-dir DIR     Path to directory with SQL reversion scripts.
   --test-dir   DIR     Path to directory with SQL test scripts.
   --extension  EXT     SQL script file name extension.
   --dry-run            Execute command without making any changes.
-v --verbose            Increment verbosity.
-V --version            Print the version number and exit.
-H --help               Print a usage statement and exit.
-M --man                Print the complete documentation and exit.</code></pre>

<h3 id="Options-Details">Options Details</h3>

<dl>

<dt><code>-p</code></dt>
<dd>

</dd>
<dt><code>--plan-file</code></dt>
<dd>

<pre><code>sqitch --plan-file plan.conf
sqitch -p sql/deploy.conf</code></pre>

<p>Path to the deployment plan file. Defaults to <i>./sqitch.plan</i>. If this file is not present, Sqitch will attempt to read from VCS files. If no supported VCS system is in place, an exception will be thrown. See <a href="#Plan-File">&quot;Plan File&quot;</a> for a description of its structure.</p>

</dd>
<dt><code>-e</code></dt>
<dd>

</dd>
<dt><code>--engine</code></dt>
<dd>

<pre><code>sqitch --engine pg
sqitch -e sqlite</code></pre>

<p>The database engine to use. Supported engines include:</p>

<ul>

<li><p><code>pg</code> - <a href="http://postgresql.org/">PostgreSQL</a></p>

</li>
<li><p><code>mysql</code> - <a href="http://mysql.com/">MySQL</a></p>

</li>
<li><p><code>sqlite</code> - <a href="http://sqlite.org/">SQLite</a></p>

</li>
</ul>

</dd>
<dt><code>-c</code></dt>
<dd>

</dd>
<dt><code>--client</code></dt>
<dd>

<pre><code>sqitch --client /usr/local/pgsql/bin/psql
sqitch -c /usr/bin/sqlite3</code></pre>

<p>Path to the command-line client for the database engine. Defaults to a client in the current path named appropriately for the specified engine.</p>

</dd>
<dt><code>-d</code></dt>
<dd>

</dd>
<dt><code>--db-name</code></dt>
<dd>

<p>Name of the database. For some engines, such as <a href="http://postgresql.org/">PostgreSQL</a> and <a href="http://mysql.com/">MySQL</a>, the database must already exist. For others, such as <a href="http://sqlite.org/">SQLite</a>, the database will be automatically created on first connect.</p>

</dd>
<dt><code>-u</code></dt>
<dd>

</dd>
<dt><code>--user</code></dt>
<dd>

</dd>
<dt><code>--username</code></dt>
<dd>

<p>User name to use when connecting to the database. Does not apply to all engines.</p>

</dd>
<dt><code>-h</code></dt>
<dd>

</dd>
<dt><code>--host</code></dt>
<dd>

<p>Host name to use when connecting to the database. Does not apply to all engines.</p>

</dd>
<dt><code>-n</code></dt>
<dd>

</dd>
<dt><code>--port</code></dt>
<dd>

<p>Port number to connect to. Does not apply to all engines.</p>

</dd>
<dt><code>--sql-dir</code></dt>
<dd>

<pre><code>sqitch --sql-dir migrations/</code></pre>

<p>Path to directory containing deployment, reversion, and test SQL scripts. It should contain subdirectories named <code>deploy</code>, <code>revert</code>, and (optionally) <code>test</code>. These may be overridden by <code>--deploy-dir</code>, <code>--revert-dir</code>, and <code>--test-dir</code>. Defaults to <code>./sql</code>.</p>

</dd>
<dt><code>--deploy-dir</code></dt>
<dd>

<pre><code>sqitch --deploy-dir db/up</code></pre>

<p>Path to a directory containing SQL deployment scripts. Overrides the value implied by <code>--sql-dir</code>.</p>

</dd>
<dt><code>--revert-dir</code></dt>
<dd>

<pre><code>sqitch --revert-dir db/up</code></pre>

<p>Path to a directory containing SQL reversion scripts. Overrides the value implied by <code>--sql-dir</code>.</p>

</dd>
<dt><code>--test-dir</code></dt>
<dd>

<pre><code>sqitch --test-dir db/t</code></pre>

<p>Path to a directory containing SQL test scripts. Overrides the value implied by <code>--sql-dir</code>.</p>

</dd>
<dt><code>--extension</code></dt>
<dd>

<pre><code>sqitch --extension ddl</code></pre>

<p>The file name extension on deployment, reversion, and test SQL scripts. Defaults to <code>sql</code>.</p>

</dd>
<dt><code>--dry-run</code></dt>
<dd>

<pre><code>sqitch --dry-run</code></pre>

<p>Execute the Sqitch command without making any actual changes. This allows you to see what Sqitch would actually do, without doing it. Implies a verbosity level of 1; add extra <code>--verbose</code>s for greater verbosity.</p>

</dd>
<dt><code>-v</code></dt>
<dd>

</dd>
<dt><code>--verbose</code></dt>
<dd>

<pre><code>sqitch --verbose -v</code></pre>

<p>A value between 0 and 3 specifying how verbose Sqitch should be. The default is 0, meaning that Sqitch will be silent. A value of 1 causes Sqitch to output some information about what it&#39;s doing, while 2 and 3 each cause greater verbosity.</p>

</dd>
<dt><code>-H</code></dt>
<dd>

</dd>
<dt><code>--help</code></dt>
<dd>

<pre><code>sqitch --help
sqitch -H</code></pre>

<p>Outputs a brief description of the options supported by <code>sqitch</code> and exits.</p>

</dd>
<dt><code>-M</code></dt>
<dd>

</dd>
<dt><code>--man</code></dt>
<dd>

<pre><code>sqitch --man
sqitch -M</code></pre>

<p>Outputs this documentation and exits.</p>

</dd>
<dt><code>-V</code></dt>
<dd>

</dd>
<dt><code>--version</code></dt>
<dd>

<pre><code>sqitch --version
sqitch -V</code></pre>

<p>Outputs the program name and version and exits.</p>

</dd>
</dl>

<h3 id="Sqitch-Commands">Sqitch Commands</h3>

<dl>

<dt><code>init</code></dt>
<dd>

<p>Initialize the database and create deployment script directories if they do not already exist.</p>

</dd>
<dt><code>status</code></dt>
<dd>

<p>Output information about the current status of the deployment, including a list of tags, deployments, and dates in chronological order. If any deploy scripts are not currently deployed, they will be listed separately.</p>

</dd>
<dt><code>check</code></dt>
<dd>

<p>Sanity check the deployment scripts. Checks include:</p>

<ul>

<li><p>Make sure all deployment scripts have complementary reversion scripts.</p>

</li>
<li><p>Make sure no deployment script appears more than once in the plan file.</p>

</li>
</ul>

</dd>
<dt><code>deploy</code></dt>
<dd>

<p>Deploy changes. Configuration properties may be specified under the <code>[deploy]</code> section of the configuration file, or via <code>sqitch config</code>:</p>

<pre><code>sqitch config deploy.$property $value</code></pre>

<p>Options and configuration properties:</p>

<dl>

<dt><code>--to</code></dt>
<dd>

<p>Tag to deploy up to. Defaults to the latest tag or to the VCS <code>HEAD</code> commit. Property name: <code>deploy.to</code>.</p>

</dd>
</dl>

</dd>
<dt><code>revert</code></dt>
<dd>

<p>Revert changes. Configuration properties may be specified under the <code>[revert]</code> section of the configuration file, or via <code>sqitch config</code>:</p>

<pre><code>sqitch config revert.$property $value</code></pre>

<p>Options and configuration properties:</p>

<dl>

<dt><code>--to</code></dt>
<dd>

<p>Tag to revert to. Defaults to reverting all changes. Property name: <code>revert.to</code>.</p>

</dd>
</dl>

</dd>
<dt><code>test</code></dt>
<dd>

<p>Test changes. All SQL scripts in <code>--test-dir</code> will be run. [XXX Not sure whether to have subdirectories for tests and expected output and to diff them, or to use some other approach.]</p>

</dd>
<dt><code>config</code></dt>
<dd>

<p>Set configuration options. By default, the options will be written to the local configuration file, <i>sqitch.ini</i>. Options:</p>

<dl>

<dt><code>--get</code></dt>
<dd>

<p>Get the value for a given key. Returns error code 1.</p>

</dd>
<dt><code>--unset</code></dt>
<dd>

<p>Remove the line matching the key from config file.</p>

</dd>
<dt><code>--list</code></dt>
<dd>

<p>List all variables set in config file.</p>

</dd>
<dt><code>--global</code></dt>
<dd>

<p>For writing options: write to global <i>~/.sqitch/config.ini</i> file rather than the local <i>sqitch.ini</i>.</p>

<p>For reading options: read only from global <i>~/.sqitch/config.ini</i> rather than from all available files.</p>

</dd>
<dt><code>--system</code></dt>
<dd>

<p>For writing options: write to system-wide <i>$prefix/etc/sqitch.ini</i> file rather than the local <i>sqitch.ini</i>.</p>

<p>For reading options: read only from system-wide <i>$prefix/etc/sqitch.ini</i> rather than from all available files.</p>

</dd>
<dt><code>--config-file</code></dt>
<dd>

<p>Use the given config file.</p>

</dd>
</dl>

</dd>
<dt><code>package</code></dt>
<dd>

<p>Package up all deployment and reversion scripts and write out a plan file. Configuration properties may be specified under the <code>[package]</code> section of the configuration file, or via <code>sqitch config package.$property $value</code> command. Options and configuration properties:</p>

<dl>

<dt><code>--from</code></dt>
<dd>

<p>Tag to start the plan from. All tags and steps prior to that tag will not be included in the plan, and their change scripts Will be omitted from the package directory. Useful if you&#39;ve rejiggered your deployment steps to start from a point later in your VCS history than the beginning of time. Property name: <code>package.from</code>.</p>

</dd>
<dt><code>--to</code></dt>
<dd>

<p>Tag with which to end the plan. No steps or tags after that tag will be included in the plan, and their change scripts will be omitted from the package directory. Property name: <code>package.to</code>.</p>

</dd>
<dt><code>--tags-only</code></dt>
<dd>

<p>Write the plan file with deployment targets listed under VCS tags, rather than individual commits. Property name: <code>package.tags_only</code>.</p>

</dd>
<dt><code>--destdir</code></dt>
<dd>

<p>Specify a destination directory. The plan file and <code>deploy</code>, <code>revert</code>, and <code>test</code> directories will be written to it. Defaults to &quot;package&quot;. Property name: <code>package.destdir</code>.</p>

</dd>
</dl>

</dd>
</dl>

<h3 id="Configuration">Configuration</h3>

<p>Sqitch configuration information is stored in standard <code>INI</code> files. The <code>#</code> and <code>;</code> characters begin comments to the end of line, blank lines are ignored.</p>

<p>The file consists of sections and properties. A section begins with the name of the section in square brackets and continues until the next section begins. Section names are not case sensitive. Only alphanumeric characters, <code>-</code> and <code>.</code> are allowed in section names. Each property must belong to some section, which means that there must be a section header before the first setting of a property.</p>

<p>All the other lines (and the remainder of the line after the section header) are recognized as setting properties, in the form <code>name = value</code>. Leading and trailing whitespace in a property value is discarded. Internal whitespace within a property value is retained verbatim.</p>

<p>All sections are named for commands except for one, named &quot;core&quot;, which contains core configuration properties.</p>

<p>Here&#39;s an example of a configuration file that might be useful checked into a VCS for a project that deploys to PostgreSQL and stores its deployment scripts with the extension <i>ddl</i> under the <code>migrations</code> directory. It also wants packages to be created in the directory <i>_build/sql</i>, and to deploy starting with the &quot;gamma&quot; tag:</p>

<pre><code>[core]
    engine    = pg
    db        = widgetopolis
    sql_dir   = migrations
    extension = ddl

[revert]
    to        = gamma

[package]
    from      = gamma
    tags_only = yes
    dest_dir  = _build/sql</code></pre>

<h4 id="Core-Properties">Core Properties</h4>

<p>This is the list of core variables, which much appear under the <code>[core]</code> section. See the documentation for individual commands for their configuration options.</p>

<dl>

<dt><code>plan_file</code></dt>
<dd>

<p>The plan file to use. Defaults to <i>sqitch.ini</i> or, if that does not exist, uses the VCS history, if available.</p>

</dd>
<dt><code>engine</code></dt>
<dd>

<p>The database engine to use. Supported engines include:</p>

<ul>

<li><p><code>pg</code> - <a href="http://postgresql.org/">PostgreSQL</a></p>

</li>
<li><p><code>mysql</code> - <a href="http://mysql.com/">MySQL</a></p>

</li>
<li><p><code>sqlite</code> - <a href="http://sqlite.org/">SQLite</a></p>

</li>
</ul>

</dd>
<dt><code>client</code></dt>
<dd>

<p>Path to the command-line client for the database engine. Defaults to a client in the current path named appropriately for the specified engine.</p>

</dd>
<dt><code>db_name</code></dt>
<dd>

<p>Name of the database.</p>

</dd>
<dt><code>username</code></dt>
<dd>

<p>User name to use when connecting to the database. Does not apply to all engines.</p>

</dd>
<dt><code>password</code></dt>
<dd>

<p>Password to use when connecting to the database. Does not apply to all engines.</p>

</dd>
<dt><code>host</code></dt>
<dd>

<p>Host name to use when connecting to the database. Does not apply to all engines.</p>

</dd>
<dt><code>port</code></dt>
<dd>

<p>Port number to connect to. Does not apply to all engines.</p>

</dd>
<dt><code>sql_dir</code></dt>
<dd>

<p>Path to directory containing deployment, reversion, and test SQL scripts. It should contain subdirectories named <code>deploy</code>, <code>revert</code>, and (optionally) <code>test</code>. These may be overridden by <code>deploy_dir</code>, <code>revert_dir</code>, and <code>test_dir</code>. Defaults to <code>./sql</code>.</p>

</dd>
<dt><code>deploy_dir</code></dt>
<dd>

<p>Path to a directory containing SQL deployment scripts. Overrides the value implied by <code>sql_dir</code>.</p>

</dd>
<dt><code>revert_dir</code></dt>
<dd>

<p>Path to a directory containing SQL reversion scripts. Overrides the value implied by <code>sql_dir</code>.</p>

</dd>
<dt><code>test_dir</code></dt>
<dd>

<p>Path to a directory containing SQL test scripts. Overrides the value implied by <code>sql_dir</code>.</p>

</dd>
<dt><code>extension</code></dt>
<dd>

<p>The file name extension on deployment, reversion, and test SQL scripts. Defaults to <code>sql</code>.</p>

</dd>
</dl>

<h3 id="Plan-File">Plan File</h3>

<p>A plan file describes the deployment tags and scripts to be run against a database. In general, if you use a VCS, you probably won&#39;t need a plan file, since your VCS history should be able to provide all the information necessary to derive a deployment plan. However, if you really do need to maintain a plan file by hand, or just want to better understand the file as output by the <code>package</code> command, read on.</p>

<h4 id="Format">Format</h4>

<p>The contents of the plan file are plain text encoded as UTF-8. It is divided up into sections that denote deployment states. Each state has a bracketed, space-delimited list of one or more tags to identify it, followed by any number of deployment steps. Here&#39;s an example of a plan file with a single state and a single step:</p>

<pre><code>[alpha]
users_table</code></pre>

<p>The state has one tag, named &quot;alpha&quot;, and one step, named &quot;users_table&quot;. A state may of course have many steps. Here&#39;s an expansion:</p>

<pre><code>[root alpha]
users_table
insert_user
update_user
delete_user</code></pre>

<p>This state has two tags, &quot;root&quot; and &quot;alpha&quot;, and four steps, &quot;users_table&quot;, &quot;insert_user&quot;, &quot;update_user&quot;, and &quot;delete_user&quot;.</p>

<p>Most plans will have multiple states. Here&#39;s a longer example with three states:</p>

<pre><code>[root alpha]
users_table
insert_user
update_user
delete_user

[beta]
widgets_table
list_widgets

[gamma]
ftw</code></pre>

<p>Using this plan, to deploy to the &quot;beta&quot; tag, the &quot;root&quot;/&quot;alpha&quot; state steps must be deployed, as must the &quot;beta&quot; steps. To then deploy to the &quot;gamma&quot; tag, the &quot;ftw&quot; step must be deployed. If you then choose to revert to the &quot;alpha&quot; tag, then the &quot;gamma&quot; step (&quot;ftw&quot;) and all of the &quot;beta&quot; steps will be reverted in reverse order.</p>

<p>Using this model, steps cannot be repeated between states. One can repeat them, however, if the contents for a file in a given tag can be retrieved from a VCS. An example:</p>

<pre><code>[alpha]
users_table

[beta]
add_widget
widgets_table

[gamma]
add_user

[44ba615b7813531f0acb6810cbf679791fe57bf2]
widgets_created_at

[HEAD epsilon master]
add_widget</code></pre>

<p>This example is derived from a Git log history. Note that the &quot;add_widget&quot; step is repeated under the state tagged &quot;beta&quot; and under the last state. Sqitch will notice the repetition when it parses this file, and then, if it is applying all changes, will fetch the version of the file as of the &quot;beta&quot; tag and apply it at that step, and then, when it gets to the last tag, retrieve the deployment file as of its tags and apply it. This works in reverse, as well, as long as the changes in this file are always <a href="https://en.wikipedia.org/wiki/Idempotence">idempotent</a>.</p>

<h4 id="Grammar">Grammar</h4>

<p>Here is the EBNF Grammar for the plan file:</p>

<pre><code>plan-file   = { &lt;state&gt; | &lt;empty-line&gt; | &lt;comment&gt; }* ;

state       = &lt;tags&gt; &lt;steps&gt; ;

tags        = &quot;[&quot; &lt;taglist&gt; &quot;]&quot; &lt;line-ending&gt; ;
taglist     = &lt;name&gt; | &lt;name&gt; &lt;white-space&gt; &lt;taglist&gt; ;

steps       = { &lt;step&gt; | &lt;empty-line&gt; | &lt;line-ending&gt; }* ;
step        = &lt;name&gt; &lt;line-ending&gt; ;

empty-line  = [ &lt;white-space&gt; ] &lt;line-ending&gt; ;
line-ending = [ &lt;comment&gt; ] &lt;EOL&gt; ;
comment     = [ &lt;white-space&gt; ] &quot;#&quot; [ &lt;string&gt; ] ;

name        = ? non-white space characters ? ;
white-space = ? white space characters ? ;
string      = ? non-EOL characters ? ;</code></pre>

<h3 id="See-Also">See Also</h3>

<p>The original design for Sqitch was sketched out in a number of blog posts:</p>

<ul>

<li><p><a href="/computers/databases/simple-sql-change-management.html">Simple SQL Change Management</a></p>

</li>
<li><p><a href="/computers/databases/vcs-sql-change-management.html">VCS-Enabled SQL Change Management</a></p>

</li>
<li><p><a href="/computers/databases/sql-change-management-sans-redundancy.html">SQL Change Management Sans Duplication</a></p>

</li>
</ul>

<p>Other tools that do database change management include:</p>

<dl>

<dt><a href="http://guides.rubyonrails.org/migrations.html">Rails migrations</a></dt>
<dd>

<p>Numbered migrations for <a href="http://rubyonrails.org/">Ruby on Rails</a>.</p>

</dd>
<dt><a href="http://search.cpan.org/perldoc?Module::Build::DB">Module::Build::DB</a></dt>
<dd>

<p>Numbered changes in pure SQL, integrated with Perl&#39;s <a href="http://search.cpan.org/perldoc?Module::Build">Module::Build</a> build system. Does not support reversion.</p>

</dd>
<dt><a href="http://search.cpan.org/perldoc?DBIx::Migration">DBIx::Migration</a></dt>
<dd>

<p>Numbered migrations in pure SQL.</p>

</dd>
<dt><a href="http://www.depesz.com/2010/08/22/versioning/">Versioning</a></dt>
<dd>

<p>PostgreSQL-specific dependency-tracking solution by <a href="http://www.depesz.com/">depesz</a>.</p>

</dd>
</dl>

<h3 id="Author">Author</h3>

<p>David E. Wheeler &lt;david@justatheory.com&gt;</p>

<h3 id="License">License</h3>

<p>Copyright (c) 2012 iovation Inc.</p>

<p>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:</p>

<p>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.</p>

<p>THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-draft.html">old layout</a>.</small></p>


