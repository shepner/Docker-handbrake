# reference:
# https://hub.docker.com/r/robshad/handbrake-cli/dockerfile
#
# sudo docker build https://github.com/shepner/Docker-handbrake.git

###########################################################################################
#FROM ubuntu:latest
FROM ubuntu:19.04

###########################################################################################
# general settings
ENV TERM=xterm
  
###########################################################################################
# user setup
ENV PUSR=docker

ENV HOME="/$PUSR"

# set the default values we will use
ARG ARG_PUID=1003
ARG ARG_PGID=1000

# These now can be changed from `docker run -e [...]`
ENV \ 
  PUID=$ARG_PUID \
  PGID=$ARG_PGID

RUN \
  groupadd -r -g $PGID $PUSR \
  && useradd -r -d $HOME -u $PUID -g $PGID -s /bin/bash $PUSR \
  && mkdir -p $HOME \
  && chown -R $PUID:$PGID $HOME

###########################################################################################
# Handbrake

# Install prerequisites
RUN \
  apt-get update -q \
  && apt-get install -qy apt-utils \
                      software-properties-common

# Install Handbrake 
# https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-releases
RUN \
  add-apt-repository ppa:stebbins/handbrake-releases \
  && apt-get update -q \
  && apt-get install -qy handbrake-cli

VOLUME ["/data"]

###########################################################################################
# installation cleanup
RUN \
  apt-get -qy autoclean \
  && apt-get -qy autoremove \
  && rm -rf /var/lib/apt/lists/*

###########################################################################################
# startup tasks
USER $PUSR:$PGID

WORKDIR /data
ENTRYPOINT ["HandBrakeCLI", "%s"] # pass all commandline params to `docker run <container>` to this
