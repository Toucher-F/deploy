#!/bin/bash
#Configure each environment variable
case $1 in
	"30QA")
		#The project home directory
		ANAPATH=/media/sf_src
		#The project name
		PROJECT=analytics
		#The project deploy environment
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		build_number=$4
		#Log directory position
		ANALOGDIR=/var/log/deploy/${ENVIRONMENT}/
		#The configuration file name
		ANACONFIG="config.qa.php"
		ANACONFIG_BAK="config.staging.php"
		ANAPHINX="phinx.qa.yml"
		ANAPHINX_BAK="phinx.staging.yml"
		#migrate the database required parameters (production/development ...)
		ANAPHINXENVIRONMENTS=qa
		REMOTE_PASS=$3
		REMOTE_ANALYTICS_URL="root@${Deploy_server}:/storage/deploy/analytics"
		WHITELISTED_IPS=(138.197.159.206 127.0.0.1 10.137.48.138)
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(localhost dealtap dealtap analytics)
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql localhost analytics public dealtap dealtap 5432 utf8)
		;;
	"30staging")
		ANAPATH=/media/sf_src
		PROJECT=analytics
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		build_number=$4
		ANALOGDIR=/var/log/deploy/${ENVIRONMENT}/
		ANACONFIG="config.staging.php"
		ANACONFIG_BAK="config.qa.php"
		ANAPHINX=phinx.staging.yml
		ANAPHINX_BAK="phinx.qa.yml"
		ANAPHINXENVIRONMENTS=staging
		REMOTE_PASS=$3
		REMOTE_ANALYTICS_URL="root@${Deploy_server}:/storage/deploy/analytics"
		WHITELISTED_IPS=(159.203.56.202 10.137.144.176 138.197.154.96 10.137.48.141 127.0.0.1)
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.48.136 dealtap dealtap analytics)
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.48.136 analytics public dealtap dealtap 5432 utf8)
		;;
	"30prod")
		#The project home directory
		ANAPATH=/media/sf_src
		#The project name
		PROJECT=analytics
		#The project deploy environment
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		build_number=$4
		#Log directory position
		ANALOGDIR=/var/log/deploy/${ENVIRONMENT}/
		#The configuration file name
		ANACONFIG=config.prod.php
		ANACONFIG_BAK="config.production.php"
		ANAPHINX=phinx.prod.yml
		ANAPHINX_BAK="phinx.production.yml"
		#migrate the database required parameters (production/development ...)
		ANAPHINXENVIRONMENTS=prod
		REMOTE_PASS=$3
		REMOTE_ANALYTICS_URL="root@${Deploy_server}:/storage/deploy/analytics"
		WHITELISTED_IPS=(138.197.145.111 10.137.176.76 138.197.145.122 10.137.176.79 127.0.0.1)
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.176.81 dealtap dealtap analytics)
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.176.81 analytics public dealtap dealtap 5432 utf8)
		;;
	"test30QA")
		#The project home directory
		ANAPATH=/media/sf_src
		#The project name
		PROJECT=analytics
		#The project deploy environment
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		build_number=$4
		#Log directory position
		ANALOGDIR=/var/log/deploy/${ENVIRONMENT}/
		#The configuration file name
		ANACONFIG="config.qa.php"
		ANACONFIG_BAK="config.staging.php"
		ANAPHINX="phinx.qa.yml"
		ANAPHINX_BAK="phinx.staging.yml"
		#migrate the database required parameters (production/development ...)
		ANAPHINXENVIRONMENTS=qa
		REMOTE_PASS=$3
		REMOTE_ANALYTICS_URL="root@${Deploy_server}:/storage/deploy/analytics"
		WHITELISTED_IPS=(138.197.158.63 127.0.0.1 10.137.176.66)
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(localhost dealtap dealtap analytics)
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql localhost analytics public dealtap dealtap 5432 utf8)
		;;
	"test30staging")
		ANAPATH=/media/sf_src
		PROJECT=analytics
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		build_number=$4
		ANALOGDIR=/var/log/deploy/${ENVIRONMENT}/
		ANACONFIG="config.staging.php"
		ANACONFIG_BAK="config.qa.php"
		ANAPHINX=phinx.staging.yml
		ANAPHINX_BAK="phinx.qa.yml"
		ANAPHINXENVIRONMENTS=staging
		REMOTE_PASS=$3
		REMOTE_ANALYTICS_URL="root@${Deploy_server}:/storage/deploy/analytics"
		WHITELISTED_IPS=(138.197.158.35 10.137.176.68 127.0.0.1)
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.176.73 dealtap dealtap analytics)
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.176.73 analytics public dealtap dealtap 5432 utf8)
		;;
	"test30prod")
		#The project home directory
		ANAPATH=/media/sf_src
		#The project name
		PROJECT=analytics
		#The project deploy environment
        ENVIRONMENT=$1
		BACKUP_NAME=$2
		Deploy_server=10.137.48.175
		build_number=$4
		#Log directory position
		ANALOGDIR=/var/log/deploy/${ENVIRONMENT}/
		#The configuration file name
		ANACONFIG=config.prod.php
		ANACONFIG_BAK="config.production.php"
		ANAPHINX=phinx.prod.yml
		ANAPHINX_BAK="phinx.production.yml"
		#migrate the database required parameters (production/development ...)
		ANAPHINXENVIRONMENTS=prod
		REMOTE_PASS=$3
		REMOTE_ANALYTICS_URL="root@${Deploy_server}:/storage/deploy/analytics"
		WHITELISTED_IPS=(138.197.145.111 10.137.176.76 138.197.145.122 10.137.176.79 127.0.0.1)
		POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
		POSTGRES_value=(10.137.176.81 dealtap dealtap analytics)
		#Phinx_pgsql=(adapter host   name    schema user    pass    port charset)
		Phinx_pgsql=(pgsql 10.137.176.81 analytics public dealtap dealtap 5432 utf8)
		;;
	*)
		echo "please reset"
		
		;;
esac
