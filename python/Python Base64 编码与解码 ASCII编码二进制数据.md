# Python Base64 编码与解码 ASCII编码二进制数据

**Python Base64模块**的作用是将二进制数据转换为适合使用的在线文本协议传输的ASCII子集，它经常被用作为[电子邮件](http://www.iplaypy.com/module/smtplib.html)的传输编码，当然二进制编码后是可以解码的，生成的所有编码都是ASCII字符。
Python Base64 编码的好处是：速度非常快，ascii字符人肉眼无法理解。
Python Base64 编码的缺点是：编码之后字符很长，容易被破解，只适合于特定的领域内使用。
下面给大家展示一个用Base64模块，进行编码和解码的源码案例：

```
>>> import base64 #首先导入模块
>>> info = "玩蛇网"
>>> bm = base64.b64encode(info)
>>> print(bm) 	 #查看编码后的结果
546p6JuH572R 
>>>
>>> jm = base64.b64decode(bm) # python base64解码
>>> print jm #输出解码后的字符串 
玩蛇网
```

