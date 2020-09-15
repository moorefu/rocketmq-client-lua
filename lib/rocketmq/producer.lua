local ffi = require "ffi"
local ffi_gc = ffi.gc
local ffi_new = ffi.new
local ffi_str = ffi.string

local search = require("rocketmq.util").search
local rocketmq = require "rocketmq.shared.rocketmq"
local message = require "rocketmq.message"
local ffi_check = require("rocketmq.exceptions").ffi_check


local producer_ptr_ct = ffi.typeof('CProducer*')
local send_result_ptr_type = ffi.typeof('struct _SendResult_')


local Producer = {
    _callback_refs={},
}
local function apply_opts(self,o,opts)
    if type(opts)=="table" then
        if opts.timeout then
            self.set_timeout(o,opts.timeout)
        end

        if opts.compress_level then
            self.set_compress_level(o,opts.compress_level)
        end

        if opts.max_message_size then
            self.set_max_message_size(o,opts.max_message_size)
        end
    end
end
function Producer:new(o,opts)
    o = o or {}
    self.__index = self
    if type(o)=="string" then
        o = {group_id=o}
    end
    if not o.ctx or not  ffi.istype(producer_ptr_ct, o.ctx) then
        local ctx = nil
        if opts and opts.orderly then
            ctx = rocketmq.CreateOrderlyProducer(o.group_id)
        else
            ctx = rocketmq.CreateProducer(o.group_id)
        end
        ffi_gc(ctx,rocketmq.DestroyProducer)
        o.ctx = ctx
    end
    if not o.ctx then
        return nil, "Returned null pointer when create Producer"
    end
    setmetatable(o,self)
    -- init
    apply_opts(self,o,opts)

    return o,nil
end

function Producer:send_sync(msg)
    -- local c_result = ffi_new("CSendResult")
    local c_result = send_result_ptr_type()
    rocketmq.SendMessageSync(self.ctx,msg,c_result)
    return c_result
end

function Producer:send_oneway(msg)
    return ffi_check(rocketmq.SendMessageOneway(self.ctx,msg))
end

function Producer:send_orderly_with_sharding_key(msg,sharding_key)
    local c_result = ffi_new("CSendResult")
    rocketmq.SendMessageOrderlyByShardingKey(self.ctx,msg,sharding_key,c_result)
    return c_result
end

function Producer:set_group(group_name)
    rocketmq.SetProducerGroupName(self.ctx,group_name)
end
function Producer:set_instance_name(name)
    rocketmq.SetProducerInstanceName(self.ctx,name)
end
function Producer:set_name_server_address(addr)
    rocketmq.SetProducerNameServerAddress(self.ctx,addr)
end
function Producer:set_name_server_domain(domain)
    rocketmq.SetProducerNameServerDomain(self.ctx,domain)
end
function Producer:set_session_credentials(access_key, access_secret, channel)
    rocketmq.SetProducerSessionCredentials(self.ctx,access_key, access_secret, channel)
end
function Producer:set_timeout(timeout)
    rocketmq.SetProducerSendMsgTimeout(self.ctx,timeout)
end
function Producer:set_compress_level(level)
    rocketmq.SetProducerCompressLevel(self.ctx,level)
end
function Producer:set_max_message_size(max_size)
    rocketmq.SetProducerMaxMessageSize(self.ctx,max_size)
end
function Producer:start()
    ffi_check(rocketmq.StartProducer(self.ctx))
end
function Producer:shutdown()
    ffi_check(rocketmq.ShutdownProducer(self.ctx))
end

function Producer:version()
    return ffi_str(rocketmq.ShowProducerVersion(self.ctx))
end

local TransactionMQProducer = {}

function TransactionMQProducer:new(o,opts)
    o = o or {}
    setmetatable(self,{__index = function(t, k)
        return search(k, {Producer})
    end})
    self.__index = self
    local group_id = o.group_id
    local checker_callback = o.checker_callback
    local user_args = o.user_args
    local transaction_checker_callback = ffi.cast("CLocalTransactionCheckerCallback",function(producer_hdl,msg_hdl,user_data)
        local msg = message.Message:new(msg_hdl)
        local check_result = checker_callback(msg)
        -- 检查status
        return check_result
    end)
    table.insert(self._callback_refs,transaction_checker_callback)
    local ctx = rocketmq.CreateTransactionProducer(group_id,transaction_checker_callback,user_args)
    ffi_gc(ctx,rocketmq.DestroyProducer)
    setmetatable(o,self)
    apply_opts(self,o,opts)
    return o,nil
end

function TransactionMQProducer:send_message_in_transaction(msg,local_execute,user_args)
    local local_execute_callback = ffi.cast("CLocalTransactionExecutorCallback",function(producer_hdl,msg_hdl,user_args)
        local recv_msg = message.ReceivedMessage:new(msg_hdl)
        local local_result = local_execute(recv_msg,user_args)
        return local_result
    end)
    table.insert(self._callback_refs,local_execute_callback)
    local result = ffi_new("CSendResult")
    rocketmq.SendMessageTransaction(self.ctx,msg.ctx,local_execute_callback,user_args,result)

    for i = #self._callback_refs, 1, -1 do
        if self._callback_refs[i] == local_execute_callback then
            table.remove(self._callback_refs,i)
        end
    end

    return result

end

return {
    Producer= Producer,
    TransactionMQProducer = TransactionMQProducer,
}