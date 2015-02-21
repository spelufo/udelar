#!/bin/bash

# ./wget-download.sh bedelias.edu.uy

# grep -oP 'href="([^"]+)"' bedelias.edu.uy/sti/facultades.html | cut -d ':' -f2 | cut -d '/' -f '3-' | grep -oP --color=none '[^"]+' > facultades.lns

# while read -r l; do ./wget-download.sh "$l"; done < facultades.lns

# FACDS=$(echo www{1,2,3}.bedelias.edu.uy/*/)

# for f in $FACDS; do
# 	grep -oP "parent.contenidos.location[^']+'\K([^']+)(?=')" $f/menu.planes* | while read -r lnk; do echo "${f/\/*/}""$lnk"; done
# done > planes.lns

# cat planes.lns | grep -P --color=none 'mats\.sel_carr8$' > planes-materias.lns
# cat planes.lns | grep -P --color=none 'carrs\.muestreo_carreras$' > planes-carreras.lns
# PREVS=$(echo www{1,2,3}.bedelias.edu.uy/*/muestra)

while read -r l; do ./wget-download.sh "$l"; done < planes.lns