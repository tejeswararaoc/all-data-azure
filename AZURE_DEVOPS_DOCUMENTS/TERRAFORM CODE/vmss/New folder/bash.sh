#! /bin/bash 
sudo apt-get update -y
sudo apt-get install -y apache2 
sudo systemctl start apache2 
sudo systemctl enable apache2 
echo "<h1> hello world:deployed via TF </h1>" | tee /var/www/html/html.index
