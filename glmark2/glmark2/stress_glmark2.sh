#!/bin/bash

#Print Detail Log? 0-No : other-Yes
log=0

#set -e
#[[ $EUID = 0 ]] && echo 'Error: This script can not be run as root!' && exit

##Check Setup_glmark2.ini
if [ ! -e Setup_glmark2.ini ]; then 
  echo "ERROR:'Setup_glmark2.ini' is Missing!"
  exit 1
fi

##Read Information From .ini File
ReadIni() {
	file=$1;
	section=$2;
	item=$3;
	val=`awk -F '=' '/\['$section'\]/{a=1}a==1 && $1~/'$item'/{print $2;exit}' $file`
	echo ${val}
} 

rtime=`echo $(date +%F%n%T)`

##New Folder For Report
mkdir -p ./Report/"$rtime"

##Get Parameters
SID=`ReadIni Setup_glmark2.ini Display ScreenID`
run=`ReadIni Setup_glmark2.ini Run GLes`
during=`ReadIni Setup_glmark2.ini Stress time`
if ((run == 1));then
	run="glmark2-es2"
elif ((run == 0));then
	run="glmark2"
else
	echo "Error : parameter [Run]GLes is illegal"
	exit
fi

export DISPLAY=:0
SCRERR=`xrandr 2>&1 |grep -i "Can't"`
if [[ $SCRERR != "" ]];then
	export DISPLAY=:1
	SCRERR=`xrandr 2>&1 |grep -i "Can't"`
	if [[ $SCRERR != "" ]];then
		export DISPLAY=$SID
		SCRERR=`xrandr 2>&1 |grep -i "Can't"`
		if [[ $SCRERR != "" ]];then
			echo "Error : Please Check the Main Screen's DISPLAY ID, And run 'xhost +' in Main Screen"
			exit 1
		fi
	fi
fi

echo "Running $run in Stress Test ..."
timeout $during $run -s 1920x1080 --run-forever > ./Report/"$rtime"/glresult_"$Ratio"_Stress.txt
