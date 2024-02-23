#! /bin/bash

##Check Setup_glxgears.ini
if [ ! -e Setup_glxgears.ini ]; then 
  echo "ERROR:'Setup_glxgears.ini' is Missing!"
  exit 1
fi

if [ ! -e glxgears-master/glxgears ]; then 
  echo "ERROR:'./glxgears-master/glxgears' is Missing!"
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

during=`ReadIni Setup_glxgears.ini Stress time`
#start time
rtime=`echo $(date +%F%n%T)`
##New Folder For Report
mkdir -p ./Report/"$rtime"

vblank_mode=0 timeout $during ./glxgears-master/glxgears -geometry 1920x1080 2> /dev/null >> ./Report/"$rtime"/Result.txt

#	Remove the maximum & minimum value
high=`sort -k 1 -n -r ./Report/"$rtime"/Result.txt|awk 'NR==3{print $1}'`
low=`sort -k 1 -n ./Report/"$rtime"/Result.txt|awk 'NR==3{print $1}'`
bias=`echo "scale=2;($high-$low)/$low"|bc`

if [ `echo "$bias > 0.2" | bc` -eq 1 ];then
#	echo "False"
	touch ./Report/"$rtime"/fail
	echo "highest=$high" >> ./Report/"$rtime"/fail
	echo "lowest=$low" >> ./Report/"$rtime"/fail
	echo "bias=$bias" >> ./Report/"$rtime"/fail
else
#	echo "True"
	touch ./Report/"$rtime"/pass
	echo "highest=$high" >> ./Report/"$rtime"/pass
	echo "lowest=$low" >> ./Report/"$rtime"/pass
	echo "bias=$bias" >> ./Report/"$rtime"/pass
fi

