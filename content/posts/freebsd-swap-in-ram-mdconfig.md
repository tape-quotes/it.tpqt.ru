---
created: 2025-02-11T04:03
updated: 2025-02-14T02:22
date: 2024-03-18
draft: false
params:
  author: Сергей Бурцев
title: Swap в ОЗУ с компрессией для FreeBSD
weight: "10"
tags:
  - freebsd
  - swap
  - mdconfig
  - linux
  - zram
---
*[mdconfig](https://man.freebsd.org/cgi/man.cgi?mdconfig(8)) FreeBSD -- аналог zram (zramctl) в linux.*
#### С компрессией zfs

[Предложен](https://t.me/freebsd_ru/509532) Борисом Люточкиным [@freebsd_ru](https://t.me/freebsd_ru)

/etc/rc.local

``` shell
set -e
<...>
specnode=mdconfig -a -t swap -s 32G
zpool create -o cachefile=none -m /zram zram-tmpfs $specnode
zfs set compression=lz4 atime=off dedup=off zram-tmpfs
<...>
```

#### Со стандартной компрессией

```sh
mdconfig -a -t swap -o compress -o reserve -s 512M -u 7
```

```sh
swapon /dev/md7
```

или

```sh
mount /dev/md7 /mnt/ramdrive
```

#### Примечание из man mdconfig:

`-t type`
Select the type of the memory disk.

`malloc` Storage for this type of memory disk is allocated with `alloc`(9). This limits the size to the malloc bucket limit in the kernel. ***If the -o reserve option is not set, creating and filling a large malloc-backed memory disk is a very easy way to panic the system*.**
\<...\>
`swap` Storage for this type of memory disk is allocated from buffer memory. Pages get pushed out to swap when the system is under memory pressure, otherwise they stay in the operating memory. ***Using `swap` backing is generally preferred instead of using `malloc` backing.***
