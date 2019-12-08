# reference:
# https://hub.docker.com/r/robshad/handbrake-cli/dockerfile
#
# sudo docker build https://github.com/shepner/Docker-handbrake.git

###########################################################################################
FROM ubuntu:latest

###########################################################################################
# general settings
ENV TERM=xterm
  
###########################################################################################
# user setup
ENV PUSR=docker

ENV \
  HOME="/$PUSR" \
  PUID=1003 \
  PGID=1100

RUN \
  groupadd -r -g $PGID $PUSR \
  && useradd -r -d $HOME -u $PUID -g $PGID -s /bin/bash $PUSR \
  && mkdir -p $HOME \
  && chown -R $PUID:$PGID $HOME

###########################################################################################
# Update base packages
RUN \
  apt-get -q update \
  && apt-get -qy upgrade \
  && apt-get -qy dist-upgrade

###########################################################################################
# general utils
#RUN apt-get install -qy wget

###########################################################################################
# Handbrake

# Install prerequisites
RUN apt-get update -q
RUN \
  apt-get install -qy apt-utils \
                      software-properties-common

# Install Handbrake 
# https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-releases
RUN add-apt-repository ppa:stebbins/handbrake-releases
RUN apt-get update -q
RUN \
  apt-get install -qy handbrake-cli
#                      ffmpeg

VOLUME ["/data"]

ENV CLI_PARAMS = "--help" # the parameters that we want Handbrake to use 

###########################################################################################
# installation cleanup
RUN \
  apt-get -qy autoclean \
  && apt-get -qy autoremove \
  && rm -rf /var/lib/apt/lists/*

###########################################################################################
# startup tasks
#ADD startup.sh $HOME/startup.sh

#RUN \
#  chmod 555 $HOME/startup.sh \
#  && chown -R $PUID:$PGID $HOME

#USER $PUSR:$PGID

#CMD $HOME/startup.sh

USER $PUSR:$PGID

#CMD cd /data; HandBrakeCLI $CLI_PARAMS

ENTRYPOINT ["HandBrakeCLI %s"]
CMD ["--version"]
