local ffi = require "ffi"
local CLIB = assert(ffi.load("rocketmq"))

ffi.cdef [[
    /* CCommon.h */
    //#define MAX_MESSAGE_ID_LENGTH 256
    //#define MAX_TOPIC_LENGTH 512
    //#define MAX_BROKER_NAME_ID_LENGTH 256
    //#define MAX_SDK_VERSION_LENGTH 256
    //#define DEFAULT_SDK_VERSION "DefaultVersion"

    typedef enum _CStatus_ {
        // Success
        OK = 0,
        /* Failed, null pointer value */
        NULL_POINTER = 1,
        MALLOC_FAILED = 2,
        PRODUCER_ERROR_CODE_START = 10,
        PRODUCER_START_FAILED = 10,
        PRODUCER_SEND_SYNC_FAILED = 11,
        PRODUCER_SEND_ONEWAY_FAILED = 12,
        PRODUCER_SEND_ORDERLY_FAILED = 13,
        PRODUCER_SEND_ASYNC_FAILED = 14,
        PRODUCER_SEND_ORDERLYASYNC_FAILED = 15,
        PRODUCER_SEND_TRANSACTION_FAILED = 16,

        PUSHCONSUMER_ERROR_CODE_START = 20,
        PUSHCONSUMER_START_FAILED = 20,

        PULLCONSUMER_ERROR_CODE_START = 30,
        PULLCONSUMER_START_FAILED = 30,
        PULLCONSUMER_FETCH_MQ_FAILED = 31,
        PULLCONSUMER_FETCH_MESSAGE_FAILED = 32,

        Not_Support = 500,
        NOT_SUPPORT_NOW = -1
    } CStatus;

    typedef enum _CLogLevel_ {
        E_LOG_LEVEL_FATAL = 1,
        E_LOG_LEVEL_ERROR = 2,
        E_LOG_LEVEL_WARN = 3,
        E_LOG_LEVEL_INFO = 4,
        E_LOG_LEVEL_DEBUG = 5,
        E_LOG_LEVEL_TRACE = 6,
        E_LOG_LEVEL_LEVEL_NUM = 7
    } CLogLevel;
    typedef enum _CMessageModel_ {
        BROADCASTING =0,
        CLUSTERING  = 1
    } CMessageModel;
    typedef enum _CTraceModel_ {
        OPEN = 0 ,
        CLOSE = 1
    } CTraceModel;

    /* CMQException.h */
    //#define MAX_EXEPTION_MSG_LENGTH 512
    //#define MAX_EXEPTION_FILE_LENGTH 256
    //#define MAX_EXEPTION_TYPE_LENGTH 128
    typedef struct _CMQException_ {
        int error;
        int line;
        char file[256]; /* MAX_EXEPTION_FILE_LENGTH */
        char msg[512];  /* MAX_EXEPTION_MSG_LENGTH */
        char type[128]; /* MAX_EXEPTION_TYPE_LENGTH */

    } CMQException;

    /* CErrorMessage.h */
    const char* GetLatestErrorMessage();  // Return the last error message

    /* CMessage.h */
    typedef struct CMessage CMessage;
    CMessage* CreateMessage(const char* topic);
    int DestroyMessage(CMessage* msg);
    int SetMessageTopic(CMessage* msg, const char* topic);
    int SetMessageTags(CMessage* msg, const char* tags);
    int SetMessageKeys(CMessage* msg, const char* keys);
    int SetMessageBody(CMessage* msg, const char* body);
    int SetByteMessageBody(CMessage* msg, const char* body, int len);
    int SetMessageProperty(CMessage* msg, const char* key, const char* value);
    int SetDelayTimeLevel(CMessage* msg, int level);
    const char* GetOriginMessageTopic(CMessage* msg);
    const char* GetOriginMessageTags(CMessage* msg);
    const char* GetOriginMessageKeys(CMessage* msg);
    const char* GetOriginMessageBody(CMessage* msg);
    const char* GetOriginMessageProperty(CMessage* msg, const char* key);
    int GetOriginDelayTimeLevel(CMessage* msg);

    /* CBatchMessage.h */
    typedef struct CBatchMessage CBatchMessage;
    CBatchMessage* CreateBatchMessage();
    int AddMessage(CBatchMessage* batchMsg, CMessage* msg);
    int DestroyBatchMessage(CBatchMessage* batchMsg);

    /* CMessageExt.h */
    typedef struct CMessageExt CMessageExt;
    const char* GetMessageTopic(CMessageExt* msgExt);
    const char* GetMessageTags(CMessageExt* msgExt);
    const char* GetMessageKeys(CMessageExt* msgExt);
    const char* GetMessageBody(CMessageExt* msgExt);
    const char* GetMessageProperty(CMessageExt* msgExt, const char* key);
    const char* GetMessageId(CMessageExt* msgExt);
    int GetMessageDelayTimeLevel(CMessageExt* msgExt);
    int GetMessageQueueId(CMessageExt* msgExt);
    int GetMessageReconsumeTimes(CMessageExt* msgExt);
    int GetMessageStoreSize(CMessageExt* msgExt);
    long long GetMessageBornTimestamp(CMessageExt* msgExt);
    long long GetMessageStoreTimestamp(CMessageExt* msgExt);
    long long GetMessageQueueOffset(CMessageExt* msgExt);
    long long GetMessageCommitLogOffset(CMessageExt* msgExt);
    long long GetMessagePreparedTransactionOffset(CMessageExt* msgExt);

    /* CMessageQueue.h */
    typedef struct _CMessageQueue_ {
        char topic[512]; /* MAX_TOPIC_LENGTH */
        char brokerName[256]; /* MAX_BROKER_NAME_ID_LENGTH */
        int queueId;
    } CMessageQueue;

    /* CSendResult.h */
    typedef enum E_CSendStatus_ {
        E_SEND_OK = 0,
        E_SEND_FLUSH_DISK_TIMEOUT = 1,
        E_SEND_FLUSH_SLAVE_TIMEOUT = 2,
        E_SEND_SLAVE_NOT_AVAILABLE = 3
    } CSendStatus;

    typedef struct _SendResult_ {
        CSendStatus sendStatus;
        char msgId[256]; /* MAX_MESSAGE_ID_LENGTH */
        long long offset;
    } CSendResult;

    /* CTransactionStatus.h */
    typedef enum E_CTransactionStatus {
        E_COMMIT_TRANSACTION = 0,
        E_ROLLBACK_TRANSACTION = 1,
        E_UNKNOWN_TRANSACTION = 2,
    } CTransactionStatus;

    /* CProducer.h */
    typedef struct CProducer CProducer;
    typedef int (*QueueSelectorCallback)(int size, CMessage* msg, void* arg);
    typedef void (*CSendSuccessCallback)(CSendResult result);
    typedef void (*CSendExceptionCallback)(CMQException e);
    typedef void (*COnSendSuccessCallback)(CSendResult result, CMessage* msg, void* userData);
    typedef void (*COnSendExceptionCallback)(CMQException e, CMessage* msg, void* userData);
    typedef CTransactionStatus (*CLocalTransactionCheckerCallback)(CProducer* producer, CMessageExt* msg, void* data);
    typedef CTransactionStatus (*CLocalTransactionExecutorCallback)(CProducer* producer, CMessage* msg, void* data);

    CProducer* CreateProducer(const char* groupId);
    CProducer* CreateOrderlyProducer(const char* groupId);
    CProducer* CreateTransactionProducer(const char* groupId,
                                        CLocalTransactionCheckerCallback callback,
                                        void* userData);
    int DestroyProducer(CProducer* producer);
    int StartProducer(CProducer* producer);
    int ShutdownProducer(CProducer* producer);
    const char* ShowProducerVersion(CProducer* producer);

    int SetProducerNameServerAddress(CProducer* producer, const char* namesrv);
    int SetProducerNameServerDomain(CProducer* producer, const char* domain);
    int SetProducerGroupName(CProducer* producer, const char* groupName);
    int SetProducerInstanceName(CProducer* producer, const char* instanceName);
    int SetProducerSessionCredentials(CProducer* producer,
                                      const char* accessKey,
                                      const char* secretKey,
                                      const char* onsChannel);
    int SetProducerLogPath(CProducer* producer, const char* logPath);
    int SetProducerLogFileNumAndSize(CProducer* producer, int fileNum, long fileSize);
    int SetProducerLogLevel(CProducer* producer, CLogLevel level);
    int SetProducerSendMsgTimeout(CProducer* producer, int timeout);
    int SetProducerCompressLevel(CProducer* producer, int level);
    int SetProducerMaxMessageSize(CProducer* producer, int size);
    int SetProducerMessageTrace(CProducer* consumer, CTraceModel openTrace);

    int SendMessageSync(CProducer* producer, CMessage* msg, CSendResult* result);
    int SendBatchMessage(CProducer* producer, CBatchMessage* msg, CSendResult* result);
    int SendMessageAsync(CProducer* producer,
                         CMessage* msg,
                         CSendSuccessCallback cSendSuccessCallback,
                         CSendExceptionCallback cSendExceptionCallback);
    int SendAsync(CProducer* producer,
                  CMessage* msg,
                  COnSendSuccessCallback cSendSuccessCallback,
                  COnSendExceptionCallback cSendExceptionCallback,
                  void* userData);
    int SendMessageOneway(CProducer* producer, CMessage* msg);
    int SendMessageOnewayOrderly(CProducer* producer,
                                 CMessage* msg,
                                 QueueSelectorCallback selector,
                                 void* arg);
    int SendMessageOrderly(CProducer* producer,
                           CMessage* msg,
                           QueueSelectorCallback callback,
                           void* arg,
                           int autoRetryTimes,
                           CSendResult* result);

    int SendMessageOrderlyAsync(CProducer* producer,
                                CMessage* msg,
                                QueueSelectorCallback callback,
                                void* arg,
                                CSendSuccessCallback cSendSuccessCallback,
                                CSendExceptionCallback cSendExceptionCallback);
    int SendMessageOrderlyByShardingKey(CProducer* producer,
                                        CMessage* msg,
                                        const char* shardingKey,
                                        CSendResult* result);
    int SendMessageTransaction(CProducer* producer,
                               CMessage* msg,
                               CLocalTransactionExecutorCallback callback,
                               void* userData,
                               CSendResult* result);
    /* CPullResult.h */

    typedef enum E_CPullStatus {
        E_FOUND,
        E_NO_NEW_MSG,
        E_NO_MATCHED_MSG,
        E_OFFSET_ILLEGAL,
        E_BROKER_TIMEOUT  // indicate pull request timeout or received NULL response
    } CPullStatus;

    typedef struct _CPullResult_ {
        CPullStatus pullStatus;
        long long nextBeginOffset;
        long long minOffset;
        long long maxOffset;
        CMessageExt** msgFoundList;
        int size;
        void* pData;
    } CPullResult;

    /* CPullConsumer.h */
    typedef struct CPullConsumer CPullConsumer;

    CPullConsumer* CreatePullConsumer(const char* groupId);
    int DestroyPullConsumer(CPullConsumer* consumer);
    int StartPullConsumer(CPullConsumer* consumer);
    int ShutdownPullConsumer(CPullConsumer* consumer);
    const char* ShowPullConsumerVersion(CPullConsumer* consumer);

    int SetPullConsumerGroupID(CPullConsumer* consumer, const char* groupId);
    const char* GetPullConsumerGroupID(CPullConsumer* consumer);
    int SetPullConsumerNameServerAddress(CPullConsumer* consumer, const char* namesrv);
    int SetPullConsumerNameServerDomain(CPullConsumer* consumer, const char* domain);
    int SetPullConsumerSessionCredentials(CPullConsumer* consumer,
                                          const char* accessKey,
                                          const char* secretKey,
                                          const char* channel);
    int SetPullConsumerLogPath(CPullConsumer* consumer, const char* logPath);
    int SetPullConsumerLogFileNumAndSize(CPullConsumer* consumer, int fileNum, long fileSize);
    int SetPullConsumerLogLevel(CPullConsumer* consumer, CLogLevel level);

    int FetchSubscriptionMessageQueues(CPullConsumer* consumer,
                                       const char* topic,
                                       CMessageQueue** mqs,
                                       int* size);
    int ReleaseSubscriptionMessageQueue(CMessageQueue* mqs);

    CPullResult Pull(CPullConsumer* consumer,
                    const CMessageQueue* mq,
                    const char* subExpression,
                    long long offset, int maxNums);
    int ReleasePullResult(CPullResult pullResult);

    /* CPushConsumer.h */
    typedef struct CPushConsumer CPushConsumer;

    typedef enum E_CConsumeStatus { E_CONSUME_SUCCESS = 0, E_RECONSUME_LATER = 1 } CConsumeStatus;

    typedef int (*MessageCallBack)(CPushConsumer*, CMessageExt*);

    CPushConsumer* CreatePushConsumer(const char* groupId);
    int DestroyPushConsumer(CPushConsumer* consumer);
    int StartPushConsumer(CPushConsumer* consumer);
    int ShutdownPushConsumer(CPushConsumer* consumer);
    const char* ShowPushConsumerVersion(CPushConsumer* consumer);
    int SetPushConsumerGroupID(CPushConsumer* consumer, const char* groupId);
    const char* GetPushConsumerGroupID(CPushConsumer* consumer);
    int SetPushConsumerNameServerAddress(CPushConsumer* consumer, const char* namesrv);
    int SetPushConsumerNameServerDomain(CPushConsumer* consumer, const char* domain);
    int Subscribe(CPushConsumer* consumer, const char* topic, const char* expression);
    int RegisterMessageCallbackOrderly(CPushConsumer* consumer, MessageCallBack pCallback);
    int RegisterMessageCallback(CPushConsumer* consumer, MessageCallBack pCallback);
    int UnregisterMessageCallbackOrderly(CPushConsumer* consumer);
    int UnregisterMessageCallback(CPushConsumer* consumer);
    int SetPushConsumerThreadCount(CPushConsumer* consumer, int threadCount);
    int SetPushConsumerMessageBatchMaxSize(CPushConsumer* consumer, int batchSize);
    int SetPushConsumerInstanceName(CPushConsumer* consumer, const char* instanceName);
    int SetPushConsumerSessionCredentials(CPushConsumer* consumer,
                                          const char* accessKey,
                                          const char* secretKey,
                                          const char* channel);
    int SetPushConsumerLogPath(CPushConsumer* consumer, const char* logPath);
    int SetPushConsumerLogFileNumAndSize(CPushConsumer* consumer, int fileNum, long fileSize);
    int SetPushConsumerLogLevel(CPushConsumer* consumer, CLogLevel level);
    int SetPushConsumerMessageModel(CPushConsumer* consumer, CMessageModel messageModel);
    int SetPushConsumerMaxCacheMessageSize(CPushConsumer* consumer, int maxCacheSize);
    int SetPushConsumerMaxCacheMessageSizeInMb(CPushConsumer* consumer, int maxCacheSizeInMb);
    int SetPushConsumerMessageTrace(CPushConsumer* consumer, CTraceModel openTrace);

]]

local library = {
    GetLatestErrorMessage = CLIB.GetLatestErrorMessage,
    CreateMessage = CLIB.CreateMessage,
    DestroyMessage = CLIB.DestroyMessage,
    SetMessageTopic = CLIB.SetMessageTopic,
    SetMessageTags = CLIB.SetMessageTags,
    SetMessageKeys = CLIB.SetMessageKeys,
    SetMessageBody = CLIB.SetMessageBody,
    SetByteMessageBody = CLIB.SetByteMessageBody,
    SetMessageProperty = CLIB.SetMessageProperty,
    SetDelayTimeLevel = CLIB.SetDelayTimeLevel,
    GetOriginMessageTopic = CLIB.GetOriginMessageTopic,
    GetOriginMessageTags = CLIB.GetOriginMessageTags,
    GetOriginMessageKeys = CLIB.GetOriginMessageKeys,
    GetOriginMessageBody = CLIB.GetOriginMessageBody,
    GetOriginMessageProperty = CLIB.GetOriginMessageProperty,
    GetOriginDelayTimeLevel = CLIB.GetOriginDelayTimeLevel,
    CreateBatchMessage = CLIB.CreateBatchMessage,
    AddMessage = CLIB.AddMessage,
    DestroyBatchMessage = CLIB.DestroyBatchMessage,
    GetMessageTopic = CLIB.GetMessageTopic,
    GetMessageTags = CLIB.GetMessageTags,
    GetMessageKeys = CLIB.GetMessageKeys,
    GetMessageBody = CLIB.GetMessageBody,
    GetMessageProperty = CLIB.GetMessageProperty,
    GetMessageId = CLIB.GetMessageId,
    GetMessageDelayTimeLevel = CLIB.GetMessageDelayTimeLevel,
    GetMessageQueueId = CLIB.GetMessageQueueId,
    GetMessageReconsumeTimes = CLIB.GetMessageReconsumeTimes,
    GetMessageStoreSize = CLIB.GetMessageStoreSize,
    GetMessageBornTimestamp = CLIB.GetMessageBornTimestamp,
    GetMessageStoreTimestamp = CLIB.GetMessageStoreTimestamp,
    GetMessageQueueOffset = CLIB.GetMessageQueueOffset,
    GetMessageCommitLogOffset = CLIB.GetMessageCommitLogOffset,
    GetMessagePreparedTransactionOffset = CLIB.GetMessagePreparedTransactionOffset,
    CreateProducer = CLIB.CreateProducer,
    CreateOrderlyProducer = CLIB.CreateOrderlyProducer,
    CreateTransactionProducer = CLIB.CreateTransactionProducer,
    DestroyProducer = CLIB.DestroyProducer,
    StartProducer = CLIB.StartProducer,
    ShutdownProducer = CLIB.ShutdownProducer,
    ShowProducerVersion = CLIB.ShowProducerVersion,
    SetProducerNameServerAddress = CLIB.SetProducerNameServerAddress,
    SetProducerNameServerDomain = CLIB.SetProducerNameServerDomain,
    SetProducerGroupName = CLIB.SetProducerGroupName,
    SetProducerInstanceName = CLIB.SetProducerInstanceName,
    SetProducerSessionCredentials = CLIB.SetProducerSessionCredentials,
    SetProducerLogPath = CLIB.SetProducerLogPath,
    SetProducerLogFileNumAndSize = CLIB.SetProducerLogFileNumAndSize,
    SetProducerLogLevel = CLIB.SetProducerLogLevel,
    SetProducerSendMsgTimeout = CLIB.SetProducerSendMsgTimeout,
    SetProducerCompressLevel = CLIB.SetProducerCompressLevel,
    SetProducerMaxMessageSize = CLIB.SetProducerMaxMessageSize,
    SetProducerMessageTrace = CLIB.SetProducerMessageTrace,
    SendMessageSync = CLIB.SendMessageSync,
    SendBatchMessage = CLIB.SendBatchMessage,
    SendMessageAsync = CLIB.SendMessageAsync,
    SendAsync = CLIB.SendAsync,
    SendMessageOneway = CLIB.SendMessageOneway,
    SendMessageOnewayOrderly = CLIB.SendMessageOnewayOrderly,
    SendMessageOrderly = CLIB.SendMessageOrderly,
    SendMessageOrderlyAsync = CLIB.SendMessageOrderlyAsync,
    SendMessageOrderlyByShardingKey = CLIB.SendMessageOrderlyByShardingKey,
    SendMessageTransaction = CLIB.SendMessageTransaction,
    CreatePullConsumer = CLIB.CreatePullConsumer,
    DestroyPullConsumer = CLIB.DestroyPullConsumer,
    StartPullConsumer = CLIB.StartPullConsumer,
    ShutdownPullConsumer = CLIB.ShutdownPullConsumer,
    ShowPullConsumerVersion = CLIB.ShowPullConsumerVersion,
    SetPullConsumerGroupID = CLIB.SetPullConsumerGroupID,
    GetPullConsumerGroupID = CLIB.GetPullConsumerGroupID,
    SetPullConsumerNameServerAddress = CLIB.SetPullConsumerNameServerAddress,
    SetPullConsumerNameServerDomain = CLIB.SetPullConsumerNameServerDomain,
    SetPullConsumerSessionCredentials = CLIB.SetPullConsumerSessionCredentials,
    SetPullConsumerLogPath = CLIB.SetPullConsumerLogPath,
    SetPullConsumerLogFileNumAndSize = CLIB.SetPullConsumerLogFileNumAndSize,
    SetPullConsumerLogLevel = CLIB.SetPullConsumerLogLevel,
    FetchSubscriptionMessageQueues = CLIB.FetchSubscriptionMessageQueues,
    ReleaseSubscriptionMessageQueue = CLIB.ReleaseSubscriptionMessageQueue,
    Pull = CLIB.Pull,
    ReleasePullResult = CLIB.ReleasePullResult,
    CreatePushConsumer = CLIB.CreatePushConsumer,
    DestroyPushConsumer = CLIB.DestroyPushConsumer,
    StartPushConsumer = CLIB.StartPushConsumer,
    ShutdownPushConsumer = CLIB.ShutdownPushConsumer,
    ShowPushConsumerVersion = CLIB.ShowPushConsumerVersion,
    SetPushConsumerGroupID = CLIB.SetPushConsumerGroupID,
    GetPushConsumerGroupID = CLIB.GetPushConsumerGroupID,
    SetPushConsumerNameServerAddress = CLIB.SetPushConsumerNameServerAddress,
    SetPushConsumerNameServerDomain = CLIB.SetPushConsumerNameServerDomain,
    Subscribe = CLIB.Subscribe,
    RegisterMessageCallbackOrderly = CLIB.RegisterMessageCallbackOrderly,
    RegisterMessageCallback = CLIB.RegisterMessageCallback,
    UnregisterMessageCallbackOrderly = CLIB.UnregisterMessageCallbackOrderly,
    UnregisterMessageCallback = CLIB.UnregisterMessageCallback,
    SetPushConsumerThreadCount = CLIB.SetPushConsumerThreadCount,
    SetPushConsumerMessageBatchMaxSize = CLIB.SetPushConsumerMessageBatchMaxSize,
    SetPushConsumerInstanceName = CLIB.SetPushConsumerInstanceName,
    SetPushConsumerSessionCredentials = CLIB.SetPushConsumerSessionCredentials,
    SetPushConsumerLogPath = CLIB.SetPushConsumerLogPath,
    SetPushConsumerLogFileNumAndSize = CLIB.SetPushConsumerLogFileNumAndSize,
    SetPushConsumerLogLevel = CLIB.SetPushConsumerLogLevel,
    SetPushConsumerMessageModel = CLIB.SetPushConsumerMessageModel,
    SetPushConsumerMaxCacheMessageSize = CLIB.SetPushConsumerMaxCacheMessageSize,
    SetPushConsumerMaxCacheMessageSizeInMb = CLIB.SetPushConsumerMaxCacheMessageSizeInMb,
    SetPushConsumerMessageTrace = CLIB.SetPushConsumerMessageTrace
}
library.enum = {
    Status = {
        OK = ffi.cast("enum _CStatus_", "OK"),
        NULL_POINTER = ffi.cast("enum _CStatus_", "NULL_POINTER"),
        MALLOC_FAILED = ffi.cast("enum _CStatus_", "MALLOC_FAILED"),
        PRODUCER_ERROR_CODE_START = ffi.cast("enum _CStatus_", "PRODUCER_ERROR_CODE_START"),
        PRODUCER_START_FAILED = ffi.cast("enum _CStatus_", "PRODUCER_START_FAILED"),
        PRODUCER_SEND_SYNC_FAILED = ffi.cast("enum _CStatus_", "PRODUCER_SEND_SYNC_FAILED"),
        PRODUCER_SEND_ONEWAY_FAILED = ffi.cast("enum _CStatus_", "PRODUCER_SEND_ONEWAY_FAILED"),
        PRODUCER_SEND_ORDERLY_FAILED = ffi.cast("enum _CStatus_", "PRODUCER_SEND_ORDERLY_FAILED"),
        PRODUCER_SEND_ASYNC_FAILED = ffi.cast("enum _CStatus_", "PRODUCER_SEND_ASYNC_FAILED"),
        PRODUCER_SEND_ORDERLYASYNC_FAILED = ffi.cast("enum _CStatus_", "PRODUCER_SEND_ORDERLYASYNC_FAILED"),
        PRODUCER_SEND_TRANSACTION_FAILED = ffi.cast("enum _CStatus_", "PRODUCER_SEND_TRANSACTION_FAILED"),
        PUSHCONSUMER_ERROR_CODE_START = ffi.cast("enum _CStatus_", "PUSHCONSUMER_ERROR_CODE_START"),
        PUSHCONSUMER_START_FAILED = ffi.cast("enum _CStatus_", "PUSHCONSUMER_START_FAILED"),
        PULLCONSUMER_ERROR_CODE_START = ffi.cast("enum _CStatus_", "PULLCONSUMER_ERROR_CODE_START"),
        PULLCONSUMER_START_FAILED = ffi.cast("enum _CStatus_", "PULLCONSUMER_START_FAILED"),
        PULLCONSUMER_FETCH_MQ_FAILED = ffi.cast("enum _CStatus_", "PULLCONSUMER_FETCH_MQ_FAILED"),
        PULLCONSUMER_FETCH_MESSAGE_FAILED = ffi.cast("enum _CStatus_", "PULLCONSUMER_FETCH_MESSAGE_FAILED"),
        Not_Support = ffi.cast("enum _CStatus_", "Not_Support"),
        NOT_SUPPORT_NOW = ffi.cast("enum _CStatus_", "NOT_SUPPORT_NOW"),
    },
    LogLevel = {
        FATAL = ffi.cast("enum _CLogLevel_", "E_LOG_LEVEL_FATAL"),
        ERROR = ffi.cast("enum _CLogLevel_", "E_LOG_LEVEL_ERROR"),
        WARN = ffi.cast("enum _CLogLevel_", "E_LOG_LEVEL_WARN"),
        INFO = ffi.cast("enum _CLogLevel_", "E_LOG_LEVEL_INFO"),
        DEBUG = ffi.cast("enum _CLogLevel_", "E_LOG_LEVEL_DEBUG"),
        TRACE = ffi.cast("enum _CLogLevel_", "E_LOG_LEVEL_TRACE"),
        LEVEL_NUM = ffi.cast("enum _CLogLevel_", "E_LOG_LEVEL_LEVEL_NUM"),
    },
    MessageModel = {
        BROADCASTING = ffi.cast("enum _CMessageModel_", "BROADCASTING"),
        CLUSTERING = ffi.cast("enum _CMessageModel_", "CLUSTERING"),
    },
    TraceModel = {
        OPEN = ffi.cast("enum _CTraceModel_", "OPEN"),
        CLOSE = ffi.cast("enum _CTraceModel_", "CLOSE"),
    },
    SendStatus = {
        OK = ffi.cast("enum E_CSendStatus_", "E_SEND_OK"),
        FLUSH_DISK_TIMEOUT = ffi.cast("enum E_CSendStatus_", "E_SEND_FLUSH_DISK_TIMEOUT"),
        FLUSH_SLAVE_TIMEOUT = ffi.cast("enum E_CSendStatus_", "E_SEND_FLUSH_SLAVE_TIMEOUT"),
        SLAVE_NOT_AVAILABLE = ffi.cast("enum E_CSendStatus_", "E_SEND_SLAVE_NOT_AVAILABLE"),
    },

    TransactionStatus = {
        COMMIT = ffi.cast("enum E_CTransactionStatus", "E_COMMIT_TRANSACTION"),
        ROLLBACK = ffi.cast("enum E_CTransactionStatus", "E_ROLLBACK_TRANSACTION"),
        UNKNOWN = ffi.cast("enum E_CTransactionStatus", "E_UNKNOWN_TRANSACTION"),
    },
    PullStatus = {
        FOUND = ffi.cast("enum E_CPullStatus", "E_FOUND"),
        NO_NEW_MSG = ffi.cast("enum E_CPullStatus", "E_NO_NEW_MSG"),
        NO_MATCHED_MSG = ffi.cast("enum E_CPullStatus", "E_NO_MATCHED_MSG"),
        OFFSET_ILLEGAL = ffi.cast("enum E_CPullStatus", "E_OFFSET_ILLEGAL"),
        BROKER_TIMEOUT = ffi.cast("enum E_CPullStatus", "E_BROKER_TIMEOUT"),
    },
    ConsumeStatus = {
        CONSUME_SUCCESS = ffi.cast("enum E_CConsumeStatus", "E_CONSUME_SUCCESS"),
        RECONSUME_LATER = ffi.cast("enum E_CConsumeStatus", "E_RECONSUME_LATER")
    },
    MessageProperty = {
        TRACE_SWITCH = "TRACE_ON",
        MSG_REGION = "MSG_REGION",
        KEYS = "KEYS",
        TAGS = "TAGS",
        WAIT_STORE_MSG_OK = "WAIT",
        DELAY_TIME_LEVEL = "DELAY",
        RETRY_TOPIC = "RETRY_TOPIC",
        REAL_TOPIC = "REAL_TOPIC",
        REAL_QUEUE_ID = "REAL_QID",
        TRANSACTION_PREPARED = "TRAN_MSG",
        PRODUCER_GROUP = "PGROUP",
        MIN_OFFSET = "MIN_OFFSET",
        MAX_OFFSET = "MAX_OFFSET",
        BUYER_ID = "BUYER_ID",
        ORIGIN_MESSAGE_ID = "ORIGIN_MESSAGE_ID",
        TRANSFER_FLAG = "TRANSFER_FLAG",
        CORRECTION_FLAG = "CORRECTION_FLAG",
        MQ2_FLAG = "MQ2_FLAG",
        RECONSUME_TIME = "RECONSUME_TIME",
        UNIQ_CLIENT_MESSAGE_ID_KEYIDX = "UNIQ_KEY",
        MAX_RECONSUME_TIMES = "MAX_RECONSUME_TIMES",
        CONSUME_START_TIMESTAMP = "CONSUME_START_TIME",
    }
}
library.clib = CLIB
return library
