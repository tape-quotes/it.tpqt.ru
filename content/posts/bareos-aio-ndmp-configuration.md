---
created: 2025-02-11T04:03
updated: 2025-02-14T02:22
date: 
draft: true
params:
  author: Сергей Бурцев
title: 
weight: 
---
#### Имя инстанса

    echo "127.0.0.1 bareos-aio-kz" >> /etc/hosts

    find /etc/bareos/ -name \*.conf -exec sed -i -e 's/Name = bareos-dir$/Name = bareos-dir-kz/g' {} \;

#### Конфигурации dir, sd, fd, bconsole c TLS-PSK

/etc/bareos/bareos-dir.d/director/bareos-dir.conf

    Director {                            # define myself
      Name = bareos-dir-kz # Имя инстанса
      QueryFile = "/usr/lib/bareos/scripts/query.sql"
      Maximum Concurrent Jobs = 20
      Password = "<random-password>"         # Пароль для подключения к Dir из bconsole
      Messages = Daemon
      Auditing = yes

      TLS Enable = yes
      TLS Require = yes
      TLS Protocol = "-TLSv1,-TLSv1.1,-TLSv1.3,TLSv1.2"
    }

/etc/bareos/bconsole.conf

    Director {
      Name = bareos-dir-kz
      address = localhost
      Password = "<random-password>" # Должен совпадать с паролем из bareos-dir.d/director/bareos-dir.conf
      Description = "Bareos Console credentials for local Director"
    }

/etc/bareos/bareos-sd.d/director/bareos-dir.conf

    Director {
      Name = bareos-dir-kz
      Password = "<random-password>" # Пароль подключения Dir<->Storage Daemon
      TLS Enable = yes
      TLS Require = yes
      TLS Protocol = "-TLSv1,-TLSv1.1,-TLSv1.3,TLSv1.2"
      Description = "Director, who is permitted to contact this storage daemon."
    }

/etc/bareos/bareos-fd.d/director/bareos-dir.conf

    Director {
      Name = bareos-dir-kz
      Password = "<random-password>" # Пароль подключения Dir<->File Daemon
      Description = "Allow the configured Director to access this file daemon."
    }

#### Конфигурация устройств (Storage Daemon)

https://docs.bareos.org/TasksAndConcepts/VolumeManagement.html#section-multiplestoragedevices

/etc/bareos/bareos-sd.d/device/low-hdd01.conf

    Device {
      Count = 20 # Из одного блока ресурса создаётся сразу 20 устройств с именами device-low-hdd01nnnn

      Name = device-low-hdd01
      Media Type = File
      Maximum Concurrent Jobs = 1
      Archive Device = /repo/low-hdd01
      LabelMedia = yes;                   # lets Bareos label unlabeled media
      Random Access = yes;
      AutomaticMount = yes;               # when device opened, read it
      RemovableMedia = no;
      AlwaysOpen = no;
      Description = "Low-speed HDD-based File Multidevice. A connecting Director must have the same Name and MediaType."
    }

В случае, если доступных типов хранилища РК больше одного (например, тиры SSD и HDD), либо если по каким-то причинам в файловой системе больше одного смонтированного каталога для одного и того же типа накопителей, необходимо создать по одному ресурсу Device для каждого каталога файловой системы, используемого в качестве репозитория, указав в параметре `Archive Device` путь к соответствующей директории:

    <...>
      Count = 20
      Name = device-high-ssd01
      <...>
      Archive Device = /repo/high-ssd01
      <...>

    <...>
      Count = 20
      Name = device-high-ssd02
      <...>
      Archive Device = /repo/high-ssd02
      <...>

#### Конфигурация хранилища (Director -\> Storage Daemon)

/etc/bareos/bareos-dir.d/storage/file-low-hdd01.conf

(!) если `hostname -fqdn` с доменом, то именно его полностью и нужно прописать в Address, иначе задания будут завершаться с ошибкой.

    Storage {
      Name = stor-file-low-hdd01 
      Address = bareos-aio-kz                # N.B. Use a fully qualified name here (do not use "localhost" here).
      Password = "random-password" # Пароль подключения Dir<->Storage Daemon
      TLS Enable = yes
      TLS Require = yes
      TLS Protocol = "-TLSv1,-TLSv1.1,-TLSv1.3,TLSv1.2"
      Device = device-low-hdd010001
      Device = device-low-hdd010002
      Device = device-low-hdd010003
      Device = device-low-hdd010004
      Device = device-low-hdd010005
      Device = device-low-hdd010006
      Device = device-low-hdd010007
      Device = device-low-hdd010008
      Device = device-low-hdd010009
      Device = device-low-hdd010010
      Device = device-low-hdd010011
      Device = device-low-hdd010012
      Device = device-low-hdd010013
      Device = device-low-hdd010014
      Device = device-low-hdd010015
      Device = device-low-hdd010016
      Device = device-low-hdd010017
      Device = device-low-hdd010018
      Device = device-low-hdd010019
      Device = device-low-hdd010020
      Maximum Concurrent Jobs = 20
      Media Type = File
    }

    Storage {
      Name = stor-ndmp-low-hdd01
      Address = bareos-aio-kz
      Protocol = NDMPv4
      Port = 10000
      Auth Type = Clear
      Username = ndmpadmin
      Password = "<ndmp-random-password>" 
      Device = device-low-hdd010001
      Device = device-low-hdd010002
      Device = device-low-hdd010003
      Device = device-low-hdd010004
      Device = device-low-hdd010005
      Device = device-low-hdd010006
      Device = device-low-hdd010007
      Device = device-low-hdd010008
      Device = device-low-hdd010009
      Device = device-low-hdd010010
      Device = device-low-hdd010011
      Device = device-low-hdd010012
      Device = device-low-hdd010013
      Device = device-low-hdd010014
      Device = device-low-hdd010015
      Device = device-low-hdd010016
      Device = device-low-hdd010017
      Device = device-low-hdd010018
      Device = device-low-hdd010019
      Device = device-low-hdd010020
      Maximum Concurrent Jobs = 20
      Media Type = File
      PairedStorage = stor-file-low-hdd01
    }

#### Конфигурация хранилища (Storage Daemon)

/etc/bareos/bareos-sd.d/storage/bareos-sd.conf

    Storage {
      Name = bareos-sd
      Maximum Concurrent Jobs = 20

      NDMP Enable = yes
      NDMP Log Level = 7 # Диагностические сообщения
      NDMP Snooping = yes # Диагностические сообщения
    }

    Ndmp {
      Name = bareos-aio-kz
      Username = ndmpadmin
      Password = <ndmp-random-password> 
      AuthType = Clear
      Log Level = 7
    }

#### Конфигурация пулов (Director)

Поскольку отвечающие за жизненный цикл резервных копий параметры `Job Retention`, `Volume Retention`, `Recycle` и `AutoPrune` применимы именно в настройках пулов, в примерах ниже предлагается по одному пулу на каждую выбранную глубину хранения (7, 14, 21, 28 дней).

Максимальный размер одного volume в примере -- 50GB. Это означает, что результат задания РК, превышающий этот объём, будет разбит на несколько volumes.

/etc/bareos/bareos-dir.d/pool/full-r07d.conf

    Pool {
      Name = pool-full-r07d
      Pool Type = Backup
      Recycle = yes                       # Bareos can automatically recycle Volumes
      AutoPrune = yes                     # Prune expired volumes
      # File Retention = 7 days         # keep File records in the Catalog database after the End time of the Job corresponding to the File records. Параметр описан в документации, но его использование приводит к невозможности запуска сервиса bareos-dir
      Job Retention = 7 days            # keep Job records in the Catalog database after the Job End time
      Volume Retention = 7 days         # How long should the Full Backups be kept?
      Maximum Volume Bytes = 50G          # Limit Volume size to something reasonable
      Maximum Volume Jobs = 1
      Label Format = "vol-$Storage-$JobId-$JobName-$Level-$NumVols" # Пояснения даны в следующем разделе
    }

/etc/bareos/bareos-dir.d/pool/full-r14d.conf

    Pool {
      Name = pool-full-r14d
      Pool Type = Backup
      Recycle = yes                       # Bareos can automatically recycle Volumes
      AutoPrune = yes                     # Prune expired volumes
      # File Retention = 14 days # will 
      Job Retention = 14 days               
      Volume Retention = 14 days         # How long should the Full Backups be kept?
      Maximum Volume Bytes = 50G          # Limit Volume size to something reasonable
      Maximum Volume Jobs = 1
      Label Format = "vol-$Storage-$JobId-$JobName-$Level-$NumVols"              # Volumes will be labeled "Full-<volume-id>"
    }

/etc/bareos/bareos-dir.d/pool/full-r21d.conf

    Pool {
      Name = pool-full-r21d
      Pool Type = Backup
      Recycle = yes                       # Bareos can automatically recycle Volumes
      AutoPrune = yes                     # Prune expired volumes
      Job Retention = 21 days
      Volume Retention = 21 days         # How long should the Full Backups be kept?
      Maximum Volume Bytes = 50G          # Limit Volume size to something reasonable
      Maximum Volume Jobs = 1
      Label Format = "vol-$Storage-$JobId-$JobName-$Level-$NumVols"              # Volumes will be labeled "Full-<volume-id>"
    }

/etc/bareos/bareos-dir.d/pool/full-r28d.conf

    Pool {
      Name = pool-full-r28d
      Pool Type = Backup
      Recycle = yes                       # Bareos can automatically recycle Volumes
      AutoPrune = yes                     # Prune expired volumes
      Job Retention = 28 days
      Volume Retention = 28 days         # How long should the Full Backups be kept?
      Maximum Volume Bytes = 50G          # Limit Volume size to something reasonable
      Maximum Volume Jobs = 1
      Label Format = "vol-$Storage-$JobId-$JobName-$Level-$NumVols"
    }

/etc/bareos/bareos-dir.d/pool/inc-r14d.conf

    Pool {
      Name = pool-inc-r14d
      Pool Type = Backup
      Recycle = yes                       # Bareos can automatically recycle Volumes
      AutoPrune = yes                     # Prune expired volumes
      Job Retention = 14 days
      Volume Retention = 14 days          # How long should the Incremental Backups be kept?
      Maximum Volume Bytes = 50G           # Limit Volume size to something reasonable
      Maximum Volume Jobs = 1
      Label Format = "vol-$Storage-$JobId-$JobName-$Level-$NumVols"
    }

##### Шаблон именования volumes (Label Format)

https://docs.bareos.org/Configuration/CustomizingTheConfiguration.html#section-variableexpansionvolumelabels

В примере предлагается следующий вариант именования volumes:

    Label Format = "vol-$Storage-$JobId-$JobName-$Level-$NumVols"

Результат:

    vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-30

Поскольку при использовании в шаблоне переменных к названию больше автоматически не добавляется нумерация, в качестве порядкового идентификатора можно использовать переменную \$NumVols (итоговое количество volumes в пуле + 1). Если этого не сделать, при разбивке результата РК на несколько volumes система попытается записать повторно в первый, уже записанный volume из очереди, а настройка `Maximum Volume Jobs = 1` не даст этого сделать, и задание передёт в статус wait до его отмены, или пока следующий volume не будет создан вручную:

    14-Sep 20:50 bareos-sd JobId 677: User defined maximum volume capacity 104,857,600 exceeded on device "device-low-hdd010001" (/repo/low-hdd01).
    14-Sep 20:50 bareos-sd JobId 677: End of medium on Volume "vol-stor-file-low-hdd01-677-job-low-r14d-001094.2024-09-14_20.50.42_03-Full" Bytes=103,809,316 Blocks=99 at 14-Sep-2024 20:50.
    14-Sep 20:50 bareos-dir-am2 JobId 677: Error: cats/sql_create.cc:406 Volume "vol-stor-file-low-hdd01-677-job-low-r14d-001094.2024-09-14_20.50.42_03-Full" already exists.
    14-Sep 20:50 bareos-dir-am2 JobId 677: Error: cats/sql_create.cc:406 Volume "vol-stor-file-low-hdd01-677-job-low-r14d-001094.2024-09-14_20.50.42_03-Full" already exists.
    14-Sep 20:50 bareos-sd JobId 677: Job job-low-r14d-001094.2024-09-14_20.50.42_03 is waiting. Cannot find any appendable volumes.
    Please use the "label" command to create a new Volume for:
        Storage:      "device-low-hdd010001" (/repo/low-hdd01)
        Pool:         pool-full-r14d
        Media type:   File

Логи успешного выполнения задания с предлагаемыми настройками:

    2024-09-14 18:47:08 bareos-sd JobId 676: User defined maximum volume capacity 104,857,600 exceeded on device "device-low-hdd010001" (/repo/low-hdd01).                                                                                                                                  
     2024-09-14 18:47:08 bareos-sd JobId 676: End of medium on Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-30" Bytes=103,809,319 Blocks=99 at 14-Sep-2024 18:47.                                                                                     
     2024-09-14 18:47:09 bareos-dir-am2 JobId 676: Created new Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-31" in catalog.                                                                                                                           
     2024-09-14 18:47:09 bareos-sd JobId 676: Labeled new Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-31" on device "device-low-hdd010001" (/repo/low-hdd01).                                                                                        
     2024-09-14 18:47:09 bareos-sd JobId 676: Wrote label to prelabeled Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-31" on device "device-low-hdd010001" (/repo/low-hdd01)                                                                           
     2024-09-14 18:47:09 bareos-dir-am2 JobId 676: Max Volume jobs=1 exceeded. Marking Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-31" as Used.                                                                                                      
     2024-09-14 18:47:09 bareos-sd JobId 676: New volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-31" mounted on device "device-low-hdd010001" (/repo/low-hdd01) at 14-Sep-2024 18:47.                                                                   
     2024-09-14 18:47:18 bareos-sd JobId 676: User defined maximum volume capacity 104,857,600 exceeded on device "device-low-hdd010001" (/repo/low-hdd01).                                                                                                                                  
     2024-09-14 18:47:18 bareos-sd JobId 676: End of medium on Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-31" Bytes=103,809,319 Blocks=99 at 14-Sep-2024 18:47.                                                                                     
     2024-09-14 18:47:18 bareos-dir-am2 JobId 676: Created new Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-32" in catalog.                                                                                                                           
     2024-09-14 18:47:18 bareos-sd JobId 676: Labeled new Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-32" on device "device-low-hdd010001" (/repo/low-hdd01).                                                                                        
     2024-09-14 18:47:18 bareos-sd JobId 676: Wrote label to prelabeled Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-32" on device "device-low-hdd010001" (/repo/low-hdd01)                                                                           
     2024-09-14 18:47:18 bareos-dir-am2 JobId 676: Max Volume jobs=1 exceeded. Marking Volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-32" as Used.                                                                                                      
     2024-09-14 18:47:18 bareos-sd JobId 676: New volume "vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-32" mounted on device "device-low-hdd010001" (/repo/low-hdd01) at 14-Sep-2024 18:47.

    *list volumes pool=pool-full-r14d
    +---------+---------------------------------------------------------------------------------+-----------+---------+-------------+----------+--------------+---------+------+-----------+-----------+---------------------+----------------------+                                        
    | mediaid | volumename                                                                      | volstatus | enabled | volbytes    | volfiles | volretention | recycle | slot | inchanger | mediatype | lastwritten         | storage              |                                        
    +---------+---------------------------------------------------------------------------------+-----------+---------+-------------+----------+--------------+---------+------+-----------+-----------+---------------------+----------------------+                                        
    |     182 | vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-28  | Full      |       1 | 103,809,319 |        0 |    1,209,600 |       1 |    0 |         0 | File      | 2024-09-14 18:46:47 | stor-file-low-hdd01  |                                        
    |     183 | vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-29  | Full      |       1 | 103,809,319 |        0 |    1,209,600 |       1 |    0 |         0 | File      | 2024-09-14 18:46:59 | stor-file-low-hdd01  |                                        
    |     184 | vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-30  | Full      |       1 | 103,809,319 |        0 |    1,209,600 |       1 |    0 |         0 | File      | 2024-09-14 18:47:08 | stor-file-low-hdd01  |                                        
    |     185 | vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-31  | Full      |       1 | 103,809,319 |        0 |    1,209,600 |       1 |    0 |         0 | File      | 2024-09-14 18:47:18 | stor-file-low-hdd01  |                                        
    |     186 | vol-stor-file-low-hdd01-676-job-low-r14d-001094.2024-09-14_18.46.28_03-Full-32  | Used      |       1 |  89,617,906 |        0 |    1,209,600 |       1 |    0 |         0 | File      | 2024-09-14 18:47:29 | stor-file-low-hdd01  |                                        
    +---------+---------------------------------------------------------------------------------+-----------+---------+-------------+----------+--------------+---------+------+-----------+-----------+---------------------+----------------------+                                        

#### Конфигурация клиентов NDMP-эндпоинтов zfs-пулов кластера vStack

/etc/bareos/bareos-dir.d/client/client-ndmp-qN-all.conf

    Client {
      Name = "client-ndmp-qN-zN"
      Address = <ip address> # IP адрес NDMP-эндпоинта пула
      Port = 10000
      Protocol = NDMPv4
      Auth Type = Clear
      Username = "vstack" # Логин, полученный от вендора после настройки службы
      Password = "<password>" Пароль, полученный от вендора после настройки службы
      Maximum Concurrent Jobs = 20
    }

##### Пример создания общего файла конфигурации клиентов NDMP-эндпоинтов zfs-пулов для каждого из 14-ти доступных пулов кластера q18:

    for i in {01..14}; do cat << EOT >> /etc/bareos/bareos-dir.d/client/client-ndmp-q18-all.conf; done
    Client {
      Name = "client-ndmp-q18-z$i"
      Address = 10.75.141.2$i
      Port = 10000
      Protocol = NDMPv4
      Auth Type = Clear
      Username = "vstack"
      Password = "<password>"
      Maximum Concurrent Jobs = 20
    }
    EOT

##### Быстрая проверка доступности NDMP endpoints

    for i in {01..14}; do echo "status client=client-ndmp-q18-z$i" | bconsole >> /root/q18_ndmp_checkout.txt; done && grep "Data Agent" /root/q18_ndmp_checkout.txt | wc -l

#### Пример FileSet

/etc/bareos/bareos-dir.d/bareos-dir.d/fileset/fs-ss4t-prj1739-serv18971.conf

    Fileset {
      Name = "fs-ss4t-prj1739-serv18971"
      Include {
        Options {
            compression = LZ4 # включаем компрессию
            meta = "BUTYPE=ZFS"
            meta = "ZFS_MODE=package"
        }
        File = /z03/.vm_V4/000139961
      }
    }

#### Пример конфигурации задания РК

/etc/bareos/bareos-dir.d/job/j-ss4t-prj1739-serv18976.conf

    Job {
      Name          = "j-ss4t-prj1739-serv18976"
      Enabled       = Yes # включаем задание для планировщика
      Schedule      = "s-full-daily-at-0000" # указываем имя планировщика
      Type          = Backup
      Protocol      = NDMP_BAREOS
      Level         = Full
      Client        = client-ndmp-q18-z03
      Backup Format = zfs
      FileSet       = "fs-ss4t-prj1739-serv18976"
      Storage       = stor-ndmp-low-hdd01
      Pool          = pool-full-r14d
      Messages      = Standard
    }

##### JobDefs (параметры задания по умолчанию)

/etc/bareos/bareos-dir.d/jobdefs/DefaultJob.conf
Эти параметры могут быть добавлены к параметру задания добавлением `JobDefs = "DefaultJob"` в его файл конфигурации

    JobDefs {
      Name = "DefaultJob"
      Type = Backup
      Level = Incremental
      Client = bareos-fd
      FileSet = "SelfTest"                     # selftest fileset
      Schedule = "WeeklyCycle"
      Storage = stor-file-low-hdd01
      Messages = Standard
      Pool = pool-inc-r14d
      Priority = 10
      Write Bootstrap = "/var/lib/bareos/%c.bsr"
      Full Backup Pool = pool-full-r14d                  # write Full Backups into "Full" Pool
      Incremental Backup Pool = pool-inc-r14d    # write Incr Backups into "Incremental" Pool
    }

#### Пример Schedule

https://docs.bareos.org/Configuration/Director.html#directorresourceschedule
/etc/bareos/bareos-dir.d/schedule/s-full-daily-at-0000.conf

    Schedule {
      Name = "s-full-daily-at-0000"
      Run = Full daily at 0:00
    }

#### Пример настройки почтовых уведомлений и логов:

/etc/bareos/bareos-dir.d/messages/Standard.conf

    Messages {
      Name = Standard
      Description = "Reasonable message delivery -- send most everything to email address and to the console."
      operatorcommand = "/usr/bin/bsmtp -h smtp.itglobal.com:25 -f \"\(Bareos\) \<%r\>\" -s \"This is a test mail: Bareos: Intervention needed for %j\" %r"
      mailcommand = "/usr/bin/bsmtp -d 150 -dt -h smtp.itglobal.com:25 -f \"\(Bareos\) \<bareos@itglobal.com\>\" -s \"%d: %t %e of %j jobid\=%i \(%l\) on %c \(%h\)\" -c bareos@itglobal.com %r"
      operator = sergey.burtsev@itglobal.com = mount
      mail = sergey.burtsev@itglobal.com, alice.kichik@vstack.com, tatyana.krivonogova@vstack.com = all, !skipped, !saved, !audit
      mail on error  = sergey.burtsev@itglobal.com, alice.kichik@vstack.com, tatyana.krivonogova@vstack.com  = all, !skipped, !saved, !audit
      console = all, !skipped, !saved, !audit
      append = "/var/log/bareos/bareos.log" = all, !skipped, !saved, !audit
      catalog = all, !skipped, !saved, !audit
    }

##### Пример заголовков писем, направленных с подготовленным шаблоном mailcommand

    bareos-dir-am2: Backup OK -- with warnings of job-low-r14d-001094.2024-09-11_07.26.48_05 jobid=641 (Full) on client-ndmp-q99-z01 (10.77.41.201)

    bareos-dir-am2: Restore OK of job-restore-ndmp.2024-09-11_08.19.01_08 jobid=644 ( ) on client-ndmp-q99-z03 (10.77.41.203)

#### Задания восстановления

Обязательными параметрами файла конфигурации задания восстановления в том числе являются:
- client (свой на каждый пул);
- fileset (свой на каждое задание);
- storage (в нашем случае может быть два типа) и pool (по одному на каждую доступную глубину хранения).

При их отсутствии служба bareos-dir не запустится:
`Error: "client" directive in Job "job-restore-ndmp" resource is required, but not found.`
`Error: "fileset" directive in Job "job-restore-ndmp" resource is required, but not found.`
`Error: No storage specified in Job "job-restore-ndmp" nor in Pool.`

Поэтому в файле конфигурации значения этих параметров можно указать любые, а отличающиеся значения задавать в команде запуска задания восстановления:

    restore jobid=642 all done client=client-ndmp-q99-z03 restoreclient=client-ndmp-q99-z03 storage=stor-ndmp-high-ssd01 fileset=fset-high-r14d-001074 restorejob=job-restore-ndmp yes

Как видно из примера, при запуске задания необходимо повторно указать client, несмотря на его наличие в файле конфигурации задания восстановления как обязательного параметра.

Содержимое job-restore-ndmp.conf:

    Job {
      Name          = "job-restore-ndmp"
      Type          = Restore
      Protocol      = NDMP_BAREOS
      Backup Format = zfs
      Client        = "client-ndmp-q99-z01"
      Fileset       = "fset-low-r14d-001094"
      Storage       = stor-ndmp-low-hdd01
      Pool          = pool-full-r14d
      Messages      = Standard
      Catalog       = MyCatalog
      Where         = /
    }

#### Пользователи, группы и права доступа к директориям

    useradd -m bareosclient -G bareos

    mkdir /home/bareosclient/.ssh && echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqwErbPJsdxkhGVEC6OOwWcOsGcxuKSbE4pGNK+vglK" >> /home/bareosclient/.ssh/authorized_keys && chown -R bareosclient:bareosclient /home/bareosclient/.ssh && chmod -R 600 /home/bareosclient/.ssh

    chown -R bareosclient:bareos /etc/bareos/bareos-dir.d/pool /etc/bareos/bareos-dir.d/fileset /etc/bareos/bareos-dir.d/schedule /etc/bareos/bareos-dir.d/job

    chmod 750 /etc/bareos/bareos-dir.d/*

    chmod -R g+w /etc/bareos/bareos-dir.d/

    chown -R bareos:bareos /repo && chmod -R 750 /repo
