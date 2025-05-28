---
title: "Mini Summit 5 Transcript: Improving the PostgreSQL Extensions Experience in Kubernetes with CloudNativePG"
slug: mini-summit-cnpg
date: 2025-05-19T03:05:10Z
lastMod: 2025-05-28T22:34:21Z
description: |
  At the final Mini-Summit of 2025, Gabriele Bartolini gave an overview of
  PostgreSQL extension management in CloudNativePG.
tags: [Postgres, Extensions, PGConf, Summit, CloudNativePG, Gabriele Bartolini]
type: post
image:
  src: /shared/extension-ecosystem-summit/cnpg-extensions-card.jpeg
  title: "PostgresSQL Extension Mini Summit: Extension Management in CNPG"
  alt: |
    Orange card with large black text reading "Extension Management in CNPG".
    Smaller text below reads "Gabriele Bartolini (EDB)" and that is the date,
    "05.07.2025".
---

The final PostgresSQL Extension Mini-Summit took place on May 7. [Gabriele
Bartolini] gave an overview of PostgreSQL extension management in
[CloudNativePG][] (CNPG). This talk brings together the topics of several
previous Mini-Summits --- notably [Peter Eisentraut] on [implementing an
extension search path][mini2] --- to look at the limitations of extension
support in CloudNativePG and the possibilities enabled by the extension search
path feature and the Kubernetes 1.33 [ImageVolume] feature. Check it out:

*   [Video](https://www.youtube.com/watch?v=LbNuUs59j2I)
*   [PDF Slides]({{% link "postgres-operand-image-future.pdf" %}})

Or read on for the full transcript with thanks to [Floor Drees] for putting it
together.

## Introduction

Floor Drees.

On May 7 we hosted the last of five (5) virtual Mini-Summits that lead up to
the big one at the Postgres Development Conference (PGConf.Dev), taking place
next week, in Montreal, Canada. [Gabriele Bartolini], [CloudNativePG]
maintainer, PostgreSQL Contributor, and VP Cloud Native at [EDB], joined to
talk about improving the Postgres extensions experience in Kubernetes with
CloudNativePG.

The organizers:

*   [David Wheeler], Principal Architect at [Tembo], maintainer of [PGXN]
*   [Yurii Rashkovskii], [Omnigres]
*   [Keith Fiske], [Crunchy Data]
*   [Floor Drees], Principal Program Manager at [EDB], PostgreSQL CoCC member,
    PGDay Lowlands organizer

The stream and the closed captions available for the recording are supported
by [PGConf.dev] and their gold level sponsors, Google, AWS, Huawei, Microsoft,
and EDB.

## Improving the Postgres extensions experience in Kubernetes with CloudNativePG

Gabriele Bartolini.

Hi everyone. Thanks for this opportunity, and thank you Floor and David for
inviting me today.

I normally start every presentation with a question, and this is actually the
question that has been hitting me and the other maintainers of [CloudNativePG]
--- and some are in this call --- from the first day. We know that extensions
are important in Kubernetes, in Postgres, and we've always been asking how can
we deploy extensions, without breaking the immutability of the container.

So today I will be telling basically our story, and hopefully providing good
insights in the future about how with CloudNativePG we are trying to improve
the experience of Postgres extensions when running databases, including
issues.

I've been using Postgres for 25 years. I'm one of the co-founders of
2ndQuadrant, which was bought by a [EDB] in 2020. And because of my
contributions, I've been recognized as a Postgres contributor and I'm really
grateful for that. And I'm also "Data on Kubernetes ambassador"; my role is to
promote the usage of stateful workloads in Kubernetes. I'm also DevOps
evangelist. I always say this: DevOps is the reason why I encountered
Kubernetes, and it will also be the reason why I move away one day from
Kubernetes. It's about culture and I'll explain this later.

In the past I've been working with [Barman]; I'm one of the creators of
Barman. And since 2022, I'm one of the maintainers of [CloudNativePG]. I want
to thank my company, [EDB], for being the major contributor in Postgres
history in terms of source code. And right now we are also the creators of
CloudNativePG. And as we'll see, the company donated the IP to the [CNCF]. So
it's something that is quite rare, and I'm really grateful for that.

What I plan to cover tonight is first, set the context and talk about
immutable application containers, which have been kind of a dogma for us from
day one. Then, how we are handling right now extensions in Kubernetes with
CNPG. This is quite similar to the way other operators deal with it. Then the
future and key takeaways.

First, we're talking about Kubernetes. If you're not familiar, it's an
orchestration system for containers. It's not just an executor of containers,
but it's a complex system that also manages infrastructure. When it manages
infrastructure, it also manages cloud native applications that are also called
workloads. When we're thinking about Postgres in Kubernetes, the database is a
workload like the others. That, I think, is the most important mind shift
among Postres users that I have faced myself, that I've always treated
Postgres differently from the rest. Here in Kubernetes is it's just another
workload.

Then of course, it's not like any other workload, and that's where operators
come into play, and I think the work that we are doing even tonight is in the
direction to improve how databases is run in Kubernetes in general, and for
everyone.

It was open sourced in 2014, and, it's owned by the [CNCF], and it's actually
the first project that graduated, and graduated is the most advanced stage in
the graduation process of the CNCF, which starts with sandbox, then incubation
and then graduation.

CloudNativePG is an operator for Postgres. It's production-ready --- what we
say is level five. Level five is kind of an utopic, and unbounded level, the
highest one as defined by the operator development framework. It's used by all
these players including Tembo, IBM Cloud Paks, Google Cloud, Azure, Akamai,
and so on. CNPG is a CNCF project since January. It's distributed under Apache
License 2.0 and the IP --- the Intellectual Property --- is owned by the
community and protected by the CNCF. It therefore is a vendor neutral and
openly governed project. This is kind of a guarantee that it will always be
free. This is also, in my opinion, a differentiation between CloudNativePG and
the rest. 

The project was originally created by EDB, but specifically at that time, by
2ndQuadrant. And, as I always like to recall, it was Simon Riggs that put me
in charge of the initiative. I'll always be grateful to Simon, not only for
that, but for everything he has done for me and the team.

CNPG can be installed in several ways. As you can see, it's very popular in
terms of stars. There's more than 4,000 commits. And what's impressive is the
number of downloads in three years, which is 78 million, which means that it's
used the way we wanted it to be used: with CICD pipelines.

This is the [CNCF landscape]; these are the CNCF projects. As you can see,
there are only five projects in the CNCF in the database area, and
CloudNativePG is the only one for Postgres. Our aim for 2025 and 2026 is to
become incubating. If you're using CNPG and you want to help with the process,
get in touch with me and Floor. 

I think to understand again, what, why we've done all this process, that led
to the patch that, you've seen in Postgres 18, it's important to understand
what cloud native has meant to us since we started in 2019. We've got our own
definition, but I think it still applies. For us it's three things, Cloud
native. It's people that work following DevOps culture. For example, there are
some capabilities that come from DevOps that apply to the cloud native world.
I selected some of them like in user infrastructure, infrastructure
abstraction, version control. These three form the infrastructure-as-code
principle, together with the declarative configuration. 

A shift left on security. You'll see with CloudNativePG, we rarely mention
security because it's pretty much everywhere. It's part of the process. Then
continuous delivery.

The second item is immutable application containers, which kind of led the
immutable way of thinking about extensions. And then the third one is that
these application containers must be orchestrated via an
infrastructure-as-code by an orchestrator, and the standard right now is
Kubernetes.

For us it's these three things, and without any of them, you cannot achieve
cloud native.

So what are these immutable application containers? To explain immutability
I'd like to talk about immutable infrastructure, which is probably what the
majority of people that have historically worked with Postgres are used to.
I'm primarily referring to traditional environments like VMs and bare metal
where the main ways we deploy Postgres is through packages, maybe even managed
by configuration managers, but still, packages are the main artifacts. The
infrastructure is seen as a long-term kind of project. Changes happen over
time and are incremental updates, updates on an existing infrastructure. So if
you want to know the history of the infrastructure over time, you need to
check all the changes that have applied. In case of failure of a system,
systems are healed. So that's the [pets] concept that comes from DevOps. 

On the other hand, immutable infrastructure relies on [OCI] container images.
OCI is a standard, the [Open Container Initiative][OCI] and it's part of the
Linux Foundation as well. Immutable infrastructure is founded on continuous
delivery, which is the foundation of [GitOps] practices. In an immutable
infrastructure, releasing a new version of an application is not updating the
system's application, it is building a new image and publishing it on a public
registry and then deploying it. Changes in the system happen in an atomic way:
the new version of a container is pulled from the registry and the existing
image is almost instantaneously replaced by the new one. This is true for
stateless applications and we'll see, in the case of stateful applications
like Postgres, is not that instantaneous because we need to perform a
switchover or restart --- in any case, generate a downtime.

When it comes to Kubernetes, the choice was kind of obvious to go towards that
immutable infrastructure. So no incremental updates, and in the case of
stateful workloads where you cannot change the content of the container, you
can use data volumes or persistent volumes. These containers are not changed.
If you want to change even a single file or a binary in a container image, you
need to create a new one. This is very important for security and change
management policies in general. 

But what I really like about this way of managing our infrastructure is that,
at any time, Kubernetes knows exactly what software is running in your
infrastructure. All of this is versioned in an [SCM], like Git or whatever.
This is something that in the mutable world is less easy to obtain. Again, for
security, this is the foundational thing because this is how you can control
[CVEs], the vulnerabilities in your system. This is a very basic
representation of how you build, contain --- let's say the lifecycle of a
container image. You create a `Dockerfile`, you put it in Git, for example,
then there's an action or a pipeline that creates the container image, maybe
even run some tests and then pushes it to the container registry.

I walked you through the concepts of mutable and immutable containers, what
are, these immutable application containers? If you go back and read what we
were rising before CloudNativePG was famous or was even used, we were always
putting in immutable application containers as one of the principles we could
not lose.

For an immutable application container, it means that there's only a single
application running; that's why it's called "application". If you have been
using Docker, you are more familiar with system containers: you run a Debian
system, you just connect and then you start treating it like a VM. Application
containers are not like that. And then they are immutable --- read-only --- so
you cannot even make any change or perform updates of packages. But in
CloudNativePG, because we are managing databases, we need to put the database
files in separate persistent volumes. Persistent volumes are standard
resources provided by Kubernetes. This is where we put PGDATA and, if you
want, a separate volume for WAL files with different storage specifications
and even an optional number of table spaces.

CloudNativePG orchestrates what we call "operand images". These are very
important to understand. They contain the Postgres binaries and they're
orchestrated via what we call the "instance manager". The instance manager is
just the process that runs and controlled Postgres; I'ss the PID 1 --- or the
entry point --- of the container.

There's no other, like SSHD or other, other applications work. There's just
the instance manager that then controls everything else. And this is the
project of the operating images. This is one open source project, and every
week we rebuild the Postgres containers. We recently made some changes to the
flavors of these images and I'll talk about it shortly.

We mentioned the database, we mentioned the binaries, but what about
extensions? This is the problem. Postgres extensions in Kubernetes with
CloudNativePG is the next section, and it's kind of a drama. I'm not hiding
this. The way we are managing extensions in Kubernetes right now, in my
opinion, is not enough. It works, but it's got several limitations --- mostly
limitations in terms of usage.

For example, we cannot place them in the data files or in persistent volumes
because these volumes are not read-only in any way. In any case, they cannot
be strictly immutable. So we discarded this option to have persistent volume
where you could kind of deploy extensions and maybe you can even download on
the fly or use the package manager to download them or these kind of
operations. We discarded this from the start and we embraced the operand image
solution. Essentially what we did was placing these extensions in the same
operand image that contains the Postgres binaries. This is a typical approach
of also the other operators. If you think about also [Zalando] we call it "the
Spilo way". Spilo contained all the software that would run with the Zalando
operator.

Our approach was a bit different, in that we wanted lighter images, so we
created a few flavors of images, and also selected some extensions that we
placed in the images. But in general, we recommended to build custom images.
We provided instructions and we've also provided the requirements to build
container images. But as you can see, the complexity of the operational layer
is quite high, it's not reasonable to ask any user or any customer to build
their own images.

This is how they look now, although this is changing as I was saying:

{{% figure
    src = "postgres-operand-image-now.png"
    alt = "A stack of boxes with “Debian base image” at the top, then “PostgreSQL”, then “Barman Cloud”, and finally  three “Extension” boxes at the bottom."
%}}

You've got a base image, for example, the Debian base image. You deploy the
Postgres binaries. Then --- even right now though it's changing ---
CloudNativePG requires Barman Cloud to be installed. And then we install the
extensions that we think are needed. For example, I think we distribute
[pgAudit], if I recall correctly, [pgvector] and [pg_failover_slots]. Every
layer you add, of course, the image is heavier and we still rely on packages
for most extensions.

The problem is, you've got a cluster that is already running and you want, for
example, to test an extension that's just come out, or you want to deploy it
in production. If that extension is not part of the images that we build, you
have to build your own image. Because of the possible combinations of
extensions that exist, it's impossible to build all of these combinations. You
could build, for example, a system that allows you to select what extensions
you want and then build the image, but in our way of thinking, this was not
the right approach. And then you've got system dependencies and, if an
extension brings a vulnerability that affects the whole image and requires
more updates --- not just of the cluster, but also of the builds of the image.

We wanted to do something else, but we immediately faced some limitations of
the technologies. One  was on Postgres, the other one was on Kubernetes. In
Postgres, extensions need to be placed in a single folder. It's not possible
to define multiple locations, but thanks to the work that Peter and this team
have done, [now we've got `extension_control_path` in version 18][mini2].

Kubernetes could not allow until, 10 days ago, to mount OCI artifacts as
read-only volumes. There's a new feature that is now part of Kubernetes 1.33
that allows us to do it.

This is [the patch][pgpatch] that I was talking about, by [Peter Eisentraut]. I'm
really happy that CloudNativePG is mentioned as one of the use cases.
And there's also mentioned for the work that, me, David, and Marco and,
primarily Marco and Niccolò from CloudNativePG have done. 

This is [the patch][k8spatch] that introduced VolumeSource in Kubernetes 1.33.

The idea is that with Postgres 18 now we can set in the configuration where we
can look up for extensions in the file system. And then, if there are
libraries, we can also use the existing `dynamic_library_path` GUC.

So, you remember, this is where we come from [image above]; the good thing is
we have the opportunity to build Postgres images that are minimal, that only
contain Postgres.

{{% figure
    src = "postgres-operand-image-future.png"
    alt = "Three stacks of boxes. On the left, “Debian base image” on top of “PostgreSQL”. On the right, “Debian base image” on top of “Barman Cloud”. On the lower right, a single box for an extension."
%}}

Instead of recreating them every week --- because it's very likely that
something has some dependency, has a CVE, and so recreate them for everyone,
forcing everyone to update their Postgres systems --- we can now release them
maybe once a month, and pretty much follow the Postgres cadence patch
releases, and maybe if there are CVEs it's released more frequently.

The other good thing is that now we are working to remove the dependency on
Barman Cloud for CloudNativePG. CloudNativePG has a new plugin interface and
with 1.26 with --- which is expected in the next weeks --- we are suggesting
people start moving new workloads to the Barman Cloud plugin solution. What
happens is that Barman Cloud will be in that sidecar image. So it will be
distributed separately, and so its lifecycle is independent from the rest. But
the biggest advantage is that any extension in Postgres can be distributed ---
right now we've got packages --- The idea is that they are distributed also as
images.

If we start thinking about this approach, if I write an extension for
Postgres, until now I've been building only packages for Debian or for RPM
systems. If I start thinking about also building container images, they could
be immediately used by the new way of CloudNativePG to manage extensions.
That's my ultimate goal, let's put it that way.

This is how things will change at run time without breaking immutability.

{{% figure
    src = "runtime-change.png"
    alt = "A box labeled “PostgreSQL Pod” with four separate boxes inside, labeled “Container Postgres”, “Sidecar Barman Cloud”, “Volume Extension 1”, and “Volume Extension 2”."
%}}

There will be no more need to think about all the possible combinations of
extensions. There will be the Postgres pod that runs, for example, a primary
or standby, that will have the container for Postgres. If you're using Barman
Cloud, the sidecar container managed by the plugin with Barman Cloud. And
then, for every extension you have, you will have a different image volume
that is read-only, very light, only containing the files distributed in the
container image of the extension, and that's all.

Once you've got these, we can then coordinate the settings for external
`extension_control_path` and `dynamic_library_path`. What we did was, starting
a fail fast pilot project within EDB to test the work that Peter was doing on
the `extension_control_path`. For that we used the [Postgres Trunk Containers
project][trunk], which is a very interesting project that we have at
CloudNativePG. Every day it rebuilds the latest snapshot of the master branch
of Postgres so that we are able to catch, at an early stage, problems with the
new version of Postgres in CloudNativePG. But there's also an action that
builds container images for a specific, for example, [Commitfest] patch. So we
use that.

Niccolò wrote a pilot patch, an exploratory patch, for the operator to define
the extensions stanza inside the cluster resource. He also built some bare
container images for a few extensions. We make sure to include a very simple
one and the most complex one, which is [PostGIS]. This is the patch that ---
it's still a draft --- and the idea is to have it in the next version, 1.27
for CloudNativePG. This is how it works:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgresql-with-extensions
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgresql-trunk:18-devel
  postgresql:
    extensions:
      - name: pgvector
        image:
          reference: ghcr.io/cloudnative-pg/pgvector-18-testing:latest
  storage:
    storageClass: standard
    size: 1Gi
```

We have the `extensions` section in the cluster definition. We name the
extension. Theoretically we could also define the version and we point to the
image. What's missing in this pilot patch is support for image catalogs, but
that's something else that we can worry about later.

What happens under the hood is that when you update, or when you add a new
extension in the cluster definition, a rolling update is initiated. So there's
this short downtime, but the container image is loaded in the replicas first,
and then in the primary. n image volume is mounted for each extension in,
let's say, `/extensions/$name_of_extension` folder and CNPG updates, these two
parameters. It's quite clean, quite neat. It works, but most of the work needs
to happen here. So that's been my call, I mean to call container images as a
first class artifacts. If these changes, we have a new way to distribute
images.

Just to approach the conclusion, if you want to know more about the whole
story, I wrote [this blog article] that recaps everything, and the key
takeaway for me --- and then we go more on the patch if you want to, and also
address the questions. But what is important for me? Being in the Postgres
community for a long time, I think this is a good way, a good moment for us to
challenge the status quo of the extension distribution ecosystem.

I think we have an opportunity now to define a standard, which, I just want to
be clear, I'm focusing myself primarily on CNPG, but this is in general, even
for other operators. I'm sure that this will benefit everyone and overall it
will reduce the waste that we collectively create when distributing these
extensions in Kubernetes. If this becomes a standard way to distribute
extensions, the benefits will be much better operational work for everyone,
primarily also easier testing and validation of extensions. I mean, right now,
if you see an extension, ideally that extension --- and it's very easy to
build --- if you're in GitHub, to build the container images. GitHub, for
example, already provides the whole infrastructure for you to easily build
container images.

So if we find a standard way to define a GitHub action to build Postgres
extensions, I think, if you're a developer of an extension, you can just use
it and then you find a registry in your project directly that continuously
publishes or periodically publishes this extension. Any user can just
reference that image URL and then without having to build images, they're just
one rolling update away from testing a patch, testing also the upgrade paths.

I think there are some unknown unknowns that kind of scare me, in general,
about upgrades, upgrades of extensions. This is, in my opinion, one of the
biggest issues. It's not that they're not solved, but they require more
attention and more testing if you're using them in an immutable world. All of
these will, in my opinion, will be much, much better with the approach we've
proposed. Images will be lighter, and the lighter image is also safer and more
secure, so less prone to have CVEs,lLess prone to require frequent updates,
and also they reduce the usage of bandwidth, for an organization in general.
What I was saying before, any extension project can be fully independent,
have their own way to build images and publish them.

One last point. I keep hearing many signs, that all of the stuff that we are
proposing right now seem like a kind of a limitation of Kubernetes. The way I
see it, in my view, that it's not actually a limitation, it's that these
problems have never been addressed before. The biggest mistake we can do is
focus on the specific problem of managing extensions without analyzing the
benefits that the entire stack brings to an organization. Kubernetes brings a
lot of benefits in terms of security, velocity, change management and,
operations that any organization must consider right now. Any Postgres DBA,
any Postgres user, my advice is, if you haven't done it yet, start taking
Kubernetes, seriously.

## Discussion

Floor: I do think that David, you wanted to talk maybe a little bit about the
mutable volume pattern? 

David: Well, if people are interested, in your early slide where you were
looking at alternatives, one you were thinking of was putting extensions on a
mutable volume and you decided not to do that. But at Tembo we did do that and
I did a bunch of work trying to improve it and try to minimize image size and
all that in the last couple months. Tembo Cloud is shutting down now, so I had
to stop before I finished it, but I made quite a bit of progress. I'm happy to
kind of talk through the ideas there. But I think that this approach is a
better long term solution, fundamentally.

Gabriele: I would like if Marco and Niccolò, if you want to talk about the
actual work you've done. Meanwhile, Peter asks, "why does an installation of
an extension require a small downtime?" The reason is that at the moment, the
image volume patch, if you add a new image volume, it requires the pod to
restart. Nico or Marco, Jonathan, if you want to correct me on that.

Nico or Marco or Jonathan: It provides a rolling update of the cluster right
now.

Gabriele: So that's the reason. That's the only drawback, but the benefits in
my opinion, are...

David: My understanding is that, to add a new extension, it's mounted it in a
different place. And because every single extension is its own mount, you have
to add it to both those GUCs. And at least one of them requires a restart.

Gabriele: But then for example, we've had this conversation at EDB for
example, we're planning to have flavors of predefined extensions. For
example, you can choose a flavor and we distribute those extensions. For
example, I dunno, for AI we place some AI kind of extensions in the same
image, so it would be different.

But otherwise I'm considering the most extreme case of one extension, one
container image, which in my opinion, for the open source world is the way
that hopefully will happen. Because this way, think about that -- I haven't
mentioned this --- if I write an extension, I can then build the image and
then run automated tests using Kubernetes to assess my extension on GitHub. If
those tests fail, my commit will never be merged on main. This is trunk
development, continuous delivery. This is, in my opinion, a far better way of
delivering and developing software. This is, again, the reason why we ended up
in Kubernetes. It's not because it's a technology we like, it's a toy or so,
it's because it solves bigger problems than database problems.

Even when we talk about databases, there's still work that needs to be done,
needs to be improved. I'm really happy that we have more people that know
Postgres nowadays that are joining CloudNativePG, and are elevating the
discussions more and more on the database level. Because before it was
primarily on Kubernetes level, but now we see people that know Postgres better
than me get in CloudNativePG and propose new ideas, which is great. Which is
the way it needs to be, in my opinion.

But I remember, Tembo approached us because we actually talked a lot with
them. Jonathan, Marco, I'm sure that you recall, when they were evaluating
different operators and they chose CloudNativePG. I remember we had these
discussions where they asked us to break immutability and we said, "no way".
That's why I think Tembo had to do the solution you described, because we
didn't want to do it upstream. 

I think, to be honest, and to be fair, if image volumes were not added, we
would've probably gone down that path, because this way of managing
extensions, as I was saying, is not scalable, the current one. Because we want
to always improve, I think that the approach we need to be critical on what we
do. So, I don't know, Niccolò, Marco, I would like you to, if you want, explain
briefly.

[A bit of chatter, opened [this Dockerfile].]

```Dockerfile
FROM ghcr.io/cloudnative-pg/postgresql-trunk:18-devel AS builder

USER 0

COPY . /tmp/pgvector

RUN set -eux; \
	mkdir -p /opt/extension && \
	apt-get update && \
	apt-get install -y --no-install-recommends build-essential clang-16 llvm-16-dev && \
	cd /tmp/pgvector && \
	make clean && \
	make OPTFLAGS="" && \
	make install datadir=/opt/extension/share/ pkglibdir=/opt/extension/lib/

FROM scratch

COPY --from=builder /opt/extension/lib/* /lib/
COPY --from=builder /opt/extension/share/extension/* /share/
```

Niccolò: I forked, for example, [pgvector], That's what we can do basically
for every simple extensions that we can just build. This is a bit more
complicated because we have to build from a trunk version of Postgres 18. So
we have to compile pgvector from source, and then in a scratch layer we just
archive the libraries and every other content that was previously built. But
ideally whenever PG 18 comes out as a stable version of Postgres, we just need
to `apt install pgvector` and grab the files from the path. Where it gets a
bit more tricky is in the case of [PostGIS], or [TimescaleDB], or any
extension whose library requires third party libraries. For example, PostGIS
has a strong requirement on the geometric libraries, so you need to import
them as well inside the mount volume. I can link you an example of the
[PostGIS one].

Gabriele: I think it's important, we've got, I think Peter here, David as
well, I mean, for example, if we could get standard ways in Postgres to
generate `Dockerfile`s for extensions, that could be great. And as I said,
these extensions can be used by any operator, not only CNPG.

David: That's my [POC] does. It's a patch against the PGXS that would build a
trunk image.

Gabriele: This is the work that Niccolò had to do to make PostGIS work in the
pilot project: he had to copy everything.

Niccolò: I think we can make it a little bit smoother and dynamically figure
out everything from the policies library, so we don't have to code everything
[like this][PostGIS one], but this is just a proof of concept that it can
work.

David: So you installed all those shared libraries that were from packages.

Niccolò: Yeah, they're being copied in the same `MountVolume` where the actual
extensions are copied as well. And then the pilot patch is able to set up the
library path inside the pod so that it makes the libraries available to the
system because of course, these libraries are only part of the `MountVolume`.
They're not injected inside the system libraries of the pod, so we have to set
up the library path to make them available to Postgres. That's how we're able
to use them. 

David: So they end up in `PKGLIBDIR` but they still work.

Niccolò: Yeah.

Gabriele: I mean, there's better ideas, better ways. As Niccolò also said, it
was a concept.

David: Probably a lot of these shared libraries could be shared with other
extensions. So you might actually want other OCI images that just have some of
the libraries that shared between.

Gabriele: Yeah, absolutely. So we could work on a special kind of, extensions
or even metadatas so that we can place, you know…

So, yeah, that's it.

Jonathan: I think it's important to invite everyone to try and test this,
especially the Postgres [trunk] containers, when they want to try something
new stuff, new like this one, just because we always need people testing. When
more people review and test, it's amazing. Because every time we release
something, probably we'll miss something, some extension like PostGIS missing
one of the libraries that wasn't included in the path. Even if we can try to
find a way to include it, it will not be there. So testing, please! Test all
the time!

Gabriele: Well, we've got this action now, they're failing. I mean, it's a bit
embarrassing. [Cross talk.] We already have patch to fix it.

But I mean, this is a great project as I mentioned before, because it allows
us to test the current version of Postgres, but also if you want to build from
a [Commitfest] or if you've got your own Postgres repository with sources, you
can compile, you can get the images from using [this project][trunk].

Floor: Gabriele, did you want to talk about [SBOM]s?

Gabriele: I forgot to mention [Software Bill of Materials][SBOM]. They're very
important. It's kind of now basic for any container image. There's also the
possibility to add them to these container images too. This is very important.
Again, in a change manager for security and all of that --- in general supply
chain. And signatures too. But we've got signature for packages as well.
There's also a attestation of provenance.

Floor: Very good, thanks everyone!

  [Gabriele Bartolini]: https://www.gabrielebartolini.it
  [CloudNativePG]: https://cloudnative-pg.io "Run PostgreSQL. The Kubernetes way."
  [Peter Eisentraut]: https://peter.eisentraut.org
  [mini2]: {{% ref "/post/postgres/2025-mini-summit-two" %}} "2025 Postgres Extensions Mini Summit Two"
  [ImageVolume]: https://kubernetes.io/docs/concepts/storage/volumes/#image
  [Floor Drees]: https://dev.to/@floord
  [PGConf.dev]: https://2025.pgconf.dev "PostgreSQL Development Conference 2025"
  [David Wheeler]: {{% ref "/" %}}
  [Tembo]: https://tembo.io/
  [PGXN]: https://pgxn.org/
  [Yurii Rashkovskii]: https://ca.linkedin.com/in/yrashk
  [Omnigres]: https://omnigres.com/
  [Keith Fiske]: https://pgxn.org/user/keithf4/
  [Crunchy Data]: https://www.crunchydata.com/
  [EDB]: https://enterprisedb.com "EnterpriseDB"
  [sponsors]: https://2025.pgconf.dev/sponsors.html
  [Barman]: https://pgbarman.org
  [CNCF]: https://www.cncf.io
  [CNCF landscape]: https://landscape.cncf.io
  [pets]: https://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/
  [OCI]: https://opencontainers.org
  [GitOps]: https://www.gitops.tech
  [SCM]: https://en.wikipedia.org/wiki/Change_control
  [CVEs]: https://cve.mitre.org
  [Zalando]: https://github.com/zalando/postgres-operator
  [pgAudit]: https://pgaudit.org/
  [pgvector]: https://pgxn.org/dist/vector/
  [pg_failover_slots]: https://github.com/EnterpriseDB/pg_failover_slots
  [pgpatch]: https://github.com/postgres/postgres/commit/4f7f7b0
  [k8spatch]: https://github.com/kubernetes/enhancements/issues/4639
  [trunk]: https://github.com/cloudnative-pg/postgres-trunk-containers
  [Commitfest]: https://commitfest.postgresql.org
  [PostGIS]: https://postgis.net
  [this blog article]: https://www.gabrielebartolini.it/articles/2025/03/the-immutable-future-of-postgresql-extensions-in-kubernetes-with-cloudnativepg/
    "The Immutable Future of PostgreSQL Extensions in Kubernetes with CloudNativePG"
  [this Dockerfile]: https://github.com/EnterpriseDB/pgvector/blob/dev/5645/Dockerfile.cnpg
  [TimescaleDB]: https://github.com/timescale/timescaledb
  [PostGIS one]: https://github.com/cloudnative-pg/postgres-trunk-containers/blob/dev/postgis/postgis/Dockerfile-postgis.cnpg
  [POC]: {{% ref "/post/postgres/trunk-oci-poc" %}}
    "POC: Distributing Trunk Binaries via OCI"
  [SBOM]: https://www.cisa.gov/sbom
