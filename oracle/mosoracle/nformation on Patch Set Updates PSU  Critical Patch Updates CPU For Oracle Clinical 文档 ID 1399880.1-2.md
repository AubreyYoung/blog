# nformation on Patch Set Updates (PSU) / Critical Patch Updates (CPU) For
Oracle Clinical (文档 ID 1399880.1)

|

|

**In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#FIX)  
---|---  
| [**What is a Patch Set Update (PSU)
?**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#aref_section21)  
---|---  
| [**What is the Difference between a Patch Set Update (PSU) and a Critical
Patch Update (CPU)
?**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#aref_section22)  
---|---  
| [**Should we apply a Critical Patch Update (CPU) or a Patch Set Update (PSU)
to an Oracle Clinical instance
?**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#aref_section23)  
---|---  
| [**Can customers apply untested database patches or PSU patchsets
?**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#aref_section24)  
---|---  
| [**Additional
Information**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#aref_section25)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497&id=1399880.1&_afrWindowMode=0&_adf.ctrl-
state=3p4n9v1rv_4#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Clinical - Version 4.6.2 and later  
Information in this document applies to any platform.  

## Goal

  
The purpose of this Note is to provide information on :

  * Patch Set Updates (PSU)
  * Critical Patch Updates (CPU)

and what should be applied to an Oracle Clinical instance.

  
  

## Solution

### **What is a Patch Set Update (PSU) ?**

Patch Set Updates (PSUs) are proactive cumulative patches containing
recommended bug fixes that are released on a regular and predictable schedule.
PSUs are on the same quarterly schedule as the Critical Patch Updates (CPU).

i.  
Patch Set Updates (PSUs) offer the following features and benefits:  
\- Low-Risk, High-Value Content  
\- One Integrated, Well Tested Patch  
\- Baseline Version for Easier Tracking  
  
  
ii.  
Patch Set Updates (PSUs) also include Critical Patch Update (CPU) fixes.  
  
  
iii.  
See the following notes for further information :  
  
[Document
854428.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1399880.1&id=854428.1)
\- Patch Set Updates for Oracle Products  
  
[Document
783141.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1399880.1&id=783141.1)
\- Reference List of Critical Patch Update Availability(CPU) and Patch Set
Update (PSU) Documents For Oracle Database and Fusion Middleware Product  
  
  

### **What is the Difference between a Patch Set Update (PSU) and a Critical
Patch Update (CPU) ?**

A Patch Set Update (PSU) consists of high value low risk fixes + CPU fixes.  
A Critical Patch Updates (CPU) is a patch or patchset consisting of just
security fixes.  
  
  

### **Should we apply a Critical Patch Update (CPU) or a Patch Set Update
(PSU) to an Oracle Clinical instance ?**

The short answer is to apply what Development certify on. Every quarterly
Oracle Clinical Patchset is certified with a Critical Patch Update eg the
4.6.4 patchset is certified with the October 2011 Critical Patch Update.
Therefore when applying 4.6.4 you should also apply the patches mentioned in
the October 2011 Critical Patch Update note.  
  
Having said this we have a adopted a PSU approach at the database level in our
Critical Patch Updates for the OC 4.6.2 release. Therefore our Critical Patch
Update Notes are actually a hybrid for the 4.6.2 release where we apply CPU
patches to the Application Tier and a PSU patchset at the database level.

****

### **Can customers apply untested database patches or PSU patchsets ?**

Development have provided the following guidance regarding untested Database
Patches :  
Customers can apply other database patches that we have not tested, as long as
there is no conflict. If there is a conflict, it will tell them when they
apply. If there is a conflict, they can request a merge patch to resolve the
conflict. To patch XML Developers Kit, which is included with the database,
you must check with support. Only apply database patches to XML Developers Kit
that have been certified by development.

### **Additional Information**

The following note provides information on the different types of Proactive
Patches that are available (SPU / PSU / Bundle Patches) :

[Document
1962125.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1399880.1&id=1962125.1)
\- Oracle Database - Overview of Database Patch Delivery Methods


---
### NOTE ATTRIBUTES
>Created Date: 2018-07-02 08:20:42  
>Last Evernote Update Date: 2018-10-01 15:55:04  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=181993521474497  
>source-url: &  
>source-url: id=1399880.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=3p4n9v1rv_4  
>source-application: WebClipper 7  