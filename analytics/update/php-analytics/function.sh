#!/bin/bash
#Backup analytics
function backup-analytics-core
	{
		if [ ! -d ${ANALOGDIR} ]
			then
				mkdir -p ${ANALOGDIR}
		fi
		current_day=`date +%Y-%m-%d`
		echo $current_day > ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		echo "=====================backup-analytics-core start $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		if [ -d ${ANAPATH}/${PROJECT} ];then
			if [ ! -d ${ANAPATH}/backup/${PROJECT}/${ENVIRONMENT}/${BACKUP_NAME} ]
			then
				mkdir -p ${ANAPATH}/backup/analytics/${ENVIRONMENT}/${BACKUP_NAME}
			fi
			if [ ! -e ${ANAPATH}/backup/analytics/${ENVIRONMENT}/${BACKUP_NAME}/${PROJECT}.tar.gz ]
				then
				cd ${ANAPATH}
				tar -zcf ${ANAPATH}/backup/analytics/${ENVIRONMENT}/${BACKUP_NAME}/${PROJECT}.tar.gz ${PROJECT} >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
			else
				echo "${PROJECT} Project has been backup without backup again"
			fi
			echo "=====================backup-analytics-core end $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		else
			echo "${PROJECT} Project no found"
			return 10
		fi
	}
############################################################################################################################
#Git pull latest code into analytics
function update-analytics
	{
		if [ -e /root/.ssh/config ] && grep -q "Host ${Deploy_server}" /root/.ssh/config
		then
			echo "" &>/dev/null
		else
			echo -e "Host ${Deploy_server}\nStrictHostKeyChecking no\nUserKnownHostsFile /dev/null" >>/root/.ssh/config
		fi
		if 
			which sshpass >/dev/null
		then
			echo "" &>/dev/null
		else
			apt-get install sshpass -y &>> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		fi
		#----------update analytics Start----------#
		if [ -e ${ANAPATH}/${PROJECT} ]
			then 
				echo "=====================update ${PROJECT} Start $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				cd ${ANAPATH}/${PROJECT}/
				if
					git remote -v | grep  "origin" | grep -wq "${REMOTE_ANALYTICS_URL}"
				then
					echo ""
				else
					if
						git remote add origin ${REMOTE_ANALYTICS_URL} &>/dev/null
					then
						echo ""
					else
						git remote set-url origin ${REMOTE_ANALYTICS_URL} &>/dev/null
					fi
				fi
				echo "=====================git status Start $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				git status >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				echo "=====================git status End $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				echo "=====================git pull Start $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				git config --global user.email "dealtap@dealtap.com"
				git config --global user.name "dealtap"
				#git add -A && git commit -m $(date +%s) >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				git stash >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				if
					sshpass -p "${REMOTE_PASS}" git pull >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				then
					echo "" &>/dev/null
				else
					cd ${ANAPATH} && rm -rf ${ANAPATH}/${PROJECT}/
					cd ${ANAPATH} && sshpass -p "${REMOTE_PASS}" git clone ${REMOTE_ANALYTICS_URL} >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
					if [ $? -ne 0 ]
						then
							echo "Analytics clone faild"
							return 1
					fi
				fi
				cd ${ANAPATH}/${PROJECT}/
				git stash >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				if 
					git checkout ${build_number} >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				then
					echo "" &>/dev/null
				else
					echo "analytics checkout branch ${build_number} faild"
					return 1
				fi
				chmod -R 777 ${ANAPATH}/*
				echo "=====================git pull End $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				echo "=====================update ${PROJECT} End $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 
				return 0
		else
				cd ${ANAPATH} && sshpass -p "${REMOTE_PASS}" git clone ${REMOTE_ANALYTICS_URL} >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				if [ $? -ne 0 ];then
					return 1
				fi
				cd ${ANAPATH}/analytics
				git checkout ${build_number} >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				chmod -R 777 ${ANAPATH}/*
		fi
		#----------update analytics End----------#
	}

############################################################################################################################
#Copy the config.php files
function copy-analytics-conf
	{	
		echo "=====================copy-analytics-conf Start $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		if [ -e ${ANAPATH}/${PROJECT}/source/config/${ANACONFIG} ]
			then
			cd ${ANAPATH}/${PROJECT}/source/config && cp ${ANACONFIG} config.php &>> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		else
			if
				cd ${ANAPATH}/${PROJECT}/source/config && cp ${ANACONFIG_BAK} config.php &>> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
			then
				echo ""
			else
				echo "${ANACONFIG} no found"
				return 1
			fi
		fi
		if [ -e ${ANAPATH}/${PROJECT}/${ANAPHINX} ]
			then
			cd ${ANAPATH}/${PROJECT} && cp ./${ANAPHINX} phinx.yml &>> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		else
			if
				cd ${ANAPATH}/${PROJECT} && cp ./${ANAPHINX_BAK} phinx.yml &>> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
			then
				echo ""
			else
				echo "${ANAPHINX} no found"
				return 1
			fi
		fi
		echo "=====================copy-analytics-conf end $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
	}
function modify-configuration {
if
	cd ${ANAPATH}/${PROJECT}/source/config/
then
	sed -i '/Enum\\ConfigAuth::WHITELISTED_IPS/,/^[\t]*],$/c\\t\tEnum\\ConfigAuth::WHITELISTED_IPS => [\n\t\t],' ./config.php
	for str in ${WHITELISTED_IPS[@]}
		do
			sed -i '/Enum\\ConfigAuth::WHITELISTED_IPS/a\\t\t\t'\'${str}\'',' ./config.php
		done
	for ((i=0;i<${#POSTGRES_arguments[@]};i++))
		do
			if [ $i -eq $((${#POSTGRES_arguments[@]}-1)) ];then
				sed -i '/Enums*\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\''' ./config.php
			else
				sed -i '/Enums*\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\'',' ./config.php
			fi
		done
else
	echo "configuration folder does not exist "
	return 1
fi
if [ -e ${ANAPATH}/analytics/phinx.yml ];then
cd ${ANAPATH}/analytics/
row=$(grep -n "default_database:" ./phinx.yml | cut -d ":" -f 1)
#Note:
#The format of the "sed" below won't be changed
	if [ ! -z $row ]
	then
		sed -i ''${row}',$c\    default_database: '${ANAPHINXENVIRONMENTS}'\
    '${ANAPHINXENVIRONMENTS}':\
        adapter: '${Phinx_pgsql[0]}'\
        host: '${Phinx_pgsql[1]}'\
        name: '${Phinx_pgsql[2]}'\
        schema: '${Phinx_pgsql[3]}'\
        user: '${Phinx_pgsql[4]}'\
        pass: '${Phinx_pgsql[5]}'\
        port: '${Phinx_pgsql[6]}'\
        charset: '${Phinx_pgsql[7]}'' ./phinx.yml
	else
		echo "modify phinx.yml faild"
		return 1
	fi
else
	return 1
fi

}	
############################################################################################################################
#Install composer dependencies
function composer-analytics
	{	
		if [ -e ${ANAPATH}/${PROJECT}/composer.json ]
			then
				echo "=====================composer ${PROJECT} Start $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				cd ${ANAPATH}/${PROJECT}
				num=$(grep -in "phalcon/devtools" ./composer.json | cut -d ":" -f 1)
				version=$(grep -i "phalcon/devtools" ./composer.json | cut -d "\"" -f 4 | cut -d "^" -f 2)
				if [ -n $version ]
					then
						sed -i "${num}s/${version}/3.0.3/g" ./composer.json
				fi
				composer config repo.packagist composer https://packagist.phpcomposer.com >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				composer update -n >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				if [ $? -ne 0 ]
					then 
						rm -f ./composer.lock
						rm -rf ./vendor/
						composer install &>> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
						if [ $? -ne 0 ]
							then 
								return 1
						else
							echo 'composer install app-ui successfully' >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
								
						fi
				else
					echo "composer update ${PROJECT} successfully" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
				fi
				echo "=====================composer analytics End $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
				chmod -R 777 ${ANAPATH}/*
				return 0
		else
				return 1
		fi
	}

############################################################################################################################
#Migrate the database
function migrate-analytics
	{	
		echo "=====================migrate-analytics Start $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
		if [ -e /${ANAPATH}/${PROJECT}/vendor/bin/phinx ]
			then
				cd ${ANAPATH}/${PROJECT} && vendor/bin/phinx migrate -e ${ANAPHINXENVIRONMENTS} >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log 2>&1
			if [ $? -ne 0 ]
					then
						return 1
			fi
		else
				return 1		
		fi
		echo "=====================migrate-analytics end $(date +%T)====================" >> ${ANALOGDIR}err_analytics_php_${BACKUP_NAME}.log
	}
############################################################################################################################
#Output running state
function echo-status
	{	
		echo "=====================$1 start $(date +%T)===================="
		$1
		is=$?
		if [ $is -eq 0 ]
			then
				echo "$1 success"
		elif [ $is -eq 10 ];then
			echo ""
		else 
			echo "$1 faild"
			sleep 10
			exit 1
		fi
		echo "=====================$1 end $(date +%T)===================="



	}