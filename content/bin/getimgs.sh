#!/bin/bash
echo && echo " В публичном репозитории SmartOS доступны следующие образы:"
echo
echo ' Название,ОС,Тип,Описание,>,Дата,URL,Формат,SHA1' > /tmp/sOS.lst
curl -s -S https://images.smartos.org/images | \
jq -r -c '.[] | [ ( .name | .[0:15] ), .os, .type, ( .description | .[0:40] ), ">", ( .published_at | .[0:10] ), "https://images.smartos.org/images/", .uuid, "/file", ( .files[] | .compression, .sha1 ) ]' | \
sed -e 's/^/ /;s/\[//g;s/\]//g;s/"//g;s/https\:\/\/images.smartos.org\/images\/\,/https\:\/\/images.smartos.org\/images\//;s/\,\/file/\/file/' | sort -t . -n -k 1,1n -k 2,2n -k 3,3n -k 4,4n >> /tmp/sOS.lst
column -t -s ',' < /tmp/sOS.lst | more
rm -f /tmp/sOS.lst
exit 0