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

dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y  &>> $logs_file
dnf install nodejs -y  &>> $logs_file
validate $? "Installing node js"

id roboshop  &>> $logs_file
if [ $? -ne 0 ]; then
{
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>> $logs_file
    validate $? " creating system user"
}
else
    echo -e "system user already exists...${Y}SKIPPING${N} "
fi

mkdir -p /app
validate $? " creating directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip   &>> $logs_file
validate $? "Downloading the catalogue"

cd /app
validate $? "go to app dir"
unzip /tmp/catalogue.zip 
validate $? "unzip the application"

npm install &>> $logs_file
validate $? "Installing the application"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/catalogue.service" &>> $logs_file
cp "$scripts_dir/catalogue.service" /etc/systemd/system/catalogue.service &>> $logs_file

systemctl daemon-reload &>> $logs_file
systemctl enable catalogue &>> $logs_file
systemctl start catalogue &>> $logs_file


echo "$(timestamp) [INFO] script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] =========Script Completed Execution======" | tee -a $logs_file