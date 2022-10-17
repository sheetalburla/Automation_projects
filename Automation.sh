#!/bin/bash

#initialising
s3_bucket=sheetal2525
name=sheetal
#Repo update
sudo apt update -y
#Apache installed or not
installed=$(dpkg -l | grep apache2)
if [ !  "$installed" ];
then sudo apt install apache2 -y 
fi
#Apache active or not 
running=$(systemctl status apache2 | grep active | awk '{print $3}'|  tr -d '()')
if [ 'running' != '${running}' ]
then 
sudo systemctl start apache2
fi
#Apache enabled or not
enabled=$(sudo systemctl is enabled apache2)
if [ 'enabled' != '${enabled}' ]
then
sudo systemctl enable apache2
fi

#Timestamp
timestamp=$(date '+%d%m%Y-%H%M%S')

#Creating tar archive for logs
cd /var/log/apache2
tar -cvf ${name}-httpd-logs-${timestamp}.tar *.log
mv *.tar /tmp/

# Moving script to s3
aws s3 \
cp /tmp/${name}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/sheetal-httpd-logs-${timestamp}.tar

#Task 3
docroot="/var/www/html"
# Check if inventory file exists
if [[ ! -f ${docroot}/inventory.html ]]; then
#statements
echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${docroot}/inventory.html
fi
# Inserting Logs into the file
if [[ -f ${docroot}/inventory.html ]]; then
#statements
size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${docroot}/inventory.html
fi
#cron job
if [[ ! -f /etc/cron.d/automation ]]; then
#statements
echo "* 23 * * * root cd /root/Automation_Project/automation.sh" >>  /etc/cron.d/automation
fi
