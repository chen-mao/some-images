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

### 步骤 
1. 安装下列xdxct容器工具包 
目录: test@172.18.25.248: ~/xdxct-docker/ubuntu20.04
- libxdxct-container1_1.0.0~rc.1-0_amd64.deb       
- libxdxct-container1-dbg_1.0.0~rc.1-0_amd64.deb   
- libxdxct-container-dev_1.0.0~rc.1-0_amd64.deb    
- libxdxct-container-tools_1.0.0~rc.1-0_amd64.deb
- xdxct-container-toolkit_1.0.0~rc.1-0_amd64.deb
- xdxct-container-toolkit-base_1.0.0~rc.1-0_amd64.deb
- xdxct-container-toolkit-operator-extensions_1.0.0~rc.1-0_amd64.deb

2. 设置harbor仓库的域名
```shell
echo "172.18.25.248 hub.xdxct.com" >> /etc/hosts 
```

3. 添加镜像的私有仓库和设置xdxct为默认runtime
```shell
cat > /etc/docker/daemon.json <<-EOF
{
    "default-runtime": "xdxct",
    "insecure-registries": ["hub.xdxct.com"],
    "runtimes": {
        "xdxct": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    }
}
EOF
```

4. 重新启动 Docker 守护进程以完成安装
```shell
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 测试验证
1. 登录harbor
```shell
docker login hub.xdxct.com
Username: admin
password: Harbor12345 
```

2. 下载docker-compose的文件
```shell
git clone https://github.com/chen-mao/some-images.git
```

3. 此时，可以通过运行基本 ubuntu 容器来测试xdxsmi
```shell
docker run --rm --gpus all hub.xdxct.com/xdxct-docker/xdxgpu/xdxsmi-sample:1.0.0-Demo-rc-1 xdxsmi
# 或者
cd utility 
docker-compose run xdxsmi-demo
```

4. Graphics的测试
```
cd graphics
xhost +local:docker                       # 启用 Docker 容器连接到本地 X 服务器的权限
docker-compose run glmark2-demo           # 启动 glmark2-demo 服务
# 进入容器
glmark2                                   # 测试glmark2            
```

5. video的测试
由于测试video功能, 需要准备好测试的视频。请将测试的视频放在~/media目录中。
```shell
cd video
xhost +local:docker                       # 启用 Docker 容器连接到本地 X 服务器的权限
docker-compose run vlc-video-demo         # 启动 vlc-video-demo 服务
# 进入容器
vlc --no-audio test.mp4                   # 测试视频播放            
```

6. Compute的测试
```shell 
cd compute 
docker-compose run opencl-demo            # 启动 opencl-demo 服务
# 进入容器
clinfo                                    # 列出当前系统上支持的OpenCL平台和设备    
```

## FAQ
Frequently asked questions.
