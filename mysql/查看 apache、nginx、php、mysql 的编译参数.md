## 查看 apache、nginx、php、mysql 的编译参数

- 查看**nginx**编译参数
```
/usr/local/nginx/sbin/nginx -V
```
- 查看**apache**编译参数
```
cat /usr/local/apache2/build/config.nice
```
- 查看**mysql**编译参数
```
cat /usr/local/mysql/bin/mysqlbug | grep CONFIGURE_LINE
```
- 查看**php**编译参数
```
/usr/local/php/bin/php -i | grep configure
```

