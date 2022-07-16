apt update
#apt upgrade -y
apt install -y nginx curl mc
MYIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i 's/Welcome to nginx!/Welcome to nginx '"${MYIP}/" index.nginx-debian.html
