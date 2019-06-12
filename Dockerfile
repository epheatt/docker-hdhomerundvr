FROM phusion/baseimage:0.11
MAINTAINER epheatt <eric.pheatt@gmail.com>
#Based on the work of Yoshiofthewire <Yoshi@urlxl.com>
#Based on the work of gfjardim <gfjardim@gmail.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN mkdir -p /opt/hdhomerun && \
	curl http://download.silicondust.com/hdhomerun/hdhomerun_record_linux_20190417 -o /opt/hdhomerun/hdhomerun_record_x64 

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

ADD install.sh /
RUN bash /install.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME /hdhomerun
EXPOSE 65001/udp 65002

CMD ["-n", "-c", "/supervisord.conf"]
ENTRYPOINT ["/usr/bin/supervisord"]