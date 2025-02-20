---
created: 2025-02-11T04:03
updated: 2025-02-14T03:15
date: 2025-02-20
draft: false
params:
  author: Сергей Бурцев
title: Скрипт для получения списка образов SmartOS / OmniOS
weight: 
tags:
  - smartos
  - omnios
  - illumos
  - cloud
  - bash
  - jq
  - json
series: 
series_order:
---
Посчастливилось познакомиться с [LX Branded Zones](https://omnios.org/info/lxzones), благополучно перекочевавшими из SmartOS в OmniOS.

Знакомство началось с выковыривания UUID'а нужного образа из простыни JSON и ручной его подстановкой  в URL для последующего скачивания и развертывания.
Мелочь -- а неприятно.

Например:
https://images.smartos.org/images -- зайди сюда и найди в простыне то, что нужно.

``` json
{
    "v": 2,
    "uuid": "50c86f0f-e25e-485c-80ca-8cf8e5640ce6",
    "owner": "00000000-0000-0000-0000-000000000000",
    "name": "almalinux-9",
    "version": "20250120",
    "state": "active",
    "disabled": false,
    "public": true,
    "published_at": "2025-01-20T19:24:01Z",
    "type": "lx-dataset",
    "os": "linux",
    "files": [
      {
        "sha1": "9f90ca1d99365d84b11ba20728b5fe25be6a1afa",
        "size": 134733634,
        "compression": "gzip"
      }
    ],
    "description": "Container-native AlmaLinux 9.5 (Teal Serval) 64-bit image. Built to run on containers with bare metal speed, while offering all the services of a typical unix host.",
    "homepage": "https://docs.tritondatacenter.com/public-cloud/instances/infrastructure/images",
    "requirements": {
      "brand": "lx",
      "min_platform": {
        "7.0": "20220407T001427Z"
      },
      "networks": [
        {
          "description": "public",
          "name": "net0"
        }
      ]
    },
    "tags": {
      "kernel_version": "5.10.0",
      "role": "os"
    }
  }
```

Подставь  найденный UUID в URL:
```
https://images.smartos.org/images/<UUID>/file
```

Загрузи образ, не забыв про формат:
```bash
curl -o /tmp/almalinux95.zss.gz https://images.smartos.org/images/50c86f0f-e25e-485c-80ca-8cf8e5640ce6/file
```

Но лучше, конечно, даже корявенький, но скрипт на bash с jq, sed, sort... и так далее.
```bash
#!/bin/bash
echo && echo " В репозитории SmartOS доступны следующие образы:"
echo
echo ' ОС,Тип,Название,Опубликовано,URL,Формат,SHA1' > /tmp/sOS.lst
curl -s -S https://images.smartos.org/images | jq -r -c '.[] | [ .os, .type, .name, .published_at, "https://images.smartos.org/images/", (.uuid), "/file", ( .files[] | .compression, .sha1 ) ]' | sed -e 's/^//;s/[//g;s/\]//g;s/"//g;s/https\:\/\/images.smartos.org\/images\/\,/https\:\/\/images.smartos.org\/images\//;s/\,\/file/\/file/' | sort -t . -n -k 1,1n -k 2,2n -k 3,3n -k 4,4n >> /tmp/sOS.lst
column -t -s ',' < /tmp/sOS.lst | more
exit 0
```

<figure>
<figcaption
aria-hidden="true">Можно полистать...</figcaption>
<img
src="../smartos-imgs-sh/404396e1700def250d21e85e932ba21543ac1ea2.png"
class="wikilink" alt="Pastedimage20250220151930.png" />
</figure>

<figure>
<figcaption
aria-hidden="true">...А можно и grep'нуть:</figcaption>
<img
src="../smartos-imgs-sh/79fe7460c393a5428e73cde3441a1e096b9f7926.png"
class="wikilink" alt="Pastedimage20250220152035.png" />
</figure>

