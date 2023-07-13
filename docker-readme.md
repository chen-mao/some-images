# docker 

## 安装指南

***

1. 更新软件包列表和系统
```shell
sudo apt update
```

2. 安装Docker的依赖包
```shell
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

3. 添加Docker官方的GPG密钥
```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

4. 添加Docker的稳定版仓库
```shell
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

5. 更新软件包列表并安装Docker
```shell
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

6. 将当前用户添加到Docker用户组, 以便无需使用sudo来运行Docker命令
```shell
sudo groupadd docker               #添加用户组
sudo gpasswd -a $USER docker       #将当前用户添加至用户组
newgrp docker                      #更新用户组
```

7. 验证Docker是否成功安装
```shell
docker version
```

8. 下载docker-compose的二进制文件
```shell
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

9. 授予执行权限
```shell
sudo chmod +x /usr/local/bin/docker-compose
```

10. 此时，可以通过运行验证安装
```shell
docker info
docker-compose version
```

## FAQ
Frequently asked questions.