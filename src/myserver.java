import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.rmi.ServerError;
import java.util.Date;

public class myserver {

    static final int PORT = 5063;
    static final String root="root";
    static final String log="log";


    public static String readFileData(File file, int fileLength) throws IOException {
        FileInputStream fileIn = null;
        byte[] fileData = new byte[fileLength];

        try {
            fileIn = new FileInputStream(file);
            fileIn.read(fileData);
        } finally {
            if (fileIn != null)
                fileIn.close();
        }

        return String.valueOf(fileData);
    }

    public static void main(String[] args) throws IOException {

        ServerSocket serverConnect = new ServerSocket(PORT);
        System.out.println("Server started.\nListening for connections on port : " + PORT + " ...\n");
        File logFile=new File(log);
        try {


            logFile.mkdir();

            while (true) {
                new serverThread(serverConnect.accept(),root,PORT);

            }

        }catch (SocketException e){
            System.out.println("server");
        }


    }
}
