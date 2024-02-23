#! /bin/bash
##version:1.3

#[[ $EUID = 0 ]] && echo 'Error: This script can not be run as root!' && exit

##Check Setup_gputest.ini
if [ ! -e Setup_gputest.ini ]; then 
  echo "ERROR:'Setup_gputest.ini' is Missing!"
  exit 1
fi

##Check Setup_gputest.ini
if [ ! -e GpuTest_Linux_x64_0.7.0/GpuTest ]; then 
  echo "ERROR:'./GpuTest_Linux_x64_0.7.0/GpuTest' is Missing!"
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

WriteToCSV(){
	str1=`tail -n 1 $1|awk -F"," '{printf $1};'`
	if [[ $str1 == $2 ]];then
		str2=`tail -n 1 $1|awk -F"," '{for (i=2;i<=NF-9;i++)printf("%s ",$i)};'`
		str3=`tail -n 1 $1|awk -F"," '{for (i=NF-8;i<=NF;i++)printf("%s,",$i)};'`
		echo $str1,\"$str2\",$str3 >> "$3"
	fi
}

SetupDir=`pwd`
rtime=`echo $(date +%F%n%T)`
WorkDir=$SetupDir/GpuTest_Linux_x64_0.7.0

mkdir -p ./Result/"$rtime"
echo "Module","Renderer","ApiVersion","Width","Height","Fullscreen","AntiAliasing","AvgFPS","Duration","MaxGpuTemp","Score" > $SetupDir/Result/"$rtime"/result.csv

#echo $rtime >> $SetupDir/Result/"rtime"/result.csv
count=`ReadIni Setup_gputest.ini Ratio RCount`
during=`ReadIni Setup_gputest.ini Stress time`
SID=`ReadIni Setup_gputest.ini Display ScreenID`

if ((FS != 0 && FS != 1));then
	echo "Error : Parameter [Ratio]FULLSCREEN is illegal"
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

cd $WorkDir
echo "Module","Renderer","ApiVersion","Width","Height","Fullscreen","AntiAliasing","AvgFPS","Duration","MaxGpuTemp","Score" > $SetupDir/GpuTest_Linux_x64_0.7.0/_geeks3d_gputest_scores.csv

if [[ ${during: -1} == "d" ]];then
	during=${during:0:-1}
	((ms=1000*60*60*24*during))
elif [[ ${during: -1} == "h" ]];then
	during=${during:0:-1}
	((ms=1000*60*60*during))
elif [[ ${during: -1} == "m" ]];then
	during=${during:0:-1}
	((ms=60000*during))
else
	((ms=1000*during))
fi
echo "running FurMark in Stress Test ..."
#echo ${during: -1},${during:0:-1},$ms
./GpuTest /test=fur /width=1920 /height=1080 /benchmark /benchmark_duration_ms=$ms /print_score /no_scorebox >/dev/null
WriteToCSV _geeks3d_gputest_scores.csv "FurMark" $SetupDir/Result/"$rtime"/result.csv
cd $SetupDir/Result/"$rtime"/
