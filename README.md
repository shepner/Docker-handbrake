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
    --aencoder copy,copy,copy,copy,copy,copy,copy,copy,copy \
    --audio-copy-mask aac,ac3,eac3,truehd,dts,dtshd,mp3,flac \
    --subtitle 1,2,3,4,5,6,7,8,9 \
    --native-language eng \
    --native-dub \
  2> "$DIRECTORY/$DST.log" 1> "/dev/null"
  
mv "$DIRECTORY/`echo "$SRC" | awk -F '/' '{ print $1 "/" $2 }'`" "$DIRECTORY/$COMPLETE"

rm "$SCRIPT"
EOM

  #ssh docker@${DOCKERHOST[$INDEX]} bash $SCRIPT &
  ssh docker@${DOCKERHOST[$INDEX]} screen -d -m bash $SCRIPT

  if [ $INDEX -lt `expr ${#DOCKERHOST[@]} - 1` ] ; then
    INDEX=`expr $INDEX + 1`
  else
    INDEX=0
  fi
    
  echo ""
done
IFS=$SAVEIFS
```

---

It would be useful to scan for and select the longest title rather then relying on `main-feature` being set correctly.  HandBrakeCLI unfortunately doesnt do this automatically (unlike the GUI) and also doesnt make things easy.

It does have the ability to scan the structure and output JSON data (sorta).  The problem is that it is outputting multiple JSON structures.  Fortunately the Title Set section is last so you can delete everything prior to that. (yes this could have been written better):

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

The results at this point is an array of each title.  I think the length of the title is in `"Duration": { "Ticks": <number> }` but didnt spend the time digging into it.  The default output seems easier to deal with:

``` shell
IFS=$'\n'
  
docker run \
  --mount type=bind,src=/mnt/nas/media/Videos,dst=/data \
  --cpus="3" \
  shepner/handbrake \
    --input <directory> \
    --title 0 2> test.txt
    
cat test.txt \
| grep "scan: scanning title" -A 2 \
| sed -e '/scanning title/{n;d;n;}' \
| sed -e 's/^.*title //' \
| sed -e 's/^.*(//; s/)//'
```

(again, that could be written better)

Here are the results which are becoming a bit more manageable:

```
34
87133 ms
--
35
66600 ms
```

...or stop screwing around and just write a Perl script to deal with all of this and then kick off the resulting job(s)
