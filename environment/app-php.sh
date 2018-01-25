#!/bin/bash
#Configure each environment variable
case $1 in
	"30QA")
		DTPATH=/media/sf_src
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		#Whether the data directory is external mount or not, 0 means yes, 1 means no
		Is_mount_data=1
		build_number=$4
		LOGDIR=/var/log/deploy/${ENVIRONMENT}/
		APPUICONFIG="config.qa.php"
		APPUICONFIG_BAK="config.staging.php"
		APPCORECONFIG="config.qa.php"
		APPCORECONFIG_BAK="config.staging.php"
		PHINXFILENAME="phinx.qa.yml"
		PHINXFILENAME_BAK="phinx.staging.yml"
		PHINXENVIRONMENTS="qa"
		FORMSLINK="http://api.localhost/api/dev/revision-forms"
		ROLESLINK="http://api.localhost/api/dev/invalidate-roles"
		REMOTE_PASS=$3
		REMOTE_UI_URL="root@${Deploy_server}:/30deployment/app-ui"
		REMOTE_CORE_URL="root@${Deploy_server}:/30deployment/app-core"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.30qa.dealtap.ca"
		AppFrontEnd_MAIN="http://app.30qa.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.30qa.dealtap.ca/"
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(localhost dealtap dealtap pre_prod)
		ConfigRedis_SERVER="localhost"
		ConfigRedis_PORT=6739
		Config_URL_UI="http://app.30qa.dealtap.ca"
		Config_URL_CORE="http://api.30qa.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.30qa.dealtap.ca/api http://dealtap-analytics/api)
		#-------App-ui config file argument end------------
		#-------phinx.yml file argument--------------------
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql localhost pre_prod public dealtap dealtap 5432 utf8)
		;;
	"30staging")
		DTPATH=/media/sf_src
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		Is_mount_data=1
		build_number=$4
		LOGDIR=/var/log/deploy/${ENVIRONMENT}/
		APPUICONFIG="config.staging.php"
		APPUICONFIG_BAK="config.qa.php"
		APPCORECONFIG="config.staging.php"
		APPCORECONFIG_BAK="config.qa.php"
		PHINXFILENAME="phinx.staging.yml"
		PHINXFILENAME_BAK="phinx.qa.yml"
		PHINXENVIRONMENTS="staging"
		FORMSLINK="https://api.localhost/api/dev/revision-forms"
		ROLESLINK="https://api.localhost/api/dev/invalidate-roles"
		REMOTE_PASS=$3
		REMOTE_UI_URL="root@${Deploy_server}:/30deployment/app-ui"
		REMOTE_CORE_URL="root@${Deploy_server}:/30deployment/app-ui"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.30staging.dealtap.ca"
		AppFrontEnd_MAIN="http://app.30staging.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.30staging.dealtap.ca/"
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.48.136 dealtap dealtap pre-prod)
		ConfigRedis_SERVER="localhost"
		ConfigRedis_PORT=6739
		Config_URL_UI="http://app.30staging.dealtap.ca"
		Config_URL_CORE="http://api.30staging.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.30staging.dealtap.ca/api http://dealtap-analytics/api)
		#-------App-ui config file argument end------------
		#-------phinx.yml file argument--------------------
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.48.136 pre-prod public dealtap dealtap 5432 utf8)
		;;
	"30prod")
		DTPATH=/media/sf_src 
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		Is_mount_data=0
		build_number=$4
		LOGDIR=/var/log/deploy/${ENVIRONMENT}/
		APPUICONFIG="config.prod.php"
		APPUICONFIG_BAK="config.production.php"
		APPCORECONFIG="config.prod.php"
		APPCORECONFIG_BAK="config.production.php"
		PHINXFILENAME="phinx.prod.yml"
		PHINXFILENAME_BAK="phinx.production.yml"
		PHINXENVIRONMENTS="prod"
		FORMSLINK="http://api.localhost/api/dev/revision-forms"
		ROLESLINK="http://api.localhost/api/dev/invalidate-roles"
		REMOTE_PASS=$3
		REMOTE_UI_URL="root@${Deploy_server}:/30deployment/app-ui"
		REMOTE_CORE_URL="root@${Deploy_server}:/30deployment/app-core"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.predprod.dealtap.ca"
		AppFrontEnd_MAIN="http://app.predprod.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.predprod.dealtap.ca/"
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.176.77 dealtap dealtap dealtap)
		ConfigRedis_SERVER="localhost"
		ConfigRedis_PORT=6739
		Config_URL_UI="http://app.predprod.dealtap.ca"
		Config_URL_CORE="http://api.predprod.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.predprod.dealtap.ca/api http://analytics.predprod.dealtap.ca/api)
		#-------App-ui config file argument end------------
		#-------phinx.yml file argument--------------------
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.176.77 dealtap public dealtap dealtap 5432 utf8)
		;;
	"test30QA")
		DTPATH=/media/sf_src
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		Is_mount_data=1
		build_number=$4
		LOGDIR=/var/log/deploy/${ENVIRONMENT}/
		APPUICONFIG="config.qa.php"
		APPUICONFIG_BAK="config.staging.php"
		APPCORECONFIG="config.qa.php"
		APPCORECONFIG_BAK="config.staging.php"
		PHINXFILENAME="phinx.qa.yml"
		PHINXFILENAME_BAK="phinx.staging.yml"
		PHINXENVIRONMENTS="qa"
		FORMSLINK="http://api.localhost/api/dev/revision-forms"
		ROLESLINK="http://api.localhost/api/dev/invalidate-roles"
		REMOTE_PASS=$3
		REMOTE_UI_URL="root@${Deploy_server}:/storage/deploy/app-ui"
		REMOTE_CORE_URL="root@${Deploy_server}:/storage/deploy/app-core"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.dqa.dealtap.ca"
		AppFrontEnd_MAIN="http://app.dqa.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.dqa.dealtap.ca/"
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(localhost dealtap dealtap pre-prod)
		ConfigRedis_SERVER="localhost"
		ConfigRedis_PORT=6739
		Config_URL_UI="http://app.dqa.dealtap.ca"
		Config_URL_CORE="http://api.dqa.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.dqa.dealtap.ca/api http://analytics.dqa.dealtap.ca/api)
		#-------App-ui config file argument end------------
		#-------phinx.yml file argument--------------------
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql localhost pre-prod public dealtap dealtap 5432 utf8)
		;;
	"test30staging")
		DTPATH=/media/sf_src
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		Is_mount_data=1
		build_number=$4
		LOGDIR=/var/log/deploy/${ENVIRONMENT}/
		APPUICONFIG="config.staging.php"
		APPUICONFIG_BAK="config.qa.php"
		APPCORECONFIG="config.staging.php"
		APPCORECONFIG_BAK="config.qa.php"
		PHINXFILENAME="phinx.staging.yml"
		PHINXFILENAME_BAK="phinx.qa.yml"
		PHINXENVIRONMENTS="staging"
		FORMSLINK="https://api.localhost/api/dev/revision-forms"
		ROLESLINK="https://api.localhost/api/dev/invalidate-roles"
		REMOTE_PASS=$3
		REMOTE_UI_URL="root@${Deploy_server}:/storage/deploy/app-ui"
		REMOTE_CORE_URL="root@${Deploy_server}:/storage/deploy/app-ui"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.dstaging.dealtap.ca"
		AppFrontEnd_MAIN="http://app.dstaging.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.dstaging.dealtap.ca/"
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.176.73 dealtap dealtap pre-prod)
		ConfigRedis_SERVER="localhost"
		ConfigRedis_PORT=6739
		Config_URL_UI="http://app.dstaging.dealtap.ca"
		Config_URL_CORE="http://api.dstaging.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.dstaging.dealtap.ca/api http://analytics.dstaging.dealtap.ca/api)
		#-------App-ui config file argument end------------
		#-------phinx.yml file argument--------------------
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.176.73 pre-prod public dealtap dealtap 5432 utf8)
		;;
	"test30prod")
		DTPATH=/media/sf_src 
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		Is_mount_data=1
		build_number=$4
		LOGDIR=/var/log/deploy/${ENVIRONMENT}/
		APPUICONFIG="config.prod.php"
		APPUICONFIG_BAK="config.production.php"
		APPCORECONFIG="config.prod.php"
		APPCORECONFIG_BAK="config.production.php"
		PHINXFILENAME="phinx.prod.yml"
		PHINXFILENAME_BAK="phinx.production.yml"
		PHINXENVIRONMENTS="prod"
		FORMSLINK="http://api.localhost/api/dev/revision-forms"
		ROLESLINK="http://api.localhost/api/dev/invalidate-roles"
		REMOTE_PASS=$3
		REMOTE_UI_URL="root@${Deploy_server}:/storage/deploy/app-ui"
		REMOTE_CORE_URL="root@${Deploy_server}:/storage/deploy/app-core"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.predprod.dealtap.ca"
		AppFrontEnd_MAIN="http://app.predprod.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.predprod.dealtap.ca/"
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.176.77 dealtap dealtap dealtap)
		ConfigRedis_SERVER="localhost"
		ConfigRedis_PORT=6739
		Config_URL_UI="http://app.predprod.dealtap.ca"
		Config_URL_CORE="http://api.predprod.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.predprod.dealtap.ca/api http://analytics.predprod.dealtap.ca/api)
		#-------App-ui config file argument end------------
		#-------phinx.yml file argument--------------------
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.176.77 dealtap public dealtap dealtap 5432 utf8)
		;;
	*)
		
		echo "please reset"
		;;
esac
