# 老男孩Python_Day04

## 列表

[^列表]: 在其它语言中称为数组

​	以[]括起来，每个元素以逗号隔开，而且他里面可以存放各种数据类型

增删改查:CURD

​	增:append insert extend

​	删: remove pop clear del

​	改:li[索引] = '修改的内容'  li[切片] = '表修改的内容'   li[切片] = [列表]

​	查: for循环  index 切片

​	range,

列表的循环

 	for循环

列表的嵌套

### 增删改查,列表的循环

```
# 列表
li = [1,[1,2,3],'a','b',2,3,'a']

print(li[0])
print(li[0:3])

# 增加
# append
li = [1,[1,2,3],'a','b',2,3,'a']

li.append('oracle')
print(li)

print(li.append('oracle'))  # 无返回值,返回None

li = []

while 1:
    name = input("请输入:")
    if name.strip().upper() == 'KILL':
        break
    else:
        li.append(name)
print(li)

# insert
li = [1,[1,2,3],'a','b',2,3,'a']
li.insert(-1,'oracle')
print(li)

# extend 迭代添加的是元素,int不可以迭代
li.extend('mysql')
print(li)

li.extend([1,2,3])
print(li)

# pop 有返回值
li = [1,[1,2,3],'a','b',2,3,'a']
name = li.pop(0)
name = li.pop()  # 默认删除最后一个
print(name,li)

# remove  默认删除第一个
li = [1,[1,2,3],'a','b',2,3,'a']
li.remove('a')
print(li)

# clear
li = [1,[1,2,3],'a','b',2,3,'a']
li.clear()
print(li)

# del
li = [1,[1,2,3],'a','b',2,3,'a']
del li
print(li)

li = [1,[1,2,3],'a','b',2,3,'a']
# del li[0:2]  # 切片删除
del li[4:]
print(li)

# 改
li = [1,[1,2,3],'a','b',2,3,'a']
li[-1] = 'mysql'
print(li)

li = [1,[1,2,3],'a','b',2,3,'a']
# li[0:2] = 'oralce'
li[0:2] = [4,5,6,'oracle']
print(li)

# 查
li = [1,[1,2,3],'a','b',2,3,'a']

for i in li:
    print(i)

li = [1,[1,2,3],'a','b',2,3,'a']

for i in li[1:3]:
    print(i)

# 公共方法
# len
li = [1,[1,2,3],'a','b',2,3,'a']
l = len(li)
print(l)
print(len('oracle'))

# count
li = [1,[1,2,3],'a','b',2,3,'a']

print(li.count('a'))

#index
li = [1,[1,2,3],'a','b',2,3,'a']

print(li.index('a',0,2))

# sort
li = [12313,43432254,767634,21312321]

# li.sort()
li.sort(reverse=True)
print(li)

# reverse
li = [1,[1,2,3],'a','b',2,3,'a']
li.reverse()
print(li)
```

### 列表的嵌套

```
li = [1,[1,2,3],'a','b',2,'mysql','linux']

print(li[1][2])

li[li.index('mysql')] = li[li.index('mysql')].capitalize()
print(li)

# replace
li = [1,[1,2,3],'a','b',2,'mysql',['linux','oracle']]

li[-2] = li[-2].replace('m','M')
print(li)

li[li.index('linux')] = li[li.index('linux')].upper()  # 报错

print(li)
```



## 元祖

元组被称为只读列表，即数据可以被查询，但不能被修改，所以，字符串的切片操作同样适用于元组。

**只读列表,可循环查询,可切片**
**儿子不能改,孙子可能可以改**

```
tuple = (1,[1,2,3],'a','b',2,'mysql',['linux','oracle'])

print(tuple[-1])
print(tuple[1:4])

for i in tuple:
    print(i)

tuple = (1,[1,2,3],'a','b',2,'mysql',['linux','oracle'])
tuple[-1][0] = tuple[-1][0].upper()
print(tuple)

tuple[-1].append('MongoDB')
print(tuple)

```



```
# join
s = 'Aubrey'
print("_".join(s))

# join 列表 --> 字符串
list = ['a','b','mysql']
print(''.join(list))  # 列表中元素不能是int、list等其他类型



# range 实际为数字列表

for i in range(0,100,2):
    print(i)

for i in range(100,0,-20):
    print(i)

for i in range(0,10,-1):  # 运行结果为空
    print(i)

for i in range(100,-20,-20):
    print(i)
```

```
# 循环递归打印
list = [1,[1,2,3],'a','b',2,'mysql',['linux','oracle']]

if isinstance(i,list):
    for i in
else:
    print(i)
```

​	**sort(reverse=True)** 

[^注]: 字符串sort 按照第一个字符 ASCII码进行排序

​	**reserve**

​	**join**   ---- **split**

​		S.join(iterable)

​		str([1,2,3])= '[1,2,3]'