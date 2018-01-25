#!/bin/bash
#backup all of core 
function backup-source
	{
		# Create backup DT directory
		if [ ! -e ${LOGDIR} ]
			then
				mkdir -p ${LOGDIR}
		fi
		current_day=`date +%Y-%m-%d`
		echo $current_day > ${LOGDIR}err_php_${BACKUP_NAME}.log
		# backup score
		echo "=====================backup core start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		if [ -d ${DTPATH}/app-ui -a -d ${DTPATH}/app-core ]
			then 
				mkdir -p ${DTPATH}/backup/${ENVIRONMENT}/${BACKUP_NAME}
				if [ ! -e ${DTPATH}/backup/${ENVIRONMENT}/${BACKUP_NAME}/app-ui.tar.gz ]
					then 
						cd ${DTPATH}
						tar zcf ${DTPATH}/backup/${ENVIRONMENT}/${BACKUP_NAME}/app-ui.tar.gz app-ui >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				else 
					echo "Project has been backup without backup again"
				fi
				if [ ! -e ${DTPATH}/backup/${ENVIRONMENT}/${BACKUP_NAME}/app-core.tar.gz ]
					then 
						cd ${DTPATH}
						tar zcf ${DTPATH}/backup/${ENVIRONMENT}/${BACKUP_NAME}/app-core.tar.gz app-core >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				else
					echo "Project has been backup without backup again"
					return 10
				fi
		else
			echo "project no found"
			echo "project no found" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
			return 10
		fi
		echo "=====================backup core end $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
	}
############################################################################################################################
function app-ui-git	
	{
		if [ -e /root/.ssh/config ] && grep -q "Host ${Deploy_server}" /root/.ssh/config
		then
			echo "" &>/dev/null
		else
			echo -e "Host ${Deploy_server}\nStrictHostKeyChecking no\nUserKnownHostsFile /dev/null" >>/root/.ssh/config
		fi
		if 
			which sshpass &>/dev/null
		then
			echo "" &>/dev/null
		else
			apt-get install sshpass -y &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
		fi
		#----------App UI Start----------#
		#https://saninco:174pass026@bitbucket.org
		if [ -e ${DTPATH}/app-ui ]
			then 
				echo "=====================App UI Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				cd ${DTPATH}/app-ui
				if
					git remote -v | grep  "origin" | grep -wq "${REMOTE_UI_URL}"
				then
					echo "" &>/dev/null
				else
					if
						git remote add origin ${REMOTE_UI_URL} &>/dev/null
					then
						echo "" &>/dev/null
					else
						git remote set-url origin ${REMOTE_UI_URL} &>/dev/null
					fi	
				fi
				echo "=====================git status Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				git status >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				echo "=====================git status End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				echo "=====================git pull Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				#git reset --hard >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				git config --global user.email "dealtap@dealtap.com"
				git config --global user.name "dealtap"
				#git add -A && git commit -m $(date +%s) >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				git stash >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				if
				sshpass -p "${REMOTE_PASS}" git pull >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				then
					echo "" &>/dev/null
				else
					cd ${DTPATH} && rm -rf ${DTPATH}/app-ui
					cd ${DTPATH} && sshpass -p "${REMOTE_PASS}" git clone  ${REMOTE_UI_URL} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
					if [ $? -ne 0 ]
					then
						echo "App-ui clone faild"
						return 1
					fi
				fi
				cd ${DTPATH}/app-ui
				echo $(date +%s) >${DTPATH}/deploy_time
				git stash >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				if
					git checkout ${build_number} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				then
					echo "" &>/dev/null
				else
					echo "app-ui checkout branch ${build_number} faild"
					return 1
				fi
				echo "=====================git pull End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				echo "=====================App UI End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				chmod -R 777 ${DTPATH}/*
				return 0
		else 
			cd ${DTPATH} 
			sshpass -p "${REMOTE_PASS}" git clone  ${REMOTE_UI_URL} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
			if [ $? -ne 0 ]
			then
				return 1
			fi
			cd ${DTPATH}/app-ui
			
			git checkout ${build_number} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
			chmod -R 777 ${DTPATH}/*
		fi
		#----------App UI End----------#
	
	}
############################################################################################################################
#Git pull latest code into app-core
function app-core-git
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
			apt-get install sshpass -y &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
		fi
		#----------App Core Start----------#
		if [ -e ${DTPATH}/app-core ]
			then 
				echo "=====================App Core Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				cd ${DTPATH}/app-core
				if
					git remote -v | grep  "origin" | grep -wq "${REMOTE_CORE_URL}"
				then
					echo "" &>/dev/null
				else
					if
						git remote add origin ${REMOTE_CORE_URL} &>/dev/null
					then
						echo "" &>/dev/null
					else
						git remote set-url origin ${REMOTE_CORE_URL} &>/dev/null
					fi
				fi
				echo "=====================git status Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				git status >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				echo "=====================git status End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				echo "=====================git pull Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				#git reset --hard >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				git config --global user.email "dealtap@dealtap.com"
				git config --global user.name "dealtap"
				#git add -A && git commit -m $(date +%s) >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				git stash >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				if
					sshpass -p ${REMOTE_PASS} git pull >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				then
					echo "" &>/dev/null
				else
					cp -r ${DTPATH}/app-core/data ${DTPATH}/data_${BACKUP_NAME}
					cp -r ${DTPATH}/app-core/import ${DTPATH}/import_${BACKUP_NAME}
					cd ${DTPATH} && rm -rf ${DTPATH}/app-core
					if
						cd ${DTPATH} && sshpass -p ${REMOTE_PASS} git clone ${REMOTE_CORE_URL} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
					then
						cp -r ${DTPATH}/data_${BACKUP_NAME} ${DTPATH}/app-core/data
						cp -r ${DTPATH}/import_${BACKUP_NAME} ${DTPATH}/app-core/import
						rm -rf ${DTPATH}/data_${BACKUP_NAME} ${DTPATH}/import_${BACKUP_NAME}
					else
						echo "App-core clone faild"
					fi
				fi
				cd ${DTPATH}/app-core
				git stash >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				if
					git checkout ${build_number} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				then
					echo "" &>/dev/null
				else
					echo "app-core checkout branch ${build_number} faild"
					return 1
				fi
				echo "=====================git pull End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				echo "=====================App Core End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
				chmod -R 777 ${DTPATH}/*
				return 0
		else 
			cd ${DTPATH}
			sshpass -p ${REMOTE_PASS} git clone ${REMOTE_CORE_URL} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
			if [ $? -ne 0 ]
				then
					return 1
			fi
			cd ${DTPATH}/app-core
			git checkout ${build_number} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
			wget-date
			wget-import
			chmod -R 777 ${DTPATH}/*
		fi
	}

############################################################################################################################
# Copy the config.php files
function copy-conf
		{
			echo "=====================copy-conf Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
			if [ -e ${DTPATH}/app-ui/app/config/samples/${APPUICONFIG} ]
				then 
					cd ${DTPATH}/app-ui/app/config && cp samples/${APPUICONFIG} config.php
			else
				if
					cd ${DTPATH}/app-ui/app/config && cp samples/${APPUICONFIG_BAK} config.php
				then
					echo "" &>/dev/null
				else
					echo "${APPUICONFIG} no found"
					return 1
				fi
			fi
			if [ -e ${DTPATH}/app-core/app/config/samples/${APPCORECONFIG} ]
				then 
					cd ${DTPATH}/app-core/app/config && cp samples/${APPCORECONFIG} config.php
			else 
				if
					cd ${DTPATH}/app-core/app/config && cp samples/${APPCORECONFIG_BAK} config.php
				then 
					echo "" &>/dev/null
				else
					echo "${APPCORECONFIG} no found"
					return 1
				fi
			fi
			if [ -e ${DTPATH}/app-core/app/config/samples/phinx/${PHINXFILENAME} ]
				then 
					cd ${DTPATH}/app-core/app/config && cp samples/phinx/${PHINXFILENAME} ${DTPATH}/app-core/phinx.yml
			else
				if
					cd ${DTPATH}/app-core/app/config && cp samples/phinx/${PHINXFILENAME_BAK} ${DTPATH}/app-core/phinx.yml
				then
					echo "" &>/dev/null
				else
					echo "${PHINXFILENAME} no found"
					return 1
				fi
			fi
			echo "=====================copy-conf end $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		}
		
############################################################################################################################
function modify-configuration {
#=========app-ui==========
if [ -e ${DTPATH}/app-ui/app/config/config.php ];then
	cd ${DTPATH}/app-ui/app/config/
	num=$(grep -in "ConfigApi::SOURCE" ./config.php | cut -d ":" -f 1)
	j=0
	for i in ${num[@]}
	do
		sed -i ''${i}'c\\t\t\tEnums\\ConfigApi::SOURCE => '\'${ConfigApi_SOURCE[$j]}\'',' ./config.php
		((j++))
	done
else
	return 1
fi
#=========app-core==========
if [ -e ${DTPATH}/app-core/app/config/config.php ];then
	cd ${DTPATH}/app-core/app/config/
	sed -i '/Enums\\ConfigAnalytics::SERVICE_URL/c\\t\tEnums\\ConfigAnalytics::SERVICE_URL          => '\'${ConfigAnalytics_SERVICE_URL}\'',' ./config.php
	sed -i '/^\t*Enums\\AppFrontEnd::MAIN/,/^[\t]*],*$/c\\t\tEnums\\AppFrontEnd::MAIN => [\n\t\t\tEnums\\ConfigFrontEnd::URL_UI => '\'${AppFrontEnd_MAIN}\'',\n\t\t],' ./config.php
	sed -i '/^\t*Enums\\AppFrontEnd::ALPHA/,/^[\t]*],*$/c\\t\tEnums\\AppFrontEnd::ALPHA => [\n\t\t\tEnums\\ConfigFrontEnd::URL_UI => '\'${AppFrontEnd_ALPHA}\'',\n\t\t]' ./config.php	
	for ((i=0;i<${#POSTGRES_arguments[@]};i++))
	do
		if [ $i -eq $((${#POSTGRES_arguments[@]}-1)) ];then
			sed -i '/Enums\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\''' ./config.php
		else
			sed -i '/Enums\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\'',' ./config.php
		fi
	done
	sed -i '/Enums\\ConfigRedis::SERVER/c\\t\tEnums\\ConfigRedis::SERVER => '\'${ConfigRedis_SERVER}\'',' ./config.php
	sed -i '/Enums\\ConfigRedis::PORT/c\\t\tEnums\\ConfigRedis::PORT => '\'${ConfigRedis_PORT}\''' ./config.php
	sed -i '/Enums\\Config::URL_UI/c\\t\tEnums\\Config::URL_UI => '\'${Config_URL_UI}\'',' ./config.php
	sed -i '/Enums\\Config::URL_CORE/c\\t\tEnums\\Config::URL_CORE => '\'${Config_URL_CORE}\'',' ./config.php
else
	return 1
fi

if [ -e ${DTPATH}/app-core/phinx.yml ];then
	cd ${DTPATH}/app-core/
#Note:
#The format of the "sed" below won't be changed
	
	row=$(grep -n "default_database:" ./phinx.yml | cut -d ":" -f 1)
	if [ ! -z $row ]
	then
		sed -i ''${row}',$c\    default_database: '${PHINXENVIRONMENTS}'\
    '${PHINXENVIRONMENTS}':\
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

#Install composer dependencies for app-ui
function composer-app-ui
		{	
			
			if [ -e ${DTPATH}/app-ui/composer.json ]
				then 
					echo "=====================composer app-ui Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
					cd ${DTPATH}/app-ui
					num=$(grep -in "phalcon/devtools" ./composer.json | cut -d ":" -f 1)
					version=$(grep -i "phalcon/devtools" ./composer.json | cut -d "\"" -f 4 | cut -d "^" -f 2)
					if [ -n $version ]
						then
							sed -i "${num}s/${version}/3.0.3/g" ./composer.json
					fi
					composer config repo.packagist composer https://packagist.phpcomposer.com
					composer update -n &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
					if [ $? -ne 0 ]
						then 
							rm -f ./composer.lock
							rm -rf ./vendor/
							composer install &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
							if [ $? -ne 0 ]
								then 
									return 1
							else
								echo 'composer install app-ui successfully' >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
								
							fi
					else
						echo 'composer update app-ui successfully' >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
					fi
					echo "=====================composerapp-ui End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
					chmod -R 777 ${DTPATH}/*
					return 0
			else
				return 1
			fi
		}
##############################################################################################################################
#Install composer dependencies for app-core
function composer-app-core
		{	
			
			echo "=====================composer app-core Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
			if [ -e ${DTPATH}/app-core/composer.json ]
				then 
					cd ${DTPATH}/app-core
					num=$(grep -in "phalcon/devtools" ./composer.json | cut -d ":" -f 1)
					version=$(grep -i "phalcon/devtools" ./composer.json | cut -d "\"" -f 4 | cut -d "^" -f 2)
					if [ -n $version ]
						then
							sed -i "${num}s/${version}/3.0.3/g" ./composer.json
					fi
					composer config repo.packagist composer https://packagist.phpcomposer.com
					composer update -n &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
					if [ $? -ne 0 ]
						then 
							rm -f ./composer.lock
							rm -rf ./vendor/
							composer install &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
							if [ $? -ne 0 ]
								then 
									return 1
							else
								echo 'composer install app-core successfully' >> ${LOGDIR}err_php_${BACKUP_NAME}.log 
								
							fi
					else
						echo 'composer update app-core successfully' >> ${LOGDIR}err_php_${BACKUP_NAME}.log 
					
					fi
					chmod -R 777 ${DTPATH}/*
					return 0
			else
				return 1
					
			fi
			echo "=====================composer app-core End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		}
############################################################################################################################
#Get additional data, ie: slideshows into local data folder
function wget-date
		{
		echo "=====================wget-date Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		if [ -d ${DTPATH}/app-core ]
			then
				cd ${DTPATH}/app-core
				if
					wget http://cdn.dealtap.ca/app-core/data.zip -P ${DTPATH}/app-core/ &>>/dev/null
				then
					unzip -o data.zip -d ${DTPATH}/app-core/data/ &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
					rm -f data.zip
				else
					echo "wget date faild" 
					echo "wget date faild" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
					return 1
				fi
		else 
				return 1
		fi
		echo "=====================wget-date End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		
		}
############################################################################################################################
#Get import files necessary for seeding
function wget-import
		{
		echo "=====================wget-import Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		if [ -d ${DTPATH}/app-core ]
			then
				cd ${DTPATH}/app-core
				if 
					wget http://cdn.dealtap.ca/app-core/import.zip -P ${DTPATH}/app-core/ &>>/dev/null
				then
					unzip -o import.zip -d ${DTPATH}/app-core/ &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
					rm -f import.zip 
				else
					echo "wget import faild" 
					echo "wget import faild" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
					return 1
				fi
				if
					wget http://cdn.dealtap.ca/app-core/data.zip -P ${DTPATH}/app-core/ &>>/dev/null
				then
					unzip -o data.zip -d ${DTPATH}/app-core/data/ &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
					rm -f data.zip
				else
					echo "wget date faild" 
					echo "wget date faild" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
					return 1
				fi
		else 
				return 1
		fi
		echo "=====================wget-import End $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		
		}
############################################################################################################################
#Migrate the database
function migrate
		{
			echo "=====================migrate Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
			if [ -e ${DTPATH}/app-core/vendor/bin/phinx ]
				then 
					# Migrate the database
					cd ${DTPATH}/app-core && vendor/bin/phinx migrate -e ${PHINXENVIRONMENTS} >> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
				if [ $? -ne 0 ]
						then
							return 1
				fi
			else
				return 1
			fi
			echo "=====================migrate end $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		}
############################################################################################################################
#Delete all files in asset/app directory
function delete-app
	{
		echo "=====================delete-app Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		if [ -e ${DTPATH}/app-ui/public/assets/app ]
			then
				rm -rf ${DTPATH}/app-ui/public/assets/app/* &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
		else
				return 1
		fi
		echo "=====================delete-app end $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log		
	}

############################################################################################################################
#Clean cache
function flushall
	{
		echo "=====================flushall Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
		redis-cli flushall &>> ${LOGDIR}err_php_${BACKUP_NAME}.log 2>&1
		if [ $? -ne 0 ]
			then 
			return 1
		fi
		echo "=====================flushall end $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
	}
############################################################################################################################
#Ensure integrity of permo roles
function roles
		{
			echo "=====================roles Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
			PUBLIC_KEY=$(grep 'Enums\\ConfigAuth::PUBLIC_KEY' ${DTPATH}/app-core/app/config/config.php | cut -d "'" -f 2)
			if
			curl -s -A Chrome/55.0.2883.87 -D /tmp/roles-http -o /tmp/roles-conment "${ROLESLINK}?pk=${PUBLIC_KEY}&qt=$(date +%s)" &>> ${LOGDIR}err_php_${BACKUP_NAME}.log
			then
				sleep 5
				rolescode=$(grep "HTTP" /tmp/roles-http | awk '{printf $2}')
				if [ $rolescode -ne 200 ]
					then 
						rm -f /tmp/roles-http /tmp/roles-conment
						return 1
				else 
					rm -f /tmp/roles-http
					if
						grep -niw "error" /tmp/roles-conment
					then
						rm -f /tmp/roles-conment
						echo "invalidate-roles document output a error"
						return 1
					else
						echo "=====================roles end $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
						return 0
					fi
				fi
			else
				return 1
			fi
			
		}
############################################################################################################################
#Revision-form
function forms
		{
			echo "=====================forms Start $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
			PUBLIC_KEY=$(grep 'Enums\\ConfigAuth::PUBLIC_KEY' ${DTPATH}/app-core/app/config/config.php | cut -d "'" -f 2)
			if
			curl -s -A Chrome/55.0.2883.87 -D /tmp/forms-http -o /tmp/forms-conment "${FORMSLINK}?pk=${PUBLIC_KEY}&qt=$(date +%s)" &>> ${LOGDIR}err_php_${BACKUP_NAME}.log 
			then
				sleep 5
				formscode=$(grep "HTTP" /tmp/forms-http | awk '{printf $2}')
				if [ $formscode -ne 200 ]
					then 
						rm -f /tmp/forms-http /tmp/forms-conment
						return 1
				else 
					rm -f /tmp/forms-http
					if 
						grep -niw "error" /tmp/forms-conment
					then
						rm -f /tmp/forms-conment
						echo "revision-forms document output a error"
						return 1
					else
						echo "=====================forms end $(date +%T)====================" >> ${LOGDIR}err_php_${BACKUP_NAME}.log
						return 0
					fi
				fi
			else
				return 1
			fi
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
