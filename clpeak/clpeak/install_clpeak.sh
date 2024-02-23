#! /bin/bash

apt-get -y install opencl-headers git

ARCH=`lscpu |grep Architecture|awk '{print $2}'``lscpu |grep 架构|awk '{print $2}'`

if [[ ! -e clpeak-master.zip ]];then
	wget https://codeload.github.com/krrishnarraj/clpeak/zip/refs/heads/master && mv master clpeak-master.zip
fi
unzip clpeak-master.zip
cd clpeak-master

#if [[ ${ARCH:0:5}="aarch" ]];then
#	old='OS_NAME'
#	new='LC_NAME'
#	sed -i "s/$old/$new/g" src/clpeak.cpp
#fi

mkdir build
cp ../sdk.zip build/
cd build
unzip sdk.zip
rm sdk.zip
cmake ../
make
