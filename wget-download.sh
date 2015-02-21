#!/bin/bash

case $# in
	1)
		DOMAIN="$(echo $1 | grep -oP --color=none '^([a-z]+\:\/\/)?\K[^/]+')"
		echo "Downloading exclusively from the domain: $DOMAIN"
		wget --recursive --no-clobber --page-requisites --html-extension --convert-links --domains $DOMAIN --no-parent $1
		;;
	2)
		wget --recursive --no-clobber --page-requisites --html-extension --convert-links --domains $1 --no-parent $2
		;;
	*)
		echo "Usage: $ dl [domain] url"
		;;
esac