#!/bin/sh

HB="/usr/local/bin/HandBrakeCLI"
RIPS="/incoming"
SORT="/output"
DONE="/storage"

SRCLIST=`find $RIPS -type d -d 2`

SAVEIFS=$IFS
IFS=$'\n' #ignore whitespace
for SRC in $SRCLIST; do
  NAME=`echo $SRC | awk -F'\/' '{ print $5 }'`
  DST=$SORT/$NAME.mkv

  #some baseline settings
  #https://trac.handbrake.fr/wiki/BuiltInPresets
  #https://trac.handbrake.fr/wiki/ConstantQuality
  #http://mattgadient.com/2013/06/20/comparing-x264-rf-settings-in-handbrake-examples/
  #http://mattgadient.com/2013/06/12/a-best-settings-guide-for-handbrake-0-9-9/
  LEVEL=auto #https://forum.handbrake.fr/viewtopic.php?f=6&t=19368
  PRESET=slower
  #TUNE="--x264-tune film"
  TUNE=""

  #adjust settings based on SD or HD source
  DIRSIZE=`du -d0 $SRC | awk '{ print $1 }'`
  if [ $DIRSIZE -gt 10000000 ] ; then
    echo `date "+%Y-%m-%d %H:%M:%S"` - HD - $NAME
    Q=22.0
    LEVEL=4.1 #to prevent auto from going higher
  else
    echo `date "+%Y-%m-%d %H:%M:%S"` - SD - $NAME
    Q=20.0
    #LEVEL=3.1
  fi

  $HB \
    -i "$SRC" \
    --main-feature \
    -o "$DST" \
    -f mkv \
    -m \
    -e x264 \
    --x264-preset $PRESET $TUNE \
    --h264-profile auto \
    -q $Q \
    --h264-level $LEVEL \
    -a 1,2,1 \
    -E copy,copy,lame \
    --audio-copy-mask aac,ac3,dtshd,dts,mp3 \
    --audio-fallback lame \
    -B 160,160,160 \
    -6 auto,auto,dpl2 \
    -R Auto,Auto,Auto \
    -D 0.0,0.0,0.0 \
    --loose-anamorphic \
    --modulus 2 \
    --decom \
    -s 1,2 \
    -F 1 \
    -N eng \
    --native-dub \
    2> "$DST.log"

  mv "$RIPS/$NAME" "$DONE/$NAME"
  
done
IFS=$SAVEIFS

