# Set path for find due to bad cygpath on my cygwin install
PATH=/bin:$PATH

DEST_DIR=$1

usage() {
	echo "Arguments: <Dir>"
	exit 1
}

if [ "$DEST_DIR" = "" ] ; then
	usage
fi 
if [ ! -d "$DEST_DIR" ] ; then
	echo "$DEST_DIR is not a directory" 
	exit 1
fi 

countByName() {
	name=$1
	
	[ -z "$name" ] && echo "Total" || echo "$name"
	total=0
	for resultDirVariant in $DEST_DIR/*
	do
		if [ -d "$resultDirVariant" ] ; then
			# Expect naming of icon '1_fire', '2_wind', remove the prefix
			count=$(find $resultDirVariant -name "*$name*" -type f -print | wc -l)
			typeWithNumber=$(basename $resultDirVariant)
			variant=$(echo $typeWithNumber | cut -d'_' -f2)
			echo "$variant $count"
			total=$((total+count))
		fi
	done 	
	echo "Total $total"
	echo
}


countByName Rare
countByName Special
countByName Normal
countByName Gift
countByName png