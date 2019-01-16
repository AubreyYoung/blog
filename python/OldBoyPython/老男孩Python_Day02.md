# 老男孩Python_Day02

## 格式化输出

%占位符 s字符串 d 数字 

%% 只是单纯显示%

```
name = input("Name:")
age = input("Age:")
job = input("Job:")
hobbie = input("Hobbie:")

info = '''
------------ info of %s ----------- #这里的每个%s就是一个占位符，本行的代表 后面拓号里的 name 
Name  : %s  #代表 name 
Age   : %s  #代表 age  
job   : %s  #代表 job 
Hobbie: %s  #代表 hobbie 
------------- end -----------------
''' %(name,name,age,job,hobbie)  # 这行的 % 号就是 把前面的字符串 与拓号 后面的 变量 关联起来 

print(info)
```

问题：现在有这么行代码

```
msg = "我是%s,年龄%d,目前学习进度为80%"%('金鑫',18)
print(msg)
```

这样会报错的，因为在格式化输出里，你出现%默认为就是占位符的%，但是我想在上面一条语句中最后的80%就是表示80%而不是占位符，怎么办？

```
msg = "我是%s,年龄%d,目前学习进度为80%%"%('金鑫',18)
print(msg)
```

这样就可以了，**第一个%是对第二个%的转译，告诉Python解释器这只是一个单纯的%，而不是占位符**。

## while else

**while 后面的else 作用是指，当while 循环正常执行完，中间没有被break 中止的话，就会执行else后面的语句**

```
count = 0
while count <= 5 :
    count += 1
    print("Loop",count)

else:
    print("循环正常执行完啦")
print("-----out of while loop ------")
```

## 初始编码

电脑的传输、存储的实际上都是0101

美国：ASCII码 为解决全球化的文字问题，常见了一个玩过码，Unicode 4个字节

中文 9万多字

升级版 utf-8  一个中文 3个字节去表示

**UTF-8 是 Unicode 的实现方式之一**。UTF-8 最大的一个特点，就是它是一种变长的编码方式。它可以使用1~4个字节表示一个符号，根据不同的符号而变化字节长度。

utf-8 一个字符最少用8位去表示，英文用8位		一个字节

​	 欧洲文字用16位去表示					两个字节

​	 中文用24位去表示					        3个字节

utf-16 一个字符最少用16位去表示

gbk	   国内使用，一个中文用2个字节

## 运算符

![1547605791368](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1547605791368.png)

![1547605909096](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1547605909096.png)

![1547605972845](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1547605972845.png)

![1547606003910](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1547606003910.png)

针对逻辑运算的进一步研究：

　　1,在没有()的情况下not 优先级高于 and，and优先级高于or，即优先级关系为( )>not>and>or，同一优先级从左往右计算。

int ---->bool 非零数字转换为bool True 

​		      0转换为bool False

```
print(1 or 2)
print(3 or 2)
print(0 or 2)
print(0 or 100)
print(bool(2))
print(bool(-2))
print(bool(0))
```

bool---int   

```
print(int(true))  # 1
print(int(false))  #0	
```

**x or y , x为真，值就是x，x为假，值是y；**

**x and y, x为真，值是y,x为假，值是x。**

```
print(2 or 1 < 3)
print(1 < 3 or 2)
print(1 > 2 and 3 or 4 and 3 < 2)  #f and 3 or 4 and f = f or f =f
```

