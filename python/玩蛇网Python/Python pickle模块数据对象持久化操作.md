# Python pickle模块数据对象持久化操作

[**Python**](http://www.iplaypy.com/) **pickle模块作用是持久化的储存数据**。

经常遇到在Python程序运行中得到了一些[字符串](http://www.iplaypy.com/jichu/str.html)、[列表](http://www.iplaypy.com/jichu/list.html)、[字典](http://www.iplaypy.com/jichu/dict.html)等数据，想要长久的保存下来，方便以后使用，而不是简单的放入内存中关机断电就丢失数据。[python模块](http://www.iplaypy.com/module/)大全中的Pickle模块就派上用场了，它可以将对象转换为一种可以传输或存储的格式。

## 一、Pickle对象串行化

Pickle模块将任意一个Python对象转换成系统字节的这个操作过程叫做串行化对象。

## 二、Pickle与CPickle对比

前者是完全用Python来实现的模块，这个CPickle是用C来实现的，它的速度要比pickle快好多倍，一般建议如果电脑中只要有CPickle的话都应该使用它。

## 三、Pickle模块的dump()方法

在Pickle模块中有2个常用的函数方法，一个叫做**dump()**，另一个叫做**load()**。

第三部分，玩蛇网先给大家讲解一下 pickle.dump()方法：

这个方法的语法是：*pickle.dump(对象, 文件，[使用协议])*

提示：将要持久化的数据“对象”，保存到“文件”中，使用有3种，索引0为ASCII，1是旧式2进制，2是新式2进制协议，不同之处在于后者更高效一些。默认的话dump方法使用0做协议。

## 四、Pickle模块的load方法

load()方法的作用正好与上面的dump()方法相反，上面是序列化数据，这个方法作用是反序列化。

语法：pickle.load(文件)

提示：从“文件”中，读取字符串，将它们反序列化转换为Python的数据对象，可以正常像操作数据类型的这些方法来操作它们。

## 五、Pickle代码案例演示

```
try:
    import _pickle as pickle
except:
    import pickle
import pprint

info=[1,2,3,'abc','Aubrey']
print("原始数据:",pprint.pformat(info))

data1 = pickle.dumps(info)
data2 = pickle.loads(data1)

print("序列化:%r" %data1)
print("反序列化:%r" %data2)
```



