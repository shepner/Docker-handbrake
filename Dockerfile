# reference:
# https://hub.docker.com/r/robshad/handbrake-cli/dockerfile
#
# sudo docker build https://github.com/shepner/Docker-handbrake.git

FROM ubuntu:18.04

LABEL \
  org.asyla.release-date="2019-01-01" \
  org.asyla.maintainer="shepner@asyla.org" \
  org.asyla.description="Handbrake CLI"

RUN apt-get update -q
RUN apt-get install -qy apt-utils
RUN apt-get install -qy perl
RUN apt-get install -qy wget
RUN apt-get install -qy software-properties-common

# https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-releases
RUN add-apt-repository ppa:stebbins/handbrake-releases
# https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-git-snapshots
# RUN add-apt-repository ppa:stebbins/handbrake-git-snapshots

#RUN add-apt-repository ppa:kirillshkrogalev/ffmpeg-next

RUN apt-get update -q
RUN apt-get install -qy handbrake-cli
RUN apt-get install -qy ffmpeg

RUN apt-get clean




