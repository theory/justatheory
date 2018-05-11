--- 
date: 2005-07-19T16:18:50Z
slug: bricolage-1.8.6
title: Bricolage 1.8.6 Released
aliases: [/bricolage/1.8.6.html]
tags: [Bricolage, Perl, Content Management, Content Managment]
---

<p>The Bricolage development team is pleased to announce the release of
Bricolage 1.8.6. This maintenance release addresses numerous minor issues in
Bricolage 1.8.5 and adds a number of improvements, including SOAP, document
expiration, and <em>bric_queued</em> fixes. The most important changes
include:</p>

<h3>Improvements</h3>

<ul>
<li>Added JavaScript code to validate that the username in the user profile does not have leading or trailing spaces.
[David]</li>

<li>Events in the event log are now returned (and displayed) in reverse
chronological order. [David]</li>

<li>The SOAP server now uses a user's template sandbox when executing previews
(such as with <code>bric_soap --to-preview workflow publish</code>). Reported
by Marshall. [David]</li>

<li>Bric::Biz::Workflow now caches calls to <code>allowed_desks()</code>. This
will allow desks to render <i>much</i> Faster, since most assets on a desk
will list the same desks in the <q>Move to</q> select lists. [David]</li>

<li>When the <code>PUBLISH_RELATED_ASSETS</code> <em>bricolage.conf</em>
directive is enabled, aliases are now also republished. Only aliases that have
previously been published will be republished, and only the last published
version will be republished, rather than any versions created since the last
publish. Suggested by Serge Sozonoff. [David]</li>

<li>A story or media document published with an expire date earlier than the
scheduled publish time no longer bothers with the publish but just expires the
story or media document. [David]</li>

<li>Media documents without an associated media file will no longer be
displayed in the search results when attempting to relate a media document to
an element. Reported by Adam Rinehart. [David]</li>
</ul>

<h3>Bug Fixes</h3>

<ul>
<li>Form validation and group management now properly work in the user
profile. [David]</li>

<li>The SFTP mover now works with <code>bric_queued</code>. [David]</li>

<li>Cloned stories now properly set the <code>published_version</code>
attribute to <code>undef</code> rather than the value of the original story,
thus preventing the clone from having a published version number greater than
its current version number. Reported by Nate Perry-Thistle and Joshua
Edelstein. [David and Nate Perry-Thistle]</li>

<li>When a category is added to a story that creates a URI conflict, the new
category does not remain associated with the story in the story profile after
the conflict error has been thrown. Reported by Paul Orrock. [David]</li>

<li>Contributor groups created in the contributor profile are no longer
missing from the contributor manager search interface. Reported by Rachel
Murray and Scott. [David]</li>

<li>The <em>favicon.ico</em> works again. [David]</li>

<li>Stories are now properly expired when
the <code>BRIC_QUEUED</code> <em>bricolage.conf</em> directive is enabled.
Reported by Scott. [David]</li>

<li>When a template is checked out of the library and then the checkout is
canceled, it is no longer left on the desk it was moved into upon the
checkout, but properly reshelved. Reported by Marshall. [David]</li>

<li>Super Bulk Edit now works for media as well as stories. Reported by Scott.
[David]</li>

<li>When a template is moved to a new category, the old version of the
template is undeployed when the new version is deployed to the new category.
The versions in the sandbox are properly synced, as well.</li>
</ul>

<p>For a complete list of the changes, see the <a
href="http://www.bricolage.cc/news/announce/changes/bricolage-1.8.6/">changes</a>.
For the complete history of ongoing changes in Bricolage, see <a
href="http://www.bricolage.cc/docs/api/current/Bric::Changes">Bric::Changes</a>.</p>

<p>Download Bricolage 1.8.6 now from the Bricolage Web site <a
href="http://www.bricolage.cc/downloads/">Downloads page</a>, from the <a
href="http://sourceforge.net/project/showfiles.php?group_id=34789">SourceForge
download page</a>, and from the <a
href="http://www.kineticode.com/bricolage/index2.html">Kineticode download
page</a>.</p>

<h3>About Bricolage</h3>

<p>Bricolage is a full-featured, enterprise-class content management and
publishing system. It offers a browser-based interface for ease-of use, a
full-fledged templating system with complete HTML::Mason, HTML::Template, and
Template Toolkit support for flexibility, and many other features. It operates
in an Apache/mod_perl environment and uses the PostgreSQL RDBMS for its
repository. A comprehensive, actively-developed open source CMS, Bricolage has
been hailed as <q>quite possibly the most capable enterprise-class open-source
application available</q> by <i>eWEEK</i>.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/1.8.6.html">old layout</a>.</small></p>


