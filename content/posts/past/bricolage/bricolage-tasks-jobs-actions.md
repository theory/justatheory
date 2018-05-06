--- 
date: 2004-06-02T01:30:51Z
slug: bricolage-tasks-jobs-actions
title: Bricolage Tasks, Jobs, Actions, and Alerts
aliases: [/bricolage/design/tasks_jobs_actions.html]
tags: [Bricolage, design, callbacks, work]
---

<p>I've been working on the design for what are called distribution jobs and
alerts in Bricolage 1.x. There were some good ideas there. Distribution jobs
enable users to set up a list of tasks to execute against the files being
distributed, such as validating them against a DTD or distributing them via
email. It also allowed developers to create fairly simple plugin modules that
could be added as new jobs. Alerts are great ways of letting users know that
some even has happened, and their rules-based evaluation of event attributes is
a powerful way of configuring alerts to be sent only for certain events logged
for certain objects.</p>

<p>The problem is that they're specific solutions to general problems.
Distribution job s are an example of scheduling arbitrary tasks to be executed,
while alerts are an example of triggering the execution of arbitrary tasks upon
the logging of an event. So what I've been working on is trying to generalize
these ideas into a simpler yet more powerful and flexible architecture. What
I've come with is this:</p>

<h3>Tasks</h3>

<p>Very simply, a task is an object of a class designed to perform a simple, um
task. Examples include publishing a document, expiring a document, sending an
alert, or validating a file against a DTD. An abstract base class,
Bricolage::Biz::Task, will establish the the interface for tasks, although its
subclasses may add their own attributes (such as the subject and message of an
alert). Each will implement an <code>execute()</code> method that will simply
carry out the task on the object passed to it. Some task classes may operate on
only one type of object (such as Task::Publish), while others may operate on
many or even all Bricolage business classes (such as Task::SendAlert). There is
no connection between task classes and events or jobs, except that the object
that called the task object's <code>execute()</code> method will be passed to
<code>execute()</code> as a second argument.</p>

<h3>Actions</h3>

<p>An action is an event-triggered series of tasks. New action types can be
created that have rules set to be evaluated against the event, just as is
currently the case for alert types in Bricolage 1.x. The difference is that
rather than being limited to sending alerts, actions types will be associated
with one or more task objects, and each of those tasks will be executed in
sequence when an action of that type is triggered. This will enable users to,
for example, configure an action to republish an index document whenever a story
document is published.</p>

<h3>Jobs</h3>

<p>A job is a scheduled series of tasks. Users will be able to create new jobs
for any single object in Bricolage, associate any number of task objects, and
then schedule the job to be run at some specific date and time in the future.
This approach will enable users to, for example, schedule a job to send an alert
about a given document one year in the future, as a reminder to update the
document.</p>

<h3>Destinations</h3>

<p>Destinations will be similar to what's currently in Bricolage 1.x. However,
rather than having <q>job</q> classes specific to distribution, they'll be able
to specify a list of any tasks that are designed to be executed against an output
file. This keeps the interface for tasks identical across all three uses.</p>

<h3>Alerts</h3>

<p>Alerts are no longer closely tied to events, since they can sent as part of a
scheduled job or as part of a distribution to a destination in addition to when
an event is logged. Rather, they will only be created by
Bricolage::Biz::Task::SendAlert. So a Bricolage business object can have any
number of associated alerts, just as it can have any number of associated
events.</p>

<h3>Upshot</h3>

<p>The upshot of this redesign, which took me several days of thinking to tease
out to be general enough to satisfy me, is that more users will have more of
what they need from Bricolage, and developers can more easily add new
functionality that's immediately available to event actions, scheduled jobs, and
distribution destinations.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/bricolage/design/tasks_jobs_actions.html">old layout</a>.</small></p>


