#!/bin/bash

###############################################################################################################
# If You need make any change in MySQL WP (database, User and password user ). please make same changes in script (install.sh)
wp_db="wordpress"
wp_user="wordpressuser"
wp_userPassword="P@ssw0rd123@"
###############################################################################################################

sudo apt update
sudo apt-get install mysql-server-8.0 sshpass -y
sudo systemctl enable --now mysql.service

sudo mysql -u root -e "CREATE USER 'mahmoud'@'%' IDENTIFIED BY 'P@ssw0rd123@';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'mahmoud'@'%' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS $wp_db;"
sudo mysql -u root -e "CREATE USER '$wp_user'@'%' IDENTIFIED BY '$wp_userPassword';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$wp_user'@'%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

if [ $(hostname -I) = '10.1.2.4' ]; then
    sudo sed -i "s/^bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/^mysqlx-bind-address/#mysqlx-bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/^# server-id/server-id/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/^# log_bin/log_bin/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    
elif [ $(hostname -I) = '10.1.2.5' ]; then
    sudo sed -i "s/^bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/^mysqlx-bind-address/#mysqlx-bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i 's/#\s*server-id\s*=\s*1/server-id = 2/' /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/^# log_bin/log_bin/g" /etc/mysql/mysql.conf.d/mysqld.cnf
fi

sudo systemctl restart mysql.service

sudo mysql -u root -e "CREATE USER 'replicator'@'%' IDENTIFIED BY 'P@ssw0rd@';"
sudo mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

###############################################################################################################################################

if [ $(hostname -I) = '10.1.2.4' ]; then
    output=$(sudo mysql -u root  -e "SHOW MASTER STATUS;")
    sudo touch /home/mahmoud/vm1
    sudo echo $(echo "$output" | awk 'NR==2{print $1}') >> /home/mahmoud/vm1
    sudo echo $(echo "$output" | awk 'NR==2{print $2}') >> /home/mahmoud/vm1
    sshpass -p 'Password123@' scp -o StrictHostKeyChecking=no "/home/mahmoud/vm1" "mahmoud@10.1.2.5:."

elif [ $(hostname -I) = '10.1.2.5' ]; then
    output2=$(sudo mysql -u root  -e "SHOW MASTER STATUS;")
    sudo touch /home/mahmoud/vm2
    sudo echo $(echo "$output2" | awk 'NR==2{print $1}') >> /home/mahmoud/vm2
    sudo echo $(echo "$output2" | awk 'NR==2{print $2}') >> /home/mahmoud/vm2
    sshpass -p 'Password123@' scp -o StrictHostKeyChecking=no "/home/mahmoud/vm2" "mahmoud@10.1.2.4:."
fi

###############################################################################################################################################
sleep 20s

if [ $(hostname -I) = '10.1.2.5' ]; then
    logg=$(sed -n '1p' /home/mahmoud/vm1)
    poss=$(sed -n '2p' /home/mahmoud/vm1)
    sudo mysql -u root -e "STOP SLAVE;"
    sudo mysql -u root -e "CHANGE MASTER TO MASTER_HOST = '10.1.2.4', MASTER_USER = 'replicator', MASTER_PASSWORD = 'P@ssw0rd@', MASTER_LOG_FILE = '$logg', MASTER_LOG_POS = $poss, GET_MASTER_PUBLIC_KEY=1;"
    sudo mysql -u root -e "START SLAVE;"
fi
sleep 5s
if [ $(hostname -I) = '10.1.2.4' ]; then
    log=$(sed -n '1p' /home/mahmoud/vm2)
    pos=$(sed -n '2p' /home/mahmoud/vm2)
    sudo mysql -u root -e "STOP SLAVE;"
    sudo mysql -u root -e "CHANGE MASTER TO MASTER_HOST = '10.1.2.5', MASTER_USER = 'replicator', MASTER_PASSWORD = 'P@ssw0rd@', MASTER_LOG_FILE = '$log', MASTER_LOG_POS = $pos, GET_MASTER_PUBLIC_KEY=1;"
    sudo mysql -u root -e "START SLAVE;"
fi

###############################################################################################################################################
sudo systemctl restart mysql.service