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
DOCKERHOST[4]="de05"
DOCKERHOST[5]="de06"

#only list the subdirs we care about and strip off the stuff we dont want
SRCLIST=`find $DIRECTORY/$INCOMING -maxdepth 2 -mindepth 2 -type d -print | sed "s|$DIRECTORY||" | sed "s|^/*||"`


SAVEIFS=$IFS
IFS=$'\n'
INDEX=0
for SRC in $SRCLIST; do
  DST=$OUTGOING/`echo $SRC | awk -F '/' '{ print $2 ".mkv" }'`
  SCRIPT=/tmp/`date +"%Y%m%d%H%M%S"`.sh
  
  echo "SRC=$SRC"
  echo "DST=$DST"
  echo "DOCKERHOST=${DOCKERHOST[$INDEX]}"
  echo "SCRIPT=$SCRIPT"
  
  ssh docker@${DOCKERHOST[$INDEX]} "cat >$SCRIPT" <<EOM
IFS=$'\n'

docker run \
  --mount type=bind,src=$DIRECTORY,dst=/data \
  --cpus="3" \
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
  2> "$DIRECTORY/$DST.log" 1> "/dev/null"
  
#mv `echo "$SRC" | awk -F '/' '{ print $1 "/" $2 }'` "$COMPLETE"

rm "$SCRIPT"
EOM

  ssh docker@${DOCKERHOST[$INDEX]} bash $SCRIPT &

  if [ $INDEX -lt `expr ${#DOCKERHOST[@]} - 1` ] ; then
    INDEX=`expr $INDEX + 1`
  else
    INDEX=0
  fi
    
  echo ""
done
IFS=$SAVEIFS
```


This scans the structure and outputs JSON data (sorta)

``` shell
IFS=$'\n'
  
docker run \
  --mount type=bind,src=/mnt/nas/media/Videos,dst=/data \
  --cpus="3" \
  shepner/handbrake \
    --json \
    --input <directory>
    --title 0 > test.txt

awk '/JSON Title Set/{i++}i' test.txt \
  | sed "s/JSON Title Set: //" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['TitleList'])"
```

The results at this point is an array of each title.  I think the length of the title is in `"Duration": { "Ticks": <number> }`
