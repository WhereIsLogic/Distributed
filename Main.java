package com.company;

public class Main extends Thread {

    static int customers = 10;
    int global_id;
    static int allServed;
    private static volatile boolean[] entering = new boolean[customers];
    private static volatile int[] ticket = new int[customers];
    private static volatile  boolean[] served = new boolean[customers];

    public Main(int id) {
        global_id = id;
    }

    private void unlock(int id) {
        ticket[id] = 0;
        served[id] = true;
        System.out.println("unlock: thread " + id);
    }

    public void lock(int id) {

        entering[id] = true;
        int max = ticket[0];
        for (int i = 1; i < ticket.length; i++) {
            if (ticket[i] > max)
                max = ticket[i];
        }
        ticket[id] = max + 1;
        entering[id] = false;

        System.out.println("lock: thread " + id);

        for (int i = 0; i < customers; i++) {

            if (i == id)
                continue;
            while (entering[i]) {
                Thread.yield();
            }
            while (ticket[i] != 0 && (ticket[id] > ticket[i] ||
                    (ticket[id] == ticket[i] && id > i))) {
                Thread.yield();
            }
        }
        if(served[id] == false) {
            served[id] = true;
            allServed++;
        }
    }

    public static void main(String[] args) {

        for (int i = 0; i < customers; i++) {
            entering[i] = false;
            ticket[i] = 0;
            served[i] = false;
            allServed = 0;
        }

        Main[] threads = new Main[customers];
        for (int i = 0; i < customers; i++) {
            threads[i] = new Main(i);
            threads[i].start();
            System.out.println("\nalive: thread " + i);
        }

        for (int i = 0; i < customers; i++) {
            try {
                threads[i].join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        System.out.println("all done");
    }

    public void run() {
        int threadId = (int) Thread.currentThread().getId() % customers;
        System.out.println("threadID " + threadId + " " + served[threadId]);
        for (int i = 0; i < customers*2; i++) {
            if(allServed == customers || served[threadId]==true){break;}
            else {
                lock(global_id);
                try {
                    sleep((int) (Math.random()) * 2);
                } catch (InterruptedException e) {
                    System.out.println(e.getMessage());
                }
                unlock(global_id);
            }
        }
    }
}

