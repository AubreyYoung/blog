# Python Gzip压缩与解压模块

**Python Gzip模块**为GNU zip文件提供了一个类文件的接口，它使用zlib来压缩和解压缩数据文件，读写gzip文件。

首先，我们来看一下压缩与解压的流程[代码](http://www.iplaypy.com/code/)：

## 一、使用gzip模块压缩文件
```
>>> import gzip #导入python gzip模块，注意名字为全小写
>>> g = gzip.GzipFile(filename="", mode="wb", compresslevel=9, fileobj=open('sitemap.log.gz', 'wb'))
>>> g.write(open('d:\\test\\sitemap.xml').read())
>>> g.close()
```
其中，filename参数是压缩文件内，文件的名字，为空也可以，不修改。fileobj是生成的压缩文件对象，它的路径名称等。最后是把文件写入gzip文件中去，再关闭操作连接。

## 二、使用gzip模块解压缩文件
```
>>> g = gzip.GzipFile(mode="rb", fileobj=open('d:\\test\\sitemap.log.gz', 'rb')) # python gzip 解压
>>> open(r"d:\\haha.xml", "wb").write(g.read())
```
使用的时候注意，[函数](http://www.iplaypy.com/jichu/function.html)方法的大小写一点要看仔细，如果gzip文件是这种形式的：*.tar.gz，证明先是由tar命令压缩后，后再由 gzip压缩的，需要先用解压缩tar文件，再用gzip模块解压缩。其实，现在很多网页为了提高浏览器端用户的访问速度，和搜索引擎爬虫抓取的速度，都在使用gzip压缩。