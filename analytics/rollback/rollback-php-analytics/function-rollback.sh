#!/bin/bash
############################################################################################
#remove analytics project current core
function rm-analytics
	{	
		if [ -e ${ANAPATH}/analytics ]
			then
				cd ${ANAPATH}
				rm -rf analytics
				if [ $? -eq 0 ]
					then
					return 0
				else 
					return 1
				fi
		else 
			echo Project analytics directory no found
			return 10
		fi	
	}
############################################################################################
#Rollback analytics project backup core
function rollback-analytics 
	{	
			if [ -e ${ANAPATH}/analytics.tar.gz ];then
				cd ${ANAPATH}
				tar -zxf analytics.tar.gz
				if [ $? -ne 0 ]
				then
					return 1
				fi
				rm -rf analytics.tar.gz
			else
				echo "analytics backup file no fuound"
				return 1
			fi
	}
############################################################################################
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
			echo "" >/dev/null
		else
			echo "$1 faild"
			sleep 10
			exit 1
		fi
		echo "=====================$1 end $(date +%T)===================="



	}
