---
created: 2025-02-11T04:03
updated: 2025-02-13T17:52
date: 2024-04-23
draft: true
params:
  author: Сергей Бурцев
title: Монтирование raw-образа диска (img) как блочного устройства в linux
weight: 
tags:
  - losetup
  - mknod
  - linux
---
#### losetup - утилита управления loop-устройствами

Простой пример использования:

1. Монтируем образ:
```bash
sudo losetup -fR image.img
```

Флаг `-f` ("find") смонтирует образ в первое свободное обнаруженное в системе loop-устройство.
Флаг `-R` ("recursive") используется для сканирования образа на существующие в нём разделы и их последующего монтирования.

2. Получаем информацию о подключенных устройствах:
``` bash
losetup -a
```

Пример вывода:
```
/dev/loop0: []: (/home/user/image.img)
```

3. Отключаем ранее подключенное устройство:
``` bash
sudo losetup -d /dev/loop0
```

На **старых системах** возможен вариант, когда флаг -R не работает, поскольку модуль `loop.ko` загружается с опцией по умолчанию `max_part=0`.

Убедиться в этом можно командой:
```bash
cat /sys/module/loop/parameters/max_part
```

В этом случае, чтобы в `/dev` для loop-устройства отобразился, к примеру, существующий раздел `loop0p1`, соответствующий первому разделу смонтированного образа, последовательность действий будет такая:

1. отключаем ранее подключенное устройство:
``` bash
sudo losetup -d /dev/loop0
```

2. выгружаем модуль:
``` bash
sudo modprobe -r loop
```

3. загружаем с нужной опцией:
``` bash
sudo modprobe loop max_part=31
```

Чтобы эта настройка стала перманентной, необходимо добавить в `/etc/modprobe.conf`или в новый файл в директории `/etc/modprobe.d/` строку: `options loop max_part=31`

4. повторно подключаем образ как loop-устройство:
``` bash
sudo losetup -f image.img
```

5. проверяем наличие смонтированных разделов:
```bash
lsblk
```

Вывод команды:
```
NAME                                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0                                           7:0    0   200M  0 loop  
└─loop0p1                                       7:1    0   199M  0 part  
```
#### mknod - 

https://www.oreilly.com/library/view/linux-device-drivers/0596000081/ch03s02.html

older:
Character devices:
1 mem
2 pty
3 ttyp
4 ttyS
6 lp
7 vcs
10 misc
13 input
14 sound
21 sg
180 usb

    Block devices:
     2 fd
     8 sd
     11 sr
     65 sd
     66 sd

newer:
Character devices:
1 mem
4 /dev/vc/0
4 tty
4 ttyS
5 /dev/tty
5 /dev/console
5 /dev/ptmx
7 vcs
10 misc
13 input
14 sound
21 sg
81 video4linux
90 mtd
108 ppp
116 alsa
128 ptm
136 pts
180 usb
188 ttyUSB
189 usb_device
202 cpu/msr
203 cpu/cpuid
216 rfcomm
226 drm
234 media
235 mei
236 nvme-generic
237 nvme
238 aux
239 cec
240 binder
241 hidraw
242 ttyDBC
243 usbmon
244 wwan_port
245 bsg
246 watchdog
247 ptp
248 pps
249 lirc
250 rtc
251 dma_heap
252 dax
253 tpm
254 gpiochip
261 accel

    Block devices:
      7 loop
      8 sd
      9 md
     11 sr
     65 sd
     66 sd
     67 sd
     68 sd
     69 sd
     70 sd
     71 sd
     128 sd
     129 sd
     130 sd
     131 sd
     132 sd
     133 sd
     134 sd
     135 sd 
     252 zram
     253 device-mapper
     254 mdp
     259 blkext

#### together

Создаём блочное устройство

    mknod /dev/sdb b 7 500

Подключаем к созданному устройству образ как loop-устройство

    losetup /dev/sdb image.img
