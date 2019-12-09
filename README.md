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
  --input "$SRC" \
  #--title 3 \
  --main-feature \
  --output "$DST" \
  --markers \
  --quality 20.0 \
  --vfr \
  --audio-lang-list und \
  --all-audio \
  --subtitle 1,2,3,4,5,6,7,8,9 \
  --native-language eng \
  --native-dub
```


Scripted example

``` shell
DIRECTORY="/root/dir"
INCOMING="sub/dir"
OUTGOING="other/dir"
COMPLETE="anotherdir"

#all the Docker engines to run this on
DOCKERHOST[0]="de01"
DOCKERHOST[1]="de02"
DOCKERHOST[2]="de03"
DOCKERHOST[3]="de04"

#only list the subdirs we care about and strip off the stuff we dont want
SRCLIST=`find $DIRECTORY/$INCOMING -maxdepth 2 -mindepth 2 -type d -print | sed "s|$DIRECTORY||" | sed "s|^/*||"`


SAVEIFS=$IFS
IFS=$'\n'
INDEX=0
for SRC in $SRCLIST; do
  DST=$OUTGOING/`echo $SRC | awk -F '/' '{ print $2 ".mkv" }'`
  echo "SRC=$SRC"
  echo "DST=$DST"
  
  ssh docker@$DOCKERHOST[$INDEX] \
    docker run \
      --mount type=bind,src=$DIRECTORY,dst=/data \
      shepner/handbrake \
        --preset "H.265 MKV 720p30" \
        --input "$SRC" \
        --main-feature \
        --output "$DST" \
        --markers \
        --quality 20.0 \
        --vfr \
        --audio-lang-list und \
        --all-audio \
        --subtitle 1,2,3,4,5,6,7,8,9 \
        --native-language eng \
        --native-dub \
      >> "/dev/null" 2>&1 \
      && mv echo "$SRC" | awk -F '/' '{ print $1 "/" $2 }' "$COMPLETE" &
      
  if [ $INDEX == ${#DOCKERHOST[@]} ] ; then
    INDEX=0
  else
    INDEX=`expr $INDEX +1`
    
  echo ""
done
IFS=$SAVEIFS
```
