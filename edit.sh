#/bin/bash
read -t 30 -p "Please input the project environment[30QA/30staging/30prod/test30QA/test30staging/test30prod]?" ENVIRONMENT
if [ -z $ENVIRONMENT ];then
	echo "Environment can't be null"
	exit 1
fi
################################################################################################################################
read -t 60 -p "Whether to create build number for application or not[y/n](default:y)?" is_deploy_app
is_deploy_app=$(echo ${is_deploy_app} | tr '[A-Z]' '[a-z]')
if [ -z ${is_deploy_app} ];then
	is_deploy_app=y
else
	if [ "${is_deploy_app}x" != "yx" ] && [ "${is_deploy_app}x" != "nx" ];then
	echo "Input is not correct(is_deploy_app)"
	exit 1
	fi
fi
#################################################################################################################################
read -t 60 -p "Whether to create build number for analytics project or not[y/n](default:n)?" is_deploy_ana
is_deploy_ana=$(echo ${is_deploy_ana} | tr '[A-Z]' '[a-z]')
if [ -z ${is_deploy_ana} ];then
	is_deploy_ana=n
else
	if [ "${is_deploy_ana}x" != "yx" ] && [ "${is_deploy_ana}x" != "nx" ];then
	echo "Input is not correct(is_deploy_ana)"
	exit 1
	fi
fi
#################################################################################################################################
read -t 30 -p "Please input the property of the deployment [as:EOF,QA showstopper,scheduled release]?" property
property_arr=(EOF 'QA showstopper' 'scheduled release')
if
	echo ${property_arr[@]} | grep -wq "${property}"
then
	echo "" >/dev/null
else
	echo "Please reset"
	exit 1
fi
#################################################################################################################################
read -s -p "Please input deployment server root user password?" pass1
if [ -z pass1 ];then
	echo "Root user password cannot be null"
	exit 1
fi
read -s -p "Please input deployment server root user password again?" pass2
if [ -z pass1 ];then
	echo "Root user password cannot be null"
	exit 1
fi
if [ "${pass1}x" != "${pass2}x" ];then
	echo "The password you enter twice must be the same."
	exit 1
fi
#################################################################################################################################
arr=(30QA 30staging 30prod)
if
	echo ${arr[@]} | grep -wq ${ENVIRONMENT}
then
	action=formal
else
	action=test
fi
mkdir /scripts/deploy/${ENVIRONMENT}
cp /scripts/deploy/build-number.sh /scripts/deploy/${ENVIRONMENT}/
cp /scripts/deploy/deploy.sh /scripts/deploy/${ENVIRONMENT}/
cp /scripts/deploy-older/deploy-older.sh /scripts/deploy/${ENVIRONMENT}/
cd /scripts/deploy/${ENVIRONMENT}
sed -i '/^\t*read/d' ./*
#################################################################################################################################
cd /scripts/deploy/
touch ${ENVIRONMENT}.sh
echo "#/bin/bash" >./${ENVIRONMENT}.sh
echo "echo -e \"LOC:\\nQuick deployment\" >/scripts/deploy/LOC" >>./${ENVIRONMENT}.sh
echo -e "action=${action}\nis_deploy_app=${is_deploy_app}\nis_deploy_ana=${is_deploy_ana}\nproperty=\"${property}\"" >>./${ENVIRONMENT}.sh
if [ "${is_deploy_app}x" == "yx" ];then
	echo -e "read -t 30 -p \"Please input the APP branch [as:alpha-staging]?\" branch" >>./${ENVIRONMENT}.sh
	echo -e "if [ -z \${branch} ];then\n\techo \"APP branch cannot be null\"\n\texit 1\nfi" >>./${ENVIRONMENT}.sh
else
	echo "is_deploy_app=n" >>./${ENVIRONMENT}.sh
fi
if [ "${is_deploy_ana}x" == "yx" ];then
	echo -e "read -t 30 -p \"Please input the analytics branch [as:alpha-staging]?\" ana_branch" >>./${ENVIRONMENT}.sh
	echo -e "if [ -z \${ana_branch} ];then\n\techo \"Analytics branch cannot be null\"\n\texit 1\nfi" >>./${ENVIRONMENT}.sh
else
	echo "is_deploy_ana=n" >>./${ENVIRONMENT}.sh
fi
echo "source /scripts/deploy/${ENVIRONMENT}/build-number.sh" >>./${ENVIRONMENT}.sh
echo -e "ENVIRONMENT=${ENVIRONMENT}" >>./${ENVIRONMENT}.sh
echo "source /scripts/deploy/${ENVIRONMENT}/deploy-older.sh" >>./${ENVIRONMENT}.sh
echo -e "ENVIRONMENT=${ENVIRONMENT}\napp_build_number=\${build_number}\nana_build_number=\${ana_build_number}\npass1=${pass1}\npass2=${pass2}" >>./${ENVIRONMENT}.sh
echo "source /scripts/deploy/${ENVIRONMENT}/deploy.sh" >>./${ENVIRONMENT}.sh