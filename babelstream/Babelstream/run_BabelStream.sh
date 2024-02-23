#! /bin/bash

#set -e
#[[ $EUID = 0 ]] && echo 'Error: This script can not be run as root!' && exit

DIR=`pwd`

##Check Setup_BabelStream.ini
if [ ! -e Setup_BabelStream.ini ]; then 
  echo "ERROR:'Setup_BabelStream.ini' is Missing!"
  exit 1
fi

if [[ `dpkg -l|grep clinfo` != "" ]];then
	CL=`clinfo 2>/dev/null|grep "Platform Version"|awk '{for (i=3;i<=NF;i++)printf("%s ",$i);print ""}'|tr "\n" " "`
	if [[ $CL == "" ]];then
		echo "Error : No OpenCL Platform"
		exit
	fi
else
	echo "Warning : No clinfo"
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
SIZE=`ReadIni Setup_BabelStream.ini Parameters Size`
NUM=`ReadIni Setup_BabelStream.ini Parameters Num`
feq=`ReadIni Setup_BabelStream.ini Frequent Times`
i=1
if [[ $SIZE == "" ]];then
	SIZE=`ReadIni Setup_BabelStream.ini Default Size`
fi
if [[ $NUM == "" ]];then
	NUM=`ReadIni Setup_BabelStream.ini Default Num`
fi
mkdir -p $DIR/Result/"$rtime"

SIZE=$((SIZE*1024*1024/24))

while ((i<=feq));do
	cd $DIR/BabelStream-main/buildocl

	echo "Running Kernel in Double, cycle $i ..."
	./ocl-stream --mibibytes -s $SIZE -n $NUM > $DIR/Result/"$rtime"/double_kernel_"$i".txt 2>&1
	echo "Running Nstream in Double, cycle $i ..."
	./ocl-stream --nstream-only --mibibytes -s $SIZE -n $NUM > $DIR/Result/"$rtime"/double_nstream_"$i".txt 2>&1 
	echo "Running Kernel in Float, cycle $i ..."
	./ocl-stream --float --mibibytes -s $((SIZE*2)) -n $NUM > $DIR/Result/"$rtime"/float_kernel_"$i".txt 2>&1 
	echo "Running Nstream in Float, cycle $i ..."
	./ocl-stream --float --nstream-only --mibibytes -s $((SIZE*2)) -n $NUM > $DIR/Result/"$rtime"/float_nstream_"$i".txt 2>&1 

	cd $DIR/Result/"$rtime"/
	
	if [[ $i == 1 ]];then
		echo "runtimes",$NUM > result.csv
		echo "array size","`awk 'BEGIN{printf "%0.2f",'"$SIZE"'*8/1048576}'` MiB (=`awk 'BEGIN{printf "%0.2f",'"$SIZE"'*8/1000000}'` MB)" >> result.csv
		echo "Total size","`awk 'BEGIN{printf "%0.2f",'"$SIZE"'*24/1048576}'` MiB (=`awk 'BEGIN{printf "%0.2f",'"$SIZE"'*24/1000000}'` MB)" >> result.csv
		echo "Function,Bandwidth_$i(MiBps)" >> result.csv
	else
		echo "" > temp.csv
		echo "" >> temp.csv
		echo "" >> temp.csv
		echo "Bandwidth_$i(MiBps)" >> temp.csv
	fi

	flag=0
	while read str ;do
		if [[ $flag == 1 ]]&&[[ $i == 1 ]];then
			echo $str|awk '{print "Double_"$1,$2}' OFS=',' >>result.csv
		elif [[ $flag == 1 ]];then
			echo $str|awk '{print $2}' OFS=',' >>temp.csv
		fi
		if [[ ${str:0:8} == "Function" ]];then
			flag=1
		fi
	done < double_kernel_"$i".txt
	flag=0
	while read str ;do
		if [[ $flag == 1 ]]&&[[ $i == 1 ]];then
			echo $str|awk '{print "Double_"$1,$2}' OFS=',' >>result.csv
		elif [[ $flag == 1 ]];then
			echo $str|awk '{print $2}' OFS=',' >>temp.csv
		fi
		if [[ ${str:0:8} == "Function" ]];then
			flag=1
		fi
	done < double_nstream_"$i".txt
	flag=0
	while read str ;do
		if [[ $flag == 1 ]]&&[[ $i == 1 ]];then
			echo $str|awk '{print "Float_"$1,$2}' OFS=',' >>result.csv
		elif [[ $flag == 1 ]];then
			echo $str|awk '{print $2}' OFS=',' >>temp.csv
		fi
		if [[ ${str:0:8} == "Function" ]];then
			flag=1
		fi
	done < float_kernel_"$i".txt
	flag=0
	while read str ;do
		if [[ $flag == 1 ]]&&[[ $i == 1 ]];then
			echo $str|awk '{print "Float_"$1,$2}' OFS=',' >>result.csv
		elif [[ $flag == 1 ]];then
			echo $str|awk '{print $2}' OFS=',' >>temp.csv
		fi
		if [[ ${str:0:8} == "Function" ]];then
			flag=1
		fi
	done < float_nstream_"$i".txt

	if [[ $i != 1 ]];then
		paste -d, result.csv temp.csv > temp2.csv
		mv temp2.csv result.csv
		rm temp.csv
	fi

	((i++))
done

echo "Function","Average" >> average_BabelStream.csv
row=`wc -l result.csv|awk '{print $1}'`
for (( i=5;i<=row;i++ ));do
	a=`awk -F, 'NR=='"$i"'{print $1}' result.csv`
	b=`awk -F, 'NR=='"$i"'{for(j=2;j<=$NF;j++)sum+=$j}END{printf"%.2f",sum/('"$feq"')}' result.csv`
	echo "$a","$b" >> average_BabelStream.csv
done

