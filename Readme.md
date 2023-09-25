# Xdxct container toolkit

## Welcome to Xdxct container toolkit

**Xdxct container toolkit** 工具包允许用户构建和运行 GPU 加速容器,  支持的容器引擎 - Docker。

***

## 安装指南

### 支持平台: 
amd64/x86_64 下的 Ubuntu 20.04 和 Ubuntu 22.04。 

### Prerequisites
The list of prerequisites for running Xdxct Container Toolkit is described below:
1. GNU/Linux x86_64 with kernel version > 3.10
2. Docker >= 19.03,  (recommended, but some distributions may include older versions of Docker. The minimum supported version is 1.12)
3. XDXCT driver >= 1.18.

### 安装
两种方式安装toolkit,使用容器安装和deb包安装。  
法一容器化安装：
```bash
docker run --privileged -it --pid=host \
-v /etc/docker:/etc/docker \
-v /usr/local/xdxct:/usr/local/xdxct \
-v /var/run:/var/run \
--env ROOT=/usr/local/xdxct \
hub.xdxct.com/xdxct-docker/container-toolkit:1.0.0-rc.1-ubuntu20.04 -c "xdxct-toolkit -n"
```

法二deb包安装:
1. 安装下列xdxct容器工具包 
目录: test@172.18.25.248: ~/xdxct-docker/ubuntu20.04
- libxdxct-container1_1.0.0~rc.1-0_amd64.deb       
- libxdxct-container1-dbg_1.0.0~rc.1-0_amd64.deb   
- libxdxct-container-dev_1.0.0~rc.1-0_amd64.deb    
- libxdxct-container-tools_1.0.0~rc.1-0_amd64.deb
- xdxct-container-toolkit_1.0.0~rc.1-0_amd64.deb
- xdxct-container-toolkit-base_1.0.0~rc.1-0_amd64.deb
- xdxct-container-toolkit-operator-extensions_1.0.0~rc.1-0_amd64.deb

2. 添加镜像的私有仓库和设置xdxct为默认runtime
```shell
cat > /etc/docker/daemon.json <<-EOF
{
    "default-runtime": "xdxct",
    "insecure-registries": ["hub.xdxct.com"],
    "runtimes": {
        "xdxct": {
            "args": [],
            "path": "xdxct-container-runtime"
        }
    }
}
EOF
```

3. 重新启动 Docker 守护进程以完成安装
```shell
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 测试验证
1. 下载docker-compose的文件
```shell
git clone https://github.com/chen-mao/some-images.git
```

2. 此时，可以通过运行基本 ubuntu 容器来测试xdxsmi
```shell
docker run --rm hub.xdxct.com/xdxct-docker/xdxsmi-sample:latest xdxsmi
# 或者
cd utility 
docker-compose run xdxsmi-demo
# 进入容器
xdxsmi                                   # 测试xdxsmi  
```

3. openGL的测试
```
cd graphics/opengl
xhost +local:docker                       # 启用 Docker 容器连接到本地 X 服务器的权限
docker-compose run opengl-demo            # 启动 opengl-demo 服务
# 进入容器
glmark2                                   # 测试glmark2            
```

4. vulkan的测试
```
cd graphics/vulkan
xhost +local:docker                       # 启用 Docker 容器连接到本地 X 服务器的权限
docker-compose run vulkan-demo            # 启动 vulkan-demo 服务
# 进入容器
vulkaninfo
# 运行
vkcube
```

5. vlc的测试
由于测试vlc播放器功能, 需要准备好测试的视频。请将测试的视频放在~/media目录中。
```shell
cd video/vlc
xhost +local:docker                       # 启用 Docker 容器连接到本地 X 服务器的权限
docker-compose run vlc-video-demo         # 启动 vlc-video-demo 服务
# 进入容器
vlc --no-audio --avcodec-hw=vaapi test.mp4                   # 测试视频播放            
```

6. mpv的测试设置
由于测试mpv播放器功能, 需要准备好测试的视频。请将测试的视频放在~/media目录中。
```shell
cd video/mpv
xhost +local:docker                       # 启用 Docker 容器连接到本地 X 服务器的权限
docker-compose run mpv-video-demo         # 启动 mpv-video-demo 服务
# 进入容器
mpv --no-audio --hwdec=vaapi-copy test.mp4                   # 测试视频播放            
```

7. ffmpeg的测试
请将测试的视频放在~/media目录中, 目前支持软件解码和vaapi硬件解码
```shell
cd video/ffmpeg
xhost +local:docker
docker-compose run ffmpeg-demo              # 启用容器
vainfo                                      # 查看vaapi是否可用
ffmpeg -hwaccel vaapi -i test.mp4 test.mkv  # 测试视频转换
```

8. Compute的测试
```shell 
cd compute 
docker-compose run clinfo-demo            # 启动 opencl-demo 服务
# 进入容器
clinfo                                    # 列出当前系统上支持的OpenCL平台和设备    
```

## FAQ
Frequently asked questions.
