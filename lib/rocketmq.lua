
local _M = {
    _VERSION = '2.1.0.1',
    Message=require("rocketmq.message").Message,
    ReceivedMessage=require("rocketmq.message").ReceivedMessage,
    Producer= require("rocketmq.producer").Producer,
    TransactionMQProducer = require("rocketmq.producer").TransactionMQProducer,
    PushConsumer = require("rocketmq.consumer").PushConsumer,
    PullConsumer = require("rocketmq.consumer").PullConsumer,

    Status = require("rocketmq.shared.rocketmq").enum.Status,
    LogLevel = require("rocketmq.shared.rocketmq").enum.LogLevel,
    MessageModel = require("rocketmq.shared.rocketmq").enum.MessageModel,
    TraceModel = require("rocketmq.shared.rocketmq").enum.TraceModel,
    SendStatus = require("rocketmq.shared.rocketmq").enum.SendStatus,
    TransactionStatus = require("rocketmq.shared.rocketmq").enum.TransactionStatus,
    PullStatus = require("rocketmq.shared.rocketmq").enum.PullStatus,
    ConsumeStatus = require("rocketmq.shared.rocketmq").enum.ConsumeStatus,
    MessageProperty = require("rocketmq.shared.rocketmq").enum.MessageProperty,

    version = "2.1.0.1"
}



return _M