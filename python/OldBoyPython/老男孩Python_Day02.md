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



