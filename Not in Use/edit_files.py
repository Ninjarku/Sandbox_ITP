#Python script to edit conf files
import os
import sys
def main():
    # Get the directory of the current script
    script_dir = os.path.dirname(__file__)

    # Define the file path
    file_path = os.path.join(script_dir, "cape2.sh")

    # replace with the network interface of the cape server
    network_pattern = 'NETWORK_IFACE='
    VM_interface = sys.argv[1] #'ens33'

    # replace with the assigned IP address of the CAPE server
    IP_addr = sys.argv[2] #'192.168.2.80' 
    pattern = 'IFACE_IP=\"'
   

    # open the file for reading
    with open(file_path, 'r', encoding='utf-8') as file: 
        conf_data = file.readlines() 
  
    # Loop through all lines in the file
    for i in range(len(conf_data)):
        line = conf_data[i].strip('\r\n')  # it's always a good behave to strip what you read from files

        # check if pattern is in file
        if pattern in line:
            
            # replace line with ip address added
            conf_data[i] = 'IFACE_IP=\"' + IP_addr + '\"\n'

        elif network_pattern in line:
            conf_data[i] = network_pattern + VM_interface + '\n'
          
    # write the configs to the file
    with open(file_path, 'w', encoding='utf-8') as file: 
        file.writelines(conf_data) 

    

if __name__ == "__main__":
    main()