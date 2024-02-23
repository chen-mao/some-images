#!/bin/bash
localpath=`pwd`
logpath=$(date +"%Y-%m-%d-%H-%M-%S")

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

feq=`ReadIni Setup_shoc.ini Frequent Times`

if [ ! -d ./result_shoc/ ];then
   mkdir ./result_shoc/
fi
echo "SHOC benchmark is running......"
cd result_shoc
mkdir ${logpath}

cd ${logpath}

for i in `seq 1 $feq`
do
	rsname=rs$i.txt
        date +"%Y-%m-%d-%H-%M-%S" > temp.txt;
	echo "=============================round $i running================================"
	${localpath}/shoc_study/shoc/bin//shocdriver -opencl >> temp.txt;
	cat temp.txt |grep result|awk -F " " '{print $3}'|awk -F ":" '{print $1}' > name.txt;
	cat temp.txt |grep result|awk -F " " '{print $5}' > unit.txt;
	cat temp.txt |grep result|awk -F " " '{print $4}' > ${rsname};
	mv Logs Logs$i
	echo "=============================round $i ended================================"
	if [[ $i == "1" ]];then
		paste -d"," name.txt unit.txt rs1.txt > all_rs.csv
	else
		paste -d"," all_rs.csv rs$i.txt > all2.csv
		mv all2.csv all_rs.csv
	fi 
done
#paste -d"," name.txt unit.txt rs1.txt rs2.txt rs3.txt > all_rs.csv
echo "SHOC benchmark run ended......"
echo "Please check the result_shoc/${logpath}!!"
