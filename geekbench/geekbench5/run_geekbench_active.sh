#! /bin/bash

#[[ $EUID -ne 0 ]] && echo 'Error: This script must be run as root!' && exit


if [ ! -e Setup_geekbench.ini ]; then 
  echo "ERROR:'Setup_geekbench.ini' is Missing!"
  exit 1
fi

ReadIni() {
	file=$1;
	section=$2;
	item=$3;
	val=`awk -F '=' '/\['$section'\]/{a=1}a==1 && $1~/'$item'/{print $2;exit}' $file`
	echo ${val}
} 

TRY=`./Geekbench-5.4.4-Linux/geekbench5 -h 2>/dev/null|grep Tryout`
if [[ $TRY != "" ]];then
	echo "You Are Running in Tryout Mode!"
	exit 1
fi

feq=`ReadIni Setup_geekbench.ini Frequent Times`
stime=`echo $(date +%F%n%T)`
CPUTEST=`ReadIni Setup_geekbench.ini Run CPU`
if ((CPUTEST != 0 && CPUTEST !=1));then
	echo "Error : parameter [Run]CPU is illegal !"
	exit 1
fi
CLTEST=`ReadIni Setup_geekbench.ini Run API_CL`
if ((CLTEST != 0 && CLTEST !=1));then
	echo "Error : parameter [Run]API_CL is illegal !"
	exit 1
fi
VKTEST=`ReadIni Setup_geekbench.ini Run API_VK`
if ((VKTEST != 0 && VKTEST !=1));then
	echo "Error : parameter [Run]API_VK is illegal !"
	exit 1
fi
flag=0
i=1 
NoRun=0

CL=`./Geekbench-5.4.4-Linux/geekbench5 --compute-list 2>/dev/null|grep OpenCL`
VK=`./Geekbench-5.4.4-Linux/geekbench5 --compute-list 2>/dev/null|grep Vulkan`

mkdir -p Result/"$stime"
while [[ $i -le $feq ]];do
	if [[ $CPUTEST != 0 ]];then
		echo "running cycle $i : CPU Testing ..."
		./Geekbench-5.4.4-Linux/geekbench5 --no-upload >> Result/"$stime"/resultCPU_$i.txt
	else
		((NoRun ++))
	fi
	if [[ $CL != "" ]]&&[[ $CLTEST != 0 ]];then
		echo "running cycle $i : OpenCL Testing ..."
		./Geekbench-5.4.4-Linux/geekbench5 --compute OpenCL --no-upload >> Result/"$stime"/resultCL_$i.txt 2>/dev/null
	elif [[ $CL == "" ]]&&[[ $CLTEST != 0 ]];then
		echo "No OpenCL API Found!"		
		((NoRun ++))
	else
		((NoRun ++))
	fi
	if [[ $VK != "" ]]&&[[ $VKTEST != 0 ]];then
		echo "running cycle $i : Vulkan Testing ..."
		./Geekbench-5.4.4-Linux/geekbench5 --compute Vulkan --no-upload >> Result/"$stime"/resultVK_$i.txt 2>/dev/null
	elif [[ $VK == "" ]]&&[[ $VKTEST != 0 ]];then
		echo "No Vulkan API Found!"
		((NoRun ++))	
	else
		((NoRun ++))
	fi
	if (( NoRun == 3));then
		echo "No test start."
		rm -r Result/"$stime"/
		exit
	fi
##CPU
	if [[ $i = 1 ]]&&[[ $CPUTEST != 0 ]];then
		while read str; do
			if [[ $str = "Single-Core" ]];then
				let flag+=1
				echo $str > Result/"$stime"/temp1.txt
			elif [[ $str = "Multi-Core" ]];then 
				echo $str >> Result/"$stime"/temp1.txt
			elif [[ $str = "Benchmark Summary" ]];then
				echo $str >> Result/"$stime"/temp1.txt
				let flag+=1
			elif [[ $str != "" ]] && [[ $flag = 1 ]];then
				a=`echo $str|awk '{print $2}'`
				b=`echo $str|awk '{print $3}'`
				case ${a:0:1} in
					[a-z]|[A-Z])
						case ${b:0:1} in
							[a-z]|[A-Z])
								echo $str|awk '{print $1,$2,$3}'>> Result/"$stime"/temp1.txt
								echo "">> Result/"$stime"/temp1.txt
							;;
							[0-9])
								echo $str|awk '{print $1,$2}'>> Result/"$stime"/temp1.txt
								echo "">> Result/"$stime"/temp1.txt
							;;
							*) ;;
						esac
						;;
					[0-9])
						echo $str|awk '{print $1}'>> Result/"$stime"/temp1.txt
						echo "">> Result/"$stime"/temp1.txt
					;;
					*) ;;
				esac
			elif [[ $str != "" ]] && [[ $flag = 2 ]];then
				a=`echo $str|awk '{print $2}'`
				b=`echo $str|awk '{print $3}'`
				case ${a:0:1} in
					[a-z]|[A-Z])
						case ${b:0:1} in
							[a-z]|[A-Z])
								echo $str|awk '{print $1,$2,$3}'>>Result/"$stime"/temp1.txt
							;;
							[0-9])
								echo $str|awk '{print $1,$2}'>>Result/"$stime"/temp1.txt
							;;
							*) ;;
						esac
						;;
					[0-9])
						echo $str|awk '{print $1}'>> Result/"$stime"/temp1.txt
					;;
					*) ;;
				esac
			fi		
		done < Result/"$stime"/resultCPU_$i.txt
	flag=0
	fi
##CL
	if [[ $i = 1 ]] && [[ $CL != "" ]]&&[[ $CLTEST != 0 ]];then
		while read str; do
			if [[ $str = "OpenCL" ]];then
				let flag+=1
				echo $str >>  Result/"$stime"/temp1.txt
			elif [[ $str = "Benchmark Summary" ]];then
				echo $str >>  Result/"$stime"/temp1.txt
				let flag+=1
			elif [[ $str != "" ]] && [[ $flag = 1 ]];then
				a=`echo $str|awk '{print $2}'`
				b=`echo $str|awk '{print $3}'`
				case ${a:0:1} in
					[a-z]|[A-Z])
						case ${b:0:1} in
							[a-z]|[A-Z])
								echo $str|awk '{print $1,$2,$3}'>> Result/"$stime"/temp1.txt
								echo "">> Result/"$stime"/temp1.txt
							;;
							[0-9])
								echo $str|awk '{print $1,$2}'>> Result/"$stime"/temp1.txt
								echo "">> Result/"$stime"/temp1.txt
							;;
							*) ;;
						esac
						;;
					[0-9])
						echo $str|awk '{print $1}'>> Result/"$stime"/temp1.txt
						echo "">> Result/"$stime"/temp1.txt
					;;
					*) ;;
				esac
			elif [[ $str != "" ]] && [[ $flag = 2 ]];then
				a=`echo $str|awk '{print $2}'`
				b=`echo $str|awk '{print $3}'`
				case ${a:0:1} in
					[a-z]|[A-Z])
						case ${b:0:1} in
							[a-z]|[A-Z])
								echo $str|awk '{print $1,$2,$3}'>> Result/"$stime"/temp1.txt
							;;
							[0-9])
								echo $str|awk '{print $1,$2}'>> Result/"$stime"/temp1.txt
							;;
							*) ;;
						esac
						;;
					[0-9])
						echo $str|awk '{print $1}'>> Result/"$stime"/temp1.txt
					;;
					*) ;;
				esac
			fi		
		done < Result/"$stime"/resultCL_$i.txt
	flag=0
	fi
##VK
	if [[ $i = 1 ]] && [[ $VK != "" ]]&&[[ $VKTEST != 0 ]];then
		while read str; do
			if [[ $str = "Vulkan" ]];then
				let flag+=1
				echo $str >>  Result/"$stime"/temp1.txt
			elif [[ $str = "Benchmark Summary" ]];then
				echo $str >>  Result/"$stime"/temp1.txt
				let flag+=1
			elif [[ $str != "" ]] && [[ $flag = 1 ]];then
				a=`echo $str|awk '{print $2}'`
				b=`echo $str|awk '{print $3}'`
				case ${a:0:1} in
					[a-z]|[A-Z])
						case ${b:0:1} in
							[a-z]|[A-Z])
								echo $str|awk '{print $1,$2,$3}'>> Result/"$stime"/temp1.txt
								echo "">> Result/"$stime"/temp1.txt
							;;
							[0-9])
								echo $str|awk '{print $1,$2}'>> Result/"$stime"/temp1.txt
								echo "">> Result/"$stime"/temp1.txt
							;;
							*) ;;
						esac
						;;
					[0-9])
						echo $str|awk '{print $1}'>> Result/"$stime"/temp1.txt
						echo "">> Result/"$stime"/temp1.txt
					;;
					*) ;;
				esac
			elif [[ $str != "" ]] && [[ $flag = 2 ]];then
				a=`echo $str|awk '{print $2}'`
				b=`echo $str|awk '{print $3}'`
				case ${a:0:1} in
					[a-z]|[A-Z])
						case ${b:0:1} in
							[a-z]|[A-Z])
								echo $str|awk '{print $1,$2,$3}'>> Result/"$stime"/temp1.txt
							;;
							[0-9])
								echo $str|awk '{print $1,$2}'>> Result/"$stime"/temp1.txt
							;;
							*) ;;
						esac
						;;
					[0-9])
						echo $str|awk '{print $1}'>> Result/"$stime"/temp1.txt
					;;
					*) ;;
				esac
			fi		
		done < Result/"$stime"/resultVK_$i.txt
	flag=0
	fi
##CPU
	if [[ $CPUTEST != 0 ]];then
		while read str; do
			if [[ $str = "Single-Core" ]];then
				let flag+=1
				echo "" >>  Result/"$stime"/temp2.txt
			elif [[ $str = "Multi-Core" ]];then 
				echo "" >>  Result/"$stime"/temp2.txt
			elif [[ $str = "Benchmark Summary" ]];then
				let flag+=1
				echo "" >>  Result/"$stime"/temp2.txt
			elif [[ $str != "" ]] && [[ $flag = 1 ]];then
				echo $str|awk 'BEGIN{OFS=","}''{print $(NF-2)}' >>  Result/"$stime"/temp2.txt
				echo " ,"$str|awk '{print $(NF-1),$NF}' >>  Result/"$stime"/temp2.txt
			elif [[ $str != "" ]] && [[ $flag = 2 ]];then
				echo $str|awk 'BEGIN{OFS=","}''{print $NF}' >>  Result/"$stime"/temp2.txt
			fi
		done < Result/"$stime"/resultCPU_$i.txt
		flag=0
	fi
##CL
	if [[ $CL != "" ]]&&[[ $CLTEST != 0 ]];then
		while read str; do
			if [[ $str = "OpenCL" ]];then
				let flag+=1
				echo "" >>  Result/"$stime"/temp2.txt
			elif [[ $str = "Benchmark Summary" ]];then
				let flag+=1
				echo "" >>  Result/"$stime"/temp2.txt
			elif [[ $str != "" ]] && [[ $flag = 1 ]];then
				echo $str|awk 'BEGIN{OFS=","}''{print $(NF-2)}' >>  Result/"$stime"/temp2.txt
				echo " ,"$str|awk '{print $(NF-1),$NF}' >>  Result/"$stime"/temp2.txt
			elif [[ $str != "" ]] && [[ $flag = 2 ]];then
				echo $str|awk 'BEGIN{OFS=","}''{print $NF}' >>  Result/"$stime"/temp2.txt
			fi
		done < Result/"$stime"/resultCL_$i.txt
		flag=0
	fi
##VK
	if [[ $VK != "" ]]&&[[ $VKTEST != 0 ]];then
		while read str; do
			if [[ $str = "Vulkan" ]];then
				let flag+=1
				echo "" >>  Result/"$stime"/temp2.txt
			elif [[ $str = "Benchmark Summary" ]];then
				let flag+=1
				echo "" >>  Result/"$stime"/temp2.txt
			elif [[ $str != "" ]] && [[ $flag = 1 ]];then
				echo $str|awk 'BEGIN{OFS=","}''{print $(NF-2)}' >>  Result/"$stime"/temp2.txt
				echo " ,"$str|awk '{print $(NF-1),$NF}' >>  Result/"$stime"/temp2.txt
			elif [[ $str != "" ]] && [[ $flag = 2 ]];then
				echo $str|awk 'BEGIN{OFS=","}''{print $NF}' >>  Result/"$stime"/temp2.txt
			fi
		done < Result/"$stime"/resultVK_$i.txt
		flag=0
	fi

	paste -d,  Result/"$stime"/temp1.txt  Result/"$stime"/temp2.txt >  Result/"$stime"/temp3.txt
	mv  Result/"$stime"/temp3.txt  Result/"$stime"/temp1.txt
	rm  Result/"$stime"/temp2.txt

	let i+=1
done

mv 	Result/"$stime"/temp1.txt Result/"$stime"/result.csv
rows=`awk -F, '{if($1=="Single-Core Score"||$1=="Multi-Core Score"||$1=="OpenCL Score"||$1=="Vulkan Score") print NR}' Result/"$stime"/result.csv`
for i in $rows;do
	awk -F, 'NR=='"$i"' {printf"%s,",$1;for(j=2;j<=$NF;j++)sum+=$j}END{printf"%.2f",sum/'"$feq"';print ""}' Result/"$stime"/result.csv >> Result/"$stime"/average_Geekbench.csv
done

#echo "Done! The Result is in Result/"$stime"."
