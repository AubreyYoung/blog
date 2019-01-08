# Python Cookie HTTP获取cookie并处理

**Cookie模块**同样是[Python标准库](http://www.iplaypy.com/module/)中的一员，它定义了一些类来解析和创建HTTP 的 cookie头部信息。

## 一、创建和设置Cookie
```
>>> import Cookie #导入Cookie操作模块，注意首字母是大写的。
>>> c = Cookie.SimpleCookie() #创建对象
>>> c['mycookie'] = 'cookie_value'
>>> print(c)
```
这样，就输出了一个符合规则的 Set-Cookie头部信息，可以作为HTTP网页响应Header信息的一部分，传递给客户端。

## 二、获取 cookie信息的代码演示
```
>>> import Cookie #python 获取cookie
>>> import urllib
>>> import urllib2
>>>
>>> c = cookielib.LWPCookieJar() #python获取cookies
>>> opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(c))
>>> login_path = “http://www.example.com/login.php”
>>>
>>> data = {“name”: “admin”, “passwd”: “hahaha”}
>>> post_info = urllib.urlencode(data)
>>> request = urllib2.Request(login_path, post_info)
>>> html = opener.open(request).read()
>>>
>>>if c:
>>>    print c
>>>
>>>c.save(‘cookie.txt’)
>>>
```
​	提示：Cookie就是储存在用户本地终端上的数据，经过加密，它的最新规范是RFC2965, 当然浏览器有设置可以禁止使用cookie，而且Cookie都有它的生命周期，一些统计系统就是利用Cookie来统计用户信息的，包括网站登录，识别用户都需要它。