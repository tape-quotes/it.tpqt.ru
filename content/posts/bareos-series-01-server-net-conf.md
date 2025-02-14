---
created: 2025-02-11T04:03
updated: 2025-02-14T03:50
date: 
draft: true
params:
  author: Сергей Бурцев
title: 
weight: 
tags: 
series:
  - Bareos
series_order: 1
---

Создаём bond:

    nmcli connection add type bond con-name vStackHostAccess ifname v39-e16 bond.options mode=802.3ad,miimon=100,lacp_rate=fast,xmit_hash_policy=layer2+3 ipv4.method disabled ipv6.method disabled

Добавляем в bond интерфейсы физических портов и поднимаем соединение:

    nmcli connection add type ethernet ifname enp101s0f0 master v39-e16 slave-type bond

    nmcli connection add type ethernet ifname enp101s0f1 master v39-e16 slave-type bond

    nmcli con up v39-e16 up

Создаём поверх bond'а интерфейс с vlan'ом сети Public Endpoints и поднимаем интерфейс:

    nmcli con add type vlan con-name vStackPublicEndpoints ifname v39-e16.v41 id 41 dev v39-e16 ipv4.method manual ipv6.method disabled connection.autoconnect yes ip4 10.200.41.180/24 gw4 10.200.41.1 ipv4.dns 8.8.8.8,8.8.4.4

    nmcli con up v39-e16.v41
