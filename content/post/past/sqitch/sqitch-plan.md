--- 
date: 2012-05-22T21:31:46Z
slug: sqitch-plan
title: "Sqitch Update: The Plan"
aliases: [/computers/databases/sqitch-plan.html]
tags: [Sqitch, SQL, database, VCS, Git]
type: post
---

<p>I gave my first presentation on Sqitch at <a href="http://pgcon.org/">PGCon</a> last week. The slides are <a href="https://www.slideshare.net/justatheory/sqitch-pgconsimple-sql-change-management-with-sqitch">on Slideshare</a> and <a href="https://www.pgcon.org/2012/schedule/events/479.en.html">the PGCon site</a>. It came together at the last minute, naturally. I was not able to pay as close attention to PGCon sessions as I would have liked, as I was doing last minute hacking to get the <code>deploy</code> command working on PostgreSQL, and then writing the slides (which are based on <a href="http://search.cpan.org/dist/App-Sqitch/lib/sqitchtutorial.pod">the tutorial</a>). I was pleased with the response, given that this is very much a project that is still under heavy development and available only as a very very early alpha. There was great discussion and feedback afterward, which I appreciate.</p>

<p>A number of folks offered to help, too. For that I am grateful. I’ve started a list of <a href="https://github.com/theory/sqitch/issues?labels=todo&amp;page=1&amp;state=open">to-dos</a> to give folks a starting point. Please fork and hack! Find me on #sqitch on Freenode for questions/comments/discussion.</p>

<p>But back to the guts. As a result of the work on the <code>deploy</code> command, as well as thinking about how I and my co-workers do database development with Git, I am starting to revise how I think about the deployment plan. You see, I personally often make a <em>lot</em> of changes to a deployment script as I develop a database, generally over many commits and even many days or weeks. If I were to then rely on the Git history to do deployments, it would probably work, but there might be ten times as many deployments as I actually need, just to get it from zero to release state. I had originally thought that using <code>sqitch bundle --tags-only</code> to create a bundle with a written plan would get around this, as it would write a plan file with only VCS tags for Sqitch tags, rather than every commit. That might be okay for releases, but still not great for the developers, such as myself, who will be using Sqitch as part of the development process all day long.</p>

<p>So now I’m thinking more that Sqitch should rely on an explicit plan file (which was to be the preferred method, if it existed, all along) rather than VCS history. That is, the plan file would be required, and a new command, <code>sqitch plan</code>, will allow one to interactively add steps and tags to it. It would also make it easier for the developer to hand-edit, as appropriate, so as not to rely on a funky Git history.</p>

<p>So I’m toying with changing the plan format, which up until now looked likes this:</p>

<pre><code>[alpha]
foo
bar
init

[beta]
users
insert_user
delete_user
update_user

[gamma]
widgets
insert_widget
</code></pre>

<p>Each item in brackets is a tag, and each item below is a deployment step (which corresponds to a script) that is part of that tag. So if you deployed to the <code>beta</code> tag, it would deploy all the way up to <code>update_user</code> step. You could only specify tags for deployment, and either all the steps for a given tag succeeded or they failed. When you added a step, it was added to the most recent tag.</p>

<p>I came up with this approach by <a href="/computers/databases/vcs-sql-change-management.html">playing with <code>git log</code></a>. But now I’m starting to think that it should feel a bit more gradual, where steps are added and a tag is applied to a certain step. Perhaps a format like this:</p>

<pre><code>foo
bar
init
@alpha

users
insert_user
delete_user
update_user
@beta

widgets
insert_widget
</code></pre>

<p>With this approach, one could deploy or revert to any step or tag. And a tag is just added to a particular step. So if you deployed to <code>@beta</code>, it would run all the steps through <code>update_user</code>, as before. But you could also update all, deploy through <code>insert_widget</code>, and then the current deployed point in the database would not have a tag (could perhaps use a symbolic tag, <code>HEAD</code>?).</p>

<p>I like this because it feels a bit more VCS-y. It also makes it easier to add steps to the plan without worrying about tagging before one  was ready. And adding steps and tags can be automated by a <code>sqitch plan</code> command pretty easily.</p>

<p>So the plan file becomes the canonical source for deployment planning, and is required. What we’ve lost, however, is the ability to use the same step name at different points in the plan, and to get the proper revision of the step by traveling back in VCS history for it. (Examples of what I mean are covered in <a href="/computers/databases/sql-change-management-sans-redundancy.html">a previous post</a>, as well as the aforementioned <a href="https://www.pgcon.org/2012/schedule/events/479.en.html">presentation</a>.) However, I think that we can still do that by <em>complementing</em> the plan with VCS history.</p>

<p>For example, take this plan:</p>

<pre><code>foo
bar
init
@alpha

users
insert_user
delete_user
update_user
@beta

insert_user
update_user
@gamma
</code></pre>

<p>Note how <code>insert_user</code> and <code>update_user</code> repeat. Normally, this would not be allowed. But <em>if</em> the plan is in a VCS, and <em>if</em> that VCS has tags corresponding to the tags, <em>then</em> we might allow it: when deploying, each step would be deployed at the point in time of the tag that follows it. In other words:</p>

<ul>
<li><code>foo</code>, <code>bar</code>, and <code>init</code> would be deployed as of the <code>alpha</code> tag.</li>
<li><code>users</code>, <code>insert_user</code>, <code>delete_user</code>, and <code>update_user</code> would be deployed as they were as of the <code>beta</code> tag.</li>
<li><code>insert_user</code> and <code>update_user</code> would again be deployed, this time as of the <code>gamma</code> tag.</li>
</ul>


<p>This is similar to what I’ve described before, in terms of where in VCS history steps are read from. But whereas before I was using the VCS history to derive the plan, I am here reversing things, requiring an explicit plan and using its hints (tags) to pull stuff from the VCS history as necessary.</p>

<p>I think this could work. I am not sure if I would require that all tags be present, or only those necessary to resolve duplications (both approaches feel a bit magical to me, though I haven’t tried it yet, either). The latter would probably be more forgiving for users. And overall, I think the whole approach is less rigid, and more likely to allow developers to work they way they are used to working.</p>

<p>But I could be off my rocker entirely. What do <em>you</em> think? I want to get this right, please, if you have an opinion here, let me have it!</p>
