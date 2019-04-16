## Markdown使用技巧总结——字体，颜色，字号，背景，首行缩进等

### 1. 换行：

   - 方法1: 连续两个以上空格+回车
   - 方法2：使用html语言换行标签：`<br>`

### 2. 首行缩进两个字符：(每个表示一个空格，连续使用两个即可）

   - `&ensp;` 半角的空格
   - `&emsp;` 全角的空格

### 3. [字体、字号与颜色](http://blog.csdn.net/testcs_dn/article/details/45719357): 

	Markdown是一种可以使用普通文本编辑器编写的标记语言，通过类似HTML的标记语法，它可以使普通文本内容具有一定的格式。但是它本身是不支持修改字体、字号与颜色等功能的！ 
CSDN-markdown编辑器是其衍生版本，扩展了Markdown的功能（如表格、脚注、内嵌HTML等等）！对，就是内嵌HTML，接下来要讲的功能就需要使用内嵌HTML的方法来实现。 
​      **字体，字号和颜色编辑如下代码**

   ```
   <font face="黑体">我是黑体字</font>
   <font face="微软雅黑">我是微软雅黑</font>
   <font face="STCAIYUN">我是华文彩云</font>
   <font color=#0099ff size=7 face="黑体">color=#0099ff size=72 face="黑体"</font>
   <font color=#00ffff size=72>color=#00ffff</font>
   <font color=gray size=72>color=gray</font>
   
   Size：规定文本的尺寸大小。可能的值：从 1 到 7 的数字。浏览器默认值是 3
   12345678
   ```

   具体颜色分类及标记请参照：[各种颜色](http://blog.csdn.net/testcs_dn/article/details/45719357/)

### 4. [背景色](http://blog.csdn.net/testcs_dn/article/details/45766819): 
   Markdown本身不支持背景色设置，需要采用内置html的方式实现：借助 table, tr, td 等表格标签的 bgcolor 属性来实现背景色的功能。举例如下：

   ```
   <table><tr><td bgcolor=orange>背景色是：orange</td></tr></table>
   1
   ```

   效果如下： 

   背景色是：orange

   2015/12/19 16:04:07

### 5. 分割线
你可以在一行中用三个以上的星号、减号、底线来建立一个分隔线，行内不能有其他东西。你也可以在星号或是减号中间插入空格。下面每种写法都可以建立分隔线

### 6. 链接
链接文字都是用 [方括号] 来标记,在方块括号后面紧接着圆括号并插入网址链接即可:
可[参照](http://www.markdown.cn/#links) 
   `[This link](http://example.net/) has no title attribute.`

###　7. [代码块](http://blog.csdn.net/testcs_dn/article/details/44204303)：

   - 代码块：用2个以上TAB键起始的段落，会被认为是代码块（效果如下）：

     ```
     struct {
       int year;
       int month;
       int day;
      }bdate;
     12345
     ```
   - 如果在一个行内需要引用代码，只要用反引号`引起来就好(Esc健）
   - 代码块与语法高亮：在需要高亮的代码块的前一行及后一行使用三个反引号“`”，同时第一行反引号后面表面代码块所使用的语言

### 8. 插入互联网上图片 
   `![这里写图片描述](http://img3.douban.com/mpic/s1108264.jpg) `

### 9. 使用LaTex数学公式

   - 行内公式：使用两个”$”符号引用公式: `$公式$`
   - 行间公式：使用两对“$”符号引用公式：

     ```
     $公式$
     ```
     ------

## 参考
1. [markdown官方指导](http://www.markdown.cn/#overview) 
2. [CSDN：Markdown博客专栏](http://blog.csdn.net/column/details/markdown.html)