#/bin/bash
ENVIRONMENT=$1
BACKUP_NAME=$2
case $1 in
	"30QA")
		DATABASE=pre_prod
		;;
	"30staging")
		DATABASE=pre-prod
		;;
	"30prod")
		DATABASE=dealtap
		;;
	"test30QA")
		DATABASE=pre-prod
		;;
	"test30staging")
		DATABASE=pre-prod
		;;
	"test30prod")
		DATABASE=dealtap
		;;
	*)
		echo "please reset"
		exit 1
		;;
esac
