#/bin/bash
case $1 in
	"30prod")
		DTPATH=/media/sf_src
		#for rewrite url
		DT_URL="app.dprod.dealtap.ca"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.dprod.dealtap.ca"
		AppFrontEnd_MAIN="http://app.dprod.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.dprod.dealtap.ca/"
		Config_URL_UI="http://app.dprod.dealtap.ca"
		Config_URL_CORE="http://api.dprod.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.dprod.dealtap.ca/api http://analytics.dprod.dealtap.ca/api)
		#-------App-ui config file argument end------------
		;;
	"test30prod")
		DTPATH=/media/sf_src
		#for rewrite url
		DT_URL="app.dprod.dealtap.ca"
		#-------App-core config file argument start--------
		ConfigAnalytics_SERVICE_URL="analytics.dprod.dealtap.ca"
		AppFrontEnd_MAIN="http://app.dprod.dealtap.ca/"
		AppFrontEnd_ALPHA="http://app.dprod.dealtap.ca/"
		Config_URL_UI="http://app.dprod.dealtap.ca"
		Config_URL_CORE="http://api.dprod.dealtap.ca"
		#-------App-core config file argument end----------
		#-------App-ui config file argument start----------
		#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
		ConfigApi_SOURCE=(http://api.dprod.dealtap.ca/api http://analytics.dprod.dealtap.ca/api)
		#-------App-ui config file argument end------------
		;;
	*)
		echo "please reset!"
		exit 1
		;;
esac
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
	sed -i '/Enums\\Config::URL_UI/c\\t\tEnums\\Config::URL_UI => '\'${Config_URL_UI}\'',' ./config.php
	sed -i '/Enums\\Config::URL_CORE/c\\t\tEnums\\Config::URL_CORE => '\'${Config_URL_CORE}\'',' ./config.php
else
	return 1
fi
}
function echo-status
	{	
		echo "=====================$1 start $(date +%T)===================="
		$1
		if [ $? -eq 0 ]
			then
				echo "$1 success"
		elif [ $? -eq 10 ];then
			echo ""
		else 
			echo "$1 faild"
			sleep 10
			exit 1
		fi
		echo "=====================$1 end $(date +%T)===================="



	}
	
echo-status modify-configuration
sed -i '/if ($host ~ '\'${DT_URL}\'')/,/}$/d' /etc/nginx/sites-enabled/app-ui.conf
service nginx restart

		