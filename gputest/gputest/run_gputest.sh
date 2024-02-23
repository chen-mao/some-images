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
feq=`ReadIni Setup_gputest.ini Frequent Times`
SID=`ReadIni Setup_gputest.ini Display ScreenID`
AA=`ReadIni Setup_gputest.ini MSAA msaa`
if ((AA != 0 && AA != 2 && AA != 4 && AA != 8));then
	echo "Error : Parameter [MSAA]msaa is illegal"
	exit
elif (( AA == 0 ));then
	AApara=""
else
	AApara="/msaa=$AA"
fi
AA="MSAA=$AA"
FS=`ReadIni Setup_gputest.ini Ratio FULLSCREEN`
if ((FS != 0 && FS != 1));then
	echo "Error : Parameter [Ratio]FULLSCREEN is illegal"
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

i=1
if [[ $FS == "1" ]];then
	((C = count + 1))
else
	((C = count))
fi
while [[ $i -le $C ]];do
	cd $SetupDir
	if [[ $i == $((count + 1)) ]];then
		para="/fullscreen"
		show="FullScreen"
	else
		width=`ReadIni Setup_gputest.ini XList x$i`
		height=`ReadIni Setup_gputest.ini YList y$i`
		para="/width=$width /height=$height"
		show="$width*$height"
	fi
	j=1
	cd $WorkDir

	echo "Module","Renderer","ApiVersion","Width","Height","Fullscreen","AntiAliasing","AvgFPS","Duration","MaxGpuTemp","Score" > $SetupDir/GpuTest_Linux_x64_0.7.0/_geeks3d_gputest_scores.csv

	while [[ $j -le $feq ]];do

		echo "running FurMark in $show $AA cycle $j ..."
		./GpuTest /test=fur $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "FurMark" $SetupDir/Result/"$rtime"/result.csv

		echo "running GiMark in $show $AA cycle $j ..."
		./GpuTest /test=gi $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "GiMark" $SetupDir/Result/"$rtime"/result.csv

		echo "running PixMark_Piano in $show $AA cycle $j ..."
		./GpuTest /test=pixmark_piano $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "PixMark Piano" $SetupDir/Result/"$rtime"/result.csv

		echo "running PixMark_Volplosion in $show $AA cycle $j ..."
		./GpuTest /test=pixmark_volplosion $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "PixMark Volplosion" $SetupDir/Result/"$rtime"/result.csv

		echo "running PixMark_JuliaFP64 in $show $AA cycle $j ..."
		./GpuTest /test=pixmark_julia_fp64 $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "PixMark JuliaFP64" $SetupDir/Result/"$rtime"/result.csv

		echo "running PixMark_JuliaFP32 in $show $AA cycle $j ..."
		./GpuTest /test=pixmark_julia_fp32 $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "PixMark JuliaFP32" $SetupDir/Result/"$rtime"/result.csv

		echo "running Plot3D in $show $AA cycle $j ..."
		./GpuTest /test=plot3d $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "Plot3D" $SetupDir/Result/"$rtime"/result.csv

		echo "running TessMark_X8 in $show $AA cycle $j ..."
		./GpuTest /test=tess_x8 $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "TessMark X8" $SetupDir/Result/"$rtime"/result.csv

		echo "running TessMark_X16 in $show $AA cycle $j ..."
		./GpuTest /test=tess_x16 $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "TessMark X16" $SetupDir/Result/"$rtime"/result.csv

		echo "running TessMark_X32 in $show $AA cycle $j ..."
		./GpuTest /test=tess_x32 $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "TessMark X32" $SetupDir/Result/"$rtime"/result.csv

		echo "running TessMark_X64 in $show $AA cycle $j ..."
		./GpuTest /test=tess_x64 $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "TessMark X64" $SetupDir/Result/"$rtime"/result.csv

		echo "running triangle in $show $AA cycle $j ..."
		./GpuTest /test=triangle $para $AApara /benchmark /print_score /no_scorebox >/dev/null
		WriteToCSV _geeks3d_gputest_scores.csv "Triangle" $SetupDir/Result/"$rtime"/result.csv

		if [[ $j == 1 ]] && [[ $i == 1 ]];then
			rows=`wc -l $SetupDir/Result/"$rtime"/result.csv|awk '{print $1}'`	
			#echo "rows=$rows"
			echo "$AA" >>	$SetupDir/Result/"$rtime"/average_GpuTest.csv
			for (( r=2;r<=rows;r++ ));do
				awk -F, 'NR=='"$r"'{print $1}' $SetupDir/Result/"$rtime"/result.csv >> $SetupDir/Result/"$rtime"/average_GpuTest.csv
			done
		fi		
		let j+=1
	done
	echo "$show" >> $SetupDir/Result/"$rtime"/temp.csv
	for ((r=2;r<=rows;r++));do
		title=`awk -F, 'NR=='"$r"'{print $1}' $SetupDir/Result/"$rtime"/average_GpuTest.csv`
		if [[ $i == $((count + 1)) ]];then
			grep -i "$title" $SetupDir/Result/"$rtime"/result.csv |awk -F, '{if($(NF-6)=="YES")print $(NF-1)}'|awk '{sum+=$1} END{printf"%.2f\n",sum/NR}' >> $SetupDir/Result/"$rtime"/temp.csv
		else
			grep -i "$title" $SetupDir/Result/"$rtime"/result.csv |awk -F, '{if($(NF-6)=="NO" && $(NF-7)=='"$height"'&& $(NF-8)=='"$width"')print $(NF-1)}'|awk -F, '{sum+=$1} END{printf"%.2f\n",sum/NR}' >> $SetupDir/Result/"$rtime"/temp.csv
		fi
	done
	paste -d, $SetupDir/Result/"$rtime"/average_GpuTest.csv $SetupDir/Result/"$rtime"/temp.csv > $SetupDir/Result/"$rtime"/temp2.csv
	mv $SetupDir/Result/"$rtime"/temp2.csv $SetupDir/Result/"$rtime"/average_GpuTest.csv
	rm $SetupDir/Result/"$rtime"/temp.csv
	let i+=1
done

