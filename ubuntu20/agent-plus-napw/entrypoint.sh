#!/bin/sh

/bin/su -s /bin/sh -c "/usr/share/ts/bin/bd-socket-plugin tmm_count 4 proc_cpuinfo_cpu_mhz 2000000 total_xml_memory 307200000 total_umu_max_size 3129344 sys_max_account_id 1024 no_static_config 2>&1 >> /var/log/app_protect/bd-socket-plugin.log &" nginx
#/usr/sbin/nginx -g 'daemon off;'
nginx
sleep 2

echo "NMS_HOST: $NMS_HOST"
echo "NMS_GRPC_PORT: $NMS_GRPC_PORT"
echo "NMS_INSTANCEGROUP: $NMS_INSTANCEGROUP"
echo "NMS_TAGS: $NMS_TAGS"

# Enable NGINX App Protect WAF Status Reporting
echo -e "
nginx_app_protect:
  # Report interval for NGINX App Protect details - the frequency the NGINX Agent checks NGINX App Protect for changes.
  report_interval: 15s
# NGINX App Protect Monitoring config
nap_monitoring:
  # Buffer size for collector. Will contain log lines and parsed log lines
  collector_buffer_size: 50000
  # Buffer size for processor. Will contain log lines and parsed log lines
  processor_buffer_size: 50000
  # Syslog server IP address the collector will be listening to
  syslog_ip: "127.0.0.1"
  # Syslog server port the collector will be listening to
  syslog_port: 514
  #We set to 10 so that event logs push out to NMS faster for demonstration
  report_count: 10
  
" >> /etc/nginx-agent/nginx-agent.conf

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


