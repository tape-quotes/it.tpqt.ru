---
created: 2025-02-11T04:03
updated: 2025-02-14T02:08
date: 
draft: true
params:
  author: Сергей Бурцев
title: 
weight: 
---

Download openssl-\*.tar.gz, and install it in a folder what defined all by yourself. Just like /usr/local/openssl, then using the follow commands:

``` sh
tar -zxvf openssl-*.tar.gz
```

``` sh
cd openssl-*
```

a)  

``` sh
./config --prefix=/usr/local/openssl shared threads 
```

b)  static libs build:

``` sh
./config --prefix=/usr/local/openssl no-shared threads 
```

``` sh
make  
```

``` sh
make test 
```

(if there have no error information occured)

``` sh
make install
```

a)  You would just manipulate your PATH and LD_LIBRARY_PATH appropriately for each application:

``` sh
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf.d/openssl1.1.1.conf
```

``` sh
ldconfig
```
