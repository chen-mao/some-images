#! /bin/bash

##Check Setup_luxmark.ini
if [ ! -e Setup_luxmark.ini ]; then 
  echo "ERROR:'Setup_luxmark.ini' is Missing!"
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

rtime=`echo $(date +%F%n%T)`
testTimes=`ReadIni Setup_luxmark.ini testTimes r1`
ModeNum=`ReadIni Setup_luxmark.ini ModeNum m1`
SceneNum=`ReadIni Setup_luxmark.ini SceneNum t1`
Dir=`pwd`
mkdir -p testResult/"$rtime"

echo scene,mode,times,score,Scene_validation,Image_validation > testResult/"$rtime"/result.csv

j=1
while [ $j -le $SceneNum ]
do
	i=1
	sce=`ReadIni Setup_luxmark.ini Scene tc$j`
	while [ $i -le $ModeNum ]
	do
		mode=`ReadIni Setup_luxmark.ini Mode mode$i`
		k=1
		while [ $k -le $testTimes ] 
		do
			echo "$sce $mode $k test time running~~"
			echo =============================${sce}=============================== >> testResult/"$rtime"/luxmark_$sce.log
			echo =============================`date`=============================== >> testResult/"$rtime"/luxmark_$sce.log
			cd $Dir/luxmark-v3.1
	        ./luxmark --scene=${sce} --mode=$mode --ext-info --single-run >> ../testResult/"$rtime"/luxmark_$sce.log 
			cd $Dir	
		    score=`tail -n -3 testResult/"$rtime"/luxmark_$sce.log | head -n 1`
			score=${score#*:}
			Scene_validation=`tail -n -2 testResult/"$rtime"/luxmark_$sce.log | head -n 1`
			Scene_validation=${Scene_validation#*:}
			Image_validation=`tail -n -1 testResult/"$rtime"/luxmark_$sce.log`
			Image_validation=${Image_validation#*:}
			echo $sce,$mode,$k,$score,$Scene_validation,$Image_validation >> testResult/"$rtime"/result.csv
			sleep 1
			((k++))
		done
		((i++))
	done
	((j++))
done
