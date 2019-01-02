# reference:
# https://hub.docker.com/r/robshad/handbrake-cli/dockerfile

FROM ubuntu:18.04

LABEL \
  org.asyla.release-date="2019-01-01" \
  org.asyla.maintainer="shepner@asyla.org" \
  org.asyla.description="Handbrake CLI"

RUN \
  add-apt-repository ppa:stebbins/handbrake-snapshots && \
  add-apt-repository ppa:kirillshkrogalev/ffmpeg-next

RUN \
  apt-get update -q && \
  apt-get install -qy handbrake-cli && \
  apt-get clean




