package com.inspur.pm4h2.amt.dao;

/**
 * @author yangguang02
 */

public class Demo04Control {
    public static void main(String[] args) {
        int n = 40;
        if (n >= 60) {
            System.out.println("及格了");
            System.out.println("恭喜你");
        }
        if (n < 60)
            System.out.println("不及格");
        System.out.println("END");
    }
}
