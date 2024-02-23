#! /bin/bash

if [[ ! -e Geekbench-5.4.4-Linux.tar.gz ]];then
	wget https://cdn.geekbench.com/Geekbench-5.4.4-Linux.tar.gz
fi
tar -zxvf Geekbench-5.4.4-Linux.tar.gz
./Geekbench-5.4.4-Linux/geekbench5 --unlock xiaobo.li@xdxct.com IB5OU-QJ3GR-PYDTW-YIJFW-UPJID-6TZPK-4QCQN-ARCAH-UF3E4 
exit

if [[ -e License-GB5.txt ]];then
	mail=`head -n 1 License-GB5.txt`
	key=`tail -n 1 License-GB5.txt |awk -F: '{print $2}'`
	./Geekbench-5.4.4-Linux/geekbench5 --unlock $mail $key
else
	echo "Warning: No License Found! Tryout Version Only."
	sudo apt-get install python3 python python3-pip
	pip install requests
fi
