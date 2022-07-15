apt update
apt install -y nginx curl mc
MYIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "<h2>Nginx IP: ${MYIP}<h2><br>" > /etc/nginx/index.html
systemctl restart nginx
