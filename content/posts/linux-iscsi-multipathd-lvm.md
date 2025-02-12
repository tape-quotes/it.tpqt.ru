---
created: "2024-08-12T23:01"
updated: "2024-09-11T19:12"
---

    dnf install -y iscsi-initiator-utils device-mapper-multipath

Уточняем имя инициатора (IQN):

    cat /etc/iscsi/initiatorname.iscsi

или записываем в файл собственное вида:
`InitiatorName=iqn.2024-08.com.itglobal.bareos-aio-kz:bareos-sd01`

Генерируем дефолтный конфиг для multipath:

    /sbin/mpathconf --enable

Вносим параметры авторизации в файл конфигурации

    vi /etc/iscsi/iscsid.conf

Username обычно совпадает с `InitiatorName` хоста
Приписка `_in` обозначает `initiator`
Без приписки `_in` - `target` или `outgoing`

    node.session.auth.authmethod = CHAP
    node.session.auth.chap_algs = SHA3-256,SHA256,SHA1,MD5 #Для centos 7 нужно убрать SHA3-256
    node.session.auth.username = iqn.1994-05.com.redhat:123123123
    node.session.auth.password = target_pass
    node.session.auth.username_in = iqn.1994-05.com.redhat:123123123
    node.session.auth.password_in = initiator_pass
    discovery.sendtargets.auth.authmethod = CHAP
    discovery.sendtargets.auth.username = iqn.1994-05.com.redhat:123123123
    discovery.sendtargets.auth.password = target_pass
    discovery.sendtargets.auth.username_in = iqn.1994-05.com.redhat:123123123
    discovery.sendtargets.auth.password_in = initiator_pass

Включаем сервисы и проверяем логи на наличие ошибок:

    systemctl enable --now iscsid && systemctl enable --now multipathd

    systemctl status iscsid

    systemctl status multipathd

Обнаруживаем точки входа к хранилищу:

    iscsiadm -m discovery -t sendtargets -p <IP address>

Подключаемся к обнаруженным узлам:

    iscsiadm -m node --login

(или подключаемся к каждому узлу хранилища, обнаруженному ранее:)
`iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.206' --login`
`iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.207' --login`
`iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.208' --login`
`iscsiadm -m node --targetname 'iqn.2002-09.com.lenovo:thinksystem.6d039ea0002cf17c00000000616ead3f' --portal '10.32.45.209' --login`

Проверяем, что выданный на хранилище диск доступен:

    multipath -ll

    mpatha (36d039ea0000016710000027f66b5e2ef) dm-2 NETAPP,INF-01-00
    size=2.0T features='3 queue_if_no_path pg_init_retries 50' hwhandler='1 alua' wp=rw
    |-+- policy='service-time 0' prio=50 status=active
    | |- 36:0:0:1 sde 8:64 active ready running
    | `- 35:0:0:1 sdd 8:48 active ready running
    `-+- policy='service-time 0' prio=10 status=enabled
      |- 34:0:0:1 sdc 8:32 active ready running
      `- 33:0:0:1 sdb 8:16 active ready running

Полученное блочное устройство будет доступно по пути `/dev/mapper/mpath[a..n]`

Разметить получившийся диск можно следующим образом:

    pvcreate /dev/mapper/mpatha

    vgcreate data_vg /dev/mapper/mpatha

    lvcreate -L 1GiB --name data_lv data_vg /dev/mapper/mpatha

    lvextend /dev/mapper/data_vg-data_lv -l +100%FREE

Рекомендуется монтировать следующей строкой в /etc/fstab:
`/dev/mapper/mpatha /data/miniovol xfs     _netdev,defaults  0 0`

При флуде в логи со стороны **multipathd** вида:

    Feb 18 12:49:33 test-w1-k8s multipathd[32939]: sda: add missing path  
    Feb 18 12:49:33 test-w1-k8s multipathd[32939]: sda: failed to get udev uid: Invalid argument  
    Feb 18 12:49:33 test-w1-k8s multipathd[32939]: sda: failed to get sysfs uid: Invalid argument  
    Feb 18 12:49:33 test-w1-k8s multipathd[32939]: sda: failed to get sgio uid: No such file or directory

необходимо добавить в **/etc/multipath.conf** в блок **blacklist**:

    blacklist {  
        device {  
             vendor "VMware"  
             product "Virtual disk"  
        }  
    }

Увеличение размера тома после увеличения размера LUN:

    lsblk

    for i in b c d e; do echo 1 > /sys/block/sd$i/device/rescan; done

    multipathd resize map mpatha

    pvresize /dev/mapper/mpatha

    lvextend /dev/repo_low_hdd_vg/low_hdd01 -l +100%FREE

    xfs_growfs /dev/repo_low_hdd_vg/low_hdd01
