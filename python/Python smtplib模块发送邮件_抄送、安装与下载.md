# Python smtplib模块发送邮件_抄送、安装与下载

我们在日常编程过程中，经过会遇到发处理Email，发送、接收、抄送、下载邮件内容等操作，这个时候就需要用Python的 **smtplib模块**。
smtplib与Email服务器(server)相互通信来传送信息，它可以用于创建定制的Email邮件服务器，还提供了一些很实用的类(Class)，可以在其它程序应用中调试Email。

## 一、发送Email信息

使用smtplib模块最常用的功能就是发送Email了，源码案例如下：
```
>>> import smtplib
>>> import email.utils
>>> from email.mime.text import MIMEText
>>> msg = MIMEText('这是消息的主体部分.')
>>> msg['To'] = email.utils.formataddr(('admin','admin@example.com'))
>>> msg['From'] = email.utils.formataddr(('Author','author@example.com'))
>>> msg['Subject'] = 'Simple test message'
>>> server = smtplib.SMTP('mail')
>>> server.set_debuglevel(True)
>>> try:
>>>     server.sendmail('author@example.com',['admin@example.com'],msg.as_string())
>>> finally:
>>>     server.quit()
```
这个用smtplib模块发送email的[源码案例](http://www.iplaypy.com/code/)中，同时用了调试功能，这样来显示客户端与服务器之间的通信信息，要不然邮件发送成功与否不会显示出来。

另外，sendmail()方法的第2个参数，就是接收邮件的地址，它一定要是一个[列表](http://www.iplaypy.com/jichu/list.html)类型，这个列表中可以包括任意多个email地址，这也就是我们常说的邮件抄送功能，它会将邮件按顺序逐个的发给接收人。