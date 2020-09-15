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
            local rocketmq = require("rocketmq")
            ngx.say(string.format("%s", rocketmq.version))
        }
    }
--- request
    GET /t
--- response_body_like
2.\d.0.\d
--- no_error_log
[error]