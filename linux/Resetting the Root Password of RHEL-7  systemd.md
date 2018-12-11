# Resetting the Root Password of RHEL-7 / systemd

$ Solution 已验证 - 已更新 2017年十一月3日12:40 - [English](https://access.redhat.com/solutions/918283)

## 环境

- Red Hat Enterprise Linux 7.

## 问题

- How to reset the root password of a RHEL-7 / systemd ?
- RHEL-7 ask for a root password even after booting in Single user mode.
- Not able to change the root password in single user mode

## 决议

1) Boot your system and wait until the GRUB2 menu appears.

2) In the boot loader menu, highlight any entry and press e.

3) Find the line beginning with linux. At the end of this line, append the following:

```
init=/bin/sh
or you can directly point to bash with:

init=/bin/bash
```

If you face a panic, instead of "ro" change to "rw" to sysroot as example below:

```

rw init=/sysroot/bin/sh
```

4) Press F10 or Ctrl+X to boot the system using the options you just edited.

Once the system boots, you will be presented with a shell prompt without having to enter any user name or password:

sh-4.2#

5) Load the installed SELinux policy:

```
sh-4.2# /usr/sbin/load_policy -i
```
6) Execute the following command to remount your root partition:

```
sh4.2# mount -o remount,rw /
```
7) Reset the root password:

```
sh4.2# passwd root
```
When prompted to, enter your new root password and confirm by pressing the Enter key. Enter the password for the second time to make sure you typed it correctly and confirm with Enter again. If both passwords match, a message informing you of a successful root password change will appear.

8) Remount the root partition again, this time as read-only:
```
sh4.2# mount -o remount,ro /
```
9) Reboot the system. From now on, you will be able to log in as the root user using the new password set up during this procedure. To reboot the system enter exit and exit again to leave the environment and reboot the system.

Or you can reboot immediately with:
```
# exec /sbin/init 6
```
In some cases it has been noticed that if the USB keyboard used or if the system is a virtual guest above described method did not work. In such case you need to follow the below mentioned steps

Note that the above mentioned steps may drop you to a prompt without access to a USB keyboard and do not work in a VM like KVM or VirtualBox. To reset the root password in these environments:

1) add rd.break instead of init=/bin/sh to the end of the line that starts with linux in Grub2:

2) when the system boots, run the following command to remount the root filesystem in read-write mode:
```
mount -o remount,rw /sysroot
```
3) then run:

```
chroot /sysroot
```
4) run:
```
passwd
```
5) instruct SELinux to relabel all files upon reboot (because the /etc/shadow file was changed outside of its regular SELinux context) -- run:
```
touch /.autorelabel
```
Note that this may take some time during the next boot.

6) type exit to leave the chroot environment.

7) type exit to log out, note this will also reboot the system.

The system will reboot, re-apply all SELinux labels, and present you with a regular login prompt.

Note: If the system is encrypted, the above method will not work. Please refer to the following article: [Resetting the Root Password of RHEL-7 for encrypted devices](https://access.redhat.com/solutions/1192343)

### Learn More

See [Changing and Resetting the Root Password](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/sec-Terminal_Menu_Editing_During_Boot.html#sec-Changing_and_Resetting_the_Root_Password) in the [Red Hat Enterprise Linux 7 System Administrator's Guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/).

产品（第） [Red Hat Enterprise Linux](https://access.redhat.com/taxonomy/products/red-hat-enterprise-linux) 元件 [grub](https://access.redhat.com/components/grub) [kernel](https://access.redhat.com/components/kernel) 类别 [Troubleshoot](https://access.redhat.com/category/troubleshoot) 标记 [bootloader](https://access.redhat.com/tags/bootloader) [rhel_7](https://access.redhat.com/taxonomy/tags/rhel7) [shells](https://access.redhat.com/tags/shells) [systemd](https://access.redhat.com/tags/systemd)

This solution is part of Red Hat’s fast-track publication program, providing a huge library of solutions that Red Hat engineers have created while supporting our customers. To give you the knowledge you need the instant it becomes available, these articles may be presented in a raw and unedited form.