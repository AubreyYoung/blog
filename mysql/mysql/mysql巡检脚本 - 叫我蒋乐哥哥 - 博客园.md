# mysql巡检脚本 - 叫我蒋乐哥哥 - 博客园

  

# [叫我蒋乐哥哥](http://www.cnblogs.com/JiangLe/)

随笔 - 542, 文章 - 0, 评论 - 9, 引用 - 0

##  [mysql巡检脚本](http://www.cnblogs.com/JiangLe/p/6266106.html)

    
    
    #!/usr/bin/env python3.5
    
    import psutil
    import mysql.connector
    import argparse
    import json
    import datetime
    
    def get_cpu_info(verbose):
        cpu_info={}
        if verbose >0:
            print("[cpu]    start collect cpu info ...")
        data=psutil.cpu_times_percent(3)
        cpu_info['user']=data[0]
        cpu_info['system']=data[2]
        cpu_info['idle']=data[3]
        cpu_info['iowait']=data[4]
        cpu_info['hardirq']=data[5]
        cpu_info['softirq']=data[6]
        cpu_info['cpu_cores']=psutil.cpu_count()
        if verbose >0:
            print("{0}".format(json.dumps(cpu_info,ensure_ascii=False,indent=4)))
            print("[cpu]    collection compeleted ...")
        return cpu_info
    
    def get_mem_info(verbose):
        mem_info={}
        if verbose >0:
            print("[mem]    start collect mem info ...")
        data=psutil.virtual_memory()
        mem_info['total']=data[0]/1024/1024/1024
        mem_info['avariable']=data[1]/1024/1024/1024
        if verbose>0:
            print("{0}".format(json.dumps(mem_info,ensure_ascii=False,indent=4)))
            print("[mem]    collection compeletd ...")
        return mem_info
    
    def get_disk_info(verbose):
        disk_info={}
        if verbose >0:
            print("[disk]    start collect disk info ...")
        partitions=psutil.disk_partitions()
        partitions=[(partition[1],partition[2])for partition in partitions if partition[2]!='iso9660']
        disk_info={}
        for partition in partitions:
            disk_info[partition[0]]={}
            disk_info[partition[0]]['fstype']=partition[1]
        for mount_point in disk_info.keys():
            data=psutil.disk_usage(mount_point)
            disk_info[mount_point]['total']=data[0]/1024/1024/1024
            disk_info[mount_point]['used_percent']=data[3]
        if verbose >0:
            print("{0}".format(json.dumps(disk_info,ensure_ascii=False,indent=4)))
            print("[disk]    collection compeleted ....")
        return disk_info
    
    def get_mysql_info(cnx_args,status_list):
        config={
            'user':cnx_args.user,
            'password':cnx_args.password,
            'host':cnx_args.host,
            'port':cnx_args.port}
        cnx=None
        cursor=None
        mysql_info={}
        try:
            cnx=mysql.connector.connect(**config)
            cursor=cnx.cursor(prepared=True)
            for index in range(len(status_list)):
                status_list[index].get_status(cursor)
                status=status_list[index]
                mysql_info[status.name]=status.value
            mysql_info['port']=config['port']
        except mysql.connector.Error as err:
            print(err)
        finally:
            if cursor != None:
                cursor.close()
            if cnx != None:
                cnx.close()
        return mysql_info
    
    class Status(object):
        def __init__(self,name):
            self.name=name
            self._value=None
    
    
        def get_status(self,cursor):
            stmt="show global status like '{0}';".format(self.name)
            cursor.execute(stmt)
            value=cursor.fetchone()[1].decode('utf8')
            self._value=int(value)
    
    
        @property
        def value(self):
            if self._value==None:
                raise Exception("cant get value befor execute the get_status function")
            else:
                return self._value
    
    IntStatus=Status
    
    
    class diskResource(object):
        def __init__(self,mount_point,status):
            self.mount_point=mount_point
            self.status=status
    
        def __str__(self):
            result='''                <div class="stage-list">
                        <div class="stage-title"><span>{0}</span></div>
                        <div class="detail">
                            <p class="detail-list">
                                <span class="detail-title">区分格式</span>
                                <span class="detail-describe">{1}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">总空间大小</span>
                                <span class="detail-describe">{2:8.2f}G</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">空闲空间(%)</span>
                                <span class="detail-describe">{3:8.2f}</span>
                            </p>
                            <p class="detail-list">
                                
                            </p>
                        </div>
                    </div>\n'''.format(self.mount_point,self.status['fstype'],self.status['total'],self.status['used_percent'])
            return result
    
    class diskResources(object):
        def __init__(self,status):
            self.disks=[]
            for mount_point in status.keys():
                self.disks.append(diskResource(mount_point,status[mount_point]))
    
        def __str__(self):
            result='''        <div class="list-item">
                <div class="category">
                    <span>磁盘</span>
                </div>
                <div class="second-stage">\n'''
            for index in range(len(self.disks)):
                result=result+self.disks[index].__str__()
            result=result+'''            </div>
            </div>\n'''
            return result
    
    class cpuResources(object):
        def __init__(self,status):
            self.status=status
        def __str__(self):
            result='''        <div class="list-item">
                <div class="category">
                    <span>CPU</span>
                </div>
                <div class="second-stage">
                    <div class="stage-list">
                        <div class="stage-title"><span>global</span></div>
                        <div class="detail">
                            <p class="detail-list">
                                <span class="detail-title">用户空间使用（%）</span>
                                <span class="detail-describe">{0}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">内核空间使用（%）</span>
                                <span class="detail-describe">{1}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">空闲（%）</span>
                                <span class="detail-describe">{2}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">硬中断（%）</span>
                                <span class="detail-describe">{3}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">软中断（%）</span>
                                <span class="detail-describe">{4}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">io等待（%）</span>
                                <span class="detail-describe">{5}</span>
                            </p>
                            <p class="detail-list">
    
                            </p>
                        </div>
                    </div>
                </div>
            </div>\n'''.format(self.status['user'],self.status['system'],self.status['idle'],self.status['hardirq'],self.status['softirq'],self.status['iowait'])
            return result
    
    class memResources(object):
        def __init__(self,status):
            self.status=status
    
        def __str__(self):
            result='''        <div class="list-item">
                <div class="category">
                    <span>MEM</span>
                </div>
                <div class="second-stage">
                    <div class="stage-list">
                        <div class="stage-title"><span>global</span></div>
                        <div class="detail">
                            <p class="detail-list">
                                <span class="detail-title">总大小</span>
                                <span class="detail-describe">{0:8.2f}G</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">空闲大小</span>
                                <span class="detail-describe">{1:8.2f}G</span>
                            </p>
                            
                            <p class="detail-list">
                                
                            </p>
                        </div>
                    </div>
                </div>
            </div>'''.format(self.status['total'],self.status['avariable'])
            return result
    
    
    class mysqlResources(object):
        def __init__(self,status):
            self.status=status
        def __str__(self):
            result='''        <div class="list-item">
                <div class="category">
                    <span>MYSQL</span>
                </div>
                <div class="second-stage">
                    <div class="stage-list">
                        <div class="stage-title"><span>{0}</span></div>
                        <div class="detail">
                            <p class="detail-list">
                                <span class="detail-title">innodb_log_wait</span>
                                <span class="detail-describe">{1}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">binlog_cache_use</span>
                                <span class="detail-describe">{2}</span>
                            </p>
                            <p class="detail-list">
                                <span class="detail-title">create_temp_disk_table</span>
                                <span class="detail-describe">{3}</span>
                            </p>
                                                    <p class="detail-list">
                                                            <span class="detail-title">Slow_querys</span>
                                                            <span class="detail-describe">{4}</span>
                                                    </p>
    
                            <p class="detail-list">
                                
                            </p>
                        </div>
                    </div>
                </div>
            </div>'''.format(self.status['port'],self.status['Innodb_log_waits'],self.status['Binlog_cache_use'],
                              self.status['Created_tmp_disk_tables'],self.status['Slow_queries'])
    
            return result
    
    class hostResources(object):
        def __init__(self,cpu_info,mem_info,disk_info,mysql_info,report_title='MySQL巡检报告'):
            self.cpu=cpuResources(cpu_info)
            self.mem=memResources(mem_info)
            self.disk=diskResources(disk_info)
            self.mysql=mysqlResources(mysql_info)
            self.report_title=report_title
        def __str__(self):
            result='''<!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>巡检报告</title>
    <style>
    *{
        margin: 0;
        padding: 0;
    }
        .content{
            width:1000px;
            height: auto;
            margin: 30px auto;
            border-bottom:1px solid #b2b2b2;
        }
        .list-item{
            border:1px solid #b2b2b2;
            border-bottom: none;
            transition: all .35s;
            overflow: hidden;
            display: flex;
        }
        .list-item:empty{
            display: none;
        }
        .top-title{
            line-height: 32px;
            font-size: 16px;
            color: #333;
            text-indent: 10px;
            font-weight: 600;
        }
        .category{
            width:97px;
            height: auto;
            border-right: 1px solid #b2b2b2;
            float: left;
            text-align: center;
            position: relative;
        }
        .stage-title>span,
        .category>span{
            display: block;
            height: 20px;
            width:100%;
            text-align: center;
            line-height: 20px;
            position: absolute;
            top: 50%;
            margin-top: -10px;left: 0;
        }
        .second-stage{
            width:900px;
            float: left;
        }
        .stage-list{
            border-bottom: 1px solid #b2b2b2;
            display: flex;
        }
        .stage-list:last-child{
            border-bottom: 0;
        }
        .stage-title{
            width:99px;
            border-right: 1px solid #b2b2b2;
            position: relative;
        }
        .detail{
            flex: 1;
        }
        .detail-list{
            border-bottom: 1px solid #b2b2b2;
            height: 40px;
            display: flex;
            transition: all .35s;
        }
        .detail-title{
            padding: 10px;
            height: 20px;
            line-height: 20px;
            border-right: 1px solid #b2b2b2;
            width:200px;
        }
        .detail-describe{
            flex: 1;
            padding: 10px;line-height: 20px;
        }
        .detail-list:last-child{
            border-bottom: 0;
        }
        .list-item:hover{
            background-color: #eee;
        }
        .detail-list:hover{
            background-color: #d1d1d1;
        }
    </style>
    </head>
    <body>
        <div class="content">
                    <div class="list-item">
                            <p class="top-title">report_title</p>
                    </div>\n'''
    
            result=result.replace('report_title',self.report_title)
            result=result+self.cpu.__str__()
            result=result+self.mem.__str__()
            result=result+self.disk.__str__()
            result=result+self.mysql.__str__()
            result=result+'''    </div>
    </body>
    </html>'''
            return result
    
    
    if __name__=="__main__":
        parser=argparse.ArgumentParser()
        parser.add_argument('--verbose',type=int,default=1,help='verbose for output')
        parser.add_argument('--user',default='chkuser',help='user name for connect to mysql')
        parser.add_argument('--password',default='123456',help='user password for connect to mysql')
        parser.add_argument('--host',default='127.0.0.1',help='mysql host ip')
        parser.add_argument('--port',default=3306,type=int,help='mysql port')
        parser.add_argument('--int-status',default=('Com_select,Com_insert,Com_update,Com_delete,Innodb_log_waits,'
                                                    'Binlog_cache_disk_use,Binlog_cache_use,Created_tmp_disk_tables,'
                                                    'Slow_queries')
                           ,help='mysql status its value like int')
        parser.add_argument('--report-title',default='MySQL巡检报告',help='report title')
        parser.add_argument('--output-dir',default='/tmp/',help='default report file output path')
        args=parser.parse_args()
        cpu_info=get_cpu_info(args.verbose)
        mem_info=get_mem_info(args.verbose)
        disk_info=get_disk_info(args.verbose)
        status_list=[ IntStatus(name=item) for item in args.int_status.split(',')]
        mysql_info=get_mysql_info(args,status_list)
        #dr=diskResources(disk_info)
        #cr=cpuResources(cpu_info)
        #mr=memResources(mem_info)
        #msr=mysqlResources(mysql_info)
        hr=hostResources(cpu_info,mem_info,disk_info,mysql_info,args.report_title)
        now=str(datetime.datetime.now()).replace(' ','^')
        if args.output_dir.endswith('/') != True:
            args.output_dir=args.output_dir+'/'
        filename=args.output_dir+'mysql_inspection_{0}.html'.format(now)
        with open(filename,'w') as output:
            output.write(hr.__str__())
        print('[report]    the report been saved to {0}    ok.... ....'.format(filename))

分类: [Python](http://www.cnblogs.com/JiangLe/category/658292.html)

好文要顶 关注我 收藏该文

[](http://home.cnblogs.com/u/JiangLe/)

[叫我蒋乐哥哥](http://home.cnblogs.com/u/JiangLe/)  
[关注 - 2](http://home.cnblogs.com/u/JiangLe/followees)  
[粉丝 - 6](http://home.cnblogs.com/u/JiangLe/followers)

+加关注

0

0

[« ](http://www.cnblogs.com/JiangLe/p/6214495.html) 上一篇：[MySQL
binlog_rows_query_log_events](http://www.cnblogs.com/JiangLe/p/6214495.html
"发布于2016-12-23 13:37")  
[» ](http://www.cnblogs.com/JiangLe/p/6287418.html)
下一篇：[innodb系统表空间维护](http://www.cnblogs.com/JiangLe/p/6287418.html
"发布于2017-01-15 17:11")  

posted on 2017-01-09 17:51 [叫我蒋乐哥哥](http://www.cnblogs.com/JiangLe/) 阅读(166)
评论(0) [编辑](https://i.cnblogs.com/EditPosts.aspx?postid=6266106)
[收藏](http://www.cnblogs.com/JiangLe/p/6266106.html#)

刷新评论[刷新页面](http://www.cnblogs.com/JiangLe/p/6266106.html#)[返回顶部](http://www.cnblogs.com/JiangLe/p/6266106.html#top)

注册用户登录后才能发表评论，请 登录 或 注册，[访问](http://www.cnblogs.com/)网站首页。

[【推荐】50万行VC++源码: 大型组态工控、电力仿真CAD与GIS源码库](http://www.ucancode.com/index.htm)  
[【推荐】报表开发有捷径：快速设计轻松集成，数据可视化和交互](http://www.gcpowertools.com.cn/products/activereports_overview.htm?utm_source=cnblogs&utm_medium=blogpage&utm_term=bottom&utm_content=AR&utm_campaign=community)  

### 导航

  * [博客园](http://www.cnblogs.com/)
  * [首页](http://www.cnblogs.com/JiangLe/)
  *   * [联系](https://msg.cnblogs.com/send/%E5%8F%AB%E6%88%91%E8%92%8B%E4%B9%90%E5%93%A5%E5%93%A5)
  *   * [管理](https://i.cnblogs.com/)

| <| 2017年10月| >  
---|---|---  
日| 一| 二| 三| 四| 五| 六  
24| 25| 26| 27| 28| 29| 30  
1| 2| 3| 4| 5| 6| 7  
8| 9| 10| 11| 12| 13| 14  
15| 16| 17| 18| 19| 20| 21  
22| 23| 24| 25| 26| 27| 28  
29| 30| 31| 1| 2| 3| 4  
  
### 公告

昵称：[叫我蒋乐哥哥](http://home.cnblogs.com/u/JiangLe/)  
园龄：[3年3个月](http://home.cnblogs.com/u/JiangLe/ "入园时间：2014-06-18")  
粉丝：[6](http://home.cnblogs.com/u/JiangLe/followers/)  
关注：[2](http://home.cnblogs.com/u/JiangLe/followees/)

+加关注

### 搜索

### 常用链接

  * [我的随笔](http://www.cnblogs.com/JiangLe/p/ "我的博客的随笔列表")
  * [我的评论](http://www.cnblogs.com/JiangLe/MyComments.html "我发表过的评论列表")
  * [我的参与](http://www.cnblogs.com/JiangLe/OtherPosts.html "我评论过的随笔列表")
  * [最新评论](http://www.cnblogs.com/JiangLe/RecentComments.html "我的博客的评论列表")
  * [我的标签](http://www.cnblogs.com/JiangLe/tag/ "我的博客的标签列表")

### 随笔分类

  * [C++(7)](http://www.cnblogs.com/JiangLe/category/867225.html)
  * [Data Mining(3)](http://www.cnblogs.com/JiangLe/category/617989.html)
  * [django(13)](http://www.cnblogs.com/JiangLe/category/942220.html)
  * [docker(1)](http://www.cnblogs.com/JiangLe/category/1010875.html)
  * [JavaScript](http://www.cnblogs.com/JiangLe/category/854743.html)
  * [Linux(47)](http://www.cnblogs.com/JiangLe/category/619585.html)
  * [MYSQL(191)](http://www.cnblogs.com/JiangLe/category/616301.html)
  * [Permon(1)](http://www.cnblogs.com/JiangLe/category/705881.html)
  * [Python(61)](http://www.cnblogs.com/JiangLe/category/658292.html)
  * [redis(11)](http://www.cnblogs.com/JiangLe/category/817439.html)
  * [SQL(1)](http://www.cnblogs.com/JiangLe/category/684984.html)
  * [SQL Server(129)](http://www.cnblogs.com/JiangLe/category/615390.html)
  * [Windows(5)](http://www.cnblogs.com/JiangLe/category/620292.html)
  * [Windows Phone(3)](http://www.cnblogs.com/JiangLe/category/645539.html)
  * [xtrabackup(3)](http://www.cnblogs.com/JiangLe/category/738697.html)
  * [算法导论--python(1)](http://www.cnblogs.com/JiangLe/category/894202.html)

### 随笔档案

  * [2017年9月 (11)](http://www.cnblogs.com/JiangLe/archive/2017/09.html)
  * [2017年8月 (8)](http://www.cnblogs.com/JiangLe/archive/2017/08.html)
  * [2017年7月 (11)](http://www.cnblogs.com/JiangLe/archive/2017/07.html)
  * [2017年6月 (15)](http://www.cnblogs.com/JiangLe/archive/2017/06.html)
  * [2017年5月 (17)](http://www.cnblogs.com/JiangLe/archive/2017/05.html)
  * [2017年4月 (7)](http://www.cnblogs.com/JiangLe/archive/2017/04.html)
  * [2017年3月 (11)](http://www.cnblogs.com/JiangLe/archive/2017/03.html)
  * [2017年2月 (7)](http://www.cnblogs.com/JiangLe/archive/2017/02.html)
  * [2017年1月 (3)](http://www.cnblogs.com/JiangLe/archive/2017/01.html)
  * [2016年12月 (7)](http://www.cnblogs.com/JiangLe/archive/2016/12.html)
  * [2016年11月 (10)](http://www.cnblogs.com/JiangLe/archive/2016/11.html)
  * [2016年10月 (3)](http://www.cnblogs.com/JiangLe/archive/2016/10.html)
  * [2016年9月 (9)](http://www.cnblogs.com/JiangLe/archive/2016/09.html)
  * [2016年8月 (33)](http://www.cnblogs.com/JiangLe/archive/2016/08.html)
  * [2016年7月 (6)](http://www.cnblogs.com/JiangLe/archive/2016/07.html)
  * [2016年6月 (9)](http://www.cnblogs.com/JiangLe/archive/2016/06.html)
  * [2016年5月 (7)](http://www.cnblogs.com/JiangLe/archive/2016/05.html)
  * [2016年4月 (19)](http://www.cnblogs.com/JiangLe/archive/2016/04.html)
  * [2016年3月 (11)](http://www.cnblogs.com/JiangLe/archive/2016/03.html)
  * [2016年2月 (2)](http://www.cnblogs.com/JiangLe/archive/2016/02.html)
  * [2016年1月 (18)](http://www.cnblogs.com/JiangLe/archive/2016/01.html)
  * [2015年12月 (9)](http://www.cnblogs.com/JiangLe/archive/2015/12.html)
  * [2015年11月 (16)](http://www.cnblogs.com/JiangLe/archive/2015/11.html)
  * [2015年10月 (14)](http://www.cnblogs.com/JiangLe/archive/2015/10.html)
  * [2015年9月 (8)](http://www.cnblogs.com/JiangLe/archive/2015/09.html)
  * [2015年8月 (2)](http://www.cnblogs.com/JiangLe/archive/2015/08.html)
  * [2015年7月 (10)](http://www.cnblogs.com/JiangLe/archive/2015/07.html)
  * [2015年6月 (17)](http://www.cnblogs.com/JiangLe/archive/2015/06.html)
  * [2015年5月 (7)](http://www.cnblogs.com/JiangLe/archive/2015/05.html)
  * [2015年4月 (17)](http://www.cnblogs.com/JiangLe/archive/2015/04.html)
  * [2015年3月 (10)](http://www.cnblogs.com/JiangLe/archive/2015/03.html)
  * [2015年2月 (9)](http://www.cnblogs.com/JiangLe/archive/2015/02.html)
  * [2015年1月 (5)](http://www.cnblogs.com/JiangLe/archive/2015/01.html)
  * [2014年12月 (16)](http://www.cnblogs.com/JiangLe/archive/2014/12.html)
  * [2014年11月 (15)](http://www.cnblogs.com/JiangLe/archive/2014/11.html)
  * [2014年10月 (140)](http://www.cnblogs.com/JiangLe/archive/2014/10.html)
  * [2014年9月 (23)](http://www.cnblogs.com/JiangLe/archive/2014/09.html)

### 最新评论

  * [1\. Re:MySQL innodb_autoinc_lock_mode 详解](http://www.cnblogs.com/JiangLe/p/6362770.html#3717601)
  * @小小小蘑菇大兄弟牛逼呀！ 之前迷信官方文档： help alter table;Name: 'ALTER TABLE'Description:Syntax:ALTER TABLE tbl_na......
  * \--叫我蒋乐哥哥
  * [2\. Re:MySQL innodb_autoinc_lock_mode 详解](http://www.cnblogs.com/JiangLe/p/6362770.html#3716150)
  * 弱弱的补充，哈哈。不要没事去更新一个auto_increment 列的值,除非在更新后重置Auto_increment值（Alter Table TableName Auto_increment = ......
  * \--小小小蘑菇
  * [3\. Re:SQL Server 创建索引的 5 种方法](http://www.cnblogs.com/JiangLe/p/4007091.html#3674714)
  * 可以的
  * \--我不清楚是谁
  * [4\. Re:MySQL-group-replication 配置](http://www.cnblogs.com/JiangLe/p/6392719.html#3669235)
  * 果然是这样( ⊙o⊙ )，谢谢博主。
  * \--无所谓技术
  * [5\. Re:MySQL-group-replication 配置](http://www.cnblogs.com/JiangLe/p/6392719.html#3668808)
  * @无所谓技术./bin/mysqld --defaults-file=/usr/local/mysql/grdata/config/s1.cnf --debug & 你要加个 ‘&’ 号 这样linu......
  * \--叫我蒋乐哥哥

### 阅读排行榜

  * [1\. SQL Server 创建索引的 5 种方法(22681)](http://www.cnblogs.com/JiangLe/p/4007091.html)
  * [2\. secure_file_priv 配置项对数据导入导出的影响(10660)](http://www.cnblogs.com/JiangLe/p/6042976.html)
  * [3\. SQL Server 无法启动的 4 种原因(9129)](http://www.cnblogs.com/JiangLe/p/4000497.html)
  * [4\. mysql sql_mode 之 NO_ENGINE_SUBSTITUTION(5678)](http://www.cnblogs.com/JiangLe/p/5621856.html)
  * [5\. MySQL--mysqldump的权限说明(5517)](http://www.cnblogs.com/JiangLe/p/5682795.html)

### 评论排行榜

  * [1\. MySQL-group-replication 配置(3)](http://www.cnblogs.com/JiangLe/p/6392719.html)
  * [2\. MySQL innodb_autoinc_lock_mode 详解(2)](http://www.cnblogs.com/JiangLe/p/6362770.html)
  * [3\. SQL Server 创建索引的 5 种方法(2)](http://www.cnblogs.com/JiangLe/p/4007091.html)
  * [4\. SQL Server dbcc checkdb 修复(1)](http://www.cnblogs.com/JiangLe/p/4003461.html)
  * [5\. Linux--本地yum库(1)](http://www.cnblogs.com/JiangLe/p/5015218.html)

### 推荐排行榜

  * [1\. MySQL innodb_autoinc_lock_mode 详解(3)](http://www.cnblogs.com/JiangLe/p/6362770.html)
  * [2\. MySQL-group-replication 配置(2)](http://www.cnblogs.com/JiangLe/p/6392719.html)
  * [3\. SQL Server 创建索引的 5 种方法(1)](http://www.cnblogs.com/JiangLe/p/4007091.html)
  * [4\. mysql explicit_defaults_for_timestamp 变量的作用(1)](http://www.cnblogs.com/JiangLe/p/6956865.html)
  * [5\. MySQL之desc查看表结构的详细信息(1)](http://www.cnblogs.com/JiangLe/p/6604012.html)

Powered by:  
[博客园](http://www.cnblogs.com/)  
Copyright © 叫我蒋乐哥哥

  


---
### ATTACHMENTS
[24de3321437f4bfd69e684e353f2b765]: media/wechat-3.png
[wechat-3.png](media/wechat-3.png)
>hash: 24de3321437f4bfd69e684e353f2b765  
>source-url: http://common.cnblogs.com/images/wechat.png  
>file-name: wechat.png  

[373280fde0d7ed152a0f7f06df3f3ad4]: media/sample_face.gif
[sample_face.gif](media/sample_face.gif)
>hash: 373280fde0d7ed152a0f7f06df3f3ad4  
>source-url: http://pic.cnblogs.com/face/sample_face.gif  
>file-name: sample_face.gif  

[51e409b11aa51c150090697429a953ed]: media/copycode-4.gif
[copycode-4.gif](media/copycode-4.gif)
>hash: 51e409b11aa51c150090697429a953ed  
>source-url: http://common.cnblogs.com/images/copycode.gif  
>file-name: copycode.gif  

[c5fd93bfefed3def29aa5f58f5173174]: media/icon_weibo_24-3.png
[icon_weibo_24-3.png](media/icon_weibo_24-3.png)
>hash: c5fd93bfefed3def29aa5f58f5173174  
>source-url: http://common.cnblogs.com/images/icon_weibo_24.png  
>file-name: icon_weibo_24.png  

---
### NOTE ATTRIBUTES
>Created Date: 2017-10-02 00:25:20  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: http://www.cnblogs.com/JiangLe/p/6266106.html  