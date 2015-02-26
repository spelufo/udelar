#!/bin/bash

# while read -r l; do
#	outfile=$(echo $l | awk '{ print "previas/" $1 "-" $2 ".json" }')
#	infile=$(echo $l | awk '{ print $3 }')
#	echo "Making $outfile" >&2
#	./extract-previas.js <(iconv -f ISO-8859-1 -t UTF-8 "$infile") "$outfile"
# done < carreras.txt


FACDS=$(echo www{1,2,3}.bedelias.edu.uy/*/)

for f in $FACDS; do
	outfile=$(echo previas/"$(basename $f)"-grupos.json)
	echo "Making $outfile" >&2
	cat "$f"muestra_prev.grupos\?codgrp=*.html | hxnormalize -x -i 0 | hxselect 'body > table > tbody' | hxnormalize -x > "$f"grupos.html
	./extract-grupos.js <(iconv -f ISO-8859-1 -t UTF-8 "$f"grupos.html) "$outfile"
done