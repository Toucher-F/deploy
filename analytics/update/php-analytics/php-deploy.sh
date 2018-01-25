#!/bin/bash
#Load the envset scripts ,$1：Receive the environment variables
source /tmp/php-analytics/analytics-php.sh $1 $2 $3 $4
#Load the  function scripts 
source /tmp/php-analytics/function.sh 
#Configure each environment running function
echo-status backup-analytics-core
echo-status update-analytics
echo-status copy-analytics-conf
echo-status modify-configuration
echo-status composer-analytics
echo-status migrate-analytics
rm -rf /tmp/php-analytics