#!/bin/bash

while read -r l; do
	outfile=$(echo $l | awk '{ print "previas/" $1 "-" $2 ".json" }')
	infile=$(echo $l | awk '{ print $3 }')
	echo "Making $outfile" >&2
	./extract-previas.js <(iconv -f ISO-8859-1 -t UTF-8 "$infile") "$outfile"
done < carreras.txt
