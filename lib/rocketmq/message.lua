local ffi = require "ffi"
local ffi_gc = ffi.gc
local ffi_new = ffi.new
local ffi_str = ffi.string

local rocketmq = require "rocketmq.shared.rocketmq"

local message_ptr_ct = ffi.typeof('CMessage*')
local message_ext_ptr_ct = ffi.typeof('CMessageExt*')

-- Message
local Message = {}

function Message:new(o)
    o = o or {}
    self.__index = self
    if type(o)=="string" then
        o = {topic=o}
    end
    if not o.ctx or not  ffi.istype(message_ptr_ct, o.ctx) then
        local ctx = rocketmq.CreateMessage(o.topic)
        ffi_gc(ctx,rocketmq.DestroyMessage)
        o.ctx = ctx
    end
    setmetatable(o,self)
    if not o.topic then
        o.topic = self.get_topic(o)
    end
    return o,nil
end

function Message.istype(l)
    return l and l.ctx and ffi.istype(message_ptr_ct, l.ctx)
end

function Message:set_keys(keys)
    return rocketmq.SetMessageKeys(self.ctx,keys)
end
function Message:set_tags(tags)
    return rocketmq.SetMessageTags(self.ctx,tags)
end

function Message:set_body(body)
    return rocketmq.SetMessageBody(self.ctx,body)
end

function Message:set_property(key, value)
    return rocketmq.SetMessageProperty(self.ctx,key,value)
end

function Message:set_delay_time_level(delay_time_level)
    return rocketmq.SetDelayTimeLevel(self.ctx,delay_time_level)
end

function Message:get_topic()
    return  ffi_str(rocketmq.GetOriginMessageTopic(self.ctx))
end

function Message:get_keys()
    return ffi_str(rocketmq.GetOriginMessageKeys(self.ctx))
end

function Message:get_tags()
    return ffi_str(rocketmq.GetOriginMessageTags(self.ctx))
end

function Message:get_body()
    return ffi_str(rocketmq.GetOriginMessageBody(self.ctx))
end

function Message:get_property(key)
    return ffi_str(rocketmq.GetOriginMessageProperty(self.ctx,key))
end

-- ReceivedMessage
local ReceivedMessage = {}
local recv_msg_mt = {
    __index = function(self, property)
        local method =
            function (self)
                return self:get_property(property)
            end
        -- cache the lazily generated method in our
        -- module table
        ReceivedMessage[property] = method
        return method
    end
}


function ReceivedMessage:new(o)
    o = o or {}
    setmetatable(self,recv_msg_mt)
    self.__index = self
    if ffi.istype(message_ext_ptr_ct, o) then
        o = {ctx = o}
    end
    if not o.ctx or not  ffi.istype(message_ext_ptr_ct, o.ctx) then
        return nil,"Not a valid ReceivedMessage"
    end
    setmetatable(o,self)
    return o,nil
end

function ReceivedMessage.istype(l)
    return l and l.ctx and ffi.istype(message_ext_ptr_ct, l.ctx)
end

function ReceivedMessage:topic()
    return  ffi_str(rocketmq.GetMessageTopic(self.ctx))
end

function ReceivedMessage:keys()
    return ffi_str(rocketmq.GetMessageKeys(self.ctx))
end

function ReceivedMessage:tags()
    return ffi_str(rocketmq.GetMessageTags(self.ctx))
end

function ReceivedMessage:body()
    return ffi_str(rocketmq.GetMessageBody(self.ctx))
end

function ReceivedMessage:id()
    return ffi_str(rocketmq.GetMessageId(self.ctx))
end

function ReceivedMessage:delay_time_level()
    return rocketmq.GetMessageDelayTimeLevel(self.ctx)
end
function ReceivedMessage:queue_id()
    return rocketmq.GetMessageQueueId(self.ctx)
end
function ReceivedMessage:reconsume_times()
    return rocketmq.GetMessageReconsumeTimes(self.ctx)
end
function ReceivedMessage:store_size()
    return rocketmq.GetMessageStoreSize(self.ctx)
end
function ReceivedMessage:born_timestamp()
    return rocketmq.GetMessageBornTimestamp(self.ctx)
end
function ReceivedMessage:store_timestamp()
    return rocketmq.GetMessageStoreTimestamp(self.ctx)
end
function ReceivedMessage:queue_offset()
    return rocketmq.GetMessageQueueOffset(self.ctx)
end
function ReceivedMessage:commit_log_offset()
    return rocketmq.GetMessageCommitLogOffset(self.ctx)
end
function ReceivedMessage:prepared_transaction_offset()
    return rocketmq.GetMessagePreparedTransactionOffset(self.ctx)
end

function ReceivedMessage:get_property(key)
    return ffi_str(rocketmq.GetMessageProperty(self.ctx,key))
end

return {
    Message=Message,
    ReceivedMessage=ReceivedMessage,
}