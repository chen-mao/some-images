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
RCount=`ReadIni Setup_vkmark.ini Ratio_Count RCount`
SID=`ReadIni Setup_vkmark.ini Display ScreenID`
feq=`ReadIni Setup_vkmark.ini Frequent Times`
Imme=`ReadIni Setup_vkmark.ini Ratio_Count Immediate`
if ((Imme != 0 && Imme != 1));then
	echo "Error : parameter [Ratio_Count]Immediate is illegal"
	exit
fi
Mail=`ReadIni Setup_vkmark.ini Ratio_Count Mailbox`
if ((Mail != 0 && Mail != 1));then
	echo "Error : parameter [Ratio_Count]Mailbox is illegal"
	exit
fi
Full=`ReadIni Setup_vkmark.ini Ratio_Count FullScreen`
if ((Full != 0 && Full != 1));then
	echo "Error : parameter [Ratio_Count]FullScreen is illegal"
	exit
fi

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
export XDG_RUNTIME_DIR=/usr/lib

i=1
j=1
error_feq=0
if [[ $Imme = 1 ]];then
	S=0
else
	S=1
fi
if [[ $Mail = 1 ]];then
	V=2
else
	V=1
fi
if [[ $Full = 1 ]];then
	((C=RCount+1))
else
	((C=RCount))
fi
instal=`vkmark -h 2>/dev/null`
while [[ $S < $V ]];do
	while [ $i -le $C ];do
		if [[ $i == $((RCount+1)) ]];then
			Ratio="FullScreen"
			para_s="--fullscreen"
		else
	    	Ratio=`ReadIni Setup_vkmark.ini Ratio_List r$i`
			para_s="-s $Ratio"
		fi
	    if [[ $S = 0 ]];then
			mode="immediate"
    	else
			mode="mailbox"
		fi
   		echo "Running vkmark in $Ratio in $mode mode, cycles : $j"
		if [[ $instal != "" ]];then
			if [[ $EUID = 0 ]];then
				user_name=`who|grep '(:'|awk '{print $1}'`
				if [[ $user_name == "" ]];then
					user_name=`who|tail -n 1|awk '{print $1}'`
				fi
				su - $user_name -c "export DISPLAY=$DISP && vkmark $para_s -p $mode > $Dir/Report/\"$rtime\"/vkresult_${Ratio}_${j}_$mode.txt"
			else
				vkmark $para_s -p "$mode" > $Dir/Report/"$rtime"/vkresult_"$Ratio"_"$j"_"$mode".txt
			fi
		else
			if [[ $EUID = 0 ]];then
				user_name=`who|grep '(:'|awk '{print $1}'`
				if [[ $user_name == "" ]];then
					user_name=`who | tail -n 1| awk '{print $1}'`
				fi
				su - $user_name -c "DISPLAY=$DISP && cd $Dir && ./vkmark-master/build/src/vkmark --winsys-dir=$Dir/vkmark-master/build/src --data-dir=$Dir/vkmark-master/data $para_s -p $mode > $Dir/Report/\"$rtime\"/vkresult_${Ratio}_${j}_$mode.txt"
			else
				./vkmark-master/build/src/vkmark --winsys-dir=./vkmark-master/build/src --data-dir=./vkmark-master/data $para_s -p "$mode" > $Dir/Report/"$rtime"/vkresult_"$Ratio"_"$j"_"$mode".txt
			fi
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
        		done <./Report/"$rtime"/vkresult_"$Ratio"_"$j"_"$mode".txt
			fi
   		 	echo "$Ratio $j $mode" > ./Report/"$rtime"/log2.csv
   			while read str; do
 				if [[ ${str:0:1} = "[" ]];then 
   	    			b=`echo $str|awk '{print $4}'`
   	        		echo $b >> ./Report/"$rtime"/log2.csv
   	    		elif [[ `echo $str|awk '{print $2}'` = "Score:" ]];then
   	        		b=`echo $str|awk '{print $3}'`
   	        		echo $b >> ./Report/"$rtime"/log2.csv
   	    		fi
   	    	done <./Report/"$rtime"/vkresult_"$Ratio"_"$j"_"$mode".txt
   	    	paste -d, ./Report/"$rtime"/log.csv ./Report/"$rtime"/log2.csv > ./Report/"$rtime"/log3.csv
   	    	mv ./Report/"$rtime"/log3.csv ./Report/"$rtime"/log.csv
			rm ./Report/"$rtime"/log2.csv
		fi

    	if [[ $j = 1 ]];then 
	    	echo "$Ratio $mode" >> ./Report/"$rtime"/vktemp.txt
		fi
    	while read str; do
   	 		if [[ `echo $str|awk '{print $2}'` = "Score:" ]];then
            	a=`echo $str|awk '{print $3}'`
            	echo $a >> ./Report/"$rtime"/vktemp.txt
        	fi
        done <./Report/"$rtime"/vkresult_"$Ratio"_"$j"_"$mode".txt

    	let j+=1
    	if [[ $j > $feq ]];then
			if [[ ! -e ./Report/"$rtime"/result.csv ]];then
				mv  ./Report/"$rtime"/vktemp.txt ./Report/"$rtime"/result.csv
			else
				paste -d, ./Report/"$rtime"/result.csv ./Report/"$rtime"/vktemp.txt > ./Report/"$rtime"/vktemp2.txt
				mv ./Report/"$rtime"/vktemp2.txt ./Report/"$rtime"/result.csv
				rm ./Report/"$rtime"/vktemp.txt
			fi
        	let i+=1
        	let j-=$feq
    	fi
	done

	let S+=1
    let i=1
	let j=1
done

(( column=(Imme + Mail) * C ))
echo "ratio,average" >> ./Report/"$rtime"/average_vkmark.csv
for (( k=1;k<=$column;k++ ));do
	b=`awk -F, 'NR==1{print $('"$k"')}' ./Report/"$rtime"/result.csv`
	c=`tail -$feq ./Report/"$rtime"/result.csv |awk -F, '{sum += $('"$k"')} END {printf"%.2f",sum/'"$feq"'}'`
	echo "$b-mode",$c >> ./Report/"$rtime"/average_vkmark.csv
done

#echo "runtime : "$rtime - $(date +%F%n%T)
#echo "Done!"
