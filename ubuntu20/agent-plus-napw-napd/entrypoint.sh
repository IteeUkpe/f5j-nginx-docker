#!/usr/bin/env bash
   
## NAP WAF
# run processes
/bin/su -s /bin/sh -c "/usr/share/ts/bin/bd-socket-plugin tmm_count 4 proc_cpuinfo_cpu_mhz 2000000 total_xml_memory 307200000 total_umu_max_size 3129344 sys_max_account_id 1024 no_static_config 2>&1 >> /var/log/app_protect/bd-socket-plugin.log &" nginx

## NAP DoS
USER=nginx
LOGDIR=/var/log/adm

# prepare environment
mkdir -p /var/run/adm /tmp/cores ${LOGDIR}
chmod 755 /var/run/adm /tmp/cores ${LOGDIR}
chown ${USER}:${USER} /var/run/adm /tmp/cores ${LOGDIR}
   
# run processes
/bin/su -s /bin/bash -c "/usr/bin/adminstall --daemons 1 --memory 200 > ${LOGDIR}/adminstall.log 2>&1" ${USER}
/bin/su -s /bin/bash -c "/usr/bin/admd -d --log info > ${LOGDIR}/admd.log 2>&1 &" ${USER}

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



