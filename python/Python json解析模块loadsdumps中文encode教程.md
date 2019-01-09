# Python json解析模块loads/dumps中文encode教程

无论是利用**python**开发还是其它语言开发的很多大中型网都在采用json格式来交换数据**，**[Python标准库](http://www.iplaypy.com/module/)中有一个专门解析这个数据格式的模块就叫做：**json模块**。

## 一、json格式介绍

JSON格式是一种轻量级别的数据交换格式，容易被人识别和机器用来解析，它的全称叫做 JavaScript Object Notation。
Python json模块提供了和[pickle python](http://www.iplaypy.com/module/pickle.html)相似的API接口，可以将内存中的Python对象转换为一个串行化表示，被叫作json。json最广泛的应用于AJAX应用中的[WEB](http://www.iplaypy.com/web/)服务器和客户端之间的通信，也可以用于其它程序的应用中。

## 二、json模块编码

玩蛇网Leo在这里使用json.dumps方法，将一个Python数据类型列表进行json格式的编码解析，
示例如下：
```
>>> import json #导入python 中的json模块
>>> l = ['iplaypython',[1,2,3], {'name':'xiaoming'}] #创建一个列表list l
>>> encoded_json = json.dumps(l) # 将l列表，进行json格式化编码
>>> print(repr(i))
>>> print(encoded_json) #输出结果
```
这样我们就将一个list列表对象，进行了json格式的编码转换。

## 三 、json模块解码

解码python json格式，可以用这个模块的json.loads()函数的解析方法，
示例如下：
```
>>> decode_json = json.loads(encoded_json)
>>> print type(decode_json) #查看一下解码后的对象类型
>>> print(decode_json) #输出结果
```

## 四 、Python json案例

