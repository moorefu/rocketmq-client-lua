local ffi = require "ffi"
local ffi_gc = ffi.gc
local ffi_new = ffi.new
local ffi_str = ffi.string

local rocketmq = require "rocketmq.shared.rocketmq"
local MessageModel = require("rocketmq.shared.rocketmq").enum.MessageModel
local message = require "rocketmq.message"

local push_consumer_ptr_ct = ffi.typeof('CPushConsumer*')

local PushConsumer = {
    _callback_refs = {},
    _orderly = false,
}

function PushConsumer:new(o,opts)
    o = o or {}
    opts = opts or {}
    self.__index = self
    if type(o)=="string" then
        o = {group_id=o}
    end
    if not opts.message_model then
        opts.message_model = MessageModel.CLUSTERING
    end
    if not o.ctx or not  ffi.istype(push_consumer_ptr_ct, o.ctx) then
        local ctx = rocketmq.CreatePushConsumer(o.group_id)
        ffi_gc(ctx,rocketmq.DestroyPushConsumer)
        o.ctx = ctx
    end
    if not o.ctx then
        return nil, "Returned null pointer when create PushConsumer"
    end
    setmetatable(o,self)
    if opts.orderly then
        self._orderly = true
    end
    self.set_message_model(o,opts.message_model)

    return o,nil
end

function PushConsumer:set_message_model(model)
    rocketmq.SetPushConsumerMessageModel(self.ctx,model)
end
function PushConsumer:start()
    rocketmq.StartPushConsumer(self.ctx)
end
function PushConsumer:shutdown()
    rocketmq.ShutdownPushConsumer(self.ctx)
end

function PushConsumer:set_group(group_id)
    rocketmq.SetPushConsumerGroupID(self.ctx,group_id)
end
function PushConsumer:set_name_server_address(addr)
    rocketmq.SetPushConsumerNameServerAddress(self.ctx,addr)
end
function PushConsumer:set_name_server_domain(domain)
    rocketmq.SetPushConsumerNameServerDomain(self.ctx,domain)
end
function PushConsumer:set_session_credentials(access_key, access_secret, channel)
    rocketmq.SetPushConsumerSessionCredentials(self.ctx,access_key,access_secret,channel)
end
function PushConsumer:subscribe(topic, callback, expression)
    if not expression then
        expression = "*"
    end
    local _on_message = function(push_consumer_hdl,msg_hdl)
        local consume_result = callback(message.ReceivedMessage:new(msg_hdl))
        return consume_result
    end
    rocketmq.Subscribe(self.ctx,topic,expression)
    self:_register_callback(_on_message)
end

function PushConsumer:_register_callback(callback)
    local message_callback = ffi.cast("MessageCallBack",callback)
    table.insert(self._callback_refs,message_callback)
    if self._orderly then
        rocketmq.RegisterMessageCallbackOrderly(self.ctx,message_callback)
    else
        rocketmq.RegisterMessageCallback(self.ctx,message_callback)
    end
end

function PushConsumer:_unregister_callback()
    if self._orderly then
        rocketmq.UnregisterMessageCallbackOrderly(self.ctx)
    end
    rocketmq.UnregisterMessageCallback(self.ctx)
    self._callback_refs = {}
end

function PushConsumer:set_thread_count(thread_count)
    rocketmq.SetPushConsumerThreadCount(self.ctx,thread_count)
end
function PushConsumer:set_message_batch_max_size(max_size)
    rocketmq.SetPushConsumerMessageBatchMaxSize(self.ctx,max_size)
end
function PushConsumer:set_instance_name(name)
    rocketmq.SetPushConsumerInstanceName(self.ctx,name)
end

local PullConsumer = {}


return {
    PushConsumer = PushConsumer,
    PullConsumer = PullConsumer,
}