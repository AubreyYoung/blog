# Data Guard Physical and Logical Standby - Data Guard Broker Configuration
Health Check (文档 ID 1583191.1)

  

|

|

 **In this Document**  

| | [Main
Content](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=265873267359897&id=1583191.1&_afrWindowMode=0&_adf.ctrl-
state=ecpc8bcy2_387#MAINCONTENT)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=265873267359897&id=1583191.1&_afrWindowMode=0&_adf.ctrl-
state=ecpc8bcy2_387#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.1 to 11.2.0.4 [Release
10.2 to 11.2]  
Information in this document applies to any platform.  

## Main Content

*** Reviewed for Relevance 16-Jul-2015 ***

The following scripts can be used to monitor the configuration and health of
Data Guard Broker Physical and Logical Standby configuration.

The purpose of these scripts is to determine the current configuration and
state of both the Primary and Standby sites for the purpose of troubleshooting
a potential problem. The results from the perl scripts execution can be
uploaded to support to aid in diagnosing Data Guard Broker configuration
issues.

The scripts have been tested and confirmed to be working in 11.2.0.x
databases.

To check the health of the broker download the attached script and execute it
while your ORACLE_SID and ORACLE_HOME environment variables are set for the
Primary site you want to perform the collection against.

For Example

1\. Set the environment for the database that is operating as the Primary
Site.

[oracle@grid1vm1 dgscripts]$ . oraenv  
ORACLE_SID = [db112a1] ? db112a1  
The Oracle base remains unchanged with value /u01/app/oracle

  
[oracle@grid1vm1 dgscripts]$ set | grep ORACLE  
OLD_ORACLE_BASE=/u01/app/oracle  
ORACLE_BASE=/u01/app/oracle  
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1  
ORACLE_SID=db112a1

2\. Download the script from My Oracle Support and enable execute privileges
for it.

[oracle@grid1vm1 dgscripts]$ chmod g+x,u+x broker_config_v5.pl

3\. Execute the script to collect the Data Guard Broker Configuration
information

[oracle@grid1vm1 dgscripts]$ ./broker_config_v5.pl

  
Collecting the Broker Config for db112a - Primary database  
Collecting the Broker Config for db112a_stb - Physical standby database  
Finished Collecting the Data Guard Configuration, please upload
/tmp/broker_config.txt to Support

_This sample code is provided for educational purposes only and not supported
by Oracle Support Services. It has been tested internally, however, and works
as documented. We do not guarantee that it will work for you, so be sure to
test it in your environment before relying on it._

_Proofread this sample code before using it! Due to the differences in the way
text editors, e-mail packages and operating systems handle text formatting
(spaces, tabs and carriage returns), this sample code may not be in an
executable state when you first receive it. Check over the sample code to
ensure that errors of this type are corrected._

**Primary Site Script**

===============================================================================

#!/usr/bin/perl  
my $date_cmd = ('date > /tmp/broker_config.txt');  
my $echo_cmd = ('echo ============================ >>
/tmp/broker_config.txt');  
my $new_line_cmd = ('echo >> /tmp/broker_config.txt');  
my $hostname_cmd = ('hostname >> /tmp/broker_config.txt');  
  
system ($date_cmd);  
system ($echo_cmd);  
system ($new_line_cmd);  
system ($hostname_cmd);  
system ($echo_cmd);  
system ($new_line_cmd);  
  
my $dg_cmd = ('dgmgrl -echo / "show configuration verbose" >>
/tmp/broker_config.txt');  
system ($dg_cmd);  
system ($echo_cmd);  
$filename = '/tmp/broker_config.txt';  
if (-e $filename) {  
open (MYFILE, $filename);  
while ($line = <MYFILE>) {  
chomp;  
if ( $line =~ /\s*([a-zA-Z0-9_]+)\s* - Primary database/ || $line =~
/\s*([a-zA-Z0-9_]+) - Physical standby/ ) {  
$rdbmsname=$1;  
print "Collecting the Broker Config for $line";  
$dg_showdb_cmd = ('dgmgrl -echo / "show database verbose '.$rdbmsname.'" >>
/tmp/broker_config.txt');  
system ($dg_showdb_cmd);  
system ($echo_cmd);  
}  
}  
close (MYFILE);  
print "Finished Collecting the Data Guard Configuration, please upload
$filename to Support \n";  
}

  
**You can directly participate in the Discussion about this Note below. The
Frame is the interactive live Discussion - not a Screenshot ;-)**

[跳过导航](https://community.oracle.com/message/12128828#j-main)

  * [](http://www.oracle.com/)
  * [Oracle Community Directory](https://www.oracle.com/communities/index.html)
  * [Oracle Community FAQ](https://community.oracle.com/community/faq)

  * [ 0](https://community.oracle.com/inbox)[user12030720](https://community.oracle.com/message/12128828#)

[500 积分](https://community.oracle.com/message/12128828# "500 积分")

  *     * [Actions](https://community.oracle.com/actions)
    * [News](https://community.oracle.com/news)
    * [Inbox](https://community.oracle.com/inbox)
    * 

[My Oracle Support Community
(MOSC)](https://community.oracle.com/community/support)

[](https://twitter.com/myoraclesupport)

  * 搜索[ __](https://community.oracle.com/message/12128828#)

  * [ 创建](https://community.oracle.com/message/12128828#)

[Go Directly To ](https://community.oracle.com/message/12128828#)

[High Availability Data Guard
(MOSC)](https://community.oracle.com/community/support/oracle_database/high_availability_data_guard)中的[更多讨论](https://community.oracle.com/community/support/oracle_database/high_availability_data_guard/content?filterID=contentstatus\[published\]~objecttype~objecttype\[thread\])
[](https://community.oracle.com/message/12128828# "此位置位于何处？")

**1 回复** [由 Terencel-Oracle 于 2013-10-14 下午4:49
最新回复](https://community.oracle.com/message/12129758?tstart=0#12129758) [ 
](https://community.oracle.com/community/feeds/messages?thread=3405482 "RSS")

#  [Discussion : Data Guard Broker Configuration check
scripts](https://community.oracle.com/message/12128828#12128828)

此问题 **未回答** 。

[ ](https://community.oracle.com/people/Paulb-Oracle)

**[Paulb-Oracle](https://community.oracle.com/people/Paulb-Oracle)**
2013-10-14 下午4:49

Hi All  
The following note contains a perl script that will automate the collecting of
the state of your broker configuration. Handy information to keep for yourself
or to supply Oracle Support with should there be a problem with the broker or
the state of your configuration.  
  
Data Guard Physical and Logical Standby - Data Guard Broker Configuration
Health Check ([Doc ID
1583191.1](https://support.oracle.com/rs?type=doc&id=1583191.1))  
  
regards  
  
Paul  

[我有同样的问题](https://community.oracle.com/message/12128828# "我有同样的问题") 显示 0
喜欢[(0)](https://community.oracle.com/message/12128828# "显示 0 喜欢")

  * 2000 查看 
  * 标签： 
  * ** 回复 **

平均用户评级: 无评分 (0 评级)

平均用户评级

无评分

(0 评级)

您的评级：

评级 差（1，最高值为 5）评级 中下（2，最高值为 5）评级 中等（3，最高值为 5）评级 中上（4，最高值为 5）评级 优（5，最高值为 5）

  * ######  **[1.](https://community.oracle.com/message/12129758#12129758 "回复链接 #1") [Re: Discussion : Data Guard Broker Configuration check scripts](https://community.oracle.com/message/12129758#12129758) **

[ ](https://community.oracle.com/people/Terencel-Oracle)

**[Terencel-Oracle](https://community.oracle.com/people/Terencel-Oracle) **
2013-10-14 下午4:49  （[回复 Paulb-
Oracle](https://community.oracle.com/message/12128828#12128828 "转至消息")）

Hi Paul,  
Just try this perl script against a 12c broker confiuration, it works
beautifully!  
  
Regards,  
Terence  

    * [喜爱](https://community.oracle.com/message/12128828# "喜爱") 显示 0 喜欢[(0)](https://community.oracle.com/message/12128828# "显示 0 喜欢")
    * ** 回复 **
    * [操作 ](https://community.oracle.com/message/12128828#)

  * [  关注 ](https://community.oracle.com/message/12128828#)
  * [书签](https://community.oracle.com/message/12128828#)显示 0 个书签[0](https://community.oracle.com/message/12128828# "显示 0 个书签")

  * [喜爱](https://community.oracle.com/message/12128828# "喜爱")显示 0 喜欢[0](https://community.oracle.com/message/12128828# "显示 0 喜欢")

#### 操作

  * [  举报滥用 ](https://community.oracle.com/message-abuse!input.jspa?objectID=3405482&objectType=1)
  * [  转换为文档 ](https://community.oracle.com/message/12128828#)
  * [  查看 PDF 版本 ](https://community.oracle.com/thread/3405482.pdf)

[My Oracle Support Community
(MOSC)](https://community.oracle.com/community/support)[MOS Support
Portal](https://support.oracle.com/)[About](http://www.oracle.com/us/support/mos-
community-ds-197359.pdf)

Powered by

## [Oracle Technology Network](https://community.oracle.com/docs/DOC-890454)

  * [Oracle Communities Directory](https://www.oracle.com/communities/index.html)
  * [FAQ](https://community.oracle.com/community/faq)

  * [About Oracle](http://www.oracle.com/us/corporate/index.html)
  * [Oracle and Sun](http://www.oracle.com/us/sun/index.html)
  * [RSS Feeds](http://www.oracle.com/us/syndication/feeds/index.html)
  * [Subscribe](http://www.oracle.com/us/syndication/subscribe/index.html)
  * [Careers](http://www.oracle.com/us/corporate/careers/index.html)
  * [Contact Us](http://www.oracle.com/us/corporate/contact/index.html)
  * [Site Maps](http://www.oracle.com/us/sitemaps/index.html)
  * [Legal Notices](http://www.oracle.com/us/legal/index.html)
  * [Terms of Use](http://www.oracle.com/us/legal/terms/index.html)
  * [Your Privacy Rights](http://www.oracle.com/us/legal/privacy/index.html)
  * Cookie Preferences

## References

[NOTE:1581388.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1583191.1&id=1581388.1)
\- Data Guard Physical Standby - Configuration Health Check  
  
  
  
  


---
### ATTACHMENTS
[0f0a83fb6ad8a6377550b09af55a5a5f]: media/level8.png-3.webp
[level8.png-3.webp](media/level8.png-3.webp)
>hash: 0f0a83fb6ad8a6377550b09af55a5a5f  
>source-url: http://www.oracle.com/webfolder/application/jive_engage/gamification/global/levels/level8.png  
>file-name: level8.png.webp  

[68e63bae19f4c02384a1cf73945320ed]: media/Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-4.1)
[Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-4.1)](media/Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-4.1))
[7f8ec69e9260ecd88a0ba6cf55f55e68]: media/Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-5.1)
[Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-5.1)](media/Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-5.1))
[fe5e340ecb4fdb955192a2c2d7245848]: media/Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-6.1)
[Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-6.1)](media/Data_Guard_Physical_and_Logical_Standby_-_Data_Guard_Broker_Configuration_Health_Check_文档_ID_158319-6.1))

---
### TAGS
{dataguard}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-20 06:18:04  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=265873267359897  
>source-url: &  
>source-url: id=1583191.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=ecpc8bcy2_387  