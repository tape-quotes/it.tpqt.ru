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
awk -F '[,]' '{ print $1, $2, $3, $4, $5, $6, $7, $8, $9 }' < /tmp/sOS.lst | more
rm -f /tmp/sOS.lst
exit 0