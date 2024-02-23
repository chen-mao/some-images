#/bin/bash
script_dir=$(dirname "$(readlink -f "$0")")
cd $script_dir
apt install -y ocl-icd-dev  ocl-icd-opencl-dev ocl-icd-libopencl1 opencl-headers
if [ -e shoc_study-master.zip ];then
    unzip shoc_study-master.zip
    mv shoc_study-master shoc_study
else
    git clone https://gitee.com/zzyjsjcom/shoc_study.git
fi 
cd shoc_study/shoc/
./build.sh


