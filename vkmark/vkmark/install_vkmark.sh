#! /bin/bash

apt -y install meson g++ gcc gawk
apt -y install libvulkan-dev
apt -y install libglm-dev libassimp-dev libxcb1-dev libxcb-icccm4-dev
apt -y install libwayland-dev wayland-protocols
apt -y install libdrm-dev libgbm-dev
if [[ ! -e vkmark-master.zip ]];then
	wget https://codeload.github.com/vkmark/vkmark/zip/refs/heads/master && mv master vkmark-master.zip
fi
unzip vkmark-master.zip
cd vkmark-master
meson build
ninja -C build
ninja -C build install
