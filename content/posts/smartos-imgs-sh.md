---
created: 2025-02-11T04:03
updated: 2025-02-14T03:15
date: 2025-02-20
draft: false
params:
  author: Сергей Бурцев
title: Скрипт для получения списка образов SmartOS в OmniOS
weight: "10"
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
aliases:
---
Посчастливилось познакомиться с [LX Branded Zones](https://omnios.org/info/lxzones), благополучно перекочевавшими в OmniOS из SmartOS.

Знакомство началось с выковыривания UUID'а нужного образа из простыни JSON и ручной его подстановкой  в URL для последующего скачивания и развертывания.

В SmartOS для этих целей существует утилита [imgadm](https://docs.smartos.org/managing-images/). *~~К сожалению, в OmniOS подобного инструмента нет и, видимо, пока не предвидится.~~*
#### Кругом разруха
**UPD: невероятно и внезапно, но такой инструмент всё же есть, и есть он прямо в составе [zadm](https://github.com/omniosorg/zadm/blob/master/doc/zadm.pod), утилиты для управления зонами OmniOS.**
```bash
pkg install zadm
```
```
zadm list-images [--refresh] [--verbose] [-b <brand>] [-p <provider>]
```

Конкретнее:
```
zadm list-images --verbose -b lx -p smartos
```

Почему вместо её использования по первой ссылке этого поста предлагается пройтись по такому ненужному алгоритму -- остаётся загадкой. Почему на той же странице по  ссылке нам предоставили такое "подробное" описание этой утилиты -- тоже. Вероятно, автор тех статей на их написании (и/или последующем обновлении) явно желал сэкономить своё время в ущерб чужому, чтобы осталось больше на портирование драйверов.

А всё, что было написано и сделано мной дальше, я просто оставлю для истории и понимания масштаба тупняка. Чтобы своё время не потратил впустую ещё кто-нибудь, можно не читать. ;)
#### Найди образ
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

#### Подставь найденный UUID в URL
```bash
https://images.smartos.org/images/<UUID>/file
```

#### Загрузи образ, не забыв про формат
```bash
curl -o /tmp/almalinux95.zss.gz https://images.smartos.org/images/50c86f0f-e25e-485c-80ca-8cf8e5640ce6/file
```

#### Но лучше, конечно,..
даже корявенький, но bash-скрипт с jq, sed... и так далее.
```bash
#!/bin/bash

if ! command -v jq &>/dev/null; then
    echo
    echo -e "  \e[91mОшибка: приложение jq не установлено.\e[0m" >&2
    echo
    exit 1
fi

echo && echo " В публичном репозитории SmartOS доступны следующие образы:"
echo
echo ' Название,ОС,Тип,Описание,>,Дата,URL,Формат,SHA1' > /tmp/sOS.lst
curl -s -S https://images.smartos.org/images | \
jq -r -c '.[] | [ ( .name | .[0:15] ), .os, .type, ( .description | .[0:40] ), ">", ( .published_at | .[0:10] ), "https://images.smartos.org/images/", .uuid, "/file", ( .files[] | .compression, .sha1 ) ]' | \
sed -e 's/^/ /;s/\[//g;s/\]//g;s/"//g;s/https\:\/\/images.smartos.org\/images\/\,/https\:\/\/images.smartos.org\/images\//;s/\,\/file/\/file/' | sort -t . -n -k 1,1n -k 2,2n -k 3,3n -k 4,4n >> /tmp/sOS.lst
column -t -s ',' < /tmp/sOS.lst | more
rm -f /tmp/sOS.lst
exit 0 ## что бы ни произошло, нужно верить в лучшее...
```

<figure>
<figcaption
aria-hidden="true">Можно полистать...</figcaption>
<img src="../smartos-imgs-sh/20250220183406.png" />
</figure>
<figure>
<figcaption
aria-hidden="true">...А можно (предпочтительно) и grep'нуть:</figcaption>
<img src="../smartos-imgs-sh/20250220183526.png" />
</figure>

#### ...Запустить неглядя
```
bash <(curl -s https://raw.githubusercontent.com/tape-quotes/it.tpqt.ru/refs/heads/main/content/bin/getimgs.sh)
```