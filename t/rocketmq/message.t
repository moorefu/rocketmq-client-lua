# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket::Lua 'no_plan';
use Cwd qw(cwd);


my $pwd = cwd();

my $use_luacov = $ENV{'TEST_NGINX_USE_LUACOV'} // '';

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;$pwd/lib/?/init.lua;;";
    init_by_lua_block {
        if "1" == "$use_luacov" then
            require 'luacov.tick'
            jit.off()
        end
    }
};

run_tests();

__DATA__
=== TEST 1: Load ffi rocketmq library
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local message = require("rocketmq.message")
            local msg,err = message.Message:new({topic = "mytopic"})
            ngx.say(string.format("%s", msg:get_topic()))
        }
    }
--- request
    GET /t
--- response_body_like
mytopic
--- no_error_log
[error]

=== TEST 2: Load ffi rocketmq library
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local message = require("rocketmq.message")
            local msg,err = message.Message:new({topic = "mytopic"})
            local msg2,err2 = message.Message:new({ctx=msg.ctx})
            local ret = msg2:set_body("helloworld")
            ngx.say(string.format("%x", ret))
            ngx.say(string.format("%s", msg.topic))
            ngx.say(string.format("%s", msg2.topic))
            ngx.say(string.format("%s", message.Message.istype(msg)))
            ngx.say(string.format("%s", msg2:get_topic()))
            ngx.say(string.format("%s", msg2:get_body()))
        }
    }
--- request
    GET /t
--- response_body_like
0
mytopic
mytopic
true
mytopic
helloworld
--- no_error_log
[error]
=== TEST 3: Received Message
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local message = require("rocketmq.message")
            local recvmsg,err = message.ReceivedMessage:new({})
            ngx.say(string.format("%s", err))
        }
    }
--- request
    GET /t
--- response_body_like
Not a valid ReceivedMessage
--- no_error_log
[error]
