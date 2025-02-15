---
created: 2025-02-11T04:03
updated: 2025-02-15T14:53
date: 2024-08-12
draft: false
params:
  author: Сергей Бурцев
title: Настройка iSCSI, multipathd и lvm в EL9
weight: "10"
tags:
  - linux
  - iscsi
  - multipathd
  - lvm
  - bash
  - VMware
  - vcd
---
#### Устанавливаем пакеты
```bash
dnf install -y iscsi-initiator-utils device-mapper-multipath
```

#### Уточняем имя инициатора (IQN)
```bash
cat /etc/iscsi/initiatorname.iscsi
```

или записываем в файл собственное вида:

`InitiatorName=iqn.2024-08.com.itglobal.bareos-aio-kz:bareos-sd01`

#### Генерируем дефолтный конфиг для multipath
```bash
/sbin/mpathconf --enable
```

#### Вносим параметры авторизации в файл конфигурации
```bash
vi /etc/iscsi/iscsid.conf
```

Пояснения:

Username обычно совпадает с `InitiatorName` хоста.

Приписка `_in` обозначает `initiator`.

Без приписки `_in` - `target` или `outgoing`.

```
node.session.auth.authmethod = CHAP
node.session.auth.chap_algs = SHA3-256,SHA256,SHA1,MD5
node.session.auth.username = iqn.1994-05.com.redhat:123123123
node.session.auth.password = target_pass
node.session.auth.username_in = iqn.1994-05.com.redhat:123123123
node.session.auth.password_in = initiator_pass
discovery.sendtargets.auth.authmethod = CHAP
discovery.sendtargets.auth.username = iqn.1994-05.com.redhat:123123123
discovery.sendtargets.auth.password = target_pass
discovery.sendtargets.auth.username_in = iqn.1994-05.com.redhat:123123123
discovery.sendtargets.auth.password_in = initiator_pass
```

#### Включаем сервисы и проверяем логи
```bash
systemctl enable --now iscsid && systemctl enable --now multipathd
```

```bash
systemctl status iscsid
```

```bash
systemctl status multipathd
```

#### Обнаруживаем точки подключения к хранилищу
```bash
iscsiadm -m discovery -t sendtargets -p <IP address>
```

#### Подключаемся к обнаруженным узлам
```bash
iscsiadm -m node --login
```

(или подключаемся вручную к каждому узлу хранилища из обнаруженным ранее)
```bash
iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.206' --login
```
```bash
iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.207' --login
```
```bash
iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.208' --login
```
```bash
iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.209' --login
```

#### Проверяем, что выданный на хранилище диск доступен:
```bash
multipath -ll
```

Пример вывода:
```
mpatha (36d039ea0000016710000027f66b5e2ef) dm-2 NETAPP,INF-01-00
size=2.0T features='3 queue_if_no_path pg_init_retries 50' hwhandler='1 alua' wp=rw
|-+- policy='service-time 0' prio=50 status=active
| |- 36:0:0:1 sde 8:64 active ready running
| |- 35:0:0:1 sdd 8:48 active ready running
|-+- policy='service-time 0' prio=10 status=enabled
| |- 34:0:0:1 sdc 8:32 active ready running
| |- 33:0:0:1 sdb 8:16 active ready running
```

Полученное блочное устройство будет доступно по пути `/dev/mapper/mpath[a..n]`

#### Размечаем получившийся диск средствами lvm2
```bash
pvcreate /dev/mapper/mpatha
```

```bash
vgcreate data_vg /dev/mapper/mpatha
```

```bash
lvcreate -L 1GiB --name data_lv data_vg /dev/mapper/mpatha
```

```bash
lvextend /dev/data_vg/data_lv -l +100%FREE
```

#### Дополнительно

Параметры монтирования для `/etc/fstab`:
```
/dev/data_vg/data_lv  /data_lv xfs     _netdev,defaults  0 0
```

При наличии в логах сообщений от **multipathd** вида:
```
Feb 18 12:49:33 <...> multipathd[32939]: sda: add missing path  
Feb 18 12:49:33 <...> multipathd[32939]: sda: failed to get udev uid: Invalid argument  
Feb 18 12:49:33 <...> multipathd[32939]: sda: failed to get sysfs uid: Invalid argument  
Feb 18 12:49:33 <...> multipathd[32939]: sda: failed to get sgio uid: No such file or directory
```

необходимо добавить в **`/etc/multipath.conf`** в блок **`blacklist`**:
```json
blacklist {  
    device {  
         vendor "VMware"  
         product "Virtual disk"  
    }  
}
```

Увеличить размера тома после увеличения размера LUN можно так:
```bash
lsblk
```

```bash
for i in b c d e; do echo 1 > /sys/block/sd$i/device/rescan; done
```

```bash
multipathd resize map mpatha
```

```bash
pvresize /dev/mapper/mpatha
```

```bash
lvextend /dev/repo_low_hdd_vg/low_hdd01 -l +100%FREE
```

```
xfs_growfs /dev/repo_low_hdd_vg/low_hdd01
```
