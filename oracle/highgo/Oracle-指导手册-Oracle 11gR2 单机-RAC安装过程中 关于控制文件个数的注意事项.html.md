# Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项.html

You need to enable JavaScript to run this app.

![](https://47.100.29.40/highgo_admin/static/media/head.530901d0.png)

  杨光  |  退出

  * 知识库

    * ▢  新建文档
    * ▢  文档复查 (3)
    * ▢  文档查询
  * 待编区

文档详细

  知识库 文档详细

![noteattachment1][7f025a17697ee15eb3197c61326b203b]

067126604

Oracle-指导手册-Oracle 11gR2 单机/RAC安装过程中 关于控制文件个数的注意事项

目录

环境

文档用途

详细信息

相关文档

内部备注

附件

环境

系统平台：N/A

版本：N/A

文档用途

说明Oracle安装过程中生成不同个数控制文件的情况。

详细信息

## 环境：Rhel 6.5 + Oracle 11.2.0.4：

## 一、单机环境说明

 **1** **、dbca过程中如下选择“Use Database File Location from Template”或“Use Common
Location for ALL Database Files”**

 **![noteattachment2][02f21b2f1c2d150c0fe27a9bf35b161a]**

控制文件默认有两个，且在同一个目录下

![noteattachment3][3e290a092c19aa6343203ceaa56fb5d4]

但此时可以手动添加多个控制文件，也可以更改控制文件存放的目录：

![noteattachment4][12f4669a5f0b79b2d8f8b7b78647a877]

Redolog的大小和个数都可以调整

![noteattachment5][44ba883daf5687005903c8d988ea5466]

 **2** **、如果选择“Use Oracle-Managed Files”，默认如下配置的情况下：**

 **![noteattachment6][66a0c0a8537f84b7065a42dc607ea3dc]**

仅有1组控制文件和三组redolog：

![noteattachment7][56e366bccd98ef81700255986bd71ac4]

且控制文件的个数不可更改，但redolog的个数和大小可以调整：

![noteattachment8][1926f307f543b4904d3858dc2c19f31c]

默认的控制文件路径及格式如下：

![noteattachment9][452b89782ba9e54d6d44a557f7433791]

 **如果选择“Use Oracle-Managed Files”且需要添加多组控制文件，点击“Multiplex Redo Logs and
Control Files”需要修改如下：**

 **![noteattachment10][de3e17e33cbcd7674123ea7626747205]**

此时dbca后即可在“/u01/app/oracle/”和“/oradata/”两个目录下各生成一个控制文件。

## 二、RAC环境说明

 **1** **、dbca过程中如下选择“Use Database File Location from Template”或“Use Common
Location for All Database Files”**

 **![noteattachment11][a787565fc55e925c0c8dac56b678b8ed]**

控制文件默认有两个，且在同一个目录下；但此时无法手动添加或删除控制文件

![noteattachment12][f93d2ad9a1e3e40860ff349bdb938ac2]

Redolog的大小和个数都可以调整



 **如果选择“Use Oracle-Managed Files”，默认不修改“Multiplex Redo Logs and Control
Files”的情况下，默认仅在指定的+DATA下生成一个控制文件；**

 ** **

 **如果选择“Use Oracle-Managed Files”且修改“Multiplex Redo Logs and Control
Files”为如下的情况时，则分别在+DATA和+FRA下生成一个控制文件，共两个控制文件，如下：**

 **![noteattachment13][a68c445ddb657760bd5b65ada50809bb]**

 **![noteattachment14][61dba8198f4338db8c0b46ddb600b6cd]**

此时redolog大小和个数可调：

![noteattachment15][200d5bc0b622e1cd4a4ff2d212e0bf80]

Dbca后的redolog和controlfile路径和个数如下：

![noteattachment16][16d4c5bf4c94b02bf51c5454dea3af67]

![noteattachment17][3d3c7722173ae152664960c0cd88ae70]

## 三、DBCA后添加控制文件个数

参考如下文章How to Multiplex Control File In RAC Database (文档 ID 1642374.1)

  

相关文档

内部备注

附件

验证码：

  换一张

输入验证码：

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABm0lEQVRIicXXwXGCQBTG8b+7uZsSTAXRCiQVhA6SXLgmJZgO5BguSQnYgR0EK0hKiAUs5rBvGVlBBEG/GWccxf0JC2/fjna7HU3JEz0BQnlNgbF3yBbIgBRIVWR+m8YcHYPzRE+BBfDY+O/KWQELFZmsNZwnegm8tgT9xCoybyfBeaJvgTVwfybqsgECFZm//Q/VwCgy1lrGroYHQEt4JSxzOgRa4GIAMsdy934PiO5npiKTuTNeXAgtrJH5UBPg54IwwJ3CVqO+swEegPea78MhYPfcroFlzTGhwtbevlFXLOrgqeKw4PeC5on+Ap5qjh37BcTPFjtXL/K+DxSAmwY4k7kiT3SGrT7+FWqNwmHJ9DPPE/0MIEtcQPnMO6EOPnYJAT5r8M4osFXYzqEpVXhXFCBT2HbllJTwM1CAtA1cws9AAVK3OqW066tibOGZd0BXKjLhdZdFuWHiC6Cx6zxLzZ4UiaG6kI2KTLEu+AUkwD6fvaMydpESLI9I33hle3u1hr62VssPZtjtSNussHdvJQoNeyeXITZt/1po2U5WDlb1AAAAAElFTkSuQmCC)![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8yNy8xN+stbYgAAAAcdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3JrcyBDUzbovLKMAAABu0lEQVRIicWX223CQBBFD26AlOAOMJoCQgl0AFQQSoEOoAN3EPLPKHYHKSFUQD686/jFPkysXMkSQsMc1jt7Z3Z2v9/xSVVTYG2eDJh3Qm5AAeRALiJfvpwzF1hVM2APbLz/rq0zcBCRIhqsqgfgLRLY1VFE9kFgVX0BLsDiSahVCaxE5Lv5ZTIxFJPrYnIPgyeAtuCDYLOnU0BruGEAZo9N9X5OCG1qKSKFXfFg5TVURiT2xe4BEmMOrnNaikgG7AKgOxPrgm9UNU2o3MilhapmInLywHcicjLblnpyrkPAUB0HF7wJvdC31EFwFgCeO+CxUIBsdr1e/V3iVzcqFypUdQswAgpALLgFh7qRREGh71yhSjufo6BjwHa1uapmZs9zwo5aD3yLhBaN1+ur9oe5EqrJYQx0jrvaXSoSqnHFJwtd0S+kMfA8BFw2js87w4XUhX/4wLY7nfD4NWEt0w59r46Ys4hsbVUfHIEEQqFauQtasxIAYwbHwOTP6GiNpzXsqWrBdFOIba9A30BWxDX9YKjJXasFNiPoX8MHx9t/G+gferX5wZLqOhKrM9VQ93CWc96drKa4tP0As8vvCUvsIrEAAAAASUVORK5CYII=)

sentinel

&nbsp;

Redolog的大小和个数都可以调整

!["4.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134800_729.png%22)

 **2** **、如果选择“Use Oracle-Managed Files”，默认如下配置的情况下：**

**!["5.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134829_131.png%22)**

仅有1组控制文件和三组redolog：

!["6.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134842_717.png%22)

且控制文件的个数不可更改，但redolog的个数和大小可以调整：

!["7.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134851_687.png%22)

默认的控制文件路径及格式如下：

!["8.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134900_889.png%22)&nbsp;

 **如果选择“Use Oracle-Managed Files”且需要添加多组控制文件，点击“Multiplex Redo Logs and
Control Files”需要修改如下：**

**!["9.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134915_363.png%22)**

此时dbca后即可在“/u01/app/oracle/”和“/oradata/”两个目录下各生成一个控制文件。

##  二、RAC环境说明

 **1** **、dbca过程中如下选择“Use Database File Location from Template”或“Use Common
Location for All Database Files”**

**!["10.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134930_735.png%22)**

控制文件默认有两个，且在同一个目录下；但此时无法手动添加或删除控制文件

!["11.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103134944_537.png%22)

Redolog的大小和个数都可以调整

&nbsp;

 **如果选择“Use Oracle-Managed Files”，默认不修改“Multiplex Redo Logs and Control
Files”的情况下，默认仅在指定的+DATA下生成一个控制文件；**

 **& nbsp;**

 **如果选择“Use Oracle-Managed Files”且修改“Multiplex Redo Logs and Control
Files”为如下的情况时，则分别在+DATA和+FRA下生成一个控制文件，共两个控制文件，如下：**

**!["12.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103135000_94.png%22)**

**!["13.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103135015_109.png%22)**

此时redolog大小和个数可调：

!["14.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103135029_361.png%22)

Dbca后的redolog和controlfile路径和个数如下：

!["15.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103135044_592.png%22)

!["16.png"](https://47.100.29.40/highgo_admin/%22https://support.highgo.com/highgo_api/images/uedit/20180103135050_852.png%22)

## 三、DBCA后添加控制文件个数

参考如下文章How to Multiplex Control File In RAC Database (文档 ID 1642374.1)

  

" name="docDetail" type="hidden">


---
### ATTACHMENTS
[02f21b2f1c2d150c0fe27a9bf35b161a]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项.html)
>hash: 02f21b2f1c2d150c0fe27a9bf35b161a  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134708_874.png  

[12f4669a5f0b79b2d8f8b7b78647a877]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-2.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-2.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-2.html)
>hash: 12f4669a5f0b79b2d8f8b7b78647a877  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134743_687.png  

[16d4c5bf4c94b02bf51c5454dea3af67]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-3.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-3.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-3.html)
>hash: 16d4c5bf4c94b02bf51c5454dea3af67  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103135044_592.png  

[1926f307f543b4904d3858dc2c19f31c]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-4.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-4.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-4.html)
>hash: 1926f307f543b4904d3858dc2c19f31c  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134851_687.png  

[200d5bc0b622e1cd4a4ff2d212e0bf80]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-5.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-5.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-5.html)
>hash: 200d5bc0b622e1cd4a4ff2d212e0bf80  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103135029_361.png  

[3d3c7722173ae152664960c0cd88ae70]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-6.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-6.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-6.html)
>hash: 3d3c7722173ae152664960c0cd88ae70  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103135050_852.png  

[3e290a092c19aa6343203ceaa56fb5d4]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-7.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-7.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-7.html)
>hash: 3e290a092c19aa6343203ceaa56fb5d4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134721_522.png  

[44ba883daf5687005903c8d988ea5466]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-8.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-8.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-8.html)
>hash: 44ba883daf5687005903c8d988ea5466  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134800_729.png  

[452b89782ba9e54d6d44a557f7433791]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-9.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-9.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-9.html)
>hash: 452b89782ba9e54d6d44a557f7433791  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134900_889.png  

[56e366bccd98ef81700255986bd71ac4]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-10.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-10.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-10.html)
>hash: 56e366bccd98ef81700255986bd71ac4  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134842_717.png  

[61dba8198f4338db8c0b46ddb600b6cd]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-11.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-11.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-11.html)
>hash: 61dba8198f4338db8c0b46ddb600b6cd  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103135015_109.png  

[66a0c0a8537f84b7065a42dc607ea3dc]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-12.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-12.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-12.html)
>hash: 66a0c0a8537f84b7065a42dc607ea3dc  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134829_131.png  

[7f025a17697ee15eb3197c61326b203b]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-13.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-13.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-13.html)
>hash: 7f025a17697ee15eb3197c61326b203b  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\11947ec6e06f4dd6a765bcc48c4fc88d.png  

[a68c445ddb657760bd5b65ada50809bb]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-14.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-14.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-14.html)
>hash: a68c445ddb657760bd5b65ada50809bb  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103135000_94.png  

[a787565fc55e925c0c8dac56b678b8ed]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-15.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-15.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-15.html)
>hash: a787565fc55e925c0c8dac56b678b8ed  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134930_735.png  

[de3e17e33cbcd7674123ea7626747205]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-16.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-16.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-16.html)
>hash: de3e17e33cbcd7674123ea7626747205  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134915_363.png  

[f93d2ad9a1e3e40860ff349bdb938ac2]: media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-17.html
[Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-17.html](media/Oracle-指导手册-Oracle_11gR2_单机-RAC安装过程中_关于控制文件个数的注意事项-17.html)
>hash: f93d2ad9a1e3e40860ff349bdb938ac2  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项_files\20180103134944_537.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-09-25 03:29:34  
>Last Evernote Update Date: 2018-10-01 15:33:47  
>author: YangKwong  
>source: desktop.win  
>source-url: file://C:\Users\galaxy\Desktop\highgo\Oracle-指导手册-Oracle 11gR2 单机-RAC安装过程中 关于控制文件个数的注意事项.html  
>source-application: evernote.win32  