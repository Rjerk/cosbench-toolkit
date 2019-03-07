# cosbench docker

示例：在两台机器上部署

- s1: 36.255.223.111

1 controller + 1 driver

- s2: 23.91.98.200

2 drivers

## Build Docker

配置 controller:

`vim controller.conf`:

```
[controller]
drivers = 3
log_level = INFO
log_file = log/system.log
archive_dir = archive

[driver1]
name = driver1
url = http://36.255.223.111:18088/driver # 为 s1 配置 driver

# 下面是 s2 的 driver 配置

[driver2]
name = driver2
url = http://23.91.98.200:18088/driver # 这里 base port 为 18088，该机器上每多一个 driver, port 递增 100

[driver3]
name = driver3
url = http://23.91.98.200:18188/driver # 所以这里为 18188
```

然后 build 镜像:

```
./build.sh
```

## Run 

`docker build` 或者 `docker load` 导入镜像后

s2 上跑 2 drivers。

base port 为 18088，每多 1 个 driver 递增 100，两个 drivers 需开放两个 docker port，即 18088 和 18188，并设置环境变量 drivers_num=2

```
docker run -d --name driver -p 18088:18088 -p 18188:18188 -e drivers_num=2 cosbench:driver
```

s1 上，先跑 driver:

```
docker run -d --name driver -p 18088:18088 -e drivers_num=1 cosbench:driver
```

然后起 controller：

```
docker run -d -name controller -p 19088:19088 cosbench:controller
```
