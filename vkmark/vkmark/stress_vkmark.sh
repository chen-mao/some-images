#!/bin/bash

#Print Detail Log? 0-No : other-Yes
log=0

#set -e
#[[ $EUID = 0 ]] && echo 'Error: This script can not be run as root!' && exit

##Check Setup_vkmark.ini
if [ ! -e Setup_vkmark.ini ]; then 
  echo "ERROR:'Setup_vkmark.ini' is Missing!"
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
Dir=`pwd`

##New Folder For Report
if [[ $EUID = 0 ]];then
	user_name=`who|grep '(:'|awk '{print $1}'`
	su - $user_name -c "mkdir -p $Dir/Report/\"$rtime\""
else
	mkdir -p $Dir/Report/"$rtime"
fi

##Get Parameters
SID=`ReadIni Setup_vkmark.ini Display ScreenID`
during=`ReadIni Setup_vkmark.ini Stress time`

export DISPLAY=:0
DISP=:0
SCRERR=`xrandr 2>&1 |grep -i "Can't"`
if [[ $SCRERR != "" ]];then
	export DISPLAY=:1
	DISP=:1
	SCRERR=`xrandr 2>&1 |grep -i "Can't"`
	if [[ $SCRERR != "" ]];then
		export DISPLAY=$SID
		DISP=$SID
		SCRERR=`xrandr 2>&1 |grep -i "Can't"`
		if [[ $SCRERR != "" ]];then
			echo "Error : Please Check the Main Screen's DISPLAY ID, And run 'xhost +' in Main Screen"
			exit 1
		fi
	fi
fi

echo "Running vkmark in Stress Test ..."
if [[ $EUID = 0 ]];then
	user_name=`who|grep '(:'|awk '{print $1}'`
	if [[ $user_name == "" ]];then
		user_name=`"who|tail -n 1|awk '{print $1}'`
	fi
	su - $user_name -c "export DISPLAY=$DISP && timeout $during vkmark -s 1920x1080 -p immediate --run-forever > $Dir/Report/$rtime/vkresult_${Ratio}_Stress.txt"
else
	timeout $during vkmark -s 1920x1080 -p immediate --run-forever > ./Report/"$rtime"/vkresult_"$Ratio"_Stress.txt
fi

if [ $? -ne 0 ]; then
	echo "errors occurred, Aborted." > ./Report/"$rtime"/fail
	exit 1
fi
