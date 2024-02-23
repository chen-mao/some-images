#! /bin/bash

#[[ $EUID = 0 ]] && echo 'Error: This script can not be run as root!' && exit

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

#start time
rtime=`echo $(date +%F%n%T)`
##New Folder For Report
mkdir -p ./Report/"$rtime"
#count of example
RCount=`ReadIni Setup_glxgears.ini Ratio_Count RCount`
Full=`ReadIni Setup_glxgears.ini Ratio_Count FULLSCREEN`
if ((Full != 0 && Full != 1));then
	echo "Error : parameter [Ratio_Count]FULLSCREEN is illegal"
	exit
fi
Default=`ReadIni Setup_glxgears.ini Ratio_Count DEFAULT`
if ((Default != 0 && Default != 1));then
	echo "Error : parameter [Ratio_Count]DEFAULT is illegal"
	exit
fi
#count of result 
feq=`ReadIni Setup_glxgears.ini Frequent Times`
#run time in second
let s=feq*5+2
#screen id
SID=`ReadIni Setup_glxgears.ini Display ScreenID`
#temporary variables
i=1
j=0

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

#echo Time : $rtime > ./Report/"$rtime"/result.txt
if [[ $Default != 0 ]];then
	echo "Ratio : Default"
	echo "Ratio : 300x300(Default)" >> ./Report/"$rtime"/result.txt
	vblank_mode=0 timeout $s ./glxgears-master/glxgears >> ./Report/"$rtime"/result.txt 2> /dev/null
	if [[ $? = 1 ]] || [[ $? = 130 ]];then
		exit 1
	fi
	sleep 4
fi

while [ $i -le $RCount ];do
    	Ratio=`ReadIni Setup_glxgears.ini Ratio_List r$i`
		echo "Ratio : $Ratio"
		echo "Ratio : $Ratio" >> ./Report/"$rtime"/result.txt
		vblank_mode=0 timeout $s ./glxgears-master/glxgears -geometry $Ratio >> ./Report/"$rtime"/result.txt 2> /dev/null
		if [[ $? = 1 ]] || [[ $? = 130 ]];then
			exit 1
		fi
		sleep 4
    let i+=1
done

if [[ $Full != 0 ]];then
	echo "Ratio : FullScreen"
	echo "Ratio : FullScreen" >> ./Report/"$rtime"/result.txt
	vblank_mode=0 timeout $s ./glxgears-master/glxgears -fullscreen >> ./Report/"$rtime"/result.txt 2> /dev/null
	if [[ $? = 1 ]] || [[ $? = 130 ]];then
		exit 1
	fi
fi

while read str; do
   	if [[ ${str:0:5} = "Ratio" ]];then 
    	a=`echo $str|awk '{print $3}'`
	elif [[ ${str:0:4} = "Time" ]];then
		continue		
		#echo $rtime >> ./Report/result.csv
	elif [[ ${str:0:9} = "ATTENTION" ]];then
		continue
	elif [[ ${str:0:7} = "Running" ]];then
		continue
	elif [[ ${str:0:5} = "appro" ]];then
		continue
	else
    	a=$a,`echo $str|awk '{print $7}'`
		let j+=1
		if [[ $j = $feq ]];then
			let j=0
			echo $a >> ./Report/"$rtime"/result.csv
		fi
    fi
done < ./Report/"$rtime"/result.txt

echo "ratio,average" >> ./Report/"$rtime"/average_glxgears.csv
for (( row=1;row<=RCount+Full+Default;row++ ));do
	ratio=`awk -F, 'NR=='"$row"' {print $1}' ./Report/"$rtime"/result.csv`
	average=`awk -F, 'NR=='"$row"'{for (k=2;k<=NF;k++)SUM+=$k}END {printf"%.2f",SUM/'"$feq"'}' ./Report/"$rtime"/result.csv`
	echo $ratio,$average >> ./Report/"$rtime"/average_glxgears.csv
done
	
