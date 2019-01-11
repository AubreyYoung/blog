f = open('D:\\Git\\blog\\python\\PythonCoding\\Coding20190111\\a.txt',mode='rb')
print(f.tell())
f.seek(3)
print(f.tell())
f.seek(10,2)
print(f.tell())
f.seek(0)

print(f.readline())

print(f.readline())

print(f.read())