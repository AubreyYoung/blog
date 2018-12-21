# ==Python多重继承的异构构造器==

[^注]: ==暂未搞明白==

在Python里面，如果你使用上Qt，SQLAlchemy，Twisted之类各种大型类库时候，有时候多重继承Multiple Inheritance是个简单的解决方法，但是多重继承的复杂性总容易造成误解和疑惑。

一般“常识”说，使用super访问父类的属性/方法，这种说法在多重继承里面是不成立的，多重继承的类并没有父类的概念(There is no superclass in a MI world)。类似的博客在过去几年被人写了无数遍了，因为过去版本里面python官方文档对super的解释非常有限而且有误导解释，直到2.6以后的文档，才详细说明了super在单继承和多继承的两种不同工作方式。当时苦逼的程序员甚至不得不去翻看Python源码才搞清楚是什么回事。以致几年来很多人对python的多重继承保持怀疑态度。

Python多重继承使用Method Resolution Order的动态算法来解决一个方法名的调用顺序，mro其实说来简单，就是一个深度优先的继承列表，很易理解，但随之来的是遇到互不相同的构造器__init__参数的问题。

Codepad运行结果：

```
class A(object):
    def __init__(self, arg1):
        print "init func in A, with arg1 '%s'" % arg1
        super(A, self).__init__()
  
class B(object):
    def __init__(self, arg1, arg2):
        print "init func in B, with arg1'%s', arg2 '%s'" % (arg1, arg2)
        super(B, self).__init__(arg1)
  
class C(B, A):
    def __init__(self, arg1, arg2):
        print "init func in C, with arg1'%s', arg2 '%s'" % (arg1, arg2)
        super(C, self).__init__(arg1, arg2)
        print C.__mro__
  
c = C("C's arg1", "C's arg2")
```

执行结果：

```
init func in C, with arg1'C's arg1', arg2 'C's arg2'
init func in B, with arg1'C's arg1', arg2 'C's arg2'
init func in A, with arg1 'C's arg1'
(<class>, <class>, <class>, <type>)
</type></class></class></class>
```

可见几个类的构造器的执行顺序正是mro列表的顺序。重点是多重继承的各个类的构造器__init__之所以能够执行，是因为每个构造器里面都有一句super()，这个super完成mro列表中下一个类的构造器的调用。

这个事实听起来似乎很自然，但看代码，B的构造器还得必须知道A的构造器的参数？B需要知道自己将会被C同时继承A，并且调用A的构造？！！很荒谬，但不幸的这是mro的特点。代码是可以这么写，但不应该，为另一个不知道什么时候会被一起继承的类特地地写代码，跟面对对象设计的解耦原则相违背。How

在mro方式的基础上，这个问题是不可能有效解决的，只能避免。概括起来大概有这么 两种方式。
1.使用传统类的方式，显式调用被继承类的构造器，避开super的mro自动化工作。

Codepad 看运行效果：

```
class A(object):
    def __init__(self, arg1):
        print "init func in A, with arg1 '%s'" % arg1
  
class B(object):
    def __init__(self, arg1, arg2):
        print "init func in B, with arg1'%s', arg2 '%s'" % (arg1, arg2)
  
class C(A, B):
    def __init__(self, arg1, arg2):
        print "init func in C, with arg1'%s', arg2 '%s'" % (arg1, arg2)
        #super(C, self).__init__(arg1) #这两行
        A.__init__(self, arg1)       #等价
        B.__init__(self, arg1, arg2)
        print C.__mro__
  
c = C("C's arg1", "C's arg2")
```

注意 C继承A，B的顺序已经改变。

要排除一个容易产生的误解。Python文档里面的super有个很显著的Note：super() only works for new-style classes. super只适用于新类。但新类并不必须使用super。

直接调用被继承类的__init__作为unbound方法调用，需要指定一个实例，如self作为参数，依次调用各个被继承类。缺点是若果这几个被继承类也在构造方法里面使用这样调用了同一个上级被继承类，会出现“爷爷类”的构造方法被调用多次的情况。

如果一定使用super，要注意继承列表的顺序。super(TYPE, self).method调用的是mro列表中第一个，也即继承列表第一个类的方法。

PyQt里面的类内部一般（未细究）都使用__init__的方式来初始化代码，因而很多PyQt的例子代码都是使用QtGui.QMainWindow.__init__(self)这样的代码来初始化。当然在单继承时候和super的写法是等价的，但最好使用统一的原则:

一个简单好记的原则：
如果”被继承类”都使用__init__，”继承类”就使用__init__来初始化；
如果”被继承类”都使用super，”继承类”就使用super来初始化；

2.使用Composition / Association Pattern的设计模式（即’Is-A’转换成’Has-A’）来实现相同功能，避免多重继承。

这个方法听起来未免有点让人不快（破坏了原有设计思维），但实际上很可能这是更好的方式，更清晰的代码，尤其是要继承的类里面混合了使用super，__init__两种初始化方式的时候。；