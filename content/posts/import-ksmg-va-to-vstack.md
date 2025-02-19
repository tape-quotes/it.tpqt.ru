---
created: 2025-02-11T04:03
date: 2024-08-30
draft: false
params:
  author: Сергей Бурцев
tags:
  - vstack
  - Kaspersky
  - VMware
  - linux
  - bash
title: Подготовка облачного образа Kaspersky Secure Mail Gateway 2.1-VA к импорту в vStack HCP
updated: 2025-02-15T14:22
---
*Пример предполагает, что в качестве существующей среды используется VMware Cloud Director.*
#### Подготовка рабочего окружения (EL9)

В примере для взаимодействия с VMware Cloud Director будет использоваться утилита vcd-cli.
Вместо неё можно использовать и ovftool.

``` bash
dnf install -y python3 qemu-img libguestfs guestfs-tools
```

``` bash
python -m ensurepip --upgrade
```

``` bash
pip install --user vcd-cli
```

#### Подготовка ВМ в vcd

Для последующего скачивания виртуальную машину нужно развернуть в отдельном vApp.

Конфигурация созданной ВМ должна соответствовать следующим параметрам:
- 8 vCPU
- 16 GB RAM
- 200 GB HDD
- Guest OS: Red Hat Enterprise Linux 9 (64-bit)
- Boot Firmware: EFI
- EFI Secure Boot: Disabled

В установщике есть проверка на соответствие этим требованиям к ресурсам. При несоответствии установку продолжить нельзя.

Необходимо произвести установку VA с ISO-образа и после установки загрузиться и пройти мастер первоначальной настройки с указанием любых параметров.

``` ad-note
Загрузиться в single после установки невозможно -- учётная запись root заблокирована.
Способ с `init=/bin/bash` также не работает.
```

#### Выгрузка шаблона ВМ/vApp из vcd с vcd-cli

Логинимся в vcd

``` bash
vcd login <vcd_fqdn> <org> <user>
```

Пример:

``` bash
$ vcd login vcloud.mycloud.com myorg my.username
Password: 
my.username logged in, org: 'myorg', vdc: 'vcd-nsxv'
```

(Для информации) получаем список доступных в vDC vApps

``` bash
vcd vapp list
```

Пример:

``` bash
isDeployed    isEnabled      memoryAllocationMB  name                                             numberOfCpus    numberOfVMs  ownerName       status         storageKB  vdcName
------------  -----------  --------------------  ---------------------------------------------  --------------  -------------  --------------  -----------  -----------  ---------
false         true                        16384  ksmg-va-2107854                                             8              1  my.username    POWERED_OFF    209715200  vdc-nsxv
true          true                        81920  lab-itglobal-com-vapp                                      32              4  my.username    MIXED          639631360  vdc-nsxv
true          true                               dr-vm-02-7e600f54-b3ec-4764-88ef-18311290564a                              0  my.username    POWERED_ON             0  vdc-nsxt
true          true                        16384  tq-dmz-vapp                                                 8              1  my.username    POWERED_ON      20971520  vdc-nsxv
true          true                        18432  tq-mgmt-vapp                                               10              2  my.username    POWERED_ON     734003200  vdc-nsxv
```

Скачиваем ранее развёрнутое vApp

``` bash
vcd vapp download <vapp_name> ./
```

Пример:

``` bash
$ vcd vapp download ksmg-va-2107854 ./

<Enabling download of Virtual Application...>

download 1,335,374,336 of 1,335,374,336 bytes, 100%
download 270,840 of 270,840 bytes, 100%
property    value
----------  ---------------
file        ksmg-va-2107854
size        1335664640
```

#### Модификация образа

Распаковываем шаблон (сделать это можно любым архиватором)

``` bash
tar -xvf ksmg-va-2107854
```

Примечание:

    The qemu driver for VMDK does not support writes to the VMDK subformat (streamOptimized).  This is a bug / shortcoming in qemu.
    The only workaround is to convert to a simpler format, eg. raw.

-- поэтому уже на текущем этапе конвертируем vmdk в raw:

``` bash
qemu-img convert -p -f vmdk -O raw vm-95b6833a-e214-4994-aa4c-6f9a60034d5a-disk-0.vmdk ksmg-va-2107854.img
```

(Для информации) получаем список имеющихся разделов и файловых систем:

``` bash
LIBGUESTFS_BACKEND=direct virt-filesystems -lh --uuid -a ksmg-va-2107854.img
```

Пример:

    Name      Type       VFS  Label Size Parent UUID
    /dev/sda1 filesystem vfat -     498M -      542A-2139
    /dev/sda2 filesystem ext2 -     466M -      82540b2f-5045-4ded-88c7-23ae6c5afd12
    /dev/sda3 filesystem ext4 -     9,7G -      32701b3b-eae1-4f69-88bb-d881efefb636
    /dev/sda4 filesystem ext4 -     24G  -      b0aa351a-5a82-4a45-8064-b9f186caaab0
    /dev/sda5 filesystem ext4 -     39G  -      39ffb068-7d45-4a87-bb57-08e6d2ecba55
    /dev/sda6 filesystem ext4 -     97G  -      da2a721d-218c-4a0c-9593-fba4bfbc94ec
    /dev/sda7 filesystem ext4 -     12G  -      0c8f6afb-de89-4fda-9276-2e2af1136d07

Переходим в режим суперпользователя

``` bash
sudo -i
```

Создаём точку монтирования

``` bash
mkdir ksmg
```

Монтируем все разделы с виртуального диска

``` bash
LIBGUESTFS_BACKEND=direct guestmount -a ksmg-va-2107854.img -i --rw ksmg
```

``` bash
mount --bind /dev ksmg/dev
```

``` bash
mount --bind /dev/pts ksmg/dev/pts
```

``` bash
mount --bind /proc ksmg/proc
```

``` bash
mount --bind /sys ksmg/sys
```

Копируем настройки dns из текущего окружения

``` bash
cp /etc/resolv.conf ksmg/etc/
```

Меняем окружение

``` bash
chroot ksmg
```

Добавляем в dracut драйверы virtio

``` bash
echo 'add_drivers+="virtio_blk virtio_scsi virtio_net virtio_pci virtio_rng virtio_balloon nvme"' > /etc/dracut.conf.d/virtio.conf
```

Выясняем версию ядра в образе ВМ:

``` bash
ls /lib/modules/
```

`5.14.0-362.18.1.el9_3.0.1.x86_64`

Генерируем initramfs

``` bash
dracut -f -v -N '' 5.14.0-362.18.1.el9_3.0.1.x86_64
```

Проверяем наличие драйверов в initramfs

``` bash
lsinitrd /boot/initramfs-5.14.0-362.18.1.el9_3.0.1.x86_64.img | grep virtio
```

Включаем репозитории Rocky Linux

``` bash
dnf config-manager --releasever 9.3 --enable baseos appstream
```

Устанавливаем cloud-init

``` bash
dnf install -y cloud-init cloud-utils-growpart
```

Активируем службы cloud-init

``` bash
systemctl enable cloud-init cloud-init-local cloud-config cloud-final
```

Добавляем настройки cloud-init datasources для vStack

``` bash
cat << EOT > /etc/cloud/cloud.cfg.d/90_vStack.cfg
datasource_list: [ "SmartOS", "NoCloud" ]
EOT
```

Модифицируем скрипт `/opt/kaspersky/ksmg-appliance-addon/bin/wizard`, чтобы избежать запроса мастером первоначальной настройки уже переданных через cloud-init сетевых параметров

``` bash
sed -i -e 's/configure_network(widgets)$/#configure_network(widgets)' /opt/kaspersky/ksmg-appliance-addon/bin/wizard
```

Удаляем open-vm-tools

``` bash
dnf --noautoremove remove open-vm-tools
```

Выключаем репозитории:

``` bash
dnf config-manager --releasever 9.3 --disable baseos appstream
```

``` bash
echo "" > /etc/resolv.conf
```

Очищаем историю

``` bash
history -c && history -w
```

Выходим из chroot и размонтируем разделы

``` bash
exit
```

``` bash
umount -R ksmg
```

Сжимаем образ

``` bash
xz -0 -T 4 ./ksmg-va-2107854.img
```

Подготовленный образ передаём вендору для добавления в кластер.

#### TBD

- growpart в примере устанавливается, но не настраивается. Для корректной работы механизма увеличения размера разделов нужно произвести дополнительную настройку, поскольку партиций на диске больше, чем одна.