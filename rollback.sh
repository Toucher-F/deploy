#!/bin/bash
read -t 30 -p "Please input rollback environment[30QA/30staging/30prod/test30QA/test30staging/test30prod]?" ENVIRONMENT
if [ -z $ENVIRONMENT ];then
	echo "Environment can't be null"
	exit 1
fi
arr=(30QA 30staging 30prod)
if
	echo ${arr[@]} | grep -wq ${ENVIRONMENT}
then
	DEPLOY_DIR="/30deployment"
else
	DEPLOY_DIR="/storage/deploy"
fi
source /scripts/deploy/environment/environment-ip.sh
#####################################################################################
read -t 60 -p "Whether to rollback application project or not [y/n](default:y)?" is_deploy_app
is_deploy_app=$(echo ${is_deploy_app} | tr '[A-Z]' '[a-z]')
if [ -z ${is_deploy_app} ];then
	is_deploy_app=y
else
	if [ "${is_deploy_app}x" != "yx" ] && [ "${is_deploy_app}x" != "nx" ];then
	echo "Input is not correct(is_deploy_app)"
	exit 1
	fi
fi

if [ "${is_deploy_app}x" == "yx" ];then
	echo "Please chose the backup file name:"
	TMP_IP="E${ENVIRONMENT}_php[@]"
	TMP_IP=${!TMP_IP}
	cd ${DEPLOY_DIR}/backup/${ENVIRONMENT}/${TMP_IP[0]}/app/ && ls -lrt | grep "^d" | awk '{print $9}'
	read -t 60 -p "Please input rollback backup file name[as:30-170220-0_1487746845]?" APP_BACKUP_NAME
	if [ -z $APP_BACKUP_NAME ];then
		APP_BACKUP_NAME=$(cd ${DEPLOY_DIR}/backup/${ENVIRONMENT}/${TMP_IP[0]}/app/ && ls -lrt | grep "^d" | awk '{print $9}' | tail -n 1)
	else
		if
			cd ${DEPLOY_DIR}/backup/${ENVIRONMENT}/${TMP_IP[0]}/app/ && ls -lrt | grep "^d" | awk '{print $9}' | grep  -wq "file name:${APP_BACKUP_NAME}"
		then
			echo "" >/dev/null
		else
			echo "Backup file doesnot exist,please reset!"
			exit 1
		fi
	fi
fi
##########################################################################################
read -t 60 -p "Whether to rollback analytics project or not[y/n](default:n)?" is_deploy_ana
is_deploy_ana=$(echo ${is_deploy_ana} | tr '[A-Z]' '[a-z]')
if [ -z ${is_deploy_ana} ];then
	is_deploy_ana=n
else
	if [ "${is_deploy_ana}x" != "yx" ] && [ "${is_deploy_ana}x" != "nx" ];then
	echo "Input is not correct(is_deploy_ana)"
	exit 1
	fi
fi

if [ "${is_deploy_ana}x" == "yx" ];then
	echo "Please chose the backup file name:"
	TMP_IP="E${ENVIRONMENT}_analytics_php[@]"
	TMP_IP=${!TMP_IP}
	cd ${DEPLOY_DIR}/backup/${ENVIRONMENT}/${TMP_IP[0]}/analytics/ && ls -lrt | grep "^d" | awk '{print $9}'
	read -t 60 -p "Please input rollback backup file name[as:30-170220-0_1487746845]?" ANA_BACKUP_NAME
	if [ -z $ANA_BACKUP_NAME ];then
		ANA_BACKUP_NAME=$(cd ${DEPLOY_DIR}/backup/${ENVIRONMENT}/$1/analytics/ && ls -lrt | grep "^d" | awk '{print $9}' | tail -n 1)
	else
		if
			cd ${DEPLOY_DIR}/backup/${ENVIRONMENT}/${TMP_IP[0]}/analytics/ && ls -lrt | grep "^d" | awk '{print $9}' | grep  -wq "file name:${ANA_BACKUP_NAME}"
		then
			echo "" >/dev/null
		else
			echo "Backup file doesnot exist,please reset!"
			exit 1
		fi
	fi
fi
###################################################################################################

DTPATH=$(sed -n '/^\t*"*'${ENVIRONMENT}'"*/,/;;/p' /scripts/deploy/environment/app-php.sh | grep DTPATH | cut -d "=" -f 2)
if [ -z $DTPATH ];then
	echo "Failed to get the target server home directory (DTPATH)"
	exit 1
fi
ANAPATH=$(sed -n '/^\t*"*'${ENVIRONMENT}'"*/,/;;/p' /scripts/deploy/environment/analytics-php.sh | grep ANAPATH | cut -d "=" -f 2)
if [ -z $ANAPATH ];then
	echo "Failed to get the target server home directory (ANAPATH)"
	exit 1
fi
##############################################################################
#Upload script file to the PHP server $1:ip $2:environment
function deploy-core-php
	{
	if [ "${is_deploy_app}x" == "yx" ];then
		scp -r ${DEPLOY_DIR}/backup/$2/$1/app/${APP_BACKUP_NAME}/* root@$1:${DTPATH}/
		scp -r /scripts/deploy/rollback/rollback-php root@$1:/tmp
		scp /scripts/deploy/environment/app-php.sh root@$1:/tmp/rollback-php/
		ssh root@$1 . /tmp/rollback-php/rollback-ui-core.sh $2 $APP_BACKUP_NAME
		echo "============================$1 RUNNING OVER============================================"
	else
		echo "" >/dev/null
	fi
	}
##############################################################################
#Upload script file to the DB server $1:ip $2:environment
function deploy-core-db
	{
	if [ "${is_deploy_app}x" == "yx" ];then
		scp ${DEPLOY_DIR}/backup/$2/$1/app/*_${APP_BACKUP_NAME}.dump root@$1:/tmp
		scp -r /scripts/deploy/rollback/rollback-db root@$1:/tmp
		scp /scripts/deploy/environment/app-db.sh root@$1:/tmp/rollback-db/
		ssh root@$1 . /tmp/rollback-db/rollback-db.sh  $2 $APP_BACKUP_NAME
		if [ ! -d /scripts/deploy/log/$2/$1 ]
			then
			mkdir -p /scripts/deploy/log/$2/$1 
		fi
			scp root@$1:/var/log/deploy/$2/err_rollback_db_${APP_BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
			echo "============================$1 RUNNING OVER============================================"
	else
		echo "" >/dev/null
	fi
	}
##############################################################################
#Upload script file to the ANALYTICS PHP server $1:ip $2:environment
function deploy-analytics-php
	{
	if [ "${is_deploy_ana}x" == "yx" ];then
		scp -r ${DEPLOY_DIR}/backup/$2/$1/analytics/${ANA_BACKUP_NAME}/* root@$1:${ANAPATH}/
		scp -r /scripts/deploy/analytics/rollback/rollback-php-analytics root@$1:/tmp
		scp /scripts/deploy/environment/analytics-php.sh root@$1:/tmp/rollback-php-analytics/
		ssh root@$1 . /tmp/rollback-php-analytics/rollback-analytics.sh $2 $ANA_BACKUP_NAME
		echo "============================$1 RUNNING OVER============================================"
	else
		echo "" >/dev/null
	fi
	}
##############################################################################
#Upload script file to the ANALYTICS DB server $1:ip $2:environment
function deploy-analytics-db
	{
	if [ "${is_deploy_ana}x" == "yx" ];then
		scp ${DEPLOY_DIR}/backup/$2/$1/analytics/*_${ANA_BACKUP_NAME}.dump root@$1:/tmp
		scp -r /scripts/deploy/analytics/rollback/rollback-db-analytics root@$1:/tmp
		scp /scripts/deploy/environment/analytics-db.sh root@$1:/tmp/rollback-db-analytics/
		ssh root@$1 . /tmp/rollback-db-analytics/rollback-analytics-db.sh $2 $ANA_BACKUP_NAME
		if [ ! -d /scripts/deploy/log/$2/$1 ]
			then
			mkdir -p /scripts/deploy/log/$2/$1
		fi
			scp root@$1:/var/log/deploy/$2/err_rollback_analytics_db_${ANA_BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
		echo "============================$1 RUNNING OVER============================================"
	else
		echo "" >/dev/null
	fi
	}
##############################################################################
#Determine the deployment environment and configuration of IP
case $ENVIRONMENT in
			"30QA")
				##########################################
				for ip in "${E30QA_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${E30QA_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${E30QA_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${E30QA_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			"30staging")
				##########################################
				for ip in "${E30staging_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${E30staging_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${E30staging_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${E30staging_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			"30prod")
				for ip in "${E30prod_php[@]}"
				do
				ssh root@$ip </scripts/deploy/update/rewrite.sh &>/dev/null
				done
				##########################################
				for ip in "${E30prod_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${E30prod_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${E30prod_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${E30prod_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT
				done
				#########################################
				read -p "After the completion of the test,please input [y/n]" anwser
				case $anwser in 
							Y|y)
							for ip in "${E30prod_php[@]}" 
							do
								scp /scripts/deploy/update/after_test.sh root@$ip:/tmp
								if
									ssh root@$ip . /tmp/after_test.sh
								then
									ssh root@$ip "rm -f /tmp/after_test.sh "
								else
									echo "rewrite back faild "
								fi
								
							done
							;;
							N|n)
							echo "Didn't change anything"
							;;
							*)
							echo "Input error,Didn't change anything"
							;;
				esac
				;;
			"test30QA")
				##########################################
				for ip in "${Etest30QA_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${Etest30QA_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${Etest30QA_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${Etest30QA_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			"test30staging")
				##########################################
				for ip in "${Etest30staging_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${Etest30staging_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${Etest30staging_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${Etest30staging_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			"test30prod")
				for ip in "${Etest30prod_php[@]}"
				do
				ssh root@$ip </scripts/deploy/update/rewrite.sh $ENVIRONMENT &>/dev/null
				done
				##########################################
				for ip in "${Etest30prod_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT
				done
				##########################################
				for ip in "${Etest30prod_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${Etest30prod_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT
				done
				#########################################
				for ip in "${Etest30prod_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT
				done
				#########################################
				read -p "After the completion of the test,please input [y/n]" anwser
				case $anwser in 
							Y|y)
							for ip in "${Etest30prod_php[@]}" 
							do
								scp /scripts/deploy/update/after_test.sh root@$ip:/tmp
								if
									ssh root@$ip . /tmp/after_test.sh $ENVIRONMENT
								then
									ssh root@$ip "rm -f /tmp/after_test.sh "
								else
									echo "rewrite back faild "
								fi
								
							done
							;;
							N|n)
							echo "Didn't change anything"
							;;
							*)
							echo "Input error,Didn't change anything"
							;;
				esac
				;;
			*)
				echo "please reset"
				;;
esac
