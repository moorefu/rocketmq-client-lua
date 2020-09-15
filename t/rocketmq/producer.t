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
=== TEST 1: Producer init
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local ffi = require("ffi")
            local Producer = require("rocketmq").Producer
            local Message = require("rocketmq").Message

            local p,err = Producer:new("group_a",{timeout=30})
            p:set_name_server_address('127.0.0.1:9876')
            p:start()
            --ngx.say(string.format("%s", p:version()))

            local msg,err = Message:new({topic = "broker"})
            msg:set_body("some body")
            msg:set_tags("tags")
            msg:set_keys("keys")
            local ret = p:send_sync(msg.ctx)
            --ngx.say(string.format("%s", ret))
            ngx.say(string.format("%s,%s,%s", tonumber(ret.sendStatus),ffi.string(ret.msgId),tonumber(ret.offset)))
            p:shutdown()
        }
    }
--- request
    GET /t
--- response_body_like
0,[0-9A-Za-z]+,\d+
--- no_error_log
[error]
