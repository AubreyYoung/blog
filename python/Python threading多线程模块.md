# Python threading多线程模块

[Python](http://www.iplaypy.com/)是支持使用多线程的，程序代码可以在一个进程空间中操作管理多个执行的线程，[python模块下载](http://www.iplaypy.com/module/)时要记得，这个库叫做 **threading**。

## 一、threading模块简介

在Python多线程中可以使用2个模块，一个是我们现在讲解的threading，还有一个是thread模块，但是后者比较底层，后者算是它的一个升级版，现在来说Python对于线程的操作还不如其它编程语言有优势，不能够利用好多核心CPU的资源，但是不妨碍我们使用。

## 二、threading模块方法讲解

1. 模块的Thread[函数](http://www.iplaypy.com/jichu/function.html)的可以实例化一个对象，每个Thread对象对应一个线程，可以通过start()方法，运行线程。 

2. threading.activeCount()方法返回当前”进程”里面”线程”的个数，

  注：返回的个数中包含主线程。类似[python统计列表中元素个数](http://www.iplaypy.com/jinjie/jj170.html)

3. threading.enumerate()的方法，返回当前运行中的Thread对象列表。

4.  threading.setDaemon()方法，参数设置为True的话会将线程声明为守护线程，必须在start() 方法之前设置，不设置为守护线程程序会被无限挂起。

## 三 、threading模块源码演示

使用threading模块多线程操作有两种模式，我们先来看第一种创建线程要执行的函数，把这个函数传递进Thread对象里，让它来执行，
玩蛇网代码如下：

![threading模块源码演示1](http://www.iplaypy.com/uploads/allimg/131226/1-1312261K4495T.jpg)

第二种是通过继承threading.Thread的方法，新建一个[类](http://www.iplaypy.com/jichu/class.html)(class)，把执行线程的代码放到这个类里面。

![threading模块代码演示2](http://www.iplaypy.com/uploads/allimg/131226/1-1312261K52U17.jpg)

## 四 、threading模块总结

threading模块的其它更多方法的代码演示，以后会陆续发布，还请大家时常关注玩蛇网的动态。