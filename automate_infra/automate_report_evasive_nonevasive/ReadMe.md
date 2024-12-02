### Steps to Run on Your Proxmox CAPE Server
1. Ensure Required Libraries Are Installed
Use the commands below to install watchdog and pdfplumber:
`pip3 install watchdog pdfplumber`


2. Save the corrected script as categorize_reports.py in a folder, for example:
`/home/cape/scripts/categorize_reports.py`

3. Run the Script
Execute the script using Python:

    `python3 /home/cape/scripts/categorize_reports.py`

4. Check for Permissions
Ensure the /opt/CAPEv2/storage/analyses/latest directory is accessible by the user running the script. If there are permission issues:
`sudo chmod -R 755 /opt/CAPEv2/storage/analyses/latest`

5. Automate Script Execution
To run automatically on server startup:

- Create a Systemd Service
- Save the following in /etc/systemd/system/report_monitor.service:
```
[Unit]
Description=Monitor CAPE reports for categorization
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/cape/scripts/categorize_reports.py
Restart=always
User=cape

[Install]
WantedBy=multi-user.target
```
- Enable and Start the Service
```
sudo systemctl enable report_monitor
sudo systemctl start report_monitor
```

6. Testing the Script
Place a sample PDF in /opt/CAPEv2/storage/analyses/latest containing a keyword like SandboxHookingDLL or VM_Evasion. Observe the console output when the file is created in the monitored folder. It should categorize the file as "Evasive" if it detects a keyword, otherwise as "Non-evasive."