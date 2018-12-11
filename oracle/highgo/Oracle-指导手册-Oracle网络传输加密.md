# Oracle-指导手册-Oracle网络传输加密

# 瀚高技术支持管理平台

## 测试环境：

11.2.0.4 winodows 单机

## 应用场景：

对oracle服务器和客户端之间的网络传输数据进行加密和完整性校验。

默认是使用明文方式传输数据，可以通过wireshark、sniffer等网络抓包工具抓取到传输的具体信息,对于敏感信息是很不安全的。

## 客户端存在两种模式：

1、通过oracle客户端软件连接数据库

2、通过jdbc驱动连接oracle数据库

### 1.通过oracle客户端的情况：

启用传输加密和校验的主要方法是通过服务器端和客户端的sqlnet.ora文件实现。

配置方法：

理论上需要在数据库server端和oracle客户端都修改sqlnet.ora文件，但因为client端默认传输加密级别是ACCEPTED，默认一致性校验级别是ACCEPTED，所以只需要在服务器端设置如下参数就可以打开传输加密和一致性校验功能，而不需要再对client端的sqlnet.ora进行设置（知识拓展部分介绍）。  
  
在oracle服务器端编辑sqlnet.ora文件，添加参数：  
SQLNET.ENCRYPTION_SERVER = REQUIRED ----加密级别  
SQLNET.ENCRYPTION_TYPES_SERVER = RC4_256 ----加密算法  
SQLNET.CRYPTO_CHECKSUM_SERVER = REQUIRED ---- 一致性能校验  
  
注意设置参数后对新建立的session起作用。

### 2.对于jdbc连接的情况：

需要写代码，不做验证，大体格式如下：  
For example:

DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());

Properties props = new Properties();

props.put("oracle.net.encryption_client", "accepted");

props.put("oracle.net.encryption_types_client", "RC4_128");

props.put("oracle.net.crypto_checksum_client", "REQUIRED"); //此行根据官方文档写，未作验证

props.put("oracle.net.crypto_checksum_types_client","MD5"); //此行根据官方文档格式写，未作验证

props.put("user", "XXX");

props.put("password", "YYY");

Connection conn =
DriverManager.getConnection("jdbc:oracle:thin:@myhost:1521:mySID", props);

### 3.对性能的影响：

既然要
加密和解密就势必会占用一定的性能资源，但影响不大，下图是一个测试结果，摘自http://www.orafaq.com/wiki/Network_Encryption

Algorithm

|

None

|

MD5

|

SHA-1  
  
---|---|---|---  
  
Time

|

%None

|

Time

|

%None

|

Time

|

%None  
  
None

|

79.6 s

| |

80.5 s

|

101%

|

82.4 s

|

104%  
  
DES

|

104.7 s

|

132%

|

107.1 s

|

135%

|

108.2 s

|

136%  
  
3DES168

|

151.8 s

|

191%

|

153.9 s

|

193%

|

155.6 s

|

196%  
  
AES128

|

88.8 s

|

112%

|

90.5 s

|

114%

|

92.1 s

|

116%  
  
AES256

|

91.8 s

|

115%

|

93.5 s

|

117%

|

94.2 s

|

118%  
  
RC4_128

|

81.6 s

|

103%

|

82.5 s

|

104%

|

85.0 s

|

107%  
  
RC4_256

|

81.7 s

|

103%

|

82.8 s

|

104%

|

85.0 s

|

107%  
  
# 参考文档：

http://docs.oracle.com/cd/B19306_01/network.102/b14268/asoconfg.htm#BBJBIECD  
http://docs.oracle.com/cd/B19306_01/network.102/b14268/asojbdc.htm#i1006209

http://www.orafaq.com/wiki/Network_Encryption

http://www.toadworld.com/platforms/oracle/w/wiki/1719.sqlnet-ora-parameters

http://blog.itpub.net/24052272/viewspace-2129175/

Measure

Measure



---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:39:14  
>Last Evernote Update Date: 2018-10-01 15:33:58  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/575845020ec1a6  
>source-application: WebClipper 7  