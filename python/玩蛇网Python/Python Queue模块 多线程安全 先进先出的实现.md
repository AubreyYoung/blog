# Python Queue模块 多线程安全 先进先出的实现

**Queue模块**提供了一个适用于多线程编程的先进先出数据结构，可以用来安全的传递多线程信息。
我们先来创建一个Queue模块的队列对象：
```
>>> import Queue 
>>> q = Queue.Queue(maxsize=10)
```
上面的代码中，我们先导入了Queue模块，之后创建了一个叫做[变量](http://www.iplaypy.com/jichu/var.html)Q的队列对象，Queue.Queue是一个[类](http://www.iplaypy.com/jichu/class.html)，相当于创建了一个队列，这个队列有一个可参数masize，可以设置队列有长度，设置为“-1”，就可以让队列达到无限。
我们可以将一个数值放入队列中去：
\>>> q.put(10)
put()方法可以在队列的尾部插入一个项目，它有2个参数，一个是需要插入的项，第二个默认参数值为1，方法让线程暂停，直到空出一个数据单元项，如果参数为0，会出发Full [Python的异常](http://www.iplaypy.com/jichu/exception.html)。
有进有出，我们将刚才插入的值，再用get()方法取出来：
\>>> q.get()
q这个对象的get()方法可以从队列头部删除而且返回一个项目，有一个可选参数，默认值是真，也就是True。get()就使调用线程暂停，直至有项目可用,如果队列为空且block为False，队列将引发Empty的Python异常。

举一个Queue的先进先出(FIFO)队列源码案例：
```
>>> import queue
>>> q = queue.Queue() #创建队列对象
>>> for i in range(8):
>>>    q.put(i)
>>> while not q.empty():
>>>    print(q.get())
>>> print()
结果：0 1 2 3 4 5 6 7
```