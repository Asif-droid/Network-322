
fileW= open("F:/3-2/CSE 322/ns2_files/offline2/offline2.txt", "w")
file_send_W= open("F:/3-2/CSE 322/ns2_files/offline2/offline2_send.txt", "w") 
file_recieve_W= open("F:/3-2/CSE 322/ns2_files/offline2/offline2_recieve.txt", "w") 
file_dropped_W= open("F:/3-2/CSE 322/ns2_files/offline2/offline2_dropped.txt", "w")
# 
    
with open("F:/3-2/CSE 322/ns2_files/offline2/offline2.tr", "r") as fileR:
    line = fileR.readline()
    while line:
    #   print(line)
        parameters=line.split(" ")
        if(parameters[0]=="D"):
            file_dropped_W.write(line)
        
        elif(parameters[0]=="s"):
            file_send_W.write(line)
        elif(parameters[0]=="r"):
            file_recieve_W.write(line)
        else:
            fileW.write(line)
        line = fileR.readline()
fileW.close()