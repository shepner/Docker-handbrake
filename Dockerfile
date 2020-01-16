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
# Update base packages
#RUN \
#  apt-get -q update \
#  && apt-get -qy upgrade \
#  && apt-get -qy dist-upgrade

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

# Install [Flatpack](https://flatpak.org/setup/Ubuntu/)
# [Install Handbrake](https://handbrake.fr/docs/en/1.2.0/get-handbrake/download-and-install.html)
RUN \
  sudo add-apt-repository ppa:alexlarsson/flatpak \
  && apt-get update -q \
  && apt-get install -qy flatpak \
  && flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
  && flatpak --user install https://flathub.org/repo/appstream/fr.handbrake.ghb.flatpakref

# Install Handbrake 
# https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-releases
#RUN add-apt-repository ppa:stebbins/handbrake-releases
#RUN apt-get update -q
#RUN apt-get install -qy handbrake-cli

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
CMD ["--help"] # use these params by default
