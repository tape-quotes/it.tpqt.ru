---
created: "2024-03-18T22:51"
updated: "2025-02-14T01:02"
---

``` table-of-contents
title: 
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

##### С компрессией zfs

rc.local

``` shell
set -e
<...>
specnode=mdconfig -a -t swap -s 32G
zpool create -o cachefile=none -m /zram zram-tmpfs $specnode
zfs set compression=lz4 atime=off dedup=off zram-tmpfs
```

##### Со стандартной компрессией

    mdconfig -a -t swap -o compress -o reserve -s 512m -u 7

    swapon /dev/md7

либо

    mount /dev/md7 /mnt/ramdrive

Примечание-цитата из man mdconfig:

`-t type`
Select the type of the memory disk.

`malloc` Storage for this type of memory disk is allocated with `alloc`(9). This limits the size to the malloc bucket limit in the kernel. If the -o reserve option is not set, creating and filling a large malloc-backed memory disk is a very easy way to panic the system.
\<...\>
`swap` Storage for this type of memory disk is allocated from buffer memory. Pages get pushed out to swap when the system is under memory pressure, otherwise they stay in the operating memory. **Using `swap` backing is generally preferred instead of using `malloc` backing.**
