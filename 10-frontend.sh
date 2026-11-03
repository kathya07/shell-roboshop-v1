#!/bin/bash

user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="${logs_folder}/${0}.log" ## /var/logs/shell-practice/13-logs.sh.log
domain_name="daws92s.site"
scripts_dir=$( dirname "$(realpath "$0")" )
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
if [ $user_id -ne 0 ]; then
    echo " please run the script using sudo access"
    exit 1
    
fi

mkdir -p $logs_folder
echo "hello world..."

# echo " script started execution at $(date +"%F %T")" &>> $logs_file

timestamp()
{
    date +"%F %T"
}
validate()
{
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR} ${2}...${R}Failed${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}...${G}Success${N}" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO] ======Script started execution=========="

dnf module disable nginx -y &>> $logs_file
dnf module enable nginx:1.26 -y &>> $logs_file
dnf install nginx -y &>> $logs_file
validate $? "Installaling nginx"

systemctl enable nginx &>> $logs_file
systemctl start nginx &>> $logs_file
validate $? "Enable and start nginx"

rm -rf /usr/share/nginx/html/* &>> $logs_file
validate $? "remove default nginx content"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip  &>> $logs_file
cd /usr/share/nginx/html &>> $logs_file
unzip /tmp/frontend.zip &>> $logs_file
validate $? "Downloading and unzipping frontend code"

sed -i "s/DOMAIN_NAME/"$domain_name"/g" "$scripts_dir/roboshop.conf" &>> $logs_file
cp "$scripts_dir/payment.service" /etc/nginx/default.d/roboshop.conf &>> $logs_file
validate $? " copied roboshop config"

nginx -t &>> $logs_file
validate $? " nginx configuration"

systemctl restart nginx
validate $? " restart the nginx"


echo "$(timestamp) [INFO] script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] =========Script Completed Execution======" | tee -a $logs_file