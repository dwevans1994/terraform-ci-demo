
#!/bin/bash
sudo yum install -y httpd
sudo service httpd start
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
latest.tar.gz  wordpress
cd wordpress
cp wp-config-sample.php wp-config.php