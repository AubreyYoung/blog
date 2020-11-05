# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: WinMonitor
@ProjectName: python-demo
@Date: 2020/11/5 10:17
-------------------------------------------------
"""

# psutil Module For monitoring:
import psutil


# cpu information:
def cpu():
    # cpu = psutil.cpu_count(False) cpu kernel number The default logical cpu kernel number, False to view
    # the real cpu core number;
    # cpu usage per second, (1,True) usage per second of each core cpu;
    cpu_per = int(psutil.cpu_percent(1))
    # print(cpu_per)
    return cpu_per


# Monitor memory information:
def mem():
    # mem = psutil.virtual_memory() View memory information;
    mem_total = int(psutil.virtual_memory()[0] / 1024 / 1024)
    mem_used = int(psutil.virtual_memory()[3] / 1024 / 1024)
    mem_per = int(psutil.virtual_memory()[2])
    mem_info = {
        'mem_total': mem_total,
        'mem_used': mem_used,
        'mem_per': mem_per
    }
    return mem_info


# HD usage:
def disk():
    c_per = int(psutil.disk_usage('C:')[
                    3])  # View the usage information of the c drive: total space, used, remaining, occupancy ratio;
    d_per = int(psutil.disk_usage('d:')[3])
    e_per = int(psutil.disk_usage('e:')[3])
    # print(c_per,d_per,e_per,f_per)
    disk_info = {
        'c_per': c_per,
        'd_per': d_per,
        'e_per': e_per,
    }
    return disk_info


# :
def network():
    # network = psutil.net_io_counters() #View information about network traffic;
    network_sent = int(psutil.net_io_counters()[0] / 8 / 1024)  # kb accepted per second
    network_recv = int(psutil.net_io_counters()[1] / 8 / 1024)
    network_info = {
        'network_sent': network_sent,
        'network_recv': network_recv
    }
    return network_info


# function, call other functions;
def main():
    cpu_info = cpu()
    mem_info = mem()
    disk_info = disk()
    network_info = network()
    info = '''
		Monitoring information
		=========================
		 Cpu usage rate: : %s,
		=========================
		 Total memory size (MB): %s,
		 Memory usage size (MB): %s,
		 Memory usage : %s,
		=========================
		 C drive usage: %s,
		 D disk usage rate: %s,
		 E disk usage rate: %s,
		=========================
		 The amount of network traffic received (MB): %s,
		 The amount of network traffic sent (MB): %s
		 ''' % (
        cpu_info, mem_info['mem_total'], mem_info['mem_used'], mem_info['mem_per'], disk_info['c_per'],
        disk_info['d_per'],
        disk_info['e_per'], network_info['network_sent'], network_info['network_recv'])
    print(info)
    exit()

main()