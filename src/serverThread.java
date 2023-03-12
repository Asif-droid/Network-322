import java.io.*;
import java.net.Socket;
import java.net.SocketException;
import java.util.Date;

public class serverThread implements Runnable {

    Thread thread;
    Socket ss;
    String root;
    int port;
    int reqno=0;

    public serverThread(Socket ss,String root,int port){
        this.ss=ss;
        this.root=root;
        this.port=port;
        thread=new Thread(this);
        thread.start();
    }



    @Override
    public void run() {
        try{

            BufferedReader in = new BufferedReader(new InputStreamReader(ss.getInputStream()));
            PrintWriter pr = new PrintWriter(ss.getOutputStream());
            reqno++;
            String tname=Thread.currentThread().getName();


            String input = in.readLine();

            String out="<html> hello <body>";
            //StringBuilder sb=new StringBuilder();

            System.out.println("input : "+input);
            if(input==null){
                in.close();
                ss.close();
                return;

            }

            if(input.length()>0){

                if(input.startsWith("GET")){
                    PrintWriter logWritter=new PrintWriter("log\\response"+tname+reqno+".log");
                    logWritter.println(input);
                    boolean download=false;
                    boolean filenotFound=false;

                    String ar[]=input.split("/");
                    String path="";

                    for(int i=1;i<ar.length-2;i++){
                        path+=ar[i]+"\\";
                    }
                    System.out.println(path);
                    File file;
                    File [] files;
                    String fpath=path.replace("root\\","");
                    if(path.equals("")||path.equals("root\\")){
                        //System.out.println(root);
                        //out+="<br><a href=http://localhost:5063/"+root+"> root</a>";
                        file=new File(root);

                    }
                    else{

                        fpath=root+"\\"+fpath;
                        System.out.println(fpath+"here");
                        file=new File(fpath);
                    }
                    if(file.exists()){
                        if(file.isDirectory()){
                            files=file.listFiles();
                            for(int i=0;i<files.length;i++){
                                if(files[i].isDirectory()){
                                    out+="<br><i><b><a href=http://localhost:5063/"+path.replace("\\","/")+files[i].getName()+
                                            "/>"+files[i].getName()+"</a></b></i>";
                                }
                                else {
                                    out+="<br><a href=http://localhost:5063/"+path.replace("\\","/")+files[i].getName()+
                                            "/ target=_blank >"+files[i].getName()+"</a>";
                                }

                            }
                            //System.out.println("found");
                        }
                        else{
                            String fileExtend[]=path.split("\\.");

                            if(fileExtend[fileExtend.length-1].equals("txt\\")){
                                FileInputStream fis = new FileInputStream(file);
                                BufferedReader br = new BufferedReader(new InputStreamReader(fis, "UTF-8"));
                                StringBuilder sb = new StringBuilder();
                                String line;
                                while(( line = br.readLine()) != null ) {
                                    sb.append( line );
                                    sb.append( '\n' );
                                }
                                out+=sb.toString();
                            }
                            else if(fileExtend[fileExtend.length-1].equalsIgnoreCase("jpg\\")||fileExtend[fileExtend.length-1].equalsIgnoreCase("png\\")) {
                                String imp=fpath.substring(0,fpath.length()-1);
                                System.out.println(imp);
                                out+=imp;
                                out+="<img src=\""+imp+"\">";
                            }
                            else{
                                System.out.println(fpath);
                                out+="download"+fpath;
                                download=true;
                            }

                        }
                    }else{
                        filenotFound=true;
                        System.out.println("noy");
                        out+="<h1>404 File not found</h1>";
                    }
                    out+="</body></html>";

                    if(download){
                    logWritter.println("HTTP/1.1 200 OK\r\nContent-Type:application/octet-stream\r\n");

                        try {
                            int c;
                            byte chunk[] = new byte[1024];
                            OutputStream os = ss.getOutputStream();
                            BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
                            os.write("HTTP/1.1 200 OK\r\n".getBytes());
                            os.write("Accept-Ranges: bytes\r\n".getBytes());
                            os.write(("Content-Length: "+file.length()+"\r\n").getBytes());
                            os.write("Content-Type: application/octet-stream\r\n".getBytes());
                            os.write(("Content-Disposition: attachment; filename=\""+file.getName()+"\"\r\n").getBytes());
                            os.write("\r\n".getBytes());

                            while((c=bis.read(chunk,0,1024)) > 0) {
                                os.write(chunk, 0, c);

                            }

                            os.flush();

                            bis.close();
                            os.close();
                        }catch (IOException e){
                            e.printStackTrace();
                        }

                    }
                    else{
                        String httpresponse;

                        if(filenotFound){
                            httpresponse="HTTP/1.1 404 NOT FOUND\r\nServer: Java HTTP Server: 1.0\r\nDate: "
                                    +new Date()+"\r\nContent-Type: text/html\r\nContent-Length: "+out.length()+"\r\n";
                        }
                        else {
                            httpresponse="HTTP/1.1 200 OK\r\n Server: Java HTTP Server: 1.0\r\n Date: "
                                    + new Date() + "\r\n Content-Type: text/html\r\nContent-Length: " + out.length() + "\r\n\r\n";

                        }
                        logWritter.println(input);
                        logWritter.println(httpresponse);
                        pr.write(httpresponse);
                        pr.write(out);
                        pr.flush();

                    }


                    pr.close();
                    logWritter.close();

                }
                else if(input.startsWith("UPLOAD")){
                    String validity=in.readLine();
                    PrintWriter logWritter=new PrintWriter("log\\response"+tname+reqno+".log");
                    logWritter.println(input);


                    if(validity.equalsIgnoreCase("valid")){
                        int c;
                        byte chunk[]=new byte[1024];

                        String name=in.readLine();
                        //System.out.println(name);
                        name="root\\upload\\"+name;
                        System.out.println("Receiving content from "+name);

                        try {
                            FileOutputStream fos = new FileOutputStream(new File(name));
                            InputStream is = ss.getInputStream();

                            while((c=is.read(chunk)) > 0){
                                fos.write(chunk);
                                System.out.print(".");
                            }
                            System.out.println();
                            System.out.println("Successfully done");
                            is.close();
                            fos.close();
                        } catch(IOException e) {
                            e.printStackTrace();
                        }
                        logWritter.println("Successfully uploaded in "+name+" at "+new Date());
                        logWritter.close();

                    }
                    else{
                        System.out.println("Invalid file");
                        logWritter.println("Invalid file upload attempted "+new Date());
                        logWritter.close();
                    }
                    //System.out.println("upload"+validity);
                }

            }
            in.close();
            ss.close();
            return;


        }catch (SocketException e){
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}
