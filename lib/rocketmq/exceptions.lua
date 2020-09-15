local ffi = require "ffi"
local C = ffi.load("rocketmq")
local ffi_gc = ffi.gc
local ffi_new = ffi.new
local ffi_str = ffi.string

local rocketmq = require "rocketmq.shared.rocketmq"
local Status = require("rocketmq.shared.rocketmq").enum.Status

local ffi_check = function(status_code)
    if status_code == Status.OK then
        return
    end
    local msg = rocketmq.GetLatestErrorMessage()
    error(msg)
end

return {
    ffi_check = ffi_check
}