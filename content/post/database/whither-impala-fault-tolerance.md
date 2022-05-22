--- 
date: 2013-09-29T14:29:00Z
link: http://blog.cloudera.com/blog/2013/09/whats-next-for-impala-after-release-1-1/
title: Whither Impala Fault Tolerance?
aliases: [/impala/2013/09/29/whither-impala-fault-tolerance/]
tags: [Impala, Justin Erickson, Hadoop, CitusDB, Databases]
type: post
---

Justin Erickson on the [Cloudera Blog]

> In December 2012, while Cloudera Impala was still in its beta phase, we
> [provided a roadmap] for planned functionality in the production release. In
> the same spirit of keeping Impala users, customers, and enthusiasts well
> informed, this post provides an updated roadmap for upcoming releases later
> this year and in early
> 2014.

[Impala] is a pretty nice-looking SQLish query engine that runs on Hadoop. It
provides the same basic interface as [Hive], but circumvents MapReduce to
access data directly from data nodes in parallel. But, in my opinion, to be
useful as a real-time query engine, it needs fault tolerance. From the
[Impala FAQ], under the list of unsupported features:

> Fault tolerance for running queries (not currently). In the current release,
> Impala aborts the query if any host on which the query is executing fails. In
> the future, we will consider adding fault tolerance to Impala, so that a
> running query would complete even in the presence of host failures.

Sounds like an unfortunate issue. Since it's pretty typical for data nodes to
go down, this seems like an essential feature. Products like [CitusDB] offer
fault tolerance:

> **Does CitusDB recover from failures?**
> 
> Yes. The CitusDB master node intelligently re-routes the work on any failed
> nodes to the remaining nodes in real-time. Since the underlying data are kept
> in fixed-size blocks in HDFS, a failed node's work can evenly be distributed
> among the remaining nodes in the cluster.

That sound exactly right. I'm excited about Citus, and if it adds solid
support for more data formats, such as [ORC] and [Parquet], it may well be the
way to go. But Impala will be a nice alternative if it can get fault tolerance
figured out. I'm disappointed it's not on the road map.

  [provided a roadmap]: https://blog.cloudera.com/blog/2012/12/whats-next-for-cloudera-impala/
  [Cloudera Blog]: https://blog.cloudera.com/
  [Impala]: https://impala.apache.org
  [Hive]: https://hive.apache.org/
  [Impala FAQ]: https://web.archive.org/web/20160211202038/http://www.cloudera.com/documentation/archive/impala/2-x/2-1-x/topics/impala_faq.html
  [CitusDB]: https://web.archive.org/web/20130223235911/http://citusdata.com/docs/sql-on-hadoop "CitusDB SQL on Hadoop"
  [ORC]: https://docs.cloudera.com/runtime/latest/hive-performance-tuning/topics/hive_maximize_storage_resources_using_orc.html
    "ORC File Format"
  [Parquet]: http://parquet.apache.org "Parquet is a columnar storage format for Hadoop."
