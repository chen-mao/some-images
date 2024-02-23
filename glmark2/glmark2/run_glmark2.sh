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
RCount=`ReadIni Setup_glmark2.ini Ratio_Count RCount`
SID=`ReadIni Setup_glmark2.ini Display ScreenID`
feq=`ReadIni Setup_glmark2.ini Frequent Times`
run=`ReadIni Setup_glmark2.ini Run GLes`
if ((run == 1));then
	run="glmark2-es2"
elif ((run == 0));then
	run="glmark2"
else
	echo "Error : parameter [Run]GLes is illegal"
	exit
fi
Ons=`ReadIni Setup_glmark2.ini Ratio_Count OnScreen`
if ((Ons != 0 && Ons != 1));then
	echo "Error : parameter [Ratio_Count]OnScreen is illegal"
	exit
fi
Offs=`ReadIni Setup_glmark2.ini Ratio_Count OffScreen`
if ((Offs != 0 && Offs != 1));then
	echo "Error : parameter [Ratio_Count]OffScreen is illegal"
	exit
fi
Full=`ReadIni Setup_glmark2.ini Ratio_Count FullScreen`
if ((Full != 0 && Full != 1));then
	echo "Error : parameter [Ratio_Count]FullScreen is illegal"
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
j=1
error_feq=0
if [[ $Offs = 1 ]];then
	S=0
else
	S=1
fi
if [[ $Ons = 1 ]];then
	V=2
else
	V=1
fi
if [[ $Full = 1 ]];then
	((C=RCount+1))
else
	((C=RCount))
fi
while [[ $S < $V ]];do
	while [ $i -le $C ];do
		if [[ $i == $((RCount+1)) ]];then
			Ratio="FullScreen"
			para_s="--fullscreen"
		else
	    	Ratio=`ReadIni Setup_glmark2.ini Ratio_List r$i`
			para_s="-s $Ratio"
		fi
	    if [[ $S = 0 ]];then
			Screen=Off
   		 	echo "Running $run in $Ratio offscreen, cycles : $j"
			$run $para_s --off-screen > ./Report/"$rtime"/glresult_"$Ratio"_"$j"_"$Screen"screen.txt 2>./Report/"$rtime"/error_"$Ratio"_"$j"_"$Screen"screen.txt
    	else
			Screen=On
	    	echo "Running $run in $Ratio onscreen, cycles : $j"
			$run $para_s > ./Report/"$rtime"/glresult_"$Ratio"_"$j"_"$Screen"screen.txt 2>./Report/"$rtime"/error_"$Ratio"_"$j"_"$Screen"screen.txt
		fi
    	##Throw Error & Prevent Endless Loop
		if [ $? -ne 0 ]; then
			let error_feq+=1
			if [[ $error_feq < 5 ]];then
				continue
			else
				echo "Too many errors occurred, Aborted."
				echo "Too many errors occurred, Aborted." > ./Report/"$rtime"/fail
				exit 1
			fi
		fi
		error_feq=0
    	##Extract CSV   
		if [[ $log != 0 ]];then
			if [[ ! -e ./Report/"$rtime"/log.csv ]];then 
		    	echo "SCENE" > ./Report/"$rtime"/log.csv
   		 		while read str; do
  	 	 			if [[ ${str:0:1} = "[" ]];then 
   		         		a=`echo $str|awk '{print $1}'`
   		         		echo $a >> ./Report/"$rtime"/log.csv
    	    		elif [[ `echo $str|awk '{print $2}'` = "Score:" ]];then
        	    		a="Score"
        	    		echo $a >> ./Report/"$rtime"/log.csv
        			fi
        		done <./Report/"$rtime"/glresult_"$Ratio"_"$j"_"$Screen"screen.txt
			fi
   		 	echo "$Ratio $j $Screen" > ./Report/"$rtime"/log2.csv
   			while read str; do
 				if [[ ${str:0:1} = "[" ]];then 
   	    			b=`echo $str|awk '{print $4}'`
   	        		echo $b >> ./Report/"$rtime"/log2.csv
   	    		elif [[ `echo $str|awk '{print $2}'` = "Score:" ]];then
   	        		b=`echo $str|awk '{print $3}'`
   	        		echo $b >> ./Report/"$rtime"/log2.csv
   	    		fi
   	    	done <./Report/"$rtime"/glresult_"$Ratio"_"$j"_"$Screen"screen.txt
   	    	paste -d, ./Report/"$rtime"/log.csv ./Report/"$rtime"/log2.csv > ./Report/"$rtime"/log3.csv
   	    	mv ./Report/"$rtime"/log3.csv ./Report/"$rtime"/log.csv
			rm ./Report/"$rtime"/log2.csv
		fi

    	if [[ $j = 1 ]];then 
	    	echo "$Ratio $Screen" >> ./Report/"$rtime"/gltemp.txt
		fi
    	while read str; do
   	 		if [[ `echo $str|awk '{print $2}'` = "Score:" ]];then
            	a=`echo $str|awk '{print $3}'`
            	echo $a >> ./Report/"$rtime"/gltemp.txt
        	fi
        done <./Report/"$rtime"/glresult_"$Ratio"_"$j"_"$Screen"screen.txt

    	let j+=1
    	if [[ $j > $feq ]];then
			if [[ ! -e ./Report/"$rtime"/result.csv ]];then
				mv  ./Report/"$rtime"/gltemp.txt ./Report/"$rtime"/result.csv
			else
				paste -d, ./Report/"$rtime"/result.csv ./Report/"$rtime"/gltemp.txt > ./Report/"$rtime"/gltemp2.txt
				mv ./Report/"$rtime"/gltemp2.txt ./Report/"$rtime"/result.csv
				rm ./Report/"$rtime"/gltemp.txt
			fi
        	let i+=1
        	let j-=$feq
    	fi
	done

	let S+=1
    let i=1
	let j=1
done

(( column=(Ons + Offs) * C ))
echo "ratio,average" >> ./Report/"$rtime"/average_"$run".csv
for (( k=1;k<=$column;k++ ));do
	b=`awk -F, 'NR==1{print $('"$k"')}' ./Report/"$rtime"/result.csv`
	c=`tail -$feq ./Report/"$rtime"/result.csv |awk -F, '{sum += $('"$k"')} END {printf"%.2f",sum/'"$feq"'}'`
	echo "$b-Screen",$c >> ./Report/"$rtime"/average_"$run".csv
done

#echo "runtime : "$rtime - $(date +%F%n%T)
#echo "Done!"
