#!/bin/bash
#backup DB of analytics project
source /tmp/db-analytics/analytics-db.sh $1 $2
echo "=====================backup analytics db start $(date +%T)====================" 

if [ ! -e /var/log/deploy/${ENVIRONMENT} ] 
		then
			mkdir -p /var/log/deploy/${ENVIRONMENT}
fi
if [ ! -e /var/backups/deploy/analytics/${ENVIRONMENT} ]
		then
			mkdir -p /var/backups/deploy/analytics/${ENVIRONMENT}
fi
echo "=====================backup analytics db start $(date +%T)====================" >>/var/log/deploy/${ENVIRONMENT}/err_analytics_db_${BACKUP_NAME}.log
psql postgres -c "\q" &>/dev/null
if [ $? -ne 0 ];then
	su - postgres -c "createuser --superuser root" &>/dev/null
fi
if [ ! -e /var/backups/deploy/analytics/${ENVIRONMENT}/${DATABASE}_${BACKUP_NAME}.dump ]
	then
		pg_dump -Fc ${DATABASE} > /var/backups/deploy/analytics/${ENVIRONMENT}/${DATABASE}_${BACKUP_NAME}.dump 2>> /var/log/deploy/$ENVIRONMENT/err_analytics_db_${BACKUP_NAME}.log
		if [ $? -eq 0 ]
			then
				echo "backup analytics db success"
		else 
			echo "backup analytics db faild"
		fi
	else
		echo "Backup has been in existence, no need to backup again"
		echo "Backup has been in existence, no need to backup again" >> /var/log/deploy/$ENVIRONMENT/err_analytics_db_${BACKUP_NAME}.log
	fi
rm -rf /tmp/db-analytics
echo "=====================backup analytics db end $(date +%T)===================="
echo "=====================backup analytics db end $(date +%T)====================" >> /var/log/deploy/${ENVIRONMENT}/err_analytics_db_${BACKUP_NAME}.log
