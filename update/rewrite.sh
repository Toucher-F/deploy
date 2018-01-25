#/bin/bash
case $1 in
	"30prod")
		DT_URL="app.dprod.dealtap.ca"
		DTPATH=/media/sf_src
		;;
	"test30prod")
		DT_URL="app.dprod.dealtap.ca"
		DTPATH=/media/sf_src
		;;
	*)
		echo "please reset!"
		exit 1
		;;
esac
mkdir -p ${DTPATH}/www/
echo "The website is upgrading, please wait!" >${DTPATH}/www/index.html
chmod -R 777 ${DTPATH}/www/
if
	grep "if \(.*host ~ '${DT_URL}'\)" /etc/nginx/sites-enabled/app-ui.conf >/dev/null
then
	echo ""
else
	num=$(grep -n "server.*{$" /etc/nginx/sites-enabled/app-ui.conf | cut -d ":" -f 1)
	sed -i ''$num'a\\tif ($host ~ '\'${DT_URL}\'') {\n\trewrite ^/.* /../../www/index.html;\n\t}' /etc/nginx/sites-enabled/app-ui.conf
	service nginx restart >/dev/null
fi

