---
created: 2025-02-11T04:03
updated: 2025-02-14T02:04
date: 
draft: true
params:
  author: Сергей Бурцев
title: 
weight: 
---

``` bash
sudo -i
```

Добавляем community-репозитории Bareos:

``` bash
bash <(curl -s https://download.bareos.org/current/EL_9/add_bareos_repositories.sh)
```

Устанавливаем пакеты:

``` bash
dnf install -y bareos postgresql-server postgresql postgresql-contrib
```

Устанавливаем пароль пользователю postgres:

``` bash
passwd postgres
```

Инициализируем БД:

``` bash
sudo -u postgres initdb -D /var/lib/pgsql/data/
```

Активируем и запускаем службу PostgreSQL:

``` bash
systemctl enable --now postgresql.service
```

Если необходимо, устанавливаем пароль пользователя postgres в БД:

``` bash
sudo -u postgres psql
```

``` postgresql
ALTER USER postgres WITH PASSWORD '<password>'
```

или
`\password`

Создаём в БД сущности Bareos:

``` bash
sudo -u postgres /usr/lib/bareos/scripts/create_bareos_database
```

``` bash
sudo -u postgres /usr/lib/bareos/scripts/make_bareos_tables
```

``` bash
sudo -u postgres /usr/lib/bareos/scripts/grant_bareos_privileges
```

Активируем и запускаем службы Bareos:

``` bash
systemctl enable --now bareos-dir && systemctl enable --now bareos-sd && systemctl enable --now bareos-fd 
```

Если нужно подключаться извне, открыть TCP-порты 9101-9103.
