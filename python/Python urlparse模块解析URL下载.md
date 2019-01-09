# Python urlparse模块解析URL下载

[Python标准库](http://www.iplaypy.com/module/)中的**urlparse模块**是一个解析与反解析[Web](http://www.iplaypy.com/web/)网址URL字符串的一个工具。
## 一、urlparse模块功能介绍
urlparse模块会将一个普通的url解析为6个部分，返回的[数据类型](http://www.iplaypy.com/jichu/data-type.html)都是[元组](http://www.iplaypy.com/jichu/tuple.html)。同时，它还可以将已经分解后的url再组合成一个url地址。返回的6个部分，分别是：*scheme*(机制)、*netloc*(网络位置)、*path*(路径)、*params*(路径段参数)、*query*(查询)、*fragment*(片段)。

## 二、urlparse模块[函数](http://www.iplaypy.com/jichu/function.html)方法

1. **urlparse.urlparse**(url)

   分解url返回元组，可以得到很多关于这个url的数据，网络协议、目录层次等

2. **urlparse.urlunparse**(parts)

   接收一个元组类型，将元组内对应元素重新组后为一个url网址，与上面功能正好相反。

3. **urlparse.urlsplit**(url)

   作用与urlparse非常相似，它不会分解url参数，对于遵循RFC2396的URL很有用处。

4. **urlparse.urljoin**(base, url ) 

   功能是基于一个base url和另一个url构造一个绝对URL。

## 三 、urlparse案例源码演示


## 四 、urlparse模块知识总结

Python的一大强项就是它在网络抓取方面的功能，像编写一个爬虫抓取网络上面的资源，往往就需要先对网址url做一个处理，这离不开urlparse模块，自己编写处理url地址的代码费时费力，不如直接找找标准库中的urlparse。

==Python3 已修改==