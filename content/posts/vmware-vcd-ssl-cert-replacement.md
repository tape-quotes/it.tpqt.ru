---
created: 2025-02-11T04:03
updated: 2025-02-14T02:21
date: 
draft: true
params:
  author: Сергей Бурцев
title: 
weight: 
---
#### 1. Preparation

Все работы проводятся на:
*vcloud-\<...\>.itglobal.com*
\##### 1.1 Создать цепочки сертификатов; поместить приватный ключ в файл `user.http.key.unenc` в `/root` на 1-м vcell.
\##### 1.2. Выполнить команды для шифрования приватного ключа паролем root'а vcloud:

``` bash
openssl pkcs8 -inform PEM -in user.http.key.unenc -out user.http.key -topk8
```

##### 1.3. Включить downtime (время простоя) для *vcloud-\<...\>.itglobal.com* в Icinga

<img
src="../vmware-vcd-ssl-cert-replacement/132dacea2afcc9717f8c0cf612e8a36e620eddbd.png"
class="wikilink" alt="Pastedimage20240427000112.png" />
\##### 1.4. Сменить email для отправки уведомлений в vCloud Director
`Administration -> Settings -> Email -> Send system notifications to`
сменить alerts@itglobal.com на vi-group@itglobal.com
\#### 2. Core Activities
Обновление сертификатов для vcloud-dx1.itglobal.com
Работы проводятся на:
vcd-cell01-dx1.itglobal.com
vcd-cell02-dx1.itglobal.com
vcd-cell03-dx1.itglobal.com
\##### 2.1 Запретить подключения извне к vcd
\###### 2.1a для NSX-V
`*vc01-<...>.itglobal.com* -> Networking and Security -> NSX Edges -> *vse-vcd-lb-<...>* ->`Networking \> Load Balancer \> Virtual Servers \> Edit \> Disable``
для:
`vcloud-https`
\###### 2.1b для NSX-T
*nsxt-\<...\>.itglobal.com* -\> Networking -\> NAT -\> T1 ITGLOBAL-NAT
NAT \> *vcloud-\<...\>*.-https \> Edit \> Enable -\> No
\##### 2.2 Выключить сервис VCD на всех cells:

``` bash
service vmware-vcd stop
```

### - Выключить все cells через `Shutdown Guest OS`

### - Сделать снэпшоты всех ВМ *vcd-cell0...-\<...\>.itglobal.com*

### - Включить все ВМ *vcd-cell0...-\<...\>.itglobal.com*

https://support.itglobal.com/record/itsm_change_request/171396624828342011

3.  Подключиться по SSH от root на ноды:

- На каждой ноде проверить вывод команды: less /opt/vmware/vcloud-director/logs/cell.log (Переключиться в поток: shift + F)
- Дождаться записи: Cell startup completed in ....

4.  На vcd-cell01-dx1.itglobal.com:

-Сделать бэкап существующих сертификатов:

    cp /opt/vmware/vcloud-director/data/transfer/user.http.pem /opt/vmware/vcloud-director/data/transfer/user.http.pem.bak

    cp /opt/vmware/vcloud-director/data/transfer/user.http.key /opt/vmware/vcloud-director/data/transfer/user.http.key.bak

-Скопируйте файлы .pem,.key, в /opt/vmware/vcloud-director/data/transfer/.

Измените права владельца и группы на файлы сертификатов на vcloud

    chown vcloud.vcloud /opt/vmware/vcloud-director/data/transfer/user.http.pem

    chown vcloud.vcloud /opt/vmware/vcloud-director/data/transfer/user.http.key

    chmod 0750 /opt/vmware/vcloud-director/data/transfer/user.http.pem

    chmod 0750 /opt/vmware/vcloud-director/data/transfer/user.http.key

4.  На всех нодах выполнить команду:

<!-- -->

    /opt/vmware/vcloud-director/bin/cell-management-tool certificates -j --cert /opt/vmware/vcloud-director/data/transfer/user.http.pem --key /opt/vmware/vcloud-director/data/transfer/user.http.key --key-password '<root-password>'

- Перезапускается сервис vmware-vcd

<!-- -->

    /opt/vmware/vcloud-director/bin/cell-management-tool cell -i $(service vmware-vcd pid cell) -s

    systemctl start vmware-vcd

5.  Разрешаем на T1 ITGLOBAL-NAT подключения извне к vcloud-dx1.itglobal.com nsxt-dx1.itglobal.com - Networking\> NAT\> vcloud-dx1.-https\> Edit\> Enable - Yes

6.  Заменить часть .PEM в облаке (во вложении):
    Заходим https://vcloud-dx1.itglobal.com/provider \> Administration \> Public Addresses \>EDIT \> Replace Certificate

7.  Принять сертификат в veeambkp01-dx1.itglobal.com и veeambkp02-dx1.itglobal.com - Backup Infrastructure -\> Managed servers -\> VMWare vCloud Director -\> DX -\> properties

8.  Принять новый сертификат в vcda - https://vcav-dx1.itglobal.com/ui/provider Settings - VMware Cloud Director address - Edit, ввести пароль администратора виклауда.

9.  Принять новый сертификат в vrops01-ds1.itglobal.com Data Sources -\> Integrations -\> Cloud Director Adapter -\> vcloud-dx1.itglobal.com -\> Edit -\> Validate Connection -\> принять сертификат - Save

10. В vCloud Director - Administration - Settings - Email - Send system notifications to сменить на alerts@itglobal.com

11. После успешной проверки удалить снапшоты ВМ vcd-cell0...-dx1.itglobal.com

#### 3. Validation

Проверяем что сервисы запустились успешно:

tail -f /opt/vmware/vcloud-director/logs/cell.log
service vmware-vcd status

Проверяем подключение VCD ко всем vCenter
Resources -\> Infrastructure Resources -\> vCenter Server Instances Refresh

Проверяем использование установленного сертификата в браузере

Проверяем основные операции с ВМ:
Включение, изменение.

Проверяем работу веб-консоли ВМ.
