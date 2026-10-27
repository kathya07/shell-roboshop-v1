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

echo " script started execution at $(date +"%F %T")" &>> $logs_file
validate()
{
    if [ $1 -ne 0 ]; then
        echo -e " ${2}...${R}Failed${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${2}...${G}Success${N}" | tee -a $logs_file
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo 
validating $? "Adding mongo repo"

dnf install mongodb-org -y &>> $logs_file
validate $? "Install MongoDB"

systemctl enable mongod &>> $logs_file
systemctl start mongod &>> $logs_file
validate $? "Enable and Start mongoDB"

