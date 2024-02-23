#! /bin/bash

WorkDir=`pwd`
# Check System
#[[ $EUID -ne 0 ]] && echo 'Error: please run as root!' && exit 1
[[ -f /etc/redhat-release ]] && os='centos'
[[ ! -z "`egrep -i debian /etc/issue`" ]] && os='debian'
[[ ! -z "`egrep -i ubuntu /etc/issue`" ]] && os='ubuntu'
[[ ! -z "`egrep -i Kylin /etc/issue`" ]] && os='kylin' 
[[ ! -z "`egrep -i UnionTech /etc/issue`" ]] && os='uniontech' 
[[ "$os" == '' ]] && echo 'Error: unsupported system!' && exit 1

# Install necessary libaries
if [ "$os" == 'centos' ]; then
    yum -y install make automake gcc autoconf gcc-c++ time perl-Time-HiRes
else
#   apt-get -y update
#   apt-get -y install make automake gcc autoconf time perl 
    apt-get -y install expect build-essential gawk
    apt-get -y install libx11-dev mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev libxext-dev 
    apt-get -y install libxft-dev libfreetype6-dev libxmuu-dev
fi

#Check the Test Files
cd $WorkDir
if [ -d UnixBench_5.1.3-master ]; then
    cd UnixBench_5.1.3-master
    Unixbench=`pwd`
elif [ -e UnixBench_5.1.3-master.zip ]; then
    unzip UnixBench_5.1.3-master.zip
    cd UnixBench_5.1.3-master
    Unixbench=`pwd`
else
    wget https://codeload.github.com/imadcat/UnixBench_5.1.3/zip/refs/heads/master && mv master UnixBench_5.1.3-master.zip
    unzip UnixBench_5.1.3-master.zip
    cd UnixBench_5.1.3-master
    Unixbench=`pwd`
fi

#Graphic Prepare
cd $WorkDir
if [ ! -e ./config.guess ];then
	wget https://raw.githubusercontent.com/gcc-mirror/gcc/master/config.guess && chmod +x config.guess
fi
Build=`./config.guess`

if [ -d x11perf-1.5 ]; then
    cd x11perf-1.5
    X11=`pwd`
elif [ -e x11perf-1.5.tar.gz ]; then
    tar -zxvf x11perf-1.5.tar.gz
    cd x11perf-1.5
    X11=`pwd`
else
    wget https://www.x.org/archive/individual/app/x11perf-1.5.tar.gz
    tar -zxvf x11perf-1.5.tar.gz
    cd x11perf-1.5
    X11=`pwd`
fi

ln -s /usr/include/freetype2/ft2build.h /usr/include/X11/Xft
./configure --build=$Build
make
make install

#VSYNC
apt-get install mesa-utils
NV=`lspci |grep VGA |grep NVIDIA`
if [ ! -e  ~/.drirc ] && [[ $NV = "" ]]; then
    touch ~/.drirc
    echo "<device screen=\"0\" driver=\"dri2\">"            >> ~/.drirc
    echo "    <application name=\"Default\">"               >> ~/.drirc
    echo "      <option name=\"vblank_mode\" value=\"0\">"  >> ~/.drirc
    echo "    </application>"                               >> ~/.drirc
    echo "</device>"                                        >> ~/.drirc
fi

#Unixbench Config
cd $Unixbench
OLD1='# GRAPHIC_TESTS = defined'
NEW1='GRAPHIC_TESTS = defined'
sed -i "s/$OLD1/$NEW1/g" $Unixbench/Makefile
OLD2='ubgears.c $(GL_LIBS)'
NEW2='ubgears.c -lm $(GL_LIBS)'
sed -i "s/$OLD2/$NEW2/g" $Unixbench/Makefile
make

cpu=`cat /proc/cpuinfo|grep processor|awk '{i++} END {print i}'`
OLD3="'maxCopies' => \(.*\) }"
NEW3="'maxCopies' => $cpu }"
sed -i "s/$OLD3/$NEW3/g" $Unixbench/Run


