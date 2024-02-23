#! /bin/bash

# set -x
#Print log? 0-No : other-Yes
log=0

#[[ $EUID = 0 ]] && echo 'Error: This script can not be run as root!' && exit

if [ ! -e ./UnixBench_5.1.3-master/Run ]; then
  echo "ERROR : 'UnixBench is Missing!"
  exit 1
fi

if [ ! -e ./Setup_unixbench.ini ]; then
  echo "ERROR : 'Setup_unixbench.ini' is Missing!"
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

feq=`ReadIni Setup_unixbench.ini Frequent Times`
sys=`ReadIni Setup_unixbench.ini Run System`
if ((sys != 0 && sys != 1));then
        echo "Error : parameter [Run]System is illegal!"
        exit 1
fi
grap=`ReadIni Setup_unixbench.ini Run Graphics`
if ((grap != 0 && grap != 1));then
        echo "Error : parameter [Run]Graphics is illegal!"
        exit 1
fi

#rtime=`date '+%Y/%m/%d-%H=%M=%S'`
rtime=`echo $(date +%F%n%T)`
SID=`ReadIni Setup_unixbench.ini Display ScreenID`
DIR=`pwd`
if [ ! -d ./Result/"$rtime"/ ];then
   mkdir -p ./Result/"$rtime"
fi

#export vblank_mode=0;
export DISPLAY=:0
SCRERR=`xrandr 2>&1 |grep -i "Can't"`
if [[ $SCRERR != "" ]];then
        export DISPLAY=:1
        SCRERR=`xrandr 2>&1 |grep -i "Can't"`
        if [[ $SCRERR != "" ]];then
                export DISPLAY=$SID
                SCRERR=`xrandr 2>&1 |grep -i "Can't"`
                if [[ $SCRERR != "" ]];then
                        echo "Error : Please Check the Main Screen's DISPLAY ID"
                        exit 1
                fi
        fi
fi

if ((sys == 1 && grap == 1));then
        runpara="gindex"
elif ((sys == 1 && grap == 0));then
        runpara=""
elif ((sys == 0 && grap == 1));then
        runpara="graphics"
else
        echo "No test running!"
        rm -r $DIR/Result/"$rtime"
        exit 0
fi

# It's not allowed in docker
# cp -r ./UnixBench_5.1.3-master /dev/shm/

JM=`lspci |grep VGA |grep JM7201``lspci |grep VGA |grep JM7200`
[[ ! -z "`egrep -i UnionTech /etc/issue`" ]] && os="uniontech"
i=1
while [ $i -le $feq ];do
        # cd /dev/shm/UnixBench_5.1.3-master
        cd UnixBench_5.1.3-master
        echo "running cycle $i ..."
        #       ./Run -i 1 >> $DIR/Result/"$rtime"/log_"$i".txt 2>/dev/null
        if [[ $JM != "" ]] && [[ $os = "uniontech" ]];then
                vblank_mode=0 ./Run $runpara -i 1 >> $DIR/Result/"$rtime"/log_"$i".txt 2>/dev/null
        else
                # ./Run $runpara -i 1 >> $DIR/Result/"$rtime"/log_"$i".txt 2>/dev/null
                ./Run $runpara -i 1 >> $DIR/Result/"$rtime"/log_"$i".txt 2>/dev/null
        fi

        cd $DIR/Result/"$rtime"
        FLAG=0
        SEG=0

        if [[ $sys = 1 ]]&&[[ $i = 1 ]];then
                sinSYS="null"
                mulSYS="null"
                echo "System Single CPU" >> ./result.csv
                echo "System Multi CPU" >> ./result.csv
        fi
        if [[ $grap = 1 ]]&&[[ $i = 1 ]];then
                sin2D="null"
                mul2D="null"
                sin3D="null"
                mul3D="null"
                echo "2D Single CPU" >> ./result.csv
                echo "2D Multi CPU" >> ./result.csv
                echo "3D Single CPU" >> ./result.csv
                echo "3D Multi CPU" >> ./result.csv
        fi

        while read str; do
                if [[ ${str:0:1} = "-" ]] && [[ $SEG = 0 ]];then
                        single=1
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "Single CPU","RESULT_$i","INDEX_$i" >> ./log.csv
                                else
                                        echo ,"Single CPU","RESULT_$i","INDEX_$i" >> ./tmp1.csv
                                fi
                        fi
                        let SEG+=1
                        continue
                fi
                if [[ ${str:0:1} = "-" ]] && [[ $SEG = 1 ]];then
                        single=0
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "" >> ./log.csv
                                        echo "Multi CPU","RESULT_$i","INDEX_$i" >> ./log.csv
                                else
                                        echo "" >> ./tmp1.csv
                                        echo ,"Multi CPU","RESULT_$i","INDEX_$i" >> ./tmp1.csv
                                fi
                        fi
                        let SEG-=1
                        continue
                fi
                if [[ ${str:0:22} = "2D Graphics Benchmarks" ]] && [[ $FLAG = 0 ]] ;then
                        let FLAG+=1
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "2D test",, >> ./log.csv
                                else
                                        echo ,"2D test",, >> ./tmp1.csv
                                fi
                        fi
                        continue
                fi
                if [[ ${str:0:22} = "2D Graphics Benchmarks" ]] && [[ $FLAG = 1 ]] ;then
                        let FLAG-=1
                        a=`echo $str|awk '{print $NF}'`
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "2D Score",,$a >> ./log.csv
                                else
                                        echo ,"2D Score",,$a >> ./tmp1.csv
                                fi
                        fi
                        if [[ $single = 1 ]];then
                                sin2D=$a
                        else
                                mul2D=$a
                        fi
                fi
                if [[ ${str:0:17} = "System Benchmarks" ]] && [[ $FLAG = 0 ]] ;then
                        let FLAG+=1
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "System test",, >> ./log.csv
                                else
                                        echo ,"System test",, >> ./tmp1.csv
                                fi
                        fi
                        continue
                fi
                if [[ ${str:0:17} = "System Benchmarks" ]] && [[ $FLAG = 1 ]] ;then
                        let FLAG-=1
                        a=`echo $str|awk '{print $NF}'`
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "System Score",,$a >> ./log.csv
                                else
                                        echo ,"System Score",,$a >> ./tmp1.csv
                                fi
                        fi
                        if [[ $single = 1 ]];then
                                sinSYS=$a
                        else
                                mulSYS=$a
                        fi
                fi
                if [[ ${str:0:22} = "3D Graphics Benchmarks" ]] && [[ $FLAG = 0 ]] ;then
                        let FLAG+=1
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "3D test",, >> ./log.csv
                                else
                                        echo ,"3D test",, >> ./tmp1.csv
                                fi
                        fi
                        continue
                fi
                if [[ ${str:0:22} = "3D Graphics Benchmarks" ]] && [[ $FLAG = 1 ]] ;then
                        let FLAG-=1
                        a=`echo $str|awk '{print $NF}'`
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo "3D Score",,$a >> ./log.csv
                                else
                                        echo ,"3D Score",,$a >> ./tmp1.csv
                                fi
                        fi
                        if [[ $single = 1 ]];then
                                sin3D=$a
                        else
                                mul3D=$a
                        fi
                fi
                if [[ $FLAG = 1 ]] && [[ ${str:0:1} != "=" ]];then
                        a=`echo $str|awk '{for (i=1;i<NF-2;i++)printf("%s ",$i);print ""}'`
                        b=`echo $str|awk '{print $(NF-1)}'`
                        c=`echo $str|awk '{print $NF}'`
                        if [[ $log != 0 ]];then
                                if [[ $i = 1 ]];then
                                        echo $a,$b,$c >> ./log.csv
                                else
                                        echo ,$a,$b,$c >> ./tmp1.csv
                                fi
                        fi
                fi
        done < ./log_"$i".txt

        if [[ $log != 0 ]];then
                if [[ $i != 1 ]];then
                        paste -d, log.csv tmp1.csv > tmp2.csv
                    mv tmp2.csv log.csv
                        rm tmp1.csv
                fi
        fi

        if [[ $sys = 1 ]];then
                echo "$sinSYS" >> ./result2.csv
                echo "$mulSYS" >> ./result2.csv
        fi
        if [[ $grap = 1 ]];then
                echo "$sin2D" >> ./result2.csv
                echo "$mul2D" >> ./result2.csv
                echo "$sin3D" >> ./result2.csv
                echo "$mul3D" >> ./result2.csv
        fi

        paste -d, result.csv result2.csv > result3.csv
        mv result3.csv result.csv
        rm result2.csv

        let i+=1
        # sleep 60s
done

echo "Test Item","Average Score" >> $DIR/Result/"$rtime"/average_unixbench.csv
row=`wc -l $DIR/Result/"$rtime"/result.csv|awk '{print $1}'`
for ((i=1;i<=row;i++));do
        awk -F, 'NR=='"$i"'{printf"%s,",$1;if($2=="null")sum="null";else for(j=2;j<=$NF;j++)sum+=$j}END{if(sum!="null")printf"%.2f",sum/'"$feq"';else printf"%s",sum;print ""}' $DIR/Result/"$rtime"/result.csv >> $DIR/Result/"$rtime"/average_unixbench.csv
done
