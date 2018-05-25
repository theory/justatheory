--- 
date: 2005-07-06T18:51:38Z
slug: bricolage-summer-of-code-winners
title: How the Bricolage Summer of Code Projects were Selected
aliases: [/bricolage/summer_of_code_winners.html]
tags: [Bricolage, Google, Google Summer Of Code, Projects, Methodology]
type: post
---

As you may have [read], we got quite a number of applications from students
wishing to contribute to Bricolage as part of Google's [Summer of Code]
initiative. Quite a few of them were very good. There were eight projects I
wanted to accept, but, Bricolage was allocated only four projects. Of course,
this is four more than we would have had otherwise, and I'm really excited to be
working with them this summer.

The four winning projects are:

-   Add Input Channels, by Marshall Roch
-   New Sample Document types and templates, by Scott Loyd
-   Port Bricolage to Apache 2/mod\_perl 2 and Windows, by Sam Strasser
-   Port Bricolage to MySQL, by Tamas Mezei

The other projects I wanted to get but could not were:

-   Add Bulk Edit, Bulk Media Upload, and Site Tags, by Andreas Hofmeister
-   Element Occurrence Specification, by Christian James Muise
-   Add JSP Templating, by Adrian Fernandez
-   Update and Modernize the Installer, by Yiannis Valassakis

I am hoping that some of these students might want to work on their projects,
anyway. I've even found other developers to help with the mentoring of JSP
templating ([Patrick LeBoutillier] with Perl/Java voodo) and the installer
modernization ([Sam Tregar] of [Matchstick] fame). Unfortunately, I've not heard
back from any of them after sending them an invite to participate in the
project. C'est la vie, I guess

The hardest part of the proposal evaluation process was selecting from the 20
proposals to port Bricolage to MySQL. Ultimate, there were four excellent
proposals for this project. Reading the proposals over and over, I couldn't
decide between them. Ultimately, I sent an email to the four top contenders with
the following items for them to reply to:

1.  Please describe in a line or two your Perl knowledge or experience (if any).
2.  Please describe in a line or two your MySQL and PostgreSQL knowledge or
    experience (if any).
3.  Please describe any previous Bricolage usage experience.
4.  Please describe any previous Bricolage development experience.
5.  Please describe any previous Open Source development experience.
6.  What school do you attend?
7.  What is your specialty at the school?
8.  How many years have you attended there?
9.  How much time do you expect to have for this project?
10. Have you applied for any other Summer of Code projects? If so, which ones?
11. Your personal or professional web page URL (if any).
12. Would you be willing to collaborate with another developer who might be
    working on a SQLite port to ensure that your changes can fully
    inter-operate?
13. Please outline your project plan for porting Bricolage to MySQL, including a
    description of what parts of the Bricolage API, DDLs, installer, and
    upgrader would need to be modified to complete the project.

For better or for worse, all four applicants responded with detailed answers to
my questions. They were all great, and that made it even harder to select just
one of them. At this point, there were only a few hours left to rank applicants
in Google's SoC Admin Web app, so I figured I had to get more objective—or at
least fool myself into thinking I was.

So I decided to rank each applicant from one to five for each question, and then
add up all of the results and see who came out on top. So now I was comparing
answers to a single question between applicants, and filling in scores for them
in a spreadsheet. As it was, things were still really close; yes, all of the
students where *that* good! Tamas came out on top with a score of 30, two others
were tied at 28, and the fourth applicant scored 26. They were close enough that
I wanted to review them all one more time, this time paying specific attention
to the last item in my questionnaire, the project plan.

Each of the four applicants had taken the time to read the mail lists and had
looked at the existing Bricolage code. But there were varying levels of detail
and demonstration of knowledge for how to implement the MySQL port, but Tamas
did come out slightly ahead on this item, so I gave his proposal the green
light.

But in truth, I would have been happy with any one of those four applicants. I
was only sorry I had to choose only one! If Google does this again, I think I'll
list many more project ideas on the Bricolage Web site, and try to steer people
to the mail lists to discuss their ideas before sending them in. Then I might
end up with 11 great applications!

  [read]: /bricolage/summer_of_code_applications.html
    "Bricolage Summer of Code Application Summary"
  [Summer of Code]: http://code.google.com/summerofcode.html
    "Google Summer of Code"
  [Patrick LeBoutillier]: http://search.cpan.org/~patl/
    "See Patrick LeBoutillier's modules on CPAN"
  [Sam Tregar]: http://sam.tregar.com/ "Sam Tregar: Life"
  [Matchstick]: http://sourceforge.net/projects/matchstick/
    "The Matcstick SourceForge project page"
