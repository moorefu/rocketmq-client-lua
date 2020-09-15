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
            local PushConsumer = require("rocketmq").PushConsumer
            local Message = require("rocketmq").Message
            local ConsumeStatus = require("rocketmq").ConsumeStatus

            local c = PushConsumer:new("group_a")
            c:set_name_server_address('127.0.0.1:9876')
            local tp = "abc"
            local callback = function(msg) 
                ngx.say(string.format("%s", msg:id()))
                 return ConsumeStatus.CONSUME_SUCCESS
            end
            c:subscribe("broker",callback,"*")
            c:start()
            --ngx.sleep(10)
            ngx.say(string.format("%s", tp))
            --c:shutdown()
        }
    }
--- request
    GET /t
--- response_body_like
([0-9A-Za-z]+)*
--- no_error_log
[error]
