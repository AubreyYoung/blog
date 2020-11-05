package com.inspur.pm4h2.amt.dao;

import com.sun.scenario.effect.impl.sw.java.JSWBlend_SRC_OUTPeer;
import com.sun.xml.internal.ws.api.model.wsdl.WSDLOutput;

import java.io.PrintStream;
import java.util.Scanner;

/**
 * @author yangguang02
 */

public class Demo03OutInput {
    public static void main(String[] args) {
        // println是print line的缩写，表示输出并换行
        System.out.print("A,");
        System.out.print("B,");
        System.out.print("C.");
        System.out.println();
        System.out.println("END");

        //格式化输出
        double d1 = 12900000;
        // 1.29E7
        System.out.println(d1);

        /*
        如果要把数据显示成我们期望的格式，就需要使用格式化输出的功能。格式化输出使用System.out.printf()，通过使用占位符%?
         printf()可以把后面的参数格式化成指定格式
         Java的格式化功能提供了多种占位符，可以把各种数据类型“格式化”成指定的字符串：
         占位符	说明
         %d	    格式化输出整数
         %x	    格式化输出十六进制整数
         %f	    格式化输出浮点数
         %e	    格式化输出科学计数法表示的浮点数
         %s	    格式化字符串
        */
        double d2 = 3.1415926;
        // 显示两位小数3.14
        System.out.printf("%.2f\n", d2);
        // 显示4位小数3.1416
        System.out.printf("%.4f\n", d2);

        int n = 12345000;
        // 注意，两个%占位符必须传入两个数
        System.out.printf("n=%d, hex=%08x", n, n);
        System.out.println();
        System.out.println();

        // 创建Scanner对象
        Scanner scanner = new Scanner(System.in);
        // 打印提示
        System.out.print("Input your name: ");
        // 读取一行输入并获取字符串
        String name = scanner.nextLine();
        // 打印提示
        System.out.print("Input your age: ");
        // 读取一行输入并获取整数
        int age = scanner.nextInt();
        // 格式化输出
        try (PrintStream printf = System.out.printf("Hi, %s, you are %d\n", name, age)) {
        }
    }
}