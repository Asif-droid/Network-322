import java.io.*;
import java.net.Socket;
import java.util.Scanner;

public class myclient {


    public static void main(String[] args) {

        Scanner sc=new Scanner(System.in);

        while(true){
            String in=sc.nextLine();
            new clientThread(in);
        }

    }
}
