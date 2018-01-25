#/bin/bash
if [ -z ${ENVIRONMENT} ];then
	echo "The project environment cannot be null"
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
##########################################################################################
if [ -z ${is_deploy_app} ];then
	echo "Whether to deploy application project,the answer cannot be null"
	exit 1
fi
is_deploy_app=$(echo ${is_deploy_app} | tr '[A-Z]' '[a-z]')
if [ "${is_deploy_app}x" == "yx" ];then
	if 
		cd ${DEPLOY_DIR}/app-ui
	then
		git branch
	else
		echo "app-ui does not exist"
		exit 1
	fi
	if [ -z ${app_build_number} ];then
		echo "build number cannot be null"
		exit 1
	else
		if
			cd ${DEPLOY_DIR}/app-ui && git branch | grep -q ".*${app_build_number}$"
		then
			echo "" >/dev/null
		else
			echo "Build number ${app_build_number} doesnot exist"
			exit 1
		fi
	fi
fi
################################################################################################
if [ -z ${is_deploy_ana} ];then
	echo "Whether to deploy analytics project,the answer cannot be null"
	exit 1
fi
is_deploy_ana=$(echo ${is_deploy_ana} | tr '[A-Z]' '[a-z]')
if [ "${is_deploy_ana}x" == "yx" ];then
	if 
		cd ${DEPLOY_DIR}/analytics
	then
		git branch
	else
		echo "analytics does not exist"
		exit 1
	fi
	if [ -z ${ana_build_number} ];then
		echo "build number cannot be null"
		exit 1
	else
		if
			cd ${DEPLOY_DIR}/analytics && git branch | grep -q ".*${ana_build_number}$"
		then
			echo "" >/dev/null
		else
			echo "Build number ${ana_build_number} doesnot exist"
			exit 1
		fi
	fi
fi
###################################################################################################
if [ -z pass1 ];then
	echo "Root user password cannot be null"
	exit 1
fi
if [ -z pass1 ];then
	echo "Root user password cannot be null"
	exit 1
fi
if [ "${pass1}x" == "${pass2}x" ];then
	pass=${pass1}
else
	echo "The password you enter twice must be the same."
	exit 1
fi
###############################################################################################
TIMESTAMP=$(date +%s)
source /scripts/deploy/environment/environment-ip.sh
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
TMP_IP="E${ENVIRONMENT}_php[@]"
TMP_IP=${!TMP_IP}
TMP_ANA_IP="E${ENVIRONMENT}_analytics_php[@]"
TMP_ANA_IP=${!TMP_ANA_IP}
if
		ssh -o StrictHostKeyChecking=no root@${TMP_IP[0]} "test -d ${DTPATH}/app-ui"
then
		older_build_number=$(ssh -o StrictHostKeyChecking=no root@${TMP_IP[0]} "cd ${DTPATH}/app-ui && git branch | grep '^*' | awk '{printf \$2}'")
		APP_BACKUP_NAME="${older_build_number}_${TIMESTAMP}"
else
		APP_BACKUP_NAME="30-$(date '+%y%m%d')-0_${TIMESTAMP}"
fi
if
		ssh -o StrictHostKeyChecking=no root@${TMP_ANA_IP[0]} "test -d ${ANAPATH}/analytics"
then
		older_build_number=$(ssh -o StrictHostKeyChecking=no root@${TMP_ANA_IP[0]} "cd ${ANAPATH}/analytics && git branch | grep '^*' | awk '{printf \$2}'")
		ANA_BACKUP_NAME="${older_build_number}_${TIMESTAMP}"
else
		ANA_BACKUP_NAME="30-$(date '+%y%m%d')-0_${TIMESTAMP}"
fi
echo "==============================================================================================="  >>/scripts/deploy/version/note
echo "${ENVIRONMENT}:$(date '+%Y-%m-%d %T') build number:${app_build_number},${ana_build_number} (for rollback backup file name:${APP_BACKUP_NAME},${ANA_BACKUP_NAME})" >>/scripts/deploy/version/note
echo "==============================================================================================="  >>/scripts/deploy/version/note
#Upload script file to the PHP server $1:ip $2:environment
function deploy-core-php
	{
	if [ "${is_deploy_app}x" == "yx" ];then
		scp -r /scripts/deploy/update/php root@$1:/tmp
		scp /scripts/deploy/environment/app-php.sh root@$1:/tmp/php/
		ssh root@$1 . /tmp/php/php-deploy.sh $2 $APP_BACKUP_NAME $pass $app_build_number
		if [ ! -d /scripts/deploy/log/$2/$1 ]
			then
			mkdir -p /scripts/deploy/log/$2/$1
		fi
		scp root@$1:/var/log/deploy/$2/err_php_${APP_BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
		if [ ! -d ${DEPLOY_DIR}/backup/$2/$1/app ]
			then
			mkdir -p ${DEPLOY_DIR}/backup/$2/$1/app
		fi
		if
			scp -rp root@$1:${DTPATH}/backup/${ENVIRONMENT}/* ${DEPLOY_DIR}/backup/$2/$1/app/
		then
			echo "Transer backup files back successfully"
			ssh root@$1 "rm -rf ${DTPATH}/backup/${ENVIRONMENT}/*"
		else
			echo "Transer backup files back faild"
		fi
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
		scp -r /scripts/deploy/update/db root@$1:/tmp
		scp /scripts/deploy/environment/app-db.sh root@$1:/tmp/db/
		ssh root@$1 . /tmp/db/db-deploy.sh $2 $APP_BACKUP_NAME
		if [ ! -d /scripts/deploy/log/$2/$1 ]
			then
			mkdir -p /scripts/deploy/log/$2/$1
		fi
			scp root@$1:/var/log/deploy/$2/err_db_${APP_BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
		if [ ! -d ${DEPLOY_DIR}/backup/$2/$1/app ]
			then
			mkdir -p ${DEPLOY_DIR}/backup/$2/$1/app
		fi
		if
			scp -p root@$1:/var/backups/deploy/${ENVIRONMENT}/* ${DEPLOY_DIR}/backup/$2/$1/app/
		then
			echo "Transer backup files back successfully"
			ssh root@$1 "rm -rf /var/backups/deploy/${ENVIRONMENT}/*"
		else
			echo "Transer backup files back faild"
		fi
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
		scp -r /scripts/deploy/analytics/update/php-analytics root@$1:/tmp
		scp /scripts/deploy/environment/analytics-php.sh root@$1:/tmp/php-analytics/
		ssh root@$1 . /tmp/php-analytics/php-deploy.sh $2 $ANA_BACKUP_NAME $pass $ana_build_number
		if [ ! -d /scripts/deploy/log/$2/$1 ]
			then
			mkdir -p /scripts/deploy/log/$2/$1
		fi
			scp root@$1:/var/log/deploy/$2/err_analytics_php_${ANA_BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
		if [ ! -d ${DEPLOY_DIR}/backup/$2/$1/analytics ]
			then
			mkdir -p ${DEPLOY_DIR}/backup/$2/$1/analytics
		fi
		if
			scp -rp root@$1:${ANAPATH}/backup/analytics/${ENVIRONMENT}/* ${DEPLOY_DIR}/backup/$2/$1/analytics/
		then
			echo "Transer backup files back successfully"
			ssh root@$1 "rm -rf ${ANAPATH}/backup/analytics/${ENVIRONMENT}/*"
		else
			echo "Transer backup files back faild"
		fi
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
		scp -r /scripts/deploy/analytics/update/db-analytics root@$1:/tmp
		scp /scripts/deploy/environment/analytics-db.sh root@$1:/tmp/db-analytics/
		ssh root@$1 . /tmp/db-analytics/db-deploy.sh $2 $ANA_BACKUP_NAME 
		if [ ! -d/scripts/deploy/log/$2/$1 ]
			then
			mkdir -p /scripts/deploy/log/$2/$1
		fi
		scp root@$1:/var/log/deploy/$2/err_analytics_db_${ANA_BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
		if [ ! -d ${DEPLOY_DIR}/backup/$2/$1/analytics ]
			then
			mkdir -p ${DEPLOY_DIR}/backup/$2/$1/analytics
		fi
		if
			scp -p root@$1:/var/backups/deploy/analytics/${ENVIRONMENT}/* ${DEPLOY_DIR}/backup/$2/$1/analytics/
		then
			echo "Transer backup files back successfully"
			ssh root@$1 "rm -rf /var/backups/deploy/analytics/${ENVIRONMENT}/*"
		else
			echo "Transer backup files back faild"
		fi
		echo "============================$1 RUNNING OVER============================================"
	else
		echo "" >/dev/null
	fi
	}
##############################################################################
#Determine the deployment environment and configuration of IP
case $ENVIRONMENT in
			"30QA")
				for ip in "${E30QA_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${E30QA_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT 
				done 
				############################################	
				for ip in "${E30QA_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT 
					
				done
				###########################################
				for ip in "${E30QA_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT 
				done
				##############################################
				;;
			"30staging")
				for ip in "${E30staging_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${E30staging_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${E30staging_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${E30staging_analytics_php[@]}"
				do
					deploy-analytics-php $ip $ENVIRONMENT 
				done
				;;
			"30prod")
				for ip in "${E30prod_php[@]}"
				do
					scp /scripts/deploy/update/rewrite.sh root@$ip:/tmp/
					if
						ssh root@$ip . /tmp/rewrite.sh $ENVIRONMENT
					then
						ssh root@$ip "rm -f /tmp/rewrite.sh"
					else
						echo "rewrite faild "
					fi
				done
				######################################################
				for ip in "${E30prod_db[@]}"
				do
					deploy-core-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${E30prod_analytics_db[@]}"
				do
					deploy-analytics-db $ip $ENVIRONMENT 
				done 
				############################################	
				for ip in "${E30prod_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT 
					
				done
				###########################################
				for ip in "${E30prod_analytics_php[@]}"
				do
					deploy-analytics-php $ip $ENVIRONMENT 
				done
				##############################################
				case $anwser in 
							Y|y)
							for ip in "${E30prod_php[@]}" 
							do
								scp /scripts/deploy/update/after_test.sh root@$ip:/tmp/
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
##########################################################  TEST  #############################################################
			"test30QA")
				for ip in "${Etest30QA_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${Etest30QA_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT 
				done 
				############################################	
				for ip in "${Etest30QA_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT 
					
				done
				###########################################
				for ip in "${Etest30QA_analytics_php[@]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT 
				done
				##############################################
				;;
			"test30staging")
				for ip in "${Etest30staging_db[@]}" 
				do
					deploy-core-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${Etest30staging_analytics_db[@]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${Etest30staging_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${Etest30staging_analytics_php[@]}"
				do
					deploy-analytics-php $ip $ENVIRONMENT 
				done
				;;
			"test30prod")
				for ip in "${Etest30prod_php[@]}"
				do
					scp /scripts/deploy/update/rewrite.sh root@$ip:/tmp/
					if
						ssh root@$ip . /tmp/rewrite.sh $ENVIRONMENT
					then
						ssh root@$ip "rm -f /tmp/rewrite.sh"
					else
						echo "rewrite faild "
					fi
				done
				######################################################
				for ip in "${Etest30prod_db[@]}"
				do
					deploy-core-db $ip $ENVIRONMENT 
				done
				###########################################
				for ip in "${Etest30prod_analytics_db[@]}"
				do
					deploy-analytics-db $ip $ENVIRONMENT 
				done 
				############################################	
				for ip in "${Etest30prod_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT 
					
				done
				###########################################
				for ip in "${Etest30prod_analytics_php[@]}"
				do
					deploy-analytics-php $ip $ENVIRONMENT 
				done
				##############################################
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
