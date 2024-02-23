#! /bin/bash

#set -e
#[[ $EUID -eq 0 ]] && echo 'Error: This script can not be run as root!' && exit
#-----------------------------------------------
##Workspace Address
#mkdir glmark2
#cd glmark2
WORKDIR=`pwd`
FIX=0
cd $WORKDIR

##Check Files
if [[ ! -e glmark2-master.zip ]];then
	wget https://codeload.github.com/glmark2/glmark2/zip/refs/heads/master && mv master glmark2-master.zip
fi

if [ ! -e zlib*.tar.gz ];then 
	wget http://www.zlib.net/zlib-1.2.12.tar.gz
fi

if [ ! -e libpng*.tar.gz ];then 
	wget https://udomain.dl.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz
fi

if [ ! -e libjpeg-turbo*.tar.gz ];then 
	wget https://udomain.dl.sourceforge.net/project/libjpeg-turbo/2.1.2/libjpeg-turbo-2.1.2.tar.gz
fi

#sudo apt-get update
apt-get -y install expect build-essential libx11-dev libgl1-mesa-dev ocl-icd-opencl-dev mesa-common-dev mesa-utils mesa-utils-extra libglew-dev libxext6 libxext6-dbg libxext-dev libglu1-mesa-dev libxft-dev libfreetype6-dev libxmuu-dev gawk
apt-get -y install openssl libssl-dev
apt-get -y install cmake

##Unpack and Install
unzip glmark2-master.zip && mv glmark2-master glmark2

cd $WORKDIR
tar -zxvf zlib*.tar.gz 
cd $WORKDIR/`ls -l |grep ^d |grep zlib |awk '{print $NF}'`/
./configure
make
make install

cd $WORKDIR
tar -zxvf libpng*.tar.gz
cd $WORKDIR/`ls -l |grep ^d |grep libpng |awk '{print $NF}'`/
./configure
make
make install

cd $WORKDIR
tar -zxvf libjpeg-turbo*.tar.gz
cd $WORKDIR/`ls -l |grep ^d |grep libjpeg |awk '{print $NF}'`/
mkdir build && cd build
cmake ..  -DCMAKE_INSTALL_PREFIX=/usr
make
make install

cd $WORKDIR/glmark2/
./waf configure --with-flavors=x11-glesv2    
./waf build -j 4
./waf install

./waf configure --with-flavors=x11-gl    
./waf build -j 4
./waf install

#echo "Install Done!"
