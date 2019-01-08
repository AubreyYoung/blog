# Python socket套接字模块server/client端操作

如果想用**Python**做一个服务器端和客户端的通信程序，那么就一定要选择标准库中的 **scoket 套接字模块**，它支持多种网络协议：TCP/IP、ICMP/IP、UDP/IP等。

**python scoket模块详解**，在网络中一个最基本的组件就是套接字(socket)，它的功能是在2个程序之间建立信息的通道。

socket包括2个套接字，一个是服务器端(server)，一个是客户端(client)。在一个程序中创建服务器端的套接字，让它等客户端的连接，这样它就在这个IP和端口处，监听。

处理Client端套接字通常比处理服务器端套接字相对容易一些，因为服务器端还要准备随时处理客户端的连接，同时还要处理多个连接任务。python socket recv
而客户端只需要简单的设置好IP和端口就可以完成任务了。

socket套接字有2个方法，一个是send，另一个是recv，它们用来传输数据信息。
可以用[字符串](http://www.iplaypy.com/jichu/str.html)参数调用send方法发送数据，用一个所需的最大字节数做参数调用recv方法来接收数据。

下面[玩蛇网](http://www.iplaypy.com/)编写了一个简单的服务端和客户端程序，
python 记录套接字源码案例如下：

## 一、socket服务器端源码
```
>>> import socket #导入socket套接字模块
>>> s = socket.socket() #创建socket对象
>>> host = socket.gethostname() #得到当前主机名
>>> port = 24 #端口号
>>> s.bind(host, post)

>>> s.listen(5)
>>> while True:
>>> c, addr = s.accept()
>>> print ‘Got connection from’,addr
>>> c.send(‘Hello, www.iplaypy.com’) #发送信息
>>> c.close() #关闭socket
```
## 二、socket客户器端源码
```
>>> import socket
>>> s = socket.socket()
>>> host = socket.gethostname()
>>> post = 1234
>>> s.connect((host, port))
>>> print s.recv(1024)
```
大家如果想了解更详细的关于 Socket套接字模块的信息，可以参考Python官网的标准库：<http://docs.python.org/2/library/socket.html>