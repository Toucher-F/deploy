#!/bin/bash
#Load the  envset scripts,$1：Receive the environment variables
source /tmp/php/app-php.sh $1 $2 $3 $4
#Load the  function scripts 
source /tmp/php/function.sh 
#Configure each environment running function,$1：Receive the environment variables 
if
	egrep -q "127\.0\.0\.1.*api\.localhost" /etc/hosts
then
	echo "" >/dev/null
else
	echo "127.0.0.1 api.localhost" >>/etc/hosts
fi
echo-status backup-source
echo-status app-ui-git
if [ ${Is_mount_data} -eq 0 ];then
	if
		umount ${DTPATH}/app-core/data
	then
		service cron stop
	else
		echo "umount ${DTPATH}/app-core/data faild"
		exit 1
	fi
fi
echo-status app-core-git
if [ ${Is_mount_data} -eq 0 ];then
	if
		mount -a
	then
		service cron start
	else
		echo "mount -a faild"
		exit 1
	fi
fi
echo-status copy-conf
echo-status modify-configuration
echo-status composer-app-ui
echo-status composer-app-core
echo-status migrate
echo-status roles
echo-status forms
echo-status flushall
echo-status delete-app
rm -rf /tmp/php