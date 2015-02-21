#!/bin/bash

dl bedelias.edu.uy bedelias.edu.uy
grep -oP 'href="([^"]+)"' bedelias.edu.uy/sti/facultades.html | cut -d ':' -f2 | cut -d '/' -f '3-' | grep -oP --color=none '[^"]+' > facultades.lns

while read -r l
do
	dl "$(echo $l | grep -oP --color=none '^[^/]+')" "$l"
done < facultades.lns


FACDS=$(echo www{1,2,3}.bedelias.edu.uy/*/)

for f in $FACDS; do
	grep -oP "parent.contenidos.location[^']+'\K([^']+)(?=')" $f/menu.planes* | while read -r lnk; do echo "${f/\/*/}""$lnk"; done
done > planes.lns


