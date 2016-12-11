#!/bin/sh
if [[ -n "$(mpc current)" ]]; then
	np=$(mpc current)
else
	np="Stopped"
fi
echo "$np"
