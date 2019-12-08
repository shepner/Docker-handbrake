# Docker-handbrake

This is intended to be a Docker based replacement of the HandBrakeCLI.  This means it depends on external scripts for any automations and is not intended to be a continuous running service.  Run it from scripts.  This gives the advantage of not consuming resources when it isnt in use and also permits running N copies if you desire.


This is how to build:

``` shell
docker build https://github.com/shepner/Docker-handbrake.git
```


Prove it works

``` shell
docker run <container> --version
```


This is an example how to run:

``` shell
DIRECTORY="/root/dir"
SRC="dir1/source dir name (year)/sub dir"
DST="dir2/dest file name (year).mkv"

docker run \
  --mount type=bind,src=$DIRECTORY,dst=/data \
  <container> \
  --preset "H.265 MKV 720p30" \
  --main-feature \
  -f av_mkv \
  -m \
  -e x265 \
  -q 20 \
  --vfr \
  --audio-lang-list und \
  --all-audio \
  --subtitle-lang-list und \
  --all-subtitles \
  --subtitle-burned none \
  --subtitle-default none \
  --native-language eng \
  -i $SRC \
  -o $DST
```


Scripted example

``` shell
DIRECTORY="/root/dir"
INCOMING="sub/dir"
SRCLIST=`find $DIRECTORY/$INCOMING -maxdepth 2 -type d`

SAVEIFS=$IFS
IFS=$'\n' #ignore whitespace
for SRCNAME in $SRCLIST; do
  NAME=`echo $DIRECTORY | awk -F'\/' '{ print $5 }'`
  DST=/some/other/dir/$NAME.mkv

  docker run [...]

done
IFS=$SAVEIFS
```
