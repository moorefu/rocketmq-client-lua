# rocketmq-client-lua

RocketMQ Lua client, based on [rocketmq-client-cpp](https://github.com/apache/rocketmq-client-cpp), supports Linux and macOS
## Prerequisites

### Install `librocketmq`
rocketmq-client-lua is a lightweight wrapper around [rocketmq-client-cpp](https://github.com/apache/rocketmq-client-cpp), so you need install 
`librocketmq` first.

#### Download by binary release.
download specific release according you OS: [rocketmq-client-cpp-2.0.0](https://github.com/apache/rocketmq-client-cpp/releases/tag/2.0.0)
- centos
    
    take centos7 as example, you can install the library in centos6 by the same method.
    ```bash
        wget https://github.com/apache/rocketmq-client-cpp/releases/download/2.1.0/rocketmq-client-cpp-2.1.0-centos7.x86_64.rpm
        sudo rpm -ivh rocketmq-client-cpp-2.1.0-centos7.x86_64.rpm
    ```
- debian
    ```bash
        wget https://github.com/apache/rocketmq-client-cpp/releases/download/2.1.0/rocketmq-client-cpp-2.1.0.amd64.deb
        sudo dpkg -i rocketmq-client-cpp-2.1.0.amd64.deb
    ```
- macOS
    ```bash
        wget https://github.com/apache/rocketmq-client-cpp/releases/download/2.1.0/rocketmq-client-cpp-2.1.0-bin-release-darwin.tar.gz
        tar -xzf rocketmq-client-cpp-2.1.0-bin-release-darwin.tar.gz
        cd rocketmq-client-cpp
        mkdir /usr/local/include/rocketmq
        cp include/* /usr/local/include/rocketmq
        cp lib/* /usr/local/lib
        install_name_tool -id "@rpath/librocketmq.dylib" /usr/local/lib/librocketmq.dylib
    ```
#### Build from source
you can also build it manually from source according to [Build and Install](https://github.com/apache/rocketmq-client-cpp/tree/master#build-and-install)

## Installation

```bash
luarocks install rocketmq-client-lua --server=https://luarocks.org/manifests/moorefu
```

## Usage

### Producer

```lua
local Producer = require("resty.rocketmq").Producer
local Message = require("resty.rocketmq").Message

local producer = Producer:new('PID-XXX')
producer:set_name_server_address('127.0.0.1:9876')
producer:start()

local msg = Message:new('YOUR-TOPIC')
msg:set_keys('XXX')
msg:set_tags('XXX')
msg:set_body('XXXX')
local ret = producer:send_sync(msg)
ngx.say(string.format("%s,%s,%s", tonumber(ret.sendStatus),ffi.string(ret.msgId),tonumber(ret.offset)))
producer:shutdown()
```

### PushConsumer

```lua
local PushConsumer = require("resty.rocketmq").PushConsumer
local ConsumeStatus = require("resty.rocketmq").ConsumeStatus

local callback = function(msg)
    ngx.say(string.format("%s,%s", msg:id(),msg:body()))
    return ConsumeStatus.CONSUME_SUCCESS
end

local consumer = PushConsumer:new('CID_XXX')
consumer:set_name_server_address('127.0.0.1:9876')
consumer:subscribe('YOUR-TOPIC', callback,"*")
consumer:start()

consumer:shutdown()

```