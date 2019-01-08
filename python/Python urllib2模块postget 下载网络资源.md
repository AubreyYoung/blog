# Python urllib2模块post/get 下载网络资源

**urllib2**是非常强大的Python网络资源访问模块，它的功能和玩蛇网前面讲过的[urllib](http://www.iplaypy.com/module/urllib.html)模块非常相似。

## 一、urllib2模块简介

[Python标准库](http://www.iplaypy.com/module/)中的urllib2模块可以说是urllib模块的一个升级的复杂版，不需要另外下载，它的[函数](http://www.iplaypy.com/jichu/function.html)可以处理更多复杂的情况，比如访问的网络资源需要Http验证，需要cookie信息，模仿普通浏览器一样去访问网络、网页资源，这个时候urllib2就派上用场了。

## 二、urllib2模块函数方法

### 1 )、设置timeout超时设置：
```python
>>> import urllib #导入urllib2模块
>>> test = urllib.request.urlopen('http://www.iplaypy.com/', timeout=15)
>>> # 2个参数，一个是url网址，另一个是超时，这次测试设置值为15。
```
### 2 )、在访问的时候加入Header头部信息
```
>>> header = {"User-Agent": "Mozilla-Firefox24.0"} #dict字典类型
>>> urllib.request.urlopen(url,header)
```
向上面这样的操作，就可以加上Header头部信息，用来模仿浏览器行为，应对一些禁止爬虫的网络资源，非常适用。

### 3 )、用urllib得到http网页状态码
```
>>> import urllib
>>> test = urllib.request.urlopen(‘http://www.baidu.com/’)
```
### 4 )、使用urllib2对Cookie进行处理
```
>>> import urllib2
>>> import cookielib
>>>
>>> cookie =cookielib.CookieJar() # 后面函数方法要注意C和J是大写的。
>>> opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookie))
>>> response = opener.open('http://www.baidu.com')

>>> for item in cookie:
>>>    if item.name == "some_cookie_item_name”
>>>         [print](http://www.iplaypy.com/jichu/print.html) item.value
```
## 三、urllib2模块注意事项

URLLIB2模块还有很多功能和方法这里没有做介绍，如Proxy代理设置可以访问一些有限制的数据，如搜索引擎的数据，重定向url网址的处理，Debug日志的记录设置等，大家有时间可以去看一下官方的文档，或者用[dir()](http://www.iplaypy.com/jichu/dir.html)和help()方法，查看一下模块的方法和说明。

在Python3中包urllib2归入了urllib中，所以要导入urllib.request，并且要把urllib2替换成urllib.request。