# Python字符串 大小写转换和控制 解决方法

在处理字符串问题的时候，我们经常能遇到英文大小写的问题，今天我们就为初学者都讲一下，Python处理和控制字符串大小写的问题。

解决方法：

字符串方法中有一个upper和lower内置方法，方法不需要参数，就可以直接返回一个原有字符串的一个拷贝，其中的每个字母都会被修改成大写或者小写字母。

s = "Hello"

Uppercase =  s.upper()  #返回大写字符

Lowercase = s.lower()  #返回小写字符


字符的顺序不会被更改，另外，还可以将字符串的首字母修改为大写，其余字母还是小写，大家可以查询一下相关的方法，下面举例说明:

```
print("one tWo thrEe".capitalize())
# 返回 One two three

>>> print("one tWo thrEe".title())
# 返回 One Two Three
```
大家注意上面两者首字母大写的，区别和使用方法。

操作字符串是非常常见的需求，有很多方法都可以让你创建需要的字符串形式，另外，还可以检查一个字符串str类型是否符合你想要的格式，
例如 isupper,islower,istitle方法，与上面使用方式一置，如果一个给定的字符串不是空的，或者至少要包含一个字母在里面，不能都是数字，或者是否都是大写字母，这几种方法都会返回布尔值True或False。

```python
>>> S='aubre yyoung'
>>> S.isupper()
False
>>> S.islower()
True
>>> S.istitle()
False
```

玩蛇网-斯巴达提示: 尽量不要自己去实现这些功能，去再造轮子，用内置方法会事半功倍。