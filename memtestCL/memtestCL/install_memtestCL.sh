#! /bin/bash

if [[ ! -e memtestCL-master.zip ]];then
	wget https://codeload.github.com/ihaque/memtestCL/zip/refs/heads/master && mv master memtestCL-master.zip
fi
unzip memtestCL-master.zip
cd memtestCL-master
make -f Makefiles/Makefile.linux64
