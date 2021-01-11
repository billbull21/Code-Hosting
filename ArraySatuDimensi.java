package array;

public class ArraySatuDimensi {

    public static void main(String[] args) {
        
        // NAMA : HABIBUL UMAM
        // NIM : 202021420022

        int[] angka = {0,1,2,3,4,5,6,7,8,9};
        String[] hari = {"Senin", "Selasa", "Rabu", "Kamis", "Jum'at", "Sabtu", "Minggu"};

        // foreach angka
        System.out.print("0-9 : ");
        for (int a: angka) {
            System.out.print(a+", ");
        }

        System.out.println("\n====\n");

        // GENAP
        System.out.print("GENAP : ");
        for (int a: angka) {
            if (a % 2 == 0 && a != 0) System.out.print(a+", ");
        }

        System.out.println("\n====\n");

        // GANJIL
        System.out.print("GANJIL : ");
        for (int a: angka) {
            if (a % 2 != 0) System.out.print(a+", ");
        }

        System.out.println("\n====\n");

        // foreach hari
        System.out.print("HARI : ");
        for (String h: hari) {
            System.out.print(h+", ");
        }

        System.out.println("\n====\n");

        // for hari (selasa s/d jum'at)

        System.out.print("SELASA S/D JUM'AT : ");
        for (int i=1;i<5;i++) {
            // 1 index dari selasa
            // 5 batas akhir dari looping, yaitu index ke 4 = jum'at
            System.out.print(hari[i]+", ");
        }

    }

}
