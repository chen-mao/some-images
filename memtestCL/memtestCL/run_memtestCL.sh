#! /bin/bash

##Read Information From .ini File
ReadIni() {
	file=$1;
	section=$2;
	item=$3;
	val=`awk -F '=' '/\['$section'\]/{a=1}a==1 && $1~/'$item'/{print $2;exit}' $file`
	echo ${val}
} 

DIR=`pwd`
IT=`ReadIni Setup_memtestCL.ini Settings Iterations`
MM=`ReadIni Setup_memtestCL.ini Settings SizeMB`
rtime=`echo $(date +%F%n%T)`

mkdir -p Result/"$rtime"

cd $DIR/memtestCL-master/
echo "Iterations : $IT , Size : $MM MB"
./memtestCL $MM $IT > ../Result/"$rtime"/log.txt

cd $DIR/Result/"$rtime"/
flag=0
err=0
while read str; do
	if [[ ${str:0:6} == "Error:" ]];then
		let err+=1
		err_msg=$str
		break
	fi
done < log.txt

if [[ $err != 0 ]];then
	#cd ../
	#rm -r $DIR/Result/"$rtime"/
	echo $err_msg > $DIR/Result/"$rtime"/fail
	echo $err_msg
else
	res=`awk '{if($1=="Final")print $4}' log.txt`
	if [[ $res == "0" ]];then
		filename="pass"
	else
		filename="fail"
	fi
	awk '{if($NF=="(SELECTED)")print $0}' log.txt|tail -n 1|awk '{printf"Platform : ";for(i=2;i<NF;i++) printf("%s ",$i);print ""}'> "$filename".txt
	awk '{if($1=="Estimated")print $0}' log.txt|awk '{for(i=1;i<NF-1;i++) printf("%s ",$i);printf(": %s %s"),$(NF-1),$NF;print ""}'>> "$filename".txt	
	awk '{if($1=="Final")print $0}' log.txt >> "$filename".txt
fi

