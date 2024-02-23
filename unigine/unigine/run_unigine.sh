#! /bin/bash

##Read Information From .ini File
ReadIni() {
	file=$1
	section=$2
	item=$3
	val=`awk -F '=' '/\['$section'\]/{a=1}a==1 && $1~/'$item'/{print $2;exit}' $file`
	echo ${val}
}

##Write Information From .ini File
Writeini() {
    allSections=$(awk -F '[][]' '/\[.*]/{print $2}' $1)
    iniSections=(${allSections// /})
    itemFlag="0"
    for temp in ${iniSections[@]};do
        if [[ "${temp}" = "$2" ]];then
            itemFlag="1"
            break
        fi
    done
    if [[ "$itemFlag" = "0" ]];then
        echo "[$2]" >> $1
    fi
    awk "/\[$2\]/{a=1}a==1" $1|sed -e '1d' -e '/^$/d'  -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e '/\[/,$d'|grep "$3.\?=">/dev/null
    if [[ "$?" -eq 0 ]];then
        itemNum=$(sed -n -e "/\[$2\]/=" $1)
        sed -i "${itemNum},/^\[.*\]/s/\($3.\?=\).*/\1$4/g" $1 >/dev/null 2>&1
        if [[ "$?" -ne 0 ]];then
            sed -i "${itemNum},/^\[.*\]/s!\($3.\?=\).*!\1$4!g" $1
        fi
    else
        sed -i "/^\[$2\]/a\\$3=$4" $1
    fi
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

#Dir
Dir=`pwd`
#start time
rtime=`echo $(date +%F%n%T)`
##New Folder For Report
mkdir -p ./Report/"$rtime"

feq=`ReadIni Setup_unigine.ini Frequent Times`
heaven=`ReadIni Setup_unigine.ini Run Heaven`
if (( heaven != "1" && heaven != "0" ));then
	echo "Parameter Heaven is illegal !"
	exit
fi
valley=`ReadIni Setup_unigine.ini Run Valley`
if (( valley != "1" && heaven != "1" ));then
	echo "Parameter Heaven is illegal !"
	exit
fi
if [[ $heaven == "1" ]];then
	echo "Running Heaven for $feq times ..."
	./heaven.py >> $Dir/Report/"$rtime"/log.txt 2>&1
	mv ~/Heaven/reports/* $Dir/Report/"$rtime"/
fi
if [[ $valley == "1" ]];then
	echo "Running Valley for $feq times ..."
	./valley.py >> $Dir/Report/"$rtime"/log.txt 2>&1
	mv ~/Valley/reports/* $Dir/Report/"$rtime"/
fi
