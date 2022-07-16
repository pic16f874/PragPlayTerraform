#!/bin/bash
apt update
#apt upgrade -y
apt install -y nginx curl mc
MY_IP_L=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
MY_IP_P=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sed -i 's/Welcome to nginx!/Welcome to nginx '"${MY_IP_L} ${MY_IP_P}/" index.nginx-debian.html
