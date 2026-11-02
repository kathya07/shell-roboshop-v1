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
if [ $cart_id -ne 0 ]; then
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

dnf module enable maven:3.9 -y
dnf install maven java-25-openjdk-devel -y
validate $? "Installing java and Maven"

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate $? "setting jav25 as default java version"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
validate $? " setting java_home for maven"


id roboshop  &>> $logs_file
if [ $? -ne 0 ]; then
{
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>> $logs_file
    validate $? "creating system cart"
}
else
    echo -e "$(timestamp) [INFO] system user already exists...${Y}SKIPPING${N} "
fi

rm -rf /app
validate $? "removing old code"

mkdir -p /app
validate $? "Creating directory"

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip   &>> $logs_file
validate $? "Downloading the shipping"

cd /app           
validate $? "go to app dir"

unzip  /tmp/shipping.zip &>> $logs_file
validate $? "unzip the application"

mvn clean package &>> $logs_file                   
validate $? "Installing the application"

mv target/shipping.jar shipping.jar
validate $? "Moving shipping jar file"

sed -i "s/DOMAIN_NAME/"$domain_name"/g" "$scripts_dir/shipping.service" &>> $logs_file
cp "$scripts_dir/shipping.service" /etc/systemd/system/shipping.service &>> $logs_file

dnf install mysql -y &>> $logs_file
validate $? "Install Mysql client"

mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "Loading shipping data"

systemctl daemon-reload &>> $logs_file
systemctl enable shipping &>> $logs_file
systemctl start shipping &>> $logs_file
validate $? "starting and enabling the service"


systemctl restart shipping
validate $? "Restarting shipping"


echo "$(timestamp) [INFO] script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] =========Script Completed Execution======" | tee -a $logs_file