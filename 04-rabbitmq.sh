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
        echo -e " ${2}...${R}Failed${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${2}...${G}Success${N}" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO] ======Script started execution=========="

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding rabbitmq repo"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? " Enable and Start rabbitmq" 

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then

    rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
    validate $? "Creating rabbitmq user"
else
    echo -e "$(timestamp) [INFO] rabbitmq user already exists...${Y}SKIPPING${N}"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "creating rabbitmq user for roboshop"

echo "$(timestamp) [INFO] script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] =========Script Completed Execution======" | tee -a $logs_file