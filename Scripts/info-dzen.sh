#!/bin/bash

FG='#C5C8C6'
BG='#1F1F1F'
fg_title="#C12B4D"

font1="Inconsolata:size=11"
font_title="Inconsolata:bold:size=11"
icons="Typicons:size=12"
icons2="FontAwesome:size=12"
icons4="FontAwesome:size=10"
icons3="Ionicons:size=12"

 #A simple popup showing system information
 disk=$(df -h / | awk 'NR==2 {total=$2; used=$3; print used" / "total}')
 termfn=$(cat $HOME/.Xresources | grep -v ! | awk '/.font/ {print $2}' | sed 's/xft://;s/:pixelsize//;s/=/\ /')
 OS=$(uname -r)
 pid=$(pgrep -x -u $USER $wm)
 HOST=$(uname -n)
 KERNEL=$(uname -r)
 uptime=$(uptime | awk '{print $3}')
 charCount=$(echo ${#uptime})
 MPC=`mpc -f %title%  | head -1`
 MPD=`mpc -f %artist%  | head -1`
 cpu=$(lscpu | grep 'Nome do modelo' | awk -F ':' '{print $2}' | cut -c 18-31)
 if [[ "$charCount" = "3" ]]
 	then
 	uptime=$(uptime | awk '{print $3}' | sed 's/,/m/')
 elif [[ "$charCount" = "1" ]] || [[ "$charCount" = "2" ]]
 	then
 	uptime=$(uptime | awk '{print $3}' | sed 's/$/m/')
 else
 	uptime=$(uptime | awk '{print $3}' | sed 's/:/h /' | sed 's/,/m/')
 fi


 PACKAGES=$(pacman -Q | wc -l)
 de=$(wmctrl -m | grep -i name | awk '{print $2}')
 ram_used=$(free -m | grep Mem | awk '{print $3" MB"}')
 ram_total=$(free -m | grep Mem | awk '{print $2" MB"}')
 cpu_user=$(mpstat | grep all | awk '{print $4"%"}')
 cpu_sys=$(mpstat | grep all | awk '{print $6"%"}')
 cpu_idle=$(mpstat | grep all | awk '{print $12"%"}')
 temp=$( sensors | awk '/^Core/ {print $3}' | head -n1 | tr -d '+')
 hdd_temp=$(hddtemp -n /dev/sda)

gtkrc="$HOME/.gtkrc-2.0"
GtkTheme=$( grep "gtk-theme-name" "$gtkrc" | cut -d\" -f2 )
GtkIcon=$( grep "gtk-icon-theme-name" "$gtkrc" | cut -d\" -f2 )
GtkFont=$( grep "gtk-font-name" "$gtkrc" | cut -d\" -f2 )

(
 echo "
 ^fg($fg_title)^fn($font_title)^p(+55)System Information^p()^fg()" # Fist line goes to title
 echo "   ^fg(#C12B4D)-----------------------------"
 echo "   ^fg(#C5C8C6)^fn($icons2)^fn($font1) Tiago | $HOST "
 echo "   ^fg(#C5C8C6)^fn($icons2)^fn($font1) $uptime"
 echo "   ^fg(#C5C8C6)^fn($icons3)P^fn() $PACKAGES packages"
 echo "   ^fg(#C12B4D)-----------------------------"
 echo "   ^fg(#C5C8C6)^fn($font_title)^fg($fg_title)^bg(#1F1F1F) INFO "
 echo "   ^fg(#C5C8C6)^fn($icons2)^fn($font1) Wm 		   ^fn($icons4)^fn($font1) $de	"
 echo "   ^fg(#C5C8C6)^fn($icons2)^fn($font1) Theme 	 ^fn($icons4)^fn($font1) $GtkTheme	"
 echo "   ^fg(#C5C8C6)^fn($icons2)^fn($font1) Icon    ^fn($icons4)^fn($font1) $GtkIcon	"
 echo "	  ^fg(#C5C8C6)^fn($icons2) ^fn($font1) Playing ^fn($icons4)^fn($font1) $MPD 							"
 echo "		^fg(#C5C8C6)								$MPC"
 echo "   ^fg(#C5C8C6)^fn($font_title)^fg($fg_title)^bg(#1F1F1F) RAM "
 echo "   ^fg(#C5C8C6)^fn($icons2) ^fn($font1)$ram_used / $ram_total"
 echo ""
 echo "   ^fg(#C5C8C6)^fn($font_title)^fg($fg_title)^bg(#1F1F1F) HDD "
 echo "   ^fg(#C5C8C6)^fn($icons2)^fn($font1) $disk
 "
 echo ""

) | dzen2 -p -x 5 -y 23 -w 280 -bg $BG -fg $FG -l 17 -sa l -ta c -e 'onstart=uncollapse;button1=exit;button3=exit' -fn $font1
