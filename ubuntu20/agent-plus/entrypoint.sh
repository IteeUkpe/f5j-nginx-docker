#!/bin/sh

#/usr/sbin/nginx -g 'daemon off;'
nginx
sleep 2

PARM="--server-grpcport $NMS_GRPC_PORT --server-host $NMS_HOST"

if [[ ! -z "$NMS_INSTANCEGROUP" ]]; then
   PARM="${PARM} --instance-group $NMS_INSTANCEGROUP"
fi

if [[ ! -z "$NMS_TAGS" ]]; then
   PARM="${PARM} --tags $NMS_TAGS"
fi

nginx-agent $PARM
