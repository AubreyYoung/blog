# 老男孩Python_Day01

## 一、计算机基础--了解	

   CPU、内存、硬盘、OS、应用程序	

## 二、Python历史--了解

   **Python2**：源码不标准，混乱，重复代码多

   **Python3**：统一、标准，去除重复代码

## 三、Python环境--了解

   **编译型：一次性将所有程序编译成二进制文件**

- 缺点：开发效率低、不能跨平台

- 优点：执行速度快

     C、C++。。。

   **解释型：当程序执行时，一行一行的解释**

-  优点：开发效率高、可以跨平台

-  缺点：运行速度慢

     Python、php。。。

   ![1547195326417](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1547195326417.png)

   ![1547195365413](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1547195365413.png)

   **python是一门动态解释性的强类型定义语言。**

## Python的发展--了解

## Python种类

   ![1547196115246](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1547196115246.png)

   Python3x：python filepath

   Python2X：python filepath

   **Python2、Python3区别：Python2默认编码方式ascii码、Python3默认编码方式utf-8码**

   **解决方式**：Python2添加
```python
# -*- encoding:utf-8 -*-
```
## 变量

   **把程序运行的中间结果临时的存在内存里，以便后续的代码调用**

   **变量定义的规则**：

   - 变量名只能是 字母、数字或下划线的任意组合
   - 变量名的第一个字符不能是数字
   - 以下关键字不能声明为变量名
     ['and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'exec', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'not', 'or', 'pass', 'print', 'raise', 'return', 'try', 'while', 'with','yield']
   - 变量的定义要具有可描述性。
   - 不能是中文,不能是拼音--约定规则

   **推荐定义方式**

   ```
//驼峰体
AgeOfOldboy = 56
NumberOfStudents = 80
//下划线
age_of_oldboy = 56
number_of_students = 80
   ```

## 常量

常量即指不变的量，如pai 3.141592653..., 或在程序运行过程中不会改变的量

举例，假如老男孩老师的年龄会变，那这就是个变量，但在一些情况下，他的年龄不会变了，那就是常量。在Python中没有一个专门的语法代表常量，程序员约定俗成用变量名**全部大写代表常量**

   ```python
AGE_OF_OLDBOY = 56
   ```

## 注释

**当行注释**：# 被注释内容

**多行注释**：'''被注释内容'''，或者"""被注释内容"""

## 用户交互

等待输入；将你输入的内容赋值给前面的变量，**input出来的数据类型全是str**

```
# 将用户输入的内容赋值给 name 变量
name = input("请输入用户名：")
# 打印输入的内容
print(name)
```

## 基础数据类型初始

**数字**：int 1,2,3

 \+ - \* /  \** % //(取余)

在32位机器上，整数的位数为32位，取值范围为-2\**31～2\**31-1，即-2147483648～2147483647

在64位系统上，整数的位数为64位，取值范围为-2\**63～2\**63-1，即-9223372036854775808～9223372036854775807

long（长整型）

跟C语言不同，Python的长整数没有指定位宽，即：Python没有限制长整数数值的大小，但实际上由于机器内存有限，我们使用的长整数数值不可能无限大。

注意，自从Python2.2起，如果整数发生溢出，Python会自动将整数数据转换为长整数，所以如今在长整数数据后面不加字母L也不会导致严重后果了。

==注意：在Python3里不再有long类型了，全都是int==

input接收的所有输入默认都是字符串格式！要想程序不出错，那怎么办呢？简单，你可以把str转成int

```
age = int(  input("Age:")  )
print(type(age))
```

肯定没问题了。相反，能不能把字符串转成数字呢？必然可以，`str( yourStr )`

**字符串**

在Python中,加了引号的字符都被认为是字符串！只能进行"相加"和"相乘"运算。字符串与数字相乘~~

```
msg = '''
今天我想写首小诗，
歌颂我的同桌，
你看他那乌黑的短发，
好像一只炸毛鸡。
'''
print(msg)
```

**布尔类型**：TRUE，FALSE

## if

```
if 条件:
	结果
```

```
if 条件:
    满足条件执行代码
else:
    if条件不满足就走这段
```

```
if 条件:
    满足条件执行代码
elif 条件:
    上面的条件不满足就走这个
elif 条件:
    上面的条件不满足就走这个
elif 条件:
    上面的条件不满足就走这个    
else:
    上面所有的条件不满足就走这段
```

```
age_of_oldboy = 48
guess = int(input(">>:"))

if guess > age_of_oldboy :
    print("猜的太大了，往小里试试...")
elif guess < age_of_oldboy :
    print("猜的太小了，往大里试试...")
else:
    print("恭喜你，猜对了...")
```

## while

```
while 条件:   
    # 循环体
 
# 如果条件为真，那么循环体则执行
# 如果条件为假，那么循环体不执行
```

终止循环：

​		改变条件，使其不成立；break。

​		continue和break有点类似，区别在于continue只是终止本次循环，接着还执行后面的循环，break则完全终止循环

```
count = 0
while count <= 100 : 
    count += 1
    if count > 5 and count < 95: #只要count在6-94之间，就不走下面的print语句，直接进入下一次loop
        continue 
    print("loop ", count)
 
print("-----out of while loop ------")
```

