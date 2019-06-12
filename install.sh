#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home
apt-get -q update
apt-get install -qy gdebi-core supervisor

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
#config
cat <<'EOT' > /etc/my_init.d/config.sh
#!/bin/bash
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  DEBIAN_FRONTEND="noninteractive" dpkg-reconfigure -f noninteractive tzdata
fi
EOT

cat <<'EOT' > /supervisord.conf
[supervisord]
nodaemon=false

[program:hdhomerun_dvr]
priority=30
directory=/opt/hdhomerun/
command=/opt/hdhomerun/hdhomerun_record_x64 foreground
user=root
autostart=true
autorestart=true
stopsignal=QUIT
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[unix_http_server]
file=%(here)s/supervisor.sock

[supervisorctl]
serverurl=unix://%(here)s/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
EOT

cat <<'EOT' > /etc/hdhomerun.conf
RecordPath=/hdhomerun
Port=65002
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

#########################################
##             INSTALLATION            ##
#########################################
chmod +x /opt/hdhomerun/hdhomerun_record_x64
chmod 666 /etc/hdhomerun.conf

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y