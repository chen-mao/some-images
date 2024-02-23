#! /bin/bash
##Author:Lijf
##FileName:BabelStream_Setup.sh

#-----------------------------------------------
##OpenCl Necessary Lib
WORKDIR=`pwd`
if [[ ! -e BabelStream-main.zip ]];then
	wget https://codeload.github.com/UoB-HPC/BabelStream/zip/refs/heads/main && mv main BabelStream-main.zip
fi
if [[ ! -e v2021.06.30.zip ]];then
	wget  https://codeload.github.com/KhronosGroup/OpenCL-Headers/zip/refs/tags/v2021.06.30 && mv v2021.06.30 v2021.06.30.zip
fi
CM=`cmake --version|grep version|awk '{print $3}'`
if [[ $CM < 3.13.0 ]];then
	if [ -e cmake-*.tar.gz ];then
		tar -zxvf cmake-*.tar.gz
		cd $WORKDIR/`ls -l |grep ^d |grep cmake |awk '{print $NF}'`/
		sudo apt install -y openssl libssl-dev
		./bootstrap && make && sudo make install
	else
		echo "Error : Cmake version is lower than 3.13"
		exit
	fi
fi
unzip BabelStream-main.zip
cd BabelStream-main

mkdir -p ./build/_deps/opencl_header-subbuild/opencl_header-populate-prefix/src
cp ../v2021.06.30.zip ./build/_deps/opencl_header-subbuild/opencl_header-populate-prefix/src/

ARCH=`lscpu |grep Architecture|awk '{print $2}'``lscpu |grep 架构|awk '{print $2}'`
if [[ $ARCH == "x86_64" ]];then
	cmake -Bbuild -H. -DMODEL=ocl -DOpenCL_LIBRARY=/usr/lib/x86_64-linux-gnu/libOpenCL.so.1
elif [[ $ARCH == "aarch64" ]];then
	cmake -Bbuild -H. -DMODEL=ocl -DOpenCL_LIBRARY=/usr/lib/aarch64-linux-gnu/libOpenCL.so.1
else
	echo "Error : Unknown Arch"
	exit
fi
cmake --build build
mv build/ buildocl/

