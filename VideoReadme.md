# Using MPV and VLC player in xdxcontainer

## 安装指南

### 支持平台: 
amd64/x86_64 下的 Ubuntu 20.04 和 Ubuntu 22.04  

### 依赖
1. GNU/Linux x86_64 with kernel version > 3.10
2. Docker >= 19.03,  (recommended, but some distributions may include older versions of Docker. The minimum supported version is 1.12)
3. XDXCT driver >= 1.18.

### 步骤
1. 下载并解压文件  
```shell
# 添加域名
sudo echo "172.18.25.248 hub.xdxct.com" >> /etc/hosts 
# 下载
wget hub.xdxct.com:5020/video-docker.txz
# 解压
tar -Jxf video-docker.txz
```
解压后的文件目录如下
```shell
video-docker
├── 10-xdxgpu.conf        # 配置文件
├── amd64                 # 依赖
├── docker-compose.yml    # dockercompose脚本
└── vlc-mpv-image.tar     # video player镜像
```
进入目录
```shell
cd video-docker
```

2. 安装依赖
```shell
sudo dpkg -i amd64/*
```

3. 导入镜像
```shell
docker load -i vlc-mpv-image.tar
```
查看镜像是否导入成功
```shell
! docker images
REPOSITORY                 TAG               IMAGE ID      SIZE 
xdxgpu/vlc-mpv-sample      1.0.0-Demo-rc-1   e3f3a295a008  482MB
```

4. 测试镜像
请将测试视频放入`~/media`文件夹下
运行以下命令启动容器
```shell
xhost +local:docker                       # 启用 Docker 容器连接到本地 X 服务器的权限
docker compose run mpv-video-demo         # 启动容器（若未将用户加入用户组，需要root权限）
mpv --no-audio test.mkv                   # 测试mpv播放器
vlc --no-audio test.mkv                   # 测试vlc播放器
```

## FAQ
Frequently asked questions.