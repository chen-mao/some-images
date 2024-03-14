#!/bin/bash

# 获取当前脚本所在目录
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 定义目标文件夹名
target_folder="luxmark"

# 构建目标文件夹的路径
target_folder_path="$script_dir/$target_folder"

# 检查目标文件夹是否存在
if [ -d "$target_folder_path" ]; then
    # 进入目标文件夹
    cd "$target_folder_path" || exit 1

    if [ ! -e freeglut3_2.8.1-3_amd64.deb ]; then
        echo "Download file...\n"
        wget 10.211.10.15:5020/benchmark/freeglut3_2.8.1-3_amd64.deb
        wget 10.211.10.15:5020/benchmark/freeglut3-dev_2.8.1-3_amd64.deb
        wget 10.211.10.15:5020/benchmark/luxmark-linux64-v3.1.tar.bz2
    fi

    echo "Check Done!"
    
else
    echo "Dir not found error!"
fi
