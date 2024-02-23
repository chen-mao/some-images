#! /bin/bash
##Author:Lijf
##FileName:glxgears_setup.sh

apt-get -y install mesa-common-dev libglew-dev libxext6 libxext6-dbg libxext-dev
apt-get -y install mesa-utils

#mkdir glxgears
#cd glxgears
if [[ ! -e glxgears-master.zip ]];then
	wget https://codeload.github.com/tobecodex/glxgears/zip/refs/heads/master && mv master glxgears-master.zip
fi
unzip glxgears-master.zip
#rm glxgears-master.zip
cd glxgears-master
make

NV=`lspci |grep VGA |grep NVIDIA`
if [ ! -e  ~/.drirc ] && [[ $NV = "" ]]; then
    touch ~/.drirc
    echo "<device screen=\"0\" driver=\"dri2\">"           >> ~/.drirc
    echo "    <application name=\"Default\">"              >> ~/.drirc
    echo "      <option name=\"vblank_mode\" value=\"0\">" >> ~/.drirc
    echo "    </application>"                              >> ~/.drirc
    echo "</device>"                                       >> ~/.drirc
fi

#sudo ./glxgears
