#!/bin/bash
if [ "${action}x" == "testx" ];then
	DEPLOY_DIR="/storage/deploy"
elif [ "${action}x" == "formalx" ];then
	DEPLOY_DIR="/30deployment"
else
	echo "please reset"
	exit 1
fi
##########################################################################################
if [ -z ${is_deploy_app} ];then
	echo "Whether to create build number for application,the answer cannot be null"
	exit 1
fi
is_deploy_app=$(echo ${is_deploy_app} | tr '[A-Z]' '[a-z]')
if [ "${is_deploy_app}x" == "yx" ];then
	if [ -z ${branch} ];then
		echo "APP branch cannot be null"
		exit 1
	fi
fi
##########################################################################################
if [ -z ${is_deploy_ana} ];then
	echo "Whether to create build number for  analytics,the answer cannot be null"
	exit 1
fi
is_deploy_ana=$(echo ${is_deploy_ana} | tr '[A-Z]' '[a-z]')
if [ "${is_deploy_ana}x" == "yx" ];then
	if [ -z ${ana_branch} ];then
		echo "Analytics branch cannot be null"
		exit 1
	fi
fi
##################################################################################################
if [ "${property}x" == "EOFx" ];then
	position="CTO"
elif [ "${property}x" == "QA showstopperx" ];then
	position="QA manager"
elif [ "${property}x" == "scheduled releasex" ];then
	position="PM"
else
	echo "Please reset!"
	exit 1
fi
#############################################################################################################	
version=30	
RQ=$(date +%y%m%d)
APPUSER="saninco"
#Git password
APPPASSWD="174pass026"
APPUIBRANK="${branch}"					
#Git URL of app-ui
APPUILINK="bitbucket.org/dealtap/app-ui.git"
#Git URL of app-core
APPCOREBRANK="${branch}"
APPCORELINK="bitbucket.org/dealtap/app-core.git"
ANAUSER="saninco"
#Git password
ANAPASSWD="174pass026"
#Git URL of analytics
ANALINK="bitbucket.org/dealtap/analytics.git"
#Git branch
ANABRANCH="${ana_branch}"
if [ -d ${DEPLOY_DIR}/app-ui -a -d ${DEPLOY_DIR}/app-core ];then
	if
		cd ${DEPLOY_DIR}/app-ui && git branch | grep ${RQ}
	then
		sub_version=$(($(git branch | grep ${RQ} | tail -n 1 | cut -d "-" -f 3)+1))
		build_number="${version}-${RQ}-${sub_version}"
	else
		build_number="${version}-${RQ}-0"
	fi
else
	build_number="${version}-${RQ}-0"
fi
if [ -d ${DEPLOY_DIR}/analytics ];then
	if
		cd ${DEPLOY_DIR}/analytics && git branch | grep ${RQ}
	then
		ana_sub_version=$(($(git branch | grep ${RQ} | tail -n 1 | cut -d "-" -f 3)+1))
		ana_build_number="${version}-${RQ}-${ana_sub_version}"
	else
		ana_build_number="${version}-${RQ}-0"
	fi
else
	ana_build_number="${version}-${RQ}-0"
fi
function app-update {
if [ ! -d ${DEPLOY_DIR} ];then
	mkdir -p ${DEPLOY_DIR}
fi
cd ${DEPLOY_DIR}
if [ -d ${DEPLOY_DIR}/app-ui ];then
	cd  ${DEPLOY_DIR}/app-ui 
	git config --global user.email "dealtap@dealtap.com"
	git config --global user.name "dealtap"
	if
		git checkout ${APPUIBRANK} && git pull &>/dev/null
	then
		echo "app-ui pull succeed $(date +%T)"
		cd ${DEPLOY_DIR}/app-ui
		if 
			git checkout -b "${build_number}" &>/dev/null
		then
			echo "app-ui build number: ${build_number}"
		else
			echo "app-ui build branch faild"
			exit 1
		fi
	else
		echo "app-ui pull faild $(date +%T)"
		exit 1
	fi
else
	if
		cd ${DEPLOY_DIR}/ && git clone https://${APPUSER}:${APPPASSWD}@${APPUILINK} --branch ${APPUIBRANK} &>/dev/null
	then
		echo "app-ui clone succeed $(date +%T)"
		cd ${DEPLOY_DIR}/app-ui
		if
			git checkout -b "${build_number}" &>/dev/null
		then
			echo "app-ui build number: ${build_number}"
		else
			echo "app-ui build branch faild"
			exit 1
		fi
	else
		echo "app-ui clone failed $(date +%T)"
		exit 1
	fi
fi
###############################################app-core###################################################################
if [ -d ${DEPLOY_DIR}/app-core ];then
	cd  ${DEPLOY_DIR}/app-core
	git config --global user.email "dealtap@dealtap.com"
	git config --global user.name "dealtap"
	if
		git checkout ${APPCOREBRANK} && git pull &>/dev/null
	then
		echo "app-core pull succeed $(date +%T)"
		cd ${DEPLOY_DIR}/app-core
		if 
			git checkout -b "${build_number}" &>/dev/null
		then
			echo "app-core build number: ${build_number}"
		else
			echo "app-core build branch faild"
			exit 1
		fi
	else
		echo "app-core pull faild $(date +%T)"
		exit 1
	fi
else
	if
		cd ${DEPLOY_DIR}/ && git clone https://${APPUSER}:${APPPASSWD}@${APPCORELINK} --branch ${APPCOREBRANK} &>/dev/null
	then
		echo "app-core clone succeed $(date +%T)"
		cd ${DEPLOY_DIR}/app-core
		if
			git checkout -b "${build_number}" &>/dev/null
		then
			echo "app-core build number: ${build_number}"
		else
			echo "app-core build branch faild"
			exit 1
		fi
	else
		echo "app-core clone faild $(date +%T)"
		exit 1
	fi
fi
}
#################################################analytics####################################################################
function analytics-update {
if [ ! -d ${DEPLOY_DIR} ];then
	mkdir -p ${DEPLOY_DIR}
fi
cd ${DEPLOY_DIR}
if [ -d ${DEPLOY_DIR}/analytics ];then
	cd  ${DEPLOY_DIR}/analytics
	git config --global user.email "dealtap@dealtap.com"
	git config --global user.name "dealtap"
	if
	git checkout ${ANABRANCH} && git pull &>/dev/null
	then
		echo "analytics pull succeed $(date +%T)"
		cd ${DEPLOY_DIR}/analytics
		if 
			git checkout -b "${ana_build_number}" &>/dev/null
		then
			echo "analytics build number: ${ana_build_number}"
		else
			echo "analytics build branch faild"
			exit 1
		fi
	else
		echo "analytics pull faild $(date +%T)"
		exit 1
	fi
else
	if
		cd ${DEPLOY_DIR}/ && git clone https://${ANAUSER}:${ANAPASSWD}@${ANALINK} --branch ${ANABRANCH} &>/dev/null
	then
		echo "analytics clone succeed $(date +%T)"
		cd ${DEPLOY_DIR}/analytics
		if
			git checkout -b "${ana_build_number}" &>/dev/null
		then
			echo "analytics build number: ${ana_build_number}"
		else
			echo "analytics build branch faild"
			exit 1
		fi
	else
		echo "analytics clone faild $(date +%T)"
		exit 1
	fi
fi
}
##########################################################################################################
function app-edit-LOC {
project=(app-ui app-core)
for pro in ${project[@]}
	do
		cd ${DEPLOY_DIR}/${pro}
		git checkout ${build_number} >/dev/null
		touch LOC
		echo "Checkout from branch:${branch}" >>./LOC
		echo "Build number:${build_number}" >>./LOC
		echo -e "$(git log | grep commit | head -n 2 | tail -n 1)" >>./LOC
		echo "${property} rolling out request by ${position}" >>./LOC
		if [ -e /scripts/deploy/LOC ];then
		cat /scripts/deploy/LOC >>./LOC
		fi
		git add -A &>/dev/null && git commit -m "Submit LOC and CCN file $(date '+%Y-%m-%d %T')" &>/dev/null
	done
	
}
############################################################################################################
function analytics-edit-LOC {
		cd ${DEPLOY_DIR}/analytics/
		git checkout ${ana_build_number} >/dev/null
		touch LOC
		echo "Checkout from branch:${ana_branch}" >>./LOC
		echo "Build number:${ana_build_number}" >>./LOC
		echo -e "$(git log | grep commit | head -n 1)" >>./LOC
		echo "${property} rolling out request by ${position}" >>./LOC
		if [ -e /scripts/deploy/LOC ];then
		cat /scripts/deploy/LOC >>./LOC
		fi
		git add -A &>/dev/null && git commit -m "Submit LOC and CCN file $(date '+%Y-%m-%d %T')" &>/dev/null
}
###############################################################################################################
function modify-deploy_time {
if
	cd ${DEPLOY_DIR}/app-ui && git checkout ${build_number}
then
	cd ./public/assets/js/app/controls/
	rm -f ./GitDetails.js
	cp /scripts/deploy/deploy_time/GitDetails.js ./GitDetails.js
	git add -A &>/dev/null && git commit -m "Modify the deployment time program code $(date '+%y%m%d %T')" &>/dev/null
else
	echo "modify-deploy_time faild,${DEPLOY_DIR}/app-ui doesnot exist or checkout branch faild"
	exit 1
fi
if
	cd ${DEPLOY_DIR}/app-core && git checkout ${build_number}
then
	cd ./app/system/entities/
	rm -f ./GitDetails.php
	cp /scripts/deploy/deploy_time/GitDetails.php ./GitDetails.php
	git add -A &>/dev/null && git commit -m "Modify the deployment time program code $(date '+%Y-%m-%d %T')" &>/dev/null
else
	echo "modify-deploy_time faild,${DEPLOY_DIR}/app-core doesnot exist or checkout branch faild"
	exit 1
fi


}
##############################################################################################################################
if [ "${is_deploy_app}x" == "yx" ];then
	app-update
	modify-deploy_time
	app-edit-LOC
fi
if [ "${is_deploy_ana}x" == "yx" ];then
	analytics-update
	analytics-edit-LOC
fi
