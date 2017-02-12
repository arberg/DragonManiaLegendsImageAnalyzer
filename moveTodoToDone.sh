#!/bin/bash

move() {
	SRC=$1
	TARGET=$2
	
	rsync -a --remove-source-files --exclude "*.md5*" $SRC/ ${TARGET}		
}

move newToSort/todo allDone
