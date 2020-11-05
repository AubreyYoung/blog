package com.inspur.pm4h2.amt.dao;

/**
 * @author
 * @create 2020-11-05 17:24
 **/

public class Demo05Switch {
    public static void main(String[] args) {
        int option = 99;
        switch (option) {
            case 1:
                System.out.println("Selected 1");
                break;
            case 2:
                System.out.println("Selected 2");
                break;
            case 3:
                System.out.println("Selected 3");
                break;
            default:
                System.out.println("Not selected");
                break;
        }
    }
}
