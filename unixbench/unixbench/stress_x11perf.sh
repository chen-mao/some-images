#!/bin/bash

#connect main screen
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


##Check Setup_x11perf.ini
if [ ! -e Setup_x11perf.ini ]; then 
  echo "ERROR:'Setup_x11perf.ini' is Missing!"
  exit 1
fi

rtime=`echo $(date +%F%n%T)`
echo $rtime > Start_time.txt
echo "x11perf test start at" $rtime

##New Folder For Report
mkdir -p ./Result/"$rtime"

##Read Information From .ini File
ReadIni() {
	file=$1;
	section=$2;
	item=$3;
	val=`awk -F '=' '/\['$section'\]/{a=1}a==1 && $1~/'$item'/{print $2;exit}' $file`
	echo ${val}
} 

time=`ReadIni Setup_x11perf.ini StressTest_time duration`

replaceAd="Times=100000000"
sed -i "/Times=/c${replaceAd}" Setup_x11perf.ini 

timeout $time ./run_x11perf.sh > ./Result/"$rtime"/Stress_x11perf.log

rtime=`echo $(date +%F%n%T)`
echo $rtime > End_time.txt
echo "x11perf test end at" $rtime
echo "x11perf test completed! Please check the test log!"

sleep 5
