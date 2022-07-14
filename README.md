1. Написати на ansible/terraform 
   підняття 2 інстансів web1 і web2 в окремій VPC 
   та ALB для балансування навантаження між цими серверами 

2. На серверах web1 і web2 за допомогою ansible/terraform 
   підняти "Hello world" сторінку в Nginx контейнері 

3. Відкрити доступ на nginx (http://nginx.org/en/docs/http/ngx_http_access_module.html) 
   до сторінки "Hello world" з IP пулів CloudFront та EC2 
   (IP можна отримати по API  https://ip-ranges.amazonaws.com/ip-ranges.json ) 
   (таск з зірочкою) 
