#!/bin/bash

if [ ! -d "Normal - Opponent_300" ] ; then
	echo "Prodably wrong folder, cannot find 'Normal - Opponent_300'"
else 
	for d in * ; do
		if [ -d "$d" ]
		then
			pushd "$d" > /dev/null
			for f in * ; do
				if [ -f "$f" ] 
				then
					# Expect format Screenshot_20170106-075950, keep first 26 chars as prefix, the rest as postfix
					# rename command would be much faster, but the syntax is different on my cygwin platform so this does not work: rename "s/(.{26})(.*)$/\$1 - $d\$2/" "$f"
					#filename="${f%.*}"
					fileprefix=$(echo $f | cut -c -26)
					filepostfixAndExtension=$(echo $f | cut -c 27-)
					#extension="${f##*.}"
					mv "$f" "$fileprefix - $d$filepostfixAndExtension"
				fi
			done	
			popd > /dev/null
		fi
	done
fi

