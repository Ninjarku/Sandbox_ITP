#!/bin/bash

script_path="/home/cape/Config_scripts/Sandbox_ITP/py_scripts/observer.py"
service_name="cape-scheduler"
user="${user:-$(whoami)}"
group="${group:-$(id -gn)}"

service_file="/etc/systemd/system/$service_name.service"

# Automates the creation of a service to execute observer.py
# Make any changes if necessary to the service here
cat <<EOF | sudo tee $service_file > /dev/null
[Unit]
Description="Service for $service_name"

[Service]
ExecStart=/usr/bin/python3 $script_path
Restart=always
User=$user
Group=$group

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $service_name.service
sudo systemctl start $service_name.service

