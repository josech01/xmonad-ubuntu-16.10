#/bin/bash

FG='#dcdcdc'
BG='#1D1F21'

font1="FantasqueSansMono:size=8"

TODAY=$(expr `date +'%d'` + 0)

cal_c_m=`cal | sed -re "s/^(.*[A-Za-z][A-Za-z]*.*)$/^fg(#f0f0f0)^bg(#187C9F) \1 /;
s/(^|[ ])($TODAY)($|[ ])/\1^bg(#187C9F)^fg(#222222)\2^fg(#6c6c6c)^bg(#222222)\3/"`

(

echo "
^fg(#187C9F)^fn(FantasqueSansMono:size=8)Date
"

echo "$cal_c_m
"

) | dzen2 -p -x 1134 -y 22 -w 145 -bg $BG -fg $FG -l 12 -sa c -ta c -e 'onstart=uncollapse;button1=exit;button3=exit' -fn $font1


