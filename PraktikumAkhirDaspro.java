package array;

import javax.swing.*;
import java.awt.*;

public class PraktikumAkhir {
    public static void main(String[] args) {
        int jumlahData;
        int jumlahField = 5;
        JOptionPane.showMessageDialog(null, "Program Sederhana Input Nilai Mahasiswa!!");
        jumlahData = Integer.parseInt(JOptionPane.showInputDialog("Berapa jumlah data nama Mahasiswa yang diinginkan? "));
        String data[][] = new String[jumlahData][jumlahField];
        for (int baris = 0; baris < jumlahData; baris++) {
            String[] response = display(baris);
            for (int kolom = 0; kolom < response.length; kolom++) {
                data[baris][kolom] = response[kolom];
            }
        }
        System.out.println("==============================================");
        System.out.println("No | Nama Mahasiswa | Ulangan | Tugas | Total | Rata-rata");
        System.out.println("==============================================");
        for (int baris = 0; baris < jumlahData; baris++) {
            for (int kolom = 0; kolom < jumlahField; kolom++) {
                int idx = baris+1;
                if (kolom == 0) System.out.print(idx+" | ");
                System.out.print(data[baris][kolom]);
                System.out.print("\t");
            }
            System.out.println("");
        }
    }

    private static String[] display(int idx) {
        JTextField field1 = new JTextField();
        JTextField field2 = new JTextField();
        JTextField field3 = new JTextField();
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.add(new JLabel("Nama : "));
        panel.add(field1);
        panel.add(new JLabel("Ulangan : "));
        panel.add(field2);
        panel.add(new JLabel("Tugas : "));
        panel.add(field3);
        int result = JOptionPane.showConfirmDialog(null, panel, "Input Nilai Mahasiswa ke-"+(idx+1),
                JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
        if (result == JOptionPane.OK_OPTION) {
            int total = Integer.parseInt(field2.getText())+Integer.parseInt(field3.getText());
            double avg = total/2;
            String[] res = {field1.getText(), field2.getText(), field3.getText(), String.valueOf(total), String.valueOf(avg)};
            return res;
        } else {
            return null;
        }
    }
}
