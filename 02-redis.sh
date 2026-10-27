#!/bin/bash

user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="${logs_folder}/${0}.log" ## /var/logs/shell-practice/13-logs.sh.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
if [ $user_id -ne 0 ]; then
    echo " please run the script using sudo access"
    exit 1
    
fi


mkdir -p $logs_folder

# echo " script started execution at $(date +"%F %T")" &>> $logs_file

timestamp()
{
    date +"%F %T"
}
validate()
{
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}...${R}Failed${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}...${G}Success${N}" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO] ======Script started execution=========="

dnf module disable redis -y &>> $logs_file
dnf module enable redis:7 -y &>> $logs_file
dnf install redis -y &>> $logs_file
validate $? " Installing Redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? " Allowing remote connections to redis"

systemctl enable redis &>> $logs_file
systemctl start redis &>> $logs_file
validate $? "Enable and Start redis" 

echo "$(timestamp) [INFO] script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] =========Script Completed Execution======" | tee -a $logs_file