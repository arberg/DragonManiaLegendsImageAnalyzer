#!/bin/bash

move() {
	SRC=$1
	TARGET=$2
	
	rsync -a --remove-source-files --exclude ".*" --exclude "*.sh" $SRC/ ${TARGET}		
}

move newToSort/todo allDone
move matches/ matchesAll
rm -f newToMatch_noChestproofs/*.png
