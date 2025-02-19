---
created: 2025-02-11T04:03
updated: 2025-02-14T02:22
date: 
draft: true
params:
  author: Сергей Бурцев
title: VMware Cloud Director Availability & On-Prem Appliance для пользователей
weight: "10"
tags:
  - vcd
  - VMware
  - cloud
  - миграция
  - репликация
---
#### Примечания

Virtual machine hardware version исходной ВМ не должна быть выше поддерживаемой используемой версией vSphere (ESXi) на принимающей стороне.

*Например:
- *для репликации из публичного облака c vCD / vSphere / ESXi 7.0u3 на локальную площадку c vSphere / ESXi 6.5 максимально допустимой VM HW version будет 13.*
- *для миграции с локальной площадки или любого публичного облака сервис-провайдера в публичное облако с vCD / vSphere / ESXi 7.0u3 максимальная VM HW version -- 19;
[Подробнее](https://knowledge.broadcom.com/external/article?legacyId=2007240)

Также в сценарии On-Prem \<-\> vCD необходимо предварительно убедиться в совместимости конкретных версий VMware Cloud Director Availability и VMware vCenter Server в [матрице совместимости ](https://interopmatrix.vmware.com/Interoperability?col=570,&row=2,&isHidePatch=true&isHideLegacyReleases=false)VMware.

Для применения параметров кастомизации гостевой ОС (в том числе новых настроек сетевых подключений) и корректного выключения ВМ на исходной площадке в процессе миграции, в исходных ВМ должны быть установлены vmware tools.

В политике, назначенной сервис-провайдером на организацию, должны быть разрешены миграция и/ или репликация (protection) в необходимом направлении
(для сценария vCD \<-\> vCD -- на обеих сторонах):
<img
src="../vmware-vcda-onprem-appliance/d1d083860e9f08d5b10ad04a414fd90812b0ef17.png"
class="wikilink" alt="Pastedimage20240727011227.png" />
<img
src="../vmware-vcda-onprem-appliance/a4e15f7d401fd5a40db74f59439b3d6e8bfce817.png"
class="wikilink" alt="Pastedimage20240802133309.png" />

#### Для VMware vSphere (Cloud Availability On-Prem Appliance)

##### 1.1. Инструкция по развёртыванию

###### Загрузите OVA для развёртывания из доступного источника

###### Разверните ВМ в кластере vSphere из загруженного шаблона, как показано на скриншотах
<img
src="../vmware-vcda-onprem-appliance/113260f4dafd8528297f97bad7365d15716e4f30.png"
class="wikilink" alt="Pastedimage20240731124130.png" />

Загрузите образ в кластер
<img
src="../vmware-vcda-onprem-appliance/24a9caa8bca899cf3ff0cf08438ecf7d65a52367.png"
class="wikilink" alt="Pastedimage20240731124700.png" />

Введите имя виртуальной машины и выберите каталог для её создания
<img
src="../vmware-vcda-onprem-appliance/c0b2a4bbaabc65d93e2d14bf0ef11e21d351e411.png"
class="wikilink" alt="Pastedimage20240731131736.png" />

Выберите необходимый resource pool
<img
src="../vmware-vcda-onprem-appliance/63e71169886a351c1eef776fe17ac6004b651bce.png"
class="wikilink" alt="Pastedimage20240731131845.png" />

Убедитесь, что данные верны
<img
src="../vmware-vcda-onprem-appliance/72cbbe617ed2a04768c18a9284eaff5a3c57fed2.png"
class="wikilink" alt="Pastedimage20240731131938.png" />

Примите соглашение
<img
src="../vmware-vcda-onprem-appliance/34c871150e0aee4716e68d66534cee6550a16353.png"
class="wikilink" alt="Pastedimage20240731131956.png" />

Выберите подходящий сценарий работы
<img
src="../vmware-vcda-onprem-appliance/efae0e02fc3a2d32ba3b73f107a855ef0a61b00e.png"
class="wikilink" alt="Pastedimage20240731132054.png" />

Укажите формат виртуального диска, политику хранения и datastore
<img
src="../vmware-vcda-onprem-appliance/ce980c2553b27991804db5f2a46e36764fad39e5.png"
class="wikilink" alt="Pastedimage20240731132210.png" />

Выберите виртуальную сеть, к которой будет подключена ВМ
<img
src="../vmware-vcda-onprem-appliance/ff3e62a1ab0b4d52503e1da62d5bf219f4d2d25d.png"
class="wikilink" alt="Pastedimage20240731132332.png" />

Введите требуемые данные для настройки (кастомизации) ВМ
<img
src="../vmware-vcda-onprem-appliance/c02e43277330daa88f32311f85c5a743cf6dd642.png"
class="wikilink" alt="Pastedimage20240731132955.png" />

Проверьте выбранные настройки и нажмите Finish
<img
src="../vmware-vcda-onprem-appliance/cb8b41bdef5f17d6a9c325e856080c04e523cc05.png"
class="wikilink" alt="Pastedimage20240731133245.png" />

##### 1.2. Инструкция по настройке

1.2.1. В веб-интерфейсе VCDA On-Prem Appliance, доступном по указанному при развёртывании OVA IP-адресу (`https://<vcda_opa_ip_address>/ui/admin`), откройте `Run initial setup wizard`
<img
src="../vmware-vcda-onprem-appliance/8e2c142cef3dc29a7d8702ffc180266745bb4d93.png"
class="wikilink" alt="Pastedimage20240710195432.png" />

1.2.2. В `Lookup Service Address` укажите адрес и учетные данные администратора Вашего vCenter
<img
src="../vmware-vcda-onprem-appliance/be9707fbfac59d6c7cb856e5469033968203d0a4.png"
class="wikilink" alt="Pastedimage20240730151538.png" />

1.2.3. Примите сертификат
<img
src="../vmware-vcda-onprem-appliance/a490da5b286a10b49db15e0f38baa2861d34fb93.png"
class="wikilink" alt="Pastedimage20240730151705.png" />

1.2.4. Укажите предпочитаемое имя вашей локальной площадки (`Site name`)
<img
src="../vmware-vcda-onprem-appliance/ff7158d32d75a049501fd572f9c9ef995e71d217.png"
class="wikilink" alt="Pastedimage20240710195637.png" />

1.2.5. Добавьте данные об удалённой площадке, где

- "`Public Service Endpoint address`" -- URL веб-интерфейса VCDA с номером порта (пример -- на скриншоте);
- "`Organization Admin`" -- учётные данные администратора тенанта в формате `<login>@<org>` и пароль.

Если необходимо управлять сервисом и из публичного облака, активируйте опцию `Allow access from Cloud`
<img
src="../vmware-vcda-onprem-appliance/1891dfcf48b7daa17cec5436c2ee6547e4c8cef8.png"
class="wikilink" alt="Pastedimage20240802153950.png" />

1.2.6. Введите учётные данные администратора тенанта vCD на принимающей стороне
<img
src="../vmware-vcda-onprem-appliance/62a74c9f7cc887974c414b0e1fe3f8963d64a3dd.png"
class="wikilink" alt="Pastedimage20240710200218.png" />


<img
src="../vmware-vcda-onprem-appliance/a4996b35b5e10fd6310a4b8701823a94e0308b7f.png"
class="wikilink" alt="Pastedimage20240710200435.png" />

<img
src="../vmware-vcda-onprem-appliance/b13ba887979b4c05a0dabe36b960e2d850c6d1cf.png"
class="wikilink" alt="Pastedimage20240710200507.png" />

<img
src="../vmware-vcda-onprem-appliance/f2a1ba2060b9f1782bd5b9c871ebb20454559691.png"
class="wikilink" alt="Pastedimage20240710200532.png" />

<img
src="../vmware-vcda-onprem-appliance/66b6ec57db0a9afac994fc7601f97c6f4cee94d3.png"
class="wikilink" alt="Pastedimage20240710200557.png" />


<figure>
<img
src="../vmware-vcda-onprem-appliance/5b12e44a7b0d38122da8e2b9fa1d3487f20c0ed6.png"
class="wikilink" alt="Pastedimage20240710200643.png" />
<figcaption
aria-hidden="true">Pastedimage20240710200643.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/52081820b0f4c776ea978ab1898b7cfefbafcbfa.png"
class="wikilink" alt="Pastedimage20240710200812.png" />
<figcaption
aria-hidden="true">Pastedimage20240710200812.png</figcaption>
</figure>

#### 2. Для публичного облака VMware Cloud Director

Необходимо:
1. Запросить у провайдера Site name и Public Service Endpoint.
1. Для настройки пиринга на стороне ITGLOBAL.COM создать тикет и указать в нём целевую площадку и полученные от другого провайдера данные Site name и Public endpoint address.
2. Предоставить другому провайдеру наши данные:
1. Site name: `<...>`
2. Public Service Endpoint: `https://vcda-<...>.itglobal.com:443/`

<figure>
<img
src="../vmware-vcda-onprem-appliance/d141f60ec925882e0a711dabbfd8891df215a906.png"
class="wikilink" alt="Pastedimage20240727011501.png" />
<figcaption
aria-hidden="true">Pastedimage20240727011501.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/6ff39fbb0bef58b973ee0b948008016abdebfc9f.png"
class="wikilink" alt="Pastedimage20240727011537.png" />
<figcaption
aria-hidden="true">Pastedimage20240727011537.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/dde6377128f68aff60a4783f1b927918f1c671aa.png"
class="wikilink" alt="Pastedimage20240727011554.png" />
<figcaption
aria-hidden="true">Pastedimage20240727011554.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/aac34c73b11686f25413eaf94e6968e271666ced.png"
class="wikilink" alt="Pastedimage20240727011727.png" />
<figcaption
aria-hidden="true">Pastedimage20240727011727.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/59e8d785f8e2e6dcf9e19bd2105cb72639036bcf.png"
class="wikilink" alt="Pastedimage20240727011856.png" />
<figcaption
aria-hidden="true">Pastedimage20240727011856.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/6484b0ac71a9345a3cb0b32999a42231da5dae6d.png"
class="wikilink" alt="Pastedimage20240727011959.png" />
<figcaption
aria-hidden="true">Pastedimage20240727011959.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/96ccf184d8075cd9ae675228c1c89ffb27a7fc4d.png"
class="wikilink" alt="Pastedimage20240727012036.png" />
<figcaption
aria-hidden="true">Pastedimage20240727012036.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/abcb0e82fbf8c4cd55296e8c14eba48c09c31d9d.png"
class="wikilink" alt="Pastedimage20240727012052.png" />
<figcaption
aria-hidden="true">Pastedimage20240727012052.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/bf79a80a9de08e79ce81348a505a70f8412e9146.png"
class="wikilink" alt="Pastedimage20240727012116.png" />
<figcaption
aria-hidden="true">Pastedimage20240727012116.png</figcaption>
</figure>

<img
src="../vmware-vcda-onprem-appliance/5cd4be7acada07e6316f93ec885603c9980fcfb6.png"
class="wikilink" alt="Pastedimage20240727012136.png" />
<img
src="../vmware-vcda-onprem-appliance/b7e203e4afe9861ced6736bfbda892c4d4b07345.png"
class="wikilink" alt="Pastedimage20240727012244.png" />

##### source VM dr-vm-01 (powered off):

<figure>
<img
src="../vmware-vcda-onprem-appliance/4470a286349221ed6658d3500e5b29777bd347d8.png"
class="wikilink" alt="Pastedimage20240727014236.png" />
<figcaption
aria-hidden="true">Pastedimage20240727014236.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/6a732707d83c4ed92922e581d99d44f4ad2e8d70.png"
class="wikilink" alt="Pastedimage20240727014248.png" />
<figcaption
aria-hidden="true">Pastedimage20240727014248.png</figcaption>
</figure>

##### source VM dr-vm-02 (delta):

<img
src="../vmware-vcda-onprem-appliance/051c61d457b19e5fe36a9c40deef158e0056d4a7.png"
class="wikilink" alt="Pastedimage20240727013314.png" />
<img
src="../vmware-vcda-onprem-appliance/0143ba2de232fe34ad6245e334706e4b541e7118.png"
class="wikilink" alt="Pastedimage20240727013518.png" />
<img
src="../vmware-vcda-onprem-appliance/53545b038b8b70b9ea2c5a31cd9f89c60d8a6b9e.png"
class="wikilink" alt="Pastedimage20240727013605.png" />
<img
src="../vmware-vcda-onprem-appliance/828eb2553e322f64ab0bb554f18c9d3b895ee254.png"
class="wikilink" alt="Pastedimage20240727013807.png" />

##### network, guest cust

<figure>
<img
src="../vmware-vcda-onprem-appliance/612e7f1a171e2b770816f323cbfb5e44fe7ae42e.png"
class="wikilink" alt="Pastedimage20240727014706.png" />
<figcaption
aria-hidden="true">Pastedimage20240727014706.png</figcaption>
</figure>

<img
src="../vmware-vcda-onprem-appliance/458f7857568209cb4b5a3bdcbb18d9b12acfaec2.png"
class="wikilink" alt="Pastedimage20240727014829.png" /><img
src="../vmware-vcda-onprem-appliance/63843a1e7a4b9ade02345a3fe878ba7a8b08f3e1.png"
class="wikilink" alt="Pastedimage20240727014854.png" />
<img
src="../vmware-vcda-onprem-appliance/8dd0825dfd638a3b7443dd7402de0769dd1baedf.png"
class="wikilink" alt="Pastedimage20240727015208.png" />
<img
src="../vmware-vcda-onprem-appliance/23eaaa7c311db51c544420eaf7542ccf71b068b0.png"
class="wikilink" alt="Pastedimage20240727015307.png" />

dr-vm-01
<img
src="../vmware-vcda-onprem-appliance/3371a6b13281b6ba0bed20da52cfa9b8e04e3342.png"
class="wikilink" alt="Pastedimage20240727015615.png" />
<img
src="../vmware-vcda-onprem-appliance/fe129706e880ea49d1c123fa903c4d66020d57ab.png"
class="wikilink" alt="Pastedimage20240727015648.png" />
Чтобы не менять пароли
<img
src="../vmware-vcda-onprem-appliance/7615519262e365b7beeb78de2e98213ab63d1cdb.png"
class="wikilink" alt="Pastedimage20240727021727.png" />
\#### test settings:

<img
src="../vmware-vcda-onprem-appliance/c4d98faef39445a27827b3bdd0890b6d922e3880.png"
class="wikilink" alt="Pastedimage20240727020644.png" />
<img
src="../vmware-vcda-onprem-appliance/920dd2539a9f3c53b381381b7af9e279693bc835.png"
class="wikilink" alt="Pastedimage20240727020659.png" />
<img
src="../vmware-vcda-onprem-appliance/a0cd6de1d68b098a0d4041bcbaf09e3a3f10bb49.png"
class="wikilink" alt="Pastedimage20240727021815.png" />

<img
src="../vmware-vcda-onprem-appliance/a0b5b25893b2269651577864ad370ba3e547d52f.png"
class="wikilink" alt="Pastedimage20240727015739.png" />
<img
src="../vmware-vcda-onprem-appliance/7d5ecb1ebdde2ae62886ed2c9b08c4da953b2416.png"
class="wikilink" alt="Pastedimage20240727015810.png" />

#### Тестовая миграция:

<figure>
<img
src="../vmware-vcda-onprem-appliance/8909cc5aec15c782d8321881c8c5c8e343268112.png"
class="wikilink" alt="Pastedimage20240727015842.png" />
<figcaption
aria-hidden="true">Pastedimage20240727015842.png</figcaption>
</figure>

<img
src="../vmware-vcda-onprem-appliance/5bf243dff5290503b5d6a37b00de42dc33b8b4cd.png"
class="wikilink" alt="Pastedimage20240727015940.png" />
<img
src="../vmware-vcda-onprem-appliance/b25372bc5a8e2a1e0af8a0bb43e3a7d42e72efa7.png"
class="wikilink" alt="Pastedimage20240727020011.png" /><img
src="../vmware-vcda-onprem-appliance/111eec81821717dbf5782f6b21883a8ca3c0216b.png"
class="wikilink" alt="Pastedimage20240727020031.png" />
<img
src="../vmware-vcda-onprem-appliance/3b3eddb9bc07b70f4b0bd88c5458d8299966bed8.png"
class="wikilink" alt="Pastedimage20240727020857.png" />

<figure>
<img
src="../vmware-vcda-onprem-appliance/d6eec3206051c93a4777af34a8af9d9b6de1e197.png"
class="wikilink" alt="Pastedimage20240727024148.png" />
<figcaption
aria-hidden="true">Pastedimage20240727024148.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/60ba0c92d91fb1ed630c7b97e840667a285935fa.png"
class="wikilink" alt="Pastedimage20240727031546.png" />
<figcaption
aria-hidden="true">Pastedimage20240727031546.png</figcaption>
</figure>

#### Миграция

<img
src="../vmware-vcda-onprem-appliance/48daad21e648c056579ec4a59a0b6e16aaf30fca.png"
class="wikilink" alt="Pastedimage20240727044811.png" /><img
src="../vmware-vcda-onprem-appliance/455b2da41adfd37beb3ee9cc752eddfa3244b813.png"
class="wikilink" alt="Pastedimage20240727044930.png" />
<img
src="../vmware-vcda-onprem-appliance/2ebc00e7ee24c9179cd0831761fd9bcd7fe2ef29.png"
class="wikilink" alt="Pastedimage20240727044951.png" />

<img
src="../vmware-vcda-onprem-appliance/4407551388be55bcb330b270de21a3a25d375593.png"
class="wikilink" alt="Pastedimage20240727045159.png" /><img
src="../vmware-vcda-onprem-appliance/b515053ed92fc01e9f5dfe606c30a19d9f6ef134.png"
class="wikilink" alt="Pastedimage20240727045523.png" />

##### Быстрая миграция (Fast migration)

<figure>
<img
src="../vmware-vcda-onprem-appliance/03b08f553a9a7f913967fb41a1bd2b5d53d91969.png"
class="wikilink" alt="Pastedimage20240731165317.png" />
<figcaption
aria-hidden="true">Pastedimage20240731165317.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/8fb3ce08d8b9962fb1dde401559979a945504d10.png"
class="wikilink" alt="Pastedimage20240731165240.png" />
<figcaption
aria-hidden="true">Pastedimage20240731165240.png</figcaption>
</figure>

##### Репликация

<figure>
<img
src="../vmware-vcda-onprem-appliance/5b09c34029a802df11082e54bab2d13ad735a5e9.png"
class="wikilink" alt="Pastedimage20240731171815.png" />
<figcaption
aria-hidden="true">Pastedimage20240731171815.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/0bb649c39351f2c58084fd5c4bf96e13a4829474.png"
class="wikilink" alt="Pastedimage20240731171853.png" />
<figcaption
aria-hidden="true">Pastedimage20240731171853.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/4aec18ef82c9330ee478a88a6948ef9aa7a899d8.png"
class="wikilink" alt="Pastedimage20240731171926.png" />
<figcaption
aria-hidden="true">Pastedimage20240731171926.png</figcaption>
</figure>

<figure>
<img
src="../vmware-vcda-onprem-appliance/77ceea2e804d351e3cf62dbed4a2479bb7e89119.png"
class="wikilink" alt="Pastedimage20240801182923.png" />
<figcaption
aria-hidden="true">Pastedimage20240801182923.png</figcaption>
</figure>
