import sqlite3

db = sqlite3.connect("D:\\Git\\blog\\python\\PythonCoding\\Coding20190109\\a.db")

cur = db.cursor()
''''
cur.execute("""create table catalog ( id integer primary key, pid integer, name varchar(10) UNIQUE )""")

cur.execute("insert into catalog values(0, 0, 'i love python')")
cur.execute("insert into catalog values(1, 0, 'hello world')")
db.commit()

cur.execute("select * from catalog")
cur.execute("insert into catalog values(2, 0, 'world')")
db.commit()
'''
cur.execute("select * from catalog")
print(cur.fetchall())