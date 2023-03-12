import java.io.*;
import java.net.Socket;

public class clientThread implements Runnable {

    Socket socket;
    Thread thread;
    String in;

    public clientThread(String in){
        this.in=in;
        thread=new Thread(this);
        thread.start();

    }

    @Override
    public void run() {
        try {
            socket=new Socket("localhost",5063);


            File inputFile=new File(in);
            OutputStream os=socket.getOutputStream();

            if(inputFile.exists()){
                System.out.println("opened");
                BufferedInputStream bis=new BufferedInputStream(new FileInputStream(inputFile));
                int c;
                byte chunk[]=new byte[1024];

                os.write("UPLOAD \r\n".getBytes());
                os.write("valid\r\n".getBytes());
                os.write(inputFile.getName().getBytes());
                os.write("\r\n".getBytes());
                os.write("\r\n".getBytes());
                System.out.println("Uploading.");
                while((c=bis.read(chunk)) > 0) {
                    os.write(chunk, 0, c);
                    System.out.print(".");
                }


                os.flush();
                System.out.println();
                System.out.println("Uploaded.");
                bis.close();
            }else {
                os.write("UPLOAD\r\n".getBytes());
                os.write("invalid\r\n".getBytes());
                os.flush();
                System.out.println("Invalid..");
            }
            os.close();
            socket.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
