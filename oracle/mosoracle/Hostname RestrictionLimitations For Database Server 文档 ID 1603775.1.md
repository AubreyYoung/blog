# Hostname Restriction/Limitations For Database Server (文档 ID 1603775.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323340085815294&id=1603775.1&_adf.ctrl-
state=4n68ptb5n_338#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323340085815294&id=1603775.1&_adf.ctrl-
state=4n68ptb5n_338#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323340085815294&id=1603775.1&_adf.ctrl-
state=4n68ptb5n_338#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 11.2.0.3 and later  
Information in this document applies to any platform.  
Checked for relevance on 23-May-2016  

## Goal

Are there any Hostname restriction for database server on Linux / Windows and
HP-UX ?  

## Solution

All host names should conform to the RFC 952 standard, which permits
alphanumeric characters. Host names using underscores ("_") are not allowed.  
  
The Internet standards (Request for Comments) for protocols mandate that
component hostname labels may contain only the ASCII letters 'a' through 'z'
(in a case-insensitive manner), the digits '0' through '9', and the hyphen
(‐). The specification of hostnames in RFC 952, mandated that labels could not
start with a digit or with a hyphen, and must not end with a hyphen.  
  
This what Oracle recommends for host name for RAC, and it apply also on non-
RAC instances.

## References

  
[NOTE:1448787.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1603775.1&id=1448787.1)
\- Directory Service Control Center(DSCC) Does Not Support Special Characters
in Directory Server Instance Names  
  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 01:26:23  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=323340085815294  
>source-url: &  
>source-url: id=1603775.1  
>source-url: &  
>source-url: _adf.ctrl-state=4n68ptb5n_338  