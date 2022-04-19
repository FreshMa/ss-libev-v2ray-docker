# ss-libev-v2ray-docker
shadowsocks-libev with v2ray-plugin dockerfile

参考了原版的 [Dockerfile](https://github.com/shadowsocks/shadowsocks-libev/blob/master/docker/alpine/Dockerfile) ，添加了 v2ray-plugin 的构建

当然在build之前建议改掉 server-config.json 里边的默认密码

## build docker image
`docker build -t {image_name} .`

需要确保网络能连到github，如果go get超时，可以在Dockerfile里添加一个GOPROXY，例如：

`ENV GOPROXY="https://proxy.golang.com.cn,direct"`

## to run
`docker run -p {port}:8388 -d {image_name}`

这里的{port}最好不要是 8388
