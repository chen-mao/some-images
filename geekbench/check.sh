#!/bin/bash

# 获取当前脚本所在目录
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 定义目标文件夹名
target_folder="geekbench5"

# 构建目标文件夹的路径
target_folder_path="$script_dir/$target_folder"

# 检查目标文件夹是否存在
if [ -d "$target_folder_path" ]; then
    # 进入目标文件夹
    cd "$target_folder_path" || exit 1

    if [ ! -e Geekbench-5.4.4-Linux.tar.gz ]; then
        echo "Start download Geekbench-5.4.4-Linux.tar.gz.\n"
        wget 10.211.10.15:5020/benchmark/Geekbench-5.4.4-Linux.tar.gz
    fi

    echo "Check Done!"

else
    echo "Dir not found error!"
fi
