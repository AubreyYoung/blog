#coding UTF-8
import time

print(time.time())
print(time.ctime())
print(time.localtime())
print(time.asctime())
print(time.strftime('%Y-%m-%d',time.localtime()))
time.sleep(2)
print(time.process_time())