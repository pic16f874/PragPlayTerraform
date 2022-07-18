#!/bin/bash
apt update
#apt upgrade -y
apt install -y nginx curl mc
#wget https://s3.eu-central-1.amazonaws.com/amazon-ssm-eu-central-1/latest/debian_amd64/amazon-ssm-agent.deb
#dpkg -i amazon-ssm-agent.deb
REG=$(curl http://169.254.169.254/latest/meta-data/placement/region)
AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
MY_IP_L=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
MY_IP_P=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sed -i 's/Welcome to nginx!/Welcome to nginx '"${MY_IP_L} ${MY_IP_P}/" /var/www/html/index.nginx-debian.html

#curl https://ip-ranges.amazonaws.com/ip-ranges.json > ip-ranges.json
#cat ip-ranges.json | awk '{ if(match($0,"ip_prefix")) { match($0,"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2}"); print (substr($0,RSTART,RLENGTH)); }   }'
