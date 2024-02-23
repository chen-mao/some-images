#! /bin/bash
##Read Information From .ini File
ReadIni() {
        file=$1;
        section=$2;
        item=$3;
        val=`awk -F '=' '/\['$section'\]/{a=1}a==1 && $1~/'$item'/{print $2;exit}' $file`
        echo ${val}
}

feq=`ReadIni Setup_clpeak.ini Frequent Times`
rtime=`echo $(date +%F%n%T)`
Dir=`pwd`
mkdir -p $Dir/Result/"$rtime"/
cd clpeak-master/build
i=1
while ((i<=feq));do
        echo "Running Cycle $i ..."
        if [[ $i == 1 ]];then
                echo "Test Item" >> $Dir/Result/"$rtime"/Result.csv
                echo "Global memory bandwidth : float(GBPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Global memory bandwidth : float2(GBPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Global memory bandwidth : float4(GBPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Global memory bandwidth : float8(GBPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Global memory bandwidth : float16(GBPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Single-precision : float(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Single-precision : float2(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Single-precision : float4(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Single-precision : float8(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Single-precision : float16(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Half-precision : float(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Half-precision : float2(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Half-precision : float4(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Half-precision : float8(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Half-precision : float16(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Double-precision : Double(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Double-precision : Double2(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Double-precision : Double4(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Double-precision : Double8(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Double-precision : Double16(GFLOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer : int (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer : int2 (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer : int4 (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer : int8 (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer : int16 (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer Fast 24bit : int (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer Fast 24bit : int (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer Fast 24bit : int (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer Fast 24bit : int (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Integer Fast 24bit : int (GIOPS)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): enqueueWriteBuffer" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): enqueueReadBuffer" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): enqueueWriteBuffer non-blocking" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): enqueueReadBuffer non-blocking" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): enqueueMapBuffer(for read)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): memcpy from mapped ptr" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): enqueueUnmap(after write)" >> $Dir/Result/"$rtime"/Result.csv
                echo "Transfer bandwidth (GBPS): memcpy to mapped ptr" >> $Dir/Result/"$rtime"/Result.csv
        fi
        ./clpeak 2>/dev/null >> $Dir/Result/"$rtime"/log"$i".txt
        flag=0
        echo "cycle $i" >> $Dir/Result/"$rtime"/tmp1.csv
        while read str ;do
                if [[ $str == "" ]];then
                        flag=0
                fi
                if [[ $flag == 1 ]];then
                        echo $str |awk -F: '{print $NF}' >> $Dir/Result/"$rtime"/tmp1.csv
                fi
                if [[ ${str:0:6} == "Global" ]];then
                        flag=1
                fi
                if [[ ${str:0:6} == "Single" ]];then
                        flag=1
                fi
                if [[ ${str:0:4} == "Half" ]];then
                        flag=1
                fi
                if [[ ${str:0:6} == "Double" ]];then
                        flag=1
                fi
                if [[ ${str:0:7} == "Integer" ]] ;then
                        flag=1
                fi
                if [[ ${str:0:8} == "Transfer" ]];then
                        flag=1
                fi
                if [[ ${str:0:2} == "No" ]] ;then
                        echo " Null" >> $Dir/Result/"$rtime"/tmp1.csv
                        echo " Null" >> $Dir/Result/"$rtime"/tmp1.csv
                        echo " Null" >> $Dir/Result/"$rtime"/tmp1.csv
                        echo " Null" >> $Dir/Result/"$rtime"/tmp1.csv
                        echo " Null" >> $Dir/Result/"$rtime"/tmp1.csv
                fi
        done < $Dir/Result/"$rtime"/log"$i".txt
        paste -d, $Dir/Result/"$rtime"/Result.csv $Dir/Result/"$rtime"/tmp1.csv > $Dir/Result/"$rtime"/tmp2.csv
        mv $Dir/Result/"$rtime"/tmp2.csv $Dir/Result/"$rtime"/Result.csv
        rm $Dir/Result/"$rtime"/tmp1.csv
        ((i+=1))
done

echo "Item","Average" >> $Dir/Result/"$rtime"/average_clpeak.csv
for ((i=2;i<=39;i++));do
        a=`awk -F", " 'NR=='"$i"'{print $1}' $Dir/Result/"$rtime"/Result.csv`
        b=`awk -F", " 'NR=='"$i"'{print $2}' $Dir/Result/"$rtime"/Result.csv`
        if [[ $b != "Null" ]];then
                b=`awk -F", " 'NR=='"$i"'{for(j=2;j<=NF;j++)sum=sum+$j}END{printf"%.2f",(sum/'"$feq"');print""}' $Dir/Result/"$rtime"/Result.csv`
        fi
        echo $a,$b >> $Dir/Result/"$rtime"/average_clpeak.csv
done

cd $Dir/Result/"$rtime"/
