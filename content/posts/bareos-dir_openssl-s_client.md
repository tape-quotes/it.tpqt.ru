---
created: "2025-02-11T04:03"
date: 2024-02-11
draft: false
params:
  author: Сергей Бурцев
title: Проверка подключения к Bareos Director с openssl s_client
updated: "2025-02-13T01:47"
weight: 10
---

``` bash
openssl s_client -connect 127.0.0.1:9101 -cipher ECDHE-PSK-CHACHA20-POLY1305 \
-psk_identity "R_CONSOLE`echo -n -e "\x1e"`*UserAgent*" \
-psk `echo -n "30b5246d003966329927" | md5sum | awk {'print $1'} | tr -d '\n'|\
xxd -p | tr -d '\n'`
```

Альтернативный вариант преобразования в hex с `od` вместо `xxd`:
`| od -A n -t x1 | sed 's/ *//g' | tr -d '\n'`

При указании `-cipher` добавлять опцию `-tls1_2` не нужно.
`echo -n -e "\x1e"` -- добавление в `psk_identity` непечатного символа`0x1e`(Record Separator).
`*UserAgent*` -- идентификатор по умолчанию для `default console`. При использовании `named`-консоли необходимо заменить `*UserAgent*` на Name этой консоли, указанное в конфиге bareos-dir. Например, для консоли с именем "named_console":
`` -psk_identity "R_CONSOLE`echo -n -e "\x1e"`named_console" ``

`-psk` == hexadecimal от md5-хэша от пароля, указанного в конфиге (в этом примере пароль `30b5246d003966329927`)

Пример вывода при успешном подключении:
<img
src="../bareos-dir_openssl-s_client/631586959ec0194cecf8c9421077b33500838ad8.png"
class="wikilink" alt="Pastedimage20240304134451.png" />
