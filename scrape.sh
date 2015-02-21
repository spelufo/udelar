#!/bin/bash

# Scrape bedelias.edu.uy por informacion de previas.
#
# Requisitos:
#
# 	$ grep --version
# 	grep (GNU grep) 2.16
#
# 	$ bash --version
# 	GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu)
#
# 	$ apt install html-xml-utils
#   $ apt show html-xml-utils
# 	Package: html-xml-utils
# 	State: installed
# 	Automatically installed: no
# 	Version: 6.5-1
# 	...


./wget-download.sh bedelias.edu.uy

grep -oP --color=none 'href=".*\K(www\d[^"]+)' bedelias.edu.uy/sti/facultades.html > facultades.lns

while read -r l; do ./wget-download.sh "$l"; done < facultades.lns

FACDS=$(echo www{1,2,3}.bedelias.edu.uy/*/)

for f in $FACDS; do
	grep -oP "parent.contenidos.location[^']+'\K([^']+)(?=')" $f/menu.planes* | while read -r lnk; do echo "${f/\/*/}""$lnk"; done
done > planes.lns

PREVS=$(echo www{1,2,3}.bedelias.edu.uy/*/muestra)

while read -r l; do ./wget-download.sh "$l"; done < planes.lns

for f in $FACDS
do
	echo "# $f" >> carreras.txt
	if [[ -f "${f}muestra_prev.selcarr.html" ]]; then
		cars=$(hxnormalize -x "${f}muestra_prev.selcarr.html" -i 0 -l 300 | hxselect option -s '\n' | grep -oP '\d+\s*-\s*\d+[^<]+' | tee -a carreras.txt | cut -d ' ' -f 1)
		for car in $cars; do ./wget-download.sh "${f}muestra_prev.imprime?carrera=${car/-/&cicl=}&p_mat=_"; done
	else
		echo "# File doesn't exist: ${f}muestra_prev.selcarr.html"  >> carreras.txt
	fi
done