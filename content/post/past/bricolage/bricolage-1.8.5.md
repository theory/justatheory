--- 
date: 2005-03-19T07:15:58Z
slug: bricolage-1.8.5
title: Bricolage 1.8.5 Released
aliases: [/bricolage/announce/1.8.5.html]
tags: [Bricolage, shipping, Perl, Postgres, Apache, mod_perl]
type: post
---

<p>The Bricolage development team is pleased to announce the release of
Bricolage 1.8.5. This maintenance release addresses a number of issues in
Bricolage 1.8.3 and adds a number of improvements (there was no announcement
for the short-lived 1.8.4 release). The SOAP server in particular sees
improvements in this release, with improved character set support; better
support for related stories and media using URIs in addition to IDs; and as
support for top-level element relations. Issues with the ordering of story
elements have also been corrected, as well as errors when attempting to revert
a story or media document or template. Here are the other highlights of this
release:</p>

<h3>Improvements</h3>

<ul>
<li>Added Linux startup script <em>contrib/start_scripts/linux</em>.
[David]</li>

<li>Related story and media elements managed through the SOAP server can now
use a combination of URI and site ID to identify related assets in addition to
the existing approach of using story and media IDs. [David]</li>

<li>A list of subelements is now less likely to mysteriously become out of
order and thus lead to strange action-at-a-distance errors. And even if they
do become out of order, the error message will be more appropriate
(<q>Warning! State inconsistent</q> instead of <q>Can't call method
&quot;get_name&quot; on an undefined value</q>). Reported by Curtis Poe.
[David]</li>

<li>The SOAP media interface now supports creating relationships between the
media documents elements and other story and media documents, just like the
SOAP story interface does. [David]</li>

<li>The SOAP interface now supports Related stories and media on story type
and media type elements just as in the UI. This involved the somewhat hackish
necessity for including the <q>related_story_id</q>
and <q>related_media_id</q> (or <q>related_story_uri</q>
and <q>related_media_uri</q>) attributes in the <q>elements</q> XML element,
but it does the trick. [David]</li>
</ul>

<h3>Bug Fixes</h3>

<ul>
<li>Calls to publish documents via SOAP will no longer fail if
the <code>published_version</code> attribute is not specified and the document
to be published has never been published before. [David]</li>

<li>The Bricolage virtual FTP server will no longer fail to start if Template
Toolkit is installed but its version number is less than 2.14. Reported by
Adam Rinehart. [David]</li>

<li>Stories and Media created or updated via the SOAP interface will now
associate contributors of the appropriate type, instead of <q>All
Contributors</q>. [Scott &amp; David]</li>

<li>Deleting an element that has a template no longer causes an error. Thanks
to Susan for the spot! [David]</li>

<li>Eliminated encoding errors when using the SOAP interface to output
stories, media, or templates with wide characters. Reported by Scott Lanning.
[David]</li>

<li>Reverting (stories, media, templates) no longer gives an error. Reported
by Simon Wilcox, Rachel Murray, and others. [David]</li>

<li>Publishing a published version of a document that has a later version in
workflow will no longer cause that later version to be mysteriously removed
from workflow. This could be caused by passing a document looked up using
the <code>published_version</code> to <code>list()</code>
to <code>$burner-&gt;publish_another</code> in a template. [David]</li>

<li>The SOAP server story and media interfaces now support elements that
contain both related stories and media, rather than one or the other.
[David]</li>

<li>Attempting to preview a story or media document currently checked out to
another user no longer causes an error. Reported by Paul Orrock. [David]</li>

<li>Custom fields with default values now have their values included when they
are added to stories and media. Thanks to Clare Parkinson for the spot!
[David]</li>

<li>The <code>bric_queued</code> script now requires a username and password
and will authenticate the user. This user will then be used for logging
events. All events logged when a job is run via the UI are now also logged
by <code>bric_queued</code>. [Mark and David]</li>

<li>Preview redirections now use the protocol setting of the preview output
channel if it&#x2019;s available, and falls back on using <q>http://</q> when
it&#x2019;s not, instead of using the hard-coded <q>http://</q>. Thanks to
Martin Bacovsky for the spot! [David]</li>

<li>The <code>has_keyword()</code> method in the Business class (from which
the story and media classes inherit) now works. Thanks to Clare Parkinson for
the spot! [David]</li>

<li>Clicking a link in the left-side navigation after the session has expired
now causes the whole window to show the login form, rather than it showing
inside the nav frame, which was useless. [Marshall]</li>

<li>The JavaScript that validates form contents once again works with
htmlArea, provided htmlArea itself is patched. See the relevant <a
href="http://sourceforge.net/tracker/index.php?func=detail&amp;aid=1155712&amp;group_id=69750&amp;atid=525656">htmlArea
bug report</a> for the patch. As of this writing, you must run the version of
htmlArea in CVS. [David &amp; Marshall]</li>

<li>The JavaScript that handles the double list manager has been vastly
optimized. It should now be able to better handle large lists, such as a list
of thousands of categories. Reported by Scott. [Marshall]</li>

<li>Uploading a new image to a media document with a different media type than
the previous image no longer causes an Imager error. [David]</li>
</ul>

<p>For a complete list of the changes, see the <a
href="http://www.bricolage.cc/news/announce/changes/bricolage-1.8.5/">changes</a>.
For the complete history of ongoing changes in Bricolage, see <a
href="http://www.bricolage.cc/docs/api/current/Bric::Changes">Bric::Changes</a>.</p>

<p>Download Bricolage 1.8.5 now from the Bricolage Web site <a
href="http://www.bricolage.cc/downloads/">Downloads page</a>, from the <a
href="http://sourceforge.net/project/showfiles.php?group_id=281500">SourceForge
download page</a>, and from the <a
href="http://www.kineticode.com/bricolage/index2.html">Kineticode download
page</a>.</p>

<h3>About Bricolage</h3>

<p>Bricolage is a full-featured, enterprise-class content management and
publishing system. It offers a browser-based interface for ease-of use, a
full-fledged templating system with complete HTML::Mason, HTML::Template, and
Template Toolkit support for flexibility, and many other features. It operates
in an Apache/mod_perl environment and uses the PostgreSQL RDBMS for its
repository. A comprehensive, actively-developed open source CMS, Bricolage was
hailed as <q>quite possibly the most capable enterprise-class open-source
application available</q> by <cite>eWEEK</cite>.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/announce/1.8.5.html">old layout</a>.</small></p>


