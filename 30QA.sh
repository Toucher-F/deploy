#/bin/bash
echo -e "LOC:\nQuick deployment" >/scripts/deploy/LOC
action=formal
is_deploy_app=y
is_deploy_ana=n
property="QA showstopper"
read -t 30 -p "Please input the APP branch [as:alpha-staging]?" branch
if [ -z ${branch} ];then
	echo "APP branch cannot be null"
	exit 1
fi
is_deploy_ana=n
source /scripts/deploy/30QA/build-number.sh
ENVIRONMENT=30QA
source /scripts/deploy/30QA/deploy-older.sh
ENVIRONMENT=30QA
app_build_number=${build_number}
ana_build_number=${ana_build_number}
pass1=dealtap1
pass2=dealtap1
source /scripts/deploy/30QA/deploy.sh
