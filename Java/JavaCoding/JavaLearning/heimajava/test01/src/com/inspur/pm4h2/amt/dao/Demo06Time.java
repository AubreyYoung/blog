package com.inspur.pm4h2.amt.dao;

import java.util.Date;

/**
 * @author yangguang02
 * @PackageName com.inspur.pm4h2.amt.dao
 * @ClassName Demo06Time
 * @DESCRIPTION Time
 * @create 2020-11-11 11:26
 **/

public class Demo06Time {
    public static void main(String[] args) {
        // 获取当前时间:
        Date date = new Date();
        // 必须加上1900
        System.out.println(date.getYear() + 1900);
        // 0~11，必须加上1
        System.out.println(date.getMonth() + 1);
        // 1~31，不能加1

        System.out.println(date.getDate());
        // 转换为String:
        System.out.println(date.toString());
        // 转换为GMT时区:
        System.out.println(date.toString());
        // 转换为本地时区:
        System.out.println(date.toString());
    }
}
