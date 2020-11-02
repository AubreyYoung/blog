name = input("Name:")
age = input("Age:")
job = input("Job:")
hobbie = input("Hobbie:")

# print('''
# ------------ info of %s -----------
# Name  : %s  #代表 name
# Age   : %s  #代表 age
# job   : %s  #代表 job
# Hobbie: %s  #代表 hobbie
# ------------- end -----------------
# ''' %(name,name,age,job,hobbie))

# print('''
# ------------ info of %s -----------
# Name  : %s  #代表 name
# Age   : %d  #代表 age
# job   : %s  #代表 job
# Hobbie: %s  #代表 hobbie
# ------------- end -----------------
# ''' %(name,name,int(age),job,hobbie))

msg = '''------------ info of %s -----------
Name  : %s  #代表 name
Age   : %s  #代表 age
job   : %s  #代表 job
Hobbie: %s  #代表 hobbie
------------- end -----------------''' %(name,name,age,job,hobbie)
print(msg)

name = input('请输入姓名')
age = input('请输入年龄')
height = input('请输入身高')
msg = "我叫%s，今年%s 身高 %s 学习进度为3%%s" %(name,age,height)
print(msg)