# Python xmlrpclib模块使用教程

XML-RPC是一种使用xml文本的方式利用http协议传输命令和数据的rpc机制，我们[Python](http://www.iplaypy.com/)的**xmlrpc模块**可以让程序与其它任何语言编写的XML-RPC服务器进行数据的传输。

1. 我们用Python写一个简单的8080端口服务器，源码如下：

\# sxr.py 新建文件，名字为sxr.py

from SimpleXMLRPCServer import SimpleXMLRPCServer

def happy():
​    [print](http://www.iplaypy.com/jichu/print.html) "I play Python.!"
​    sxr=SimpleXMLRPCServer(("", 8080), allow_none=True)
​    sxr.register_function(happy)
​    sxr.serve_forever()

然后，我们运行程序，启动SimpleXMLRPCServer模块的服务器。

$ ： python sxr.py # 启动sxr.py服务器文件，也就是上面的代码。

最后，使用xmlrpclib模块ServerProxy方法连接至上面的服务器，看下面代码：

\#happy.py 再次新建一个文件，名为 happy.py

from xmlrpclib import ServerProxy

sp = ServerProxy("http://localhost:8080")
sp.happy()

启动，并运行，看到终端模拟器或者Windows的Dos界面中，输出 “I play Python.”，就证明我们已经和xml-rpc服务器连接上了。

==Python3 只有xmlrpc和xml模块，本节内容无效==