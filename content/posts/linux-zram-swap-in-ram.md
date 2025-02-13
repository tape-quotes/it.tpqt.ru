---
created: 2025-02-11T04:03
draft: true
params:
  author: Сергей Бурцев
updated: 2025-02-14T02:22
date: 
title: 
weight: 
---
### Пример из мануала

    zramctl --find --size 1024M

`/dev/zram0`

    mkswap /dev/zram0

    swapon /dev/zram0

...

    swapoff /dev/zram0

    zramctl --reset /dev/zram0

------------------------------------------------------------------------

### Живой пример

``` shell
zramctl
```

`NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT`
`/dev/zram0 lzo-rle       7,4G   5G  1,1G  1,2G       4 [SWAP]`

``` shell
sudo zramctl -f -s 7,6GiB -a zstd
```

`/dev/zram1`

``` shell
zramctl
```

`NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT`
`/dev/zram0 lzo-rle       7,4G   5G  1,1G  1,2G       4 [SWAP]`
`/dev/zram1 zstd            8G   0B    0B    0B       4`

``` shell
sudo mkswap /dev/zram1
```

`Setting up swapspace version 1, size = 8 GiB (8589930496 bytes)`
`no label, UUID=a7565f88-0f6a-4b16-9906-7c9e23e8bbe7`

``` shell
swapon /dev/zram1
```

`NAME       ALGORITHM DISKSIZE  DATA COMPR TOTAL STREAMS MOUNTPOINT`
`/dev/zram0 lzo-rle       7,4G  5,1G  1,2G  1,2G       4 [SWAP]`
`/dev/zram1 zstd            8G    4K   59B   20K       4 [SWAP]`

    sudo swapoff /dev/zram0
