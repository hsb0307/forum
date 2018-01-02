﻿using System;
using System.Text;
using ECommon.Components;
using ECommon.Remoting;
using ECommon.Serializing;
using EQueue.Protocols;
using EQueue.Protocols.Brokers;
using EQueue.Protocols.Brokers.Requests;
using EQueue.Protocols.NameServers.Requests;
using EQueue.Utils;

namespace EQueue.NameServer.RequestHandlers
{
    public class CreateTopicForClusterRequestHandler : IRequestHandler
    {
        private NameServerController _nameServerController;
        private IBinarySerializer _binarySerializer;

        public CreateTopicForClusterRequestHandler(NameServerController nameServerController)
        {
            _binarySerializer = ObjectContainer.Resolve<IBinarySerializer>();
            _nameServerController = nameServerController;
        }

        public RemotingResponse HandleRequest(IRequestHandlerContext context, RemotingRequest remotingRequest)
        {
            var request = _binarySerializer.Deserialize<CreateTopicForClusterRequest>(remotingRequest.Body);
            var requestService = new BrokerRequestService(_nameServerController);

            requestService.ExecuteActionToAllClusterBrokers(request.ClusterName, remotingClient =>
            {
                var requestData = _binarySerializer.Serialize(new CreateTopicRequest(request.Topic, request.InitialQueueCount));
                var remotingResponse = remotingClient.InvokeSync(new RemotingRequest((int)BrokerRequestCode.CreateTopic, requestData), 30000);
                if (remotingResponse.ResponseCode != ResponseCode.Success)
                {
                    throw new Exception(string.Format("CreateTopic failed, errorMessage: {0}", Encoding.UTF8.GetString(remotingResponse.ResponseBody)));
                }
            });

            return RemotingResponseFactory.CreateResponse(remotingRequest);
        }
    }
}
