# The MySQL “swap insanity” problem and the effects of the NUMA architecture

  

# The MySQL “swap insanity” problem and the effects of the NUMA architecture

**Update** : Also read [A brief update on NUMA and
MySQL](https://blog.jcole.us/2012/04/16/a-brief-update-on-numa-and-mysql/).

## The “swap insanity” problem, in brief

When running MySQL on a large system (e.g., 64GB RAM and dual quad core CPUs)
with a large InnoDB buffer pool (e.g., 48GB), over time, Linux decides to swap
out potentially large amounts of memory, despite appearing1 to be under no
real memory pressure. Monitoring reveals that at no time is the system in
actual need of more memory than it has available; and memory isn’t leaking,
`mysqld`‘s [RSS](http://en.wikipedia.org/wiki/Resident_set_size) is normal and
stable.

Normally a tiny bit of swap usage could be OK (we’re really concerned about
activity—swaps in and out), but in many cases, “real” useful memory is being
swapped: primarily parts of InnoDB’s buffer pool. When it’s needed once again,
a big performance hit is taken to swap it back in, causing random delays in
random queries. This can cause overall unpredictable performance on production
systems, and often once swapping starts, the system may enter a performance
death-spiral.

While not every system, and not every workload experiences this problem, it’s
common enough that it’s well known, and for those that know it well it can be
a major headache.

## The history of “swap insanity”

Over the past two to four years, there has been an off-and-on discussion about
Linux swapping and MySQL, often titled “swap insanity” (I think coined by
Kevin Burton). I have followed it closely, but I haven’t contributed much
because I didn’t have anything new to add. The major contributors to the
discussion over the past years have been:

  * [Kevin Burton](http://feedblog.org/2006/09/27/stupid-linux-swap-tricks-with-swappiness/) — Discussion of swappiness and MySQL on Linux.
  * [Kevin Burton](http://feedblog.org/2007/09/29/using-o_direct-on-linux-and-innodb-to-fix-swap-insanity/) — Proposed IO_DIRECT as a solution (doesn’t work) and discussed memlock (may help, but not a full solution).
  * [Peter Zaitsev](http://www.mysqlperformanceblog.com/2008/04/06/should-you-have-your-swap-file-enabled-while-running-mysql/) — Discussed swappiness, memlock, and fielded a lot of discussion in the comments.
  * [Don MacAskill](http://don.blogs.smugmug.com/2008/05/01/mysql-and-the-linux-swap-problem/) — Proposed an innovative (albeit hacky) solution using swap on ramdisk, and a lot more interesting discussion in the comments.
  * [Dathan Pattishall](http://mysqldba.blogspot.com/2008/05/linux-64-bit-mysql-swap-and-memory.html) — Describes how Linux behavior can be even worse with swap disabled, and proposes using `swapoff` to clear it, but no real solution.
  * [Rik van Riel on the LKML](http://marc.info/?t=120997175700001) — A few answers and proposal of the Split-LRU patch.
  * [Kevin Burton](http://feedblog.org/2008/09/03/linux-split-lru-patch-improves-mysql-swap-performance/) — Discussion of Linux Split-LRU patch with some success.
  * [Mark Callaghan](http://mysqlha.blogspot.com/2008/11/linux-mysql-vmstat.html) — Discussion of vmstat and monitoring things, and a recap of a few possible solutions.
  * [Kevin Burton](http://feedblog.org/2009/01/25/splitlru-patch-in-kernel-2628-must-have-for-mysql-and-innodb/) — More discussion that Linux Split-LRU is essential.
  * [Kevin Burton](http://feedblog.org/2009/02/14/the-middle-path-and-the-solution-to-linux-swap/) — Choosing the middle road by enabling swap, but with a small amount of space, and giving up the battle.
  * [Peter Zaitsev](http://www.mysqlperformanceblog.com/2010/01/18/why-swapping-is-bad-for-mysql-performance/) — More discussion about why swapping is bad, but no solution.

Despite all the discussion, not much has changed. There are some hacky
solutions to get MySQL to stop swapping, but nothing definite. I’ve known
these solutions and hacks now for a while, but the core question was never
really settled: “ _Why_ does this happen?” and it’s never sat well with me. I
was recently tasked with trying to sort this mess out once and for all, so
I’ve now done quite a bit of research and testing related to the problem. I’ve
learned a lot, and decided a big blog entry might be the best way to share it.
Enjoy.

There was a lot of discussion and some work went into adding the relatively
new `swappiness` tunable a few years ago, and I think that may have solved
some of the original problems, but at around the same time the basic
architecture of the machine changed to NUMA, which I think introduced some new
problems, with the very same symptoms, masking the original fix.

## Contrasting the SMP/UMA and NUMA architectures

### The SMP/UMA architecture

  
_The SMP, or UMA architecture, simplified_

When the PC world first got multiple processors, they were all arranged with
equal access to all of the memory in the system. This is called [Symmetric
Multi-processing (SMP)](http://en.wikipedia.org/wiki/Symmetric_Multi-
Processing), or sometimes Uniform Memory Architecture (UMA, especially in
contrast to NUMA). In the past few years this architecture has been largely
phased out between physical socketed processors, but is still alive and well
today within a single processor with multiple cores: all cores have equal
access to the memory bank.

### The NUMA architecture

  
_The NUMA architecture, simplified_

The new architecture for multiple processors, starting with [AMD’s
Opteron](http://en.wikipedia.org/wiki/Opteron) and [Intel’s
Nehalem](http://en.wikipedia.org/wiki/Nehalem_%28microarchitecture%29)2
processors (we’ll call these “modern PC CPUs”), is a [Non-Uniform Memory
Access (NUMA)](http://en.wikipedia.org/wiki/Non-Uniform_Memory_Access)
architecture, or more correctly [Cache-Coherent NUMA
(ccNUMA)](http://en.wikipedia.org/wiki/Non-
Uniform_Memory_Access#Cache_coherent_NUMA_.28ccNUMA.29). In this architecture,
each processor has a “local” bank of memory, to which it has much closer
(lower latency) access. The whole system may still operate as one unit, and
all memory is basically accessible from everywhere, but at a potentially
higher latency and lower performance.

Fundamentally, some memory locations (“local” ones) are faster, that is, cost
less to access, than other locations (“remote” ones attached to other
processors). For a more detailed discussion of NUMA implementation and its
support in Linux, see [Ulrich Drepper’s article on
LWN.net](http://lwn.net/Articles/254445/).

## How Linux handles a NUMA system

Linux automatically understands when it’s running on a NUMA architecture
system and does a few things:

  1. Enumerates the hardware to understand the physical layout.
  2. Divides the processors (not cores) into “nodes”. With modern PC processors, this means one node per physical processor, regardless of the number of cores present.
  3. Attaches each memory module in the system to the node for the processor it is local to.
  4. Collects cost information about inter-node communication (“distance” between nodes).

You can see how Linux enumerated your system’s NUMA layout using the `numactl
--hardware` command:

>

>     # numactl --hardware

>     available: 2 nodes (0-1)

>     node 0 size: 32276 MB

>     node 0 free: 26856 MB

>     node 1 size: 32320 MB

>     node 1 free: 26897 MB

>     node distances:

>     node   0   1

>       0:  10  21

>       1:  21  10

>  

This tells you a few important things:

  * **The number of nodes, and their node numbers** — In this case there are two nodes numbered “0” and “1”.
  * **The amount of memory available within each node** — This machine has 64GB of memory total, and two physical (quad core) CPUs, so it has 32GB in each node. Note that the sizes aren’t exactly half of 64GB, and aren’t exactly equal, due to some memory being stolen from each node for whatever internal purposes the kernel has in mind.
  * **The “distance” between nodes** — This is a representation of the cost of accessing memory located in (for example) Node 0 from Node 1. In this case, Linux claims a distance of “10” for local memory and “21” for non-local memory.

## How NUMA changes things for Linux

Technically, as long as everything runs just fine, there’s no reason that
being UMA or NUMA should change _how_ things work at the OS level. However, if
you’re to get the best possible performance (and indeed in some cases with
extreme performance differences for non-local NUMA access, any performance at
all) some additional work has to be done, directly dealing with the internals
of NUMA. Linux does the following things which might be unexpected if you
think of CPUs and memory as black boxes:

  * Each process and thread inherits, from its parent, a NUMA policy. The inherited policy can be modified on a per-thread basis, and it defines the CPUs and even individual cores the process is allowed to be scheduled on, where it should be allocated memory from, and how strict to be about those two decisions.
  * Each thread is initially allocated a “preferred” node to run on. The thread _can_ be run elsewhere (if policy allows), but the scheduler attempts to ensure that it is always run on the preferred node.
  * Memory allocated for the process is allocated on a particular node, by default “current”, which means the same node as the thread is preferred to run on. On UMA/SMP architectures all memory was treated equally, and had the same cost, but now the system has to think a bit about where it comes from, because accessing non-local memory has implications on performance and may cause cache coherency delays.
  * Memory allocations made on one node will **not** be moved to another node, regardless of system needs. Once memory is allocated on a node, it will stay there.

The NUMA policy of any process can be changed, with broad-reaching effects,
very simply using [`numactl`](http://linux.die.net/man/8/numactl) as a wrapper
for the program. With a bit of additional work, it can be fine-tuned in detail
by linking in [`libnuma`](http://linux.die.net/man/3/numa) and writing some
code yourself to manage the policy. Some interesting things that can be done
simply with the `numactl` wrapper are:

  * Allocate memory with a particular policy: 
    * locally on the “current” node — using `--localalloc`, and also the default mode
    * preferably on a particular node, but elsewhere if necessary — using `--preferred= _node_`
    * always on a particular node or set of nodes — using `--membind= _nodes_`
    * _interleaved_ , that is, spread evenly round-robin across all or a set of nodes — using `--interleaved=all` or `--interleaved= _nodes_`
  * Run the program on a particular node or set of nodes, in this case that means physical CPUs (`--cpunodebind= _nodes_` ) or on a particular core or set of cores (`--physcpubind= _cpus_` ).

## What NUMA means for MySQL and InnoDB

InnoDB, and really, nearly all database servers ([such as
Oracle](http://kevinclosson.wordpress.com/2009/05/14/you-buy-a-numa-system-
oracle-says-disable-numa-what-gives-part-ii/)), present an atypical workload
(from the point of view of the majority of installations) to Linux: a single
large multi-threaded process which consumes nearly all of the system’s memory
and should be expected to consume as much of the rest of the system resources
as possible.

In a NUMA-based system, where the memory is divided into multiple nodes, how
the system should handle this is not necessarily straightforward. The default
behavior of the system is to allocate memory in the same node as a thread is
scheduled to run on, and this works well for small amounts of memory, but when
you want to allocate more than half of the system memory it’s no longer
physically possible to even do it in a single NUMA node: In a two-node system,
only 50% of the memory is in each node. Additionally, since many different
queries will be running at the same time, on both processors, neither
individual processor necessarily has preferential access to any particular
part of memory needed by a particular query.

It turns out that this seems to matter in one very important way. Using
[`/proc/ _pid_ /numa_maps`](http://linux.die.net/man/5/numa_maps) we can see
all of the allocations made by `mysqld`, and some interesting information
about them. If you look for a really big number in the `anon= _size_` , you
can pretty easily find the buffer pool (which will consume [more than 51GB of
memory](http://mysqlha.blogspot.com/2008/11/innodb-memory-overhead.html) for
the 48GB that it has been configured to use) [line-wrapped for clarity]:

>

>     2aaaaad3e000 default anon=13240527 dirty=13223315

>       swapcache=3440324 active=13202235 N0=7865429 N1=5375098

>  

The fields being shown here are:

  * `2aaaaad3e000` — The virtual address of the memory region. Ignore this other than the fact that it’s a unique ID for this piece of memory.
  * `default` — The NUMA policy in use for this region.
  * `anon= _number_` — The number of anonymous pages mapped.
  * ` dirty= _number_` — The number of pages that are dirty because they have been modified. Generally memory allocated only within a single process is always going to be used, and thus dirty, but if a process forks it may have many copy-on-write pages mapped that are not dirty.
  * ` swapcache= _number_` — The number of pages swapped out but unmodified since they were swapped out, and thus they are ready to be freed if needed, but are still in memory at the moment.
  * ` active= _number_` — The number of pages on the “active list”; if this field is shown, some memory is inactive (` anon` minus `active`) which means it may be paged out by the swapper soon.
  * `N0= _number_` and ` N1= _number_` — The number of pages allocated on Node 0 and Node 1, respectively.

The entire `numa_maps` can be quickly summarized by the a simple script [numa-
maps-summary.pl](http://jcole.us/blog/files/numa-maps-summary.pl), which I’ve
written while analyzing this problem:

>

>     N0        :      7983584 ( 30.45 GB)

>     N1        :      5440464 ( 20.75 GB)

>     active    :     13406601 ( 51.14 GB)

>     anon      :     13422697 ( 51.20 GB)

>     dirty     :     13407242 ( 51.14 GB)

>     mapmax    :          977 (  0.00 GB)

>     mapped    :         1377 (  0.01 GB)

>     swapcache :      3619780 ( 13.81 GB)

>  

An couple of interesting and somewhat unexpected things pop out to me:

  1. The sheer imbalance in how much memory is allocated in Node 0 versus Node 1. This is actually absolutely normal per the default policy. Using the default NUMA policy, memory was preferentially allocated in Node 0, but Node 1 was used as a last resort.
  2. The sheer _amount_ of memory allocated in Node 0. This is absolutely critical — Node 0 is out of free memory! It only contains about 32GB of memory in total, and it has allocated a single large chunk of more than 30GB to InnoDB’s buffer pool. A few other smaller allocations to other processes finish it off, and suddenly it has no memory free, and isn’t even caching anything.

The memory allocated by MySQL looks something like this:

  
_Allocating memory severely imbalanced, preferring Node 0_

Due to Node 0 being completely exhausted of free memory, even though the
system has plenty of free memory overall (over 10GB has been used for caches)
it is _entirely_ on Node 1. If any process scheduled on Node 0 needs local
memory for anything, it will cause some of the already-allocated memory to be
swapped out in order to free up some Node 0 pages. Even though there is free
memory on Node 1, the Linux kernel in many circumstances (which admittedly I
don’t totally understand 3) prefers to page out Node 0 memory rather than free
some of the cache on Node 1 and use that memory. Of course the paging is far
more expensive than non-local memory access ever would be.

## A small change, to big effect

An easy solution to this is to interleave the allocated memory. It is possible
to do this using `numactl` as described above:

>

>     # numactl --interleave all _command_

>  

We can use this with MySQL by making a [one-line change to
`mysqld_safe`](http://jcole.us/patches/mysql/5.1/numa_interleave_simple.patch),
adding the following line (after `cmd="$NOHUP_NICENESS"`), which prefixes the
command to start `mysqld` with a call to `numactl`:

>

>     cmd="/usr/bin/numactl --interleave all $cmd"

>  

Now, when MySQL needs memory it will allocate it interleaved across all nodes,
effectively balancing the amount of memory allocated in each node. This will
leave some free memory in each node, allowing the Linux kernel to cache data
on both nodes, thus allowing memory to be easily freed on either node just by
freeing caches (as it’s supposed to work) rather than paging.

Performance regression testing has been done comparing the two scenarios
(default local plus spillover allocation versus interleaved allocation) using
the DBT2 benchmark, and found that performance in the nominal case is
identical. This is expected. The breakthrough comes in that: In all cases
where swap use could be triggered in a repeatable fashion, the system _no
longer swaps_!

You can now see from the `numa_maps` that all allocated memory has been spread
evenly across Node 0 and Node 1:

>

>     2aaaaad3e000 interleave=0-1 anon=13359067 dirty=13359067

>       N0=6679535 N1=6679532

>  

And the summary looks like this:

>

>     N0        :      6814756 ( 26.00 GB)

>     N1        :      6816444 ( 26.00 GB)

>     anon      :     13629853 ( 51.99 GB)

>     dirty     :     13629853 ( 51.99 GB)

>     mapmax    :          296 (  0.00 GB)

>     mapped    :         1384 (  0.01 GB)

>  

In graphical terms, the allocation of all memory within `mysqld` has been made
in a balanced way:

  
_Allocating memory balanced (interleaved) across nodes_

## An aside on ` zone_reclaim_mode`

The
[`zone_reclaim_mode`](http://www.kernel.org/doc/Documentation/sysctl/vm.txt)
tunable in `/proc/sys/vm` can be used to fine-tune memory reclamation policies
in a NUMA system. Subject to [some clarifications](http://marc.info/?l=linux-
mm&m=128563913214216&w=2) from the `linux-mm` mailing list, it doesn’t seem to
help in this case.

## An even better solution?

It occurred to me (and was backed up by the `linux-mm` mailing list) that
there is probably further room for optimization, although I haven’t done any
testing so far. Interleaving _all_ allocations is a pretty big hammer, and
while it does solve this problem, I wonder if an even better solution would be
to _intelligently_ manage the fact that this is a NUMA architecture, using the
` libnuma` library. Some thoughts that come to mind are:

  * Spread the buffer pool across all nodes intelligently in large chunks, or by index, rather than round-robin per page.
  * Keep the allocation policy for normal query threads to “local” so their memory isn’t interleaved across both nodes. I think interleaved allocation could cause slightly worse performance for some queries which would use a substantial amount of local memory (such as for large queries, temporary tables, or sorts), but I haven’t tested this.
  * Managing I/O in and out to/from the buffer pool using threads that will only be scheduled on the same node that the memory they will use is allocated on (this is a rather complex optimization).
  * Re-schedule simpler query threads (many PK lookups, etc.) on nodes with local access to the data they need. Move them actively when necessary, rather than keeping them on the same node. (I don’t know if the cost of the switch makes up for this, but it could be trivial if the buffer pool were organized by index onto separate nodes.)

I have no idea if any of the above would really show practical benefits in a
real-world system, but I’d love to hear any comments or ideas.

**Update 1** : Changed the link for “Rik van Riel on the LKML — A few answers
and proposal of the Split-LRU patch.” to be a bit closer to my intention. The
old link points to the message that started the thread, the new link points to
the index of the messages in the thread.

**Update 2** : Added a
[link](http://kevinclosson.wordpress.com/2009/05/14/you-buy-a-numa-system-
oracle-says-disable-numa-what-gives-part-ii/) above [provided by Kevin
Closson](http://jcole.us/blog/archives/2010/09/28/mysql-swap-insanity-and-the-
numa-architecture/#comment-1578970) about Oracle on NUMA systems.

**Update 3** : I should have included a warning about `numa_maps`. Simon Mudd
notes correctly that [reading the `/proc/ _pid_ /numa_maps` file stalls the
_pid_ process](http://blog.wl0.org/2012/09/checking-procnuma_maps-can-be-
dangerous-for-mysql-client-connections/) to generate the data it provides. It
should be used carefully in production systems against ` mysqld` as connection
and query stalls will occur while it is reading. Do not monitor it minutely.

– – –

1 Using `free` shows some memory free and lots of cache in use, and totalling
up the resident set sizes from `ps` or `top` shows that the running processes
don’t need more memory than is available.

2 An article in Dr. Dobb’s Journal titled [A Deeper Look Inside Intel
QuickPath Interconnect](http://www.drdobbs.com/go-
parallel/article/printableArticle.jhtml?articleID=222301437) gives pretty good
high level coverage. Intel published a paper entitled [Performance Analysis
Guide for IntelÂ® CoreTM i7 Processor and IntelÂ® XeonTM 5500
processors](http://software.intel.com/sites/products/collateral/hpc/vtune/performance_analysis_guide.pdf)
which is quite good for understanding the internals of NUMA and QPI on Intel’s
Nehalem series of processors.

3 I started a thread on the `linux-mm` mailing list related to [MySQL on
NUMA](http://marc.info/?t=128528110500005), and there are two other threads
related on [zone_reclaim_mode](http://marc.info/?t=128434966300001) and on
[swapping](http://marc.info/?t=128075346800003).

### Share this:

  * [Tweet](https://twitter.com/share)
  *   *   * inShare.53

  * [reddit](https://www.reddit.com/submit?url=https%3A%2F%2Fblog.jcole.us%2F2010%2F09%2F28%2Fmysql-swap-insanity-and-the-numa-architecture%2F&title=The%20MySQL%20%22swap%20insanity%22%20problem%20and%20the%20effects%20of%20the%20NUMA%20architecture)

[Upvote](https://www.reddit.com/submit?url=https%3A%2F%2Fblog.jcole.us%2F2010%2F09%2F28%2Fmysql-
swap-insanity-and-the-numa-
architecture%2F&title=The%20MySQL%20%22swap%20insanity%22%20problem%20and%20the%20effects%20of%20the%20NUMA%20architecture)[Downvote](https://www.reddit.com/submit?url=https%3A%2F%2Fblog.jcole.us%2F2010%2F09%2F28%2Fmysql-
swap-insanity-and-the-numa-
architecture%2F&title=The%20MySQL%20%22swap%20insanity%22%20problem%20and%20the%20effects%20of%20the%20NUMA%20architecture)[submit](https://www.reddit.com/submit?url=https%3A%2F%2Fblog.jcole.us%2F2010%2F09%2F28%2Fmysql-
swap-insanity-and-the-numa-
architecture%2F&title=The%20MySQL%20%22swap%20insanity%22%20problem%20and%20the%20effects%20of%20the%20NUMA%20architecture)

  * .

### _Related_

[A brief update on NUMA and MySQL](https://blog.jcole.us/2012/04/16/a-brief-
update-on-numa-and-mysql/ "A brief update on NUMA and MySQLSome time ago, I
wrote a rather popular post The MySQL "swap insanity" problem and the effects
of the NUMA architecture \(if you haven't read it, stop now and do that!\),
which described using numactl --interleave=all to balance memory allocation
across nodes in a NUMA system. I should've titled it…") In "InnoDB"

[On Sun's acquisition of MySQL AB](https://blog.jcole.us/2008/01/16/on-suns-
acquisition-of-mysql-ab/ "On Sun's acquisition of MySQL ABIf you follow the
MySQL world at all, or you just have your eyes open, you have probably noticed
that an agreement has been reached for Sun to acquire MySQL AB for about one
billion dollars. Quite a few people have asked for my thoughts on the matter,
so I…")In "MySQL"

[My top 5 wishes for MySQL](https://blog.jcole.us/2007/06/20/my-top-5-wishes-
for-mysql/ "My top 5 wishes for MySQLJay Pipes, Stewart Smith, Marten Mickos,
Frank Mash, and Kevin Burton have all gotten into it, and Marten suggested
that I should write my top five. I'm usually not into lists, but this sounds
interesting, so here goes! My top 5 wishes for MySQL are: 1. Restore some of
my…")In "MySQL"

Posted on [September 28, 2010](https://blog.jcole.us/2010/09/28/mysql-swap-
insanity-and-the-numa-architecture/ "18:10") by [Jeremy
Cole](https://blog.jcole.us/author/jeremycole/ "View all posts by Jeremy
Cole"). This entry was posted in
[InnoDB](https://blog.jcole.us/category/mysql/innodb/),
[Linux](https://blog.jcole.us/category/linux/),
[MySQL](https://blog.jcole.us/category/mysql/). Bookmark the
[permalink](https://blog.jcole.us/2010/09/28/mysql-swap-insanity-and-the-numa-
architecture/ "Permalink to The MySQL “swap insanity” problem and the effects
of the NUMA architecture").

  


---
### ATTACHMENTS
[4be7bae5c80782382795060ca19e59cf]: media/numa-imbalanced-allocatio.png
[numa-imbalanced-allocatio.png](media/numa-imbalanced-allocatio.png)
>hash: 4be7bae5c80782382795060ca19e59cf  
>source-url: https://i0.wp.com/jcole.us/blog/files/numa-imbalanced-allocation.png  
>file-name: numa-imbalanced-allocation.png  

[5a8ace87b193d3f52c85a9defc8c071c]: media/uma-architecture.png
[uma-architecture.png](media/uma-architecture.png)
>hash: 5a8ace87b193d3f52c85a9defc8c071c  
>source-url: https://i2.wp.com/jcole.us/blog/files/uma-architecture.png  
>file-name: uma-architecture.png  

[ceb3071fe3f52b49cf8fcc02a1139ab3]: media/numa-architecture.png
[numa-architecture.png](media/numa-architecture.png)
>hash: ceb3071fe3f52b49cf8fcc02a1139ab3  
>source-url: https://i0.wp.com/jcole.us/blog/files/numa-architecture.png  
>file-name: numa-architecture.png  

[e570a8c09a84cccf12a65071a3804931]: media/numa-balanced-allocatio.png
[numa-balanced-allocatio.png](media/numa-balanced-allocatio.png)
>hash: e570a8c09a84cccf12a65071a3804931  
>source-url: https://i2.wp.com/jcole.us/blog/files/numa-balanced-allocation.png  
>file-name: numa-balanced-allocation.png  


---
### TAGS
{SWAP}  {numa}

---
### NOTE ATTRIBUTES
>Created Date: 2017-03-01 01:00:31  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>source: web.clip  
>source-url: https://blog.jcole.us/2010/09/28/mysql-swap-insanity-and-the-numa-architecture/  