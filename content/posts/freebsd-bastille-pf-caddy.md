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
#### pf

https://habr.com/ru/companies/ics/articles/546720/
\##### /etc/pf.conf

``` shell
ext_if="vmx0"
# ! IMPORTANT: this needs to be set before you can start using it!
ext_addr=10.111.10.5

# Caddy related
caddy_addr=10.0.2.6

set block-policy return
scrub in on $ext_if all fragment reassemble
set skip on lo

table <jails> persist
nat on $ext_if from <jails> to any -> $ext_addr

# container routes
rdr pass inet proto tcp from any to port 80 -> $caddy_addr port 8880
rdr pass inet proto tcp from any to port 443 -> $caddy_addr port 4443

# Enable dynamic rdr (see below)
rdr-anchor "rdr/*"

block in all
pass out quick modulate state
antispoof for $ext_if inet
pass in inet proto tcp from any to any port ssh flags S/SA keep state
```

##### /etc/rc.conf

``` shell
pf_enable="YES" # включает pf и загружает модуль
pf_flags="" # дополнительные флаги pfctl
pf_rules="/etc/pf.conf"  # файл конфигурации
pflog_enable="YES" # запуск pflog
pflog_flags="" # флаги pflog
pflog_logfile="/var/log/pflog" # файл лога
```

##### Основные команды управления файрволом

`pfctl` - \# Включить файрвол  
`pfctl -d` \# Выключить файрвол  
`pfctl -nf` \# Проверить синтаксис файла  
`pfctl -f` \# Перечитать правила из файла  
`pfctl -Rf` \# Перечитать правила фильтрации из файла  
`pfctl -Nf` \# Перечитать правила NAT из файла  
`pfctl -sa` \# Просмотр всех состояний  
`pfctl -s` \# Просмотр правил фильтрации  
`pfctl -sn` \# Просмотр правил NAT  
`pfctl -s Anchors -v` \# Просмотр дерева якорей  
`pfctl -ss` \# Просмотр текущих соединений
\##### Синтаксис правил

``` shell
action [direction] [log] [quick] [on interface] [af] [proto protocol] \
[from src_addr [port src_port]] [to dst_addr [port dst_port]] \
[flags tcp_flags] [state]
```

`action` --- что следует сделать с пакетом  
`direction` --- in out, направление  
`log` --- попадёт ли пакет в pflog  
`quick` --- если пакет попал под это правило, то дальнейшей обработки не будет. Это правило будет последним для пакета  
`interface` --- название сетевого интерфейса  
`af` --- address family, inet или inet6, IPv4 или IPv6 соответственно  
`protocol` --- протокол 4 уровня, к примеру: tcp, udp, icmp  
`scr_addr`, `dst_addr` --- адреса источника и назначения  
`src_port`, `dst_port` --- порты  
`tcp_flags` --- флаги tcp  
`state` --- опции сохранения состояния. Например, keep state будет означать, что соединение сохранится в таблице состояний, и ответные пакеты могут проходить. Поведение по умолчанию.
\#### Bastille
https://www.jaredwolff.com/my-latest-self-hosted-hugo-workflow/#setting-up-your-freebsd-server-with-bastille
https://bastillebsd.org/getting-started/
\##### Setup Bastille
\###### Set up bastille networking

``` shell
sysrc cloned_interfaces+=lo1
```

``` shell
sysrc ifconfig_lo1_name="bastille0"
```

``` shell
service netif cloneup
```

###### Bootstrap the base jail and start bastille

``` shell
bastille bootstrap 13.2-RELEASE update
```

``` shell
sysrc bastille_enable="YES"
```

``` shell
service bastille start
```

##### Create & start jail

``` shell
bastille create caddy 13.2-RELEASE 10.0.2.6
```

``` shell
bastille start caddy
```

##### Install Caddy into container

###### install the binary

``` shell
bastille pkg caddy ins -y caddy
```

###### (create the caddy user)

``` shell
bastille cmd caddy pw useradd caddy -m -s /usr/sbin/nologin
```

###### (install ca root file)

``` shell
bastille pkg caddy install ca_root_nss
```

To enable caddy:
Edit /usr/local/etc/caddy/Caddyfile
See https://caddyserver.com/docs/
Run 'service enable caddy'

Note while Caddy currently defaults to running as root:wheel, it is strongly
recommended to run the server as an unprivileged user, such as www:www --

Use security/portacl-rc to enable privileged port binding:

    pkg install security/portacl-rc

    sysrc portaclusers+=www

    sysrc portacluserwwwtcp="http https"

    sysrc portacluserwww_udp="https"

    service portacl enable

    service portacl start

Configure caddy to run as www:www

``` shell
sysrc caddyuser=www caddygroup=www
```

Note if Caddy has been started as root previously, files in
/var/log/caddy, /var/db/caddy, and /var/run/caddy may require their ownership
changing manually.

/usr/local/etc/rc.d/caddy has the following defaults:
Server log: /var/log/caddy/caddy.log (runtime messages, NOT an access.log)
Automatic SSL certificate storage: /var/db/caddy/data/caddy/
Administration endpoint: //unix/var/run/caddy/caddy.sock
Runs as root:wheel (this will change to www:www in the future)
