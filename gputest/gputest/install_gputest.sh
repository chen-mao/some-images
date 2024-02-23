#! /bin/bash

chmod 775 .
apt-get -y install python-tk
if [ ! -e GpuTest_Linux_x64_0.7.0.zip ] && [ ! -d GpuTest_Linux_x64_0.7.0 ];then
	wget https://ozone3d.net/gputest/dl/GpuTest_Linux_x64_0.7.0.zip
fi
if [ ! -d GpuTest_Linux_x64_0.7.0 ];then
	unzip GpuTest_Linux_x64_0.7.0.zip
fi
#cd GpuTest_Linux_x64_0.7.0
