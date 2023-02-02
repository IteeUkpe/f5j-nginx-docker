#!/bin/sh

#/usr/sbin/nginx -g 'daemon off;'
nginx
sleep 2

echo "NMS_HOST: $NMS_HOST"
echo "NMS_GRPC_PORT: $NMS_GRPC_PORT"
echo "NMS_INSTANCEGROUP: $NMS_INSTANCEGROUP"
echo "NMS_TAGS: $NMS_TAGS"

PARM="--server-grpcport $NMS_GRPC_PORT --server-host $NMS_HOST"

if ( [ -n "$NMS_INSTANCEGROUP" ] && [ -n "$NMS_TAGS" ] ); then
   PARM="${PARM} --instance-group $NMS_INSTANCEGROUP --tags $NMS_TAGS"
fi

if ( [ -n "$NMS_INSTANCEGROUP" ] && [ -z "$NMS_TAGS" ] ); then
   PARM="${PARM} --instance-group $NMS_INSTANCEGROUP"
fi

if ( [ -z "$NMS_INSTANCEGROUP" ] && [ -n "$NMS_TAGS" ] ); then
   PARM="${PARM} --tags $NMS_TAGS"
fi

# RUN NGINX agent
if ( [ -n "$NMS_GRPC_PORT" ] && [ -n "$NMS_HOST" ] ); then
   nginx-agent $PARM
fi

