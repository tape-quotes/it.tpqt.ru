---
created: "2025-02-11T04:03"
date: 2025-02-16
draft: false
params:
  author: Сергей Бурцев
tags:
- hugo
- blowfish
- web
- yandex
title: Интеграция Hugo / Blowfish с Яндекс.Метрикой
updated: "2025-02-16T22:22"
weight: 10
---

В поисках решения задачки по интеграции Яндекс.Метрики с Hugo / Blowfish я наткнулся только на [пост](https://www.reddit.com/r/gohugo/comments/ndyfai/yandexmetrica_and_hugo/) пользователя Reddit о том, что он наткнулся только на [пост](https://discourse.gohugo.io/t/free-hosted-analytics-providers-that-arent-google/11615) в их discourse, не содержащий ничего "except some political bullshit".

Собственно, теперь, спустя шесть лет, ответ на его вопрос [стал доступен](https://discourse.gohugo.io/t/free-hosted-analytics-providers-that-arent-google/11615/31?u=tape_quotes). :)

Решение несложное. Нужно всего лишь:

1.  Добавить в `layouts/partials/head.html` блок с шаблонизированным мной скриптом, который предлагает Яндекс для добавления в `<head></head>`:

``` js
{{/* Yandex Metrika */}}
  {{ with $.Site.Params.metrika }}
  {{ if isset $.Site.Params "metrika" }}
  <script type="text/javascript" >
    (function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
    m[i].l=1*new Date();
    for (var j = 0; j < document.scripts.length; j++) {if (document.scripts[j].src === r) { return; }}
    k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)})
    (window, document, "script", "https://mc.webvisor.org/metrika/tag_ww.js", "ym");
 
    ym({{ $.Site.Params.metrika.countercode }}, "init", {
         clickmap:true,
         trackLinks:true,
         accurateTrackBounce:true,
         webvisor:true
    });
   </script>
   <noscript><div><img src="https://mc.yandex.ru/watch/{{ $.Site.Params.metrika.countercode }}" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
  {{ end }}
  {{ end }}
```

2.  Указать полученный в панели управления metrika.yandex.ru номер созданного счётчика в файле `config/_default/params.toml`:

``` toml
[metrika]
countercode = "123456789"
```

Теперь при каждой сборке статического содержимого скрипт Яндекса будет включен в код всех страниц сайта.
