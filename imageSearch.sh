command=$1
inputDir=$2
DEST_DIR=$3
# if distance to image is above this then image will be marked as unmatched. For darkened images where for instance volume control is visible on screen, the image distance is 800-900.
MAX_DISTANCE_IMAGES=1000

usage() {
	echo "Syntax command inputDir DestinationDir"
	echo "where command is match or extract"
	exit 1
}

if [ "$command" = "extract" ] ; then
	COMMAND=extractIcons
	DO_SORT_MATCH_MOVE_ALL=0
elif [ "$command" = "matchMove" ] ; then
	COMMAND=extractAndMatchAndMove
	DO_SORT_MATCH_MOVE_ALL=1
elif [ "$command" = "match" ] ; then
	COMMAND=extractAndMatch
	DO_SORT_MATCH_MOVE_ALL=0
else 
	usage
fi

if [ ! -d "$inputDir" ] ; then
	usage
fi

[ ! -d "$DEST_DIR" ] && mkdir $DEST_DIR
CREATE_DIFF_IMAGES=0

safeMkdir() {
	[ ! -d "$1" ] && mkdir -p "$1"
	echo $1
}

findBestMatch() {
	extractedSubImage=$1
	name=$2
	srcFile=$3
	icons=$4
	doMoveSourceImage=$5

	smallestValueSoFar=99999999
	best=None
	for icon in $icons/*.png
	do
		if [ ! -f $icon ] ; then
			echo "Error: No icons found in folder '$icon'"
			exit 1
		fi
		#Compare
		diff=$(magick compare -metric MSE $extractedSubImage $icon null: 2>&1)
		# echo "$icon $diff"
		difference=$(echo $diff | cut -d' ' -f1 | cut -d'.'  -f1)
		if (( difference < smallestValueSoFar )) ; then
			#echo "$difference smaller than $smallestValueSoFar"
			smallestValueSoFar=$difference
			best=$icon
		# else 
			#echo "$difference NOT smaller than $smallestValueSoFar"
		fi
	done	
	bestfilename="$(basename $best)"
	bestname="${bestfilename%.*}"
	# echo "Best $bestname: mv $extractedSubImage $bestname - $name"

	if [ "$CREATE_DIFF_IMAGES" = "1" ] ; then
		# Create diff
		diffdir=$(safeMkdir "${DEST_DIR}/${bestname}Diff")
		magick composite $extractedSubImage "$best" -compose difference "$diffdir/${bestname} Diff - $smallestValueSoFar - $name.png"
	fi
	srcFileBaseName=$(basename "$srcFile")
	if (( smallestValueSoFar < $MAX_DISTANCE_IMAGES )) ; then
		dir=$(safeMkdir "${DEST_DIR}/${bestname}")
		if [ "$doMoveSourceImage" =  "1" ] ; then
			mv "$srcFile" "$dir/$srcFileBaseName"
			rm  $extractedSubImage
		else 
			mv $extractedSubImage "$dir/${bestname} - $name.png"	
		fi
		echo "Matched $name with distance $smallestValueSoFar"
	else 
		dir=$(safeMkdir "${DEST_DIR}/unmatched")
		if [ "$doMoveSourceImage" =  "1" ] ; then
			mv "$srcFile" "$dir/$srcFileBaseName"
			rm  $extractedSubImage
		else 
			mv $extractedSubImage "$dir/$name - Unmatched - Distance $smallestValueSoFar.png"
			cp "$srcFile" "$dir/$(basename "$srcFile")"
		fi
		echo "Warning large difference $smallestValueSoFar for \"$name\""
	fi
}

extract() {
	crop="$1"
	file="$2"
	dstfile="$3"

	magick convert "$file" -crop "$crop" "$dstfile"

	if [ "$?" != "0" ] ; then
		echo "Missing ImageMagick"
		exit 1
	fi
	# #Create diff
	# magick composite cropped.png $searchFile -compose difference diff.png
}


extractAndMatchCommon() {
	idx=$1
	crop="$2"
	file="$3"
	icons="$4"
	moveSourceFiles="$5"

	filename=$(basename "$file")
	name="${filename%.*}"
	extract "$crop" "$file" cropped.png
	findBestMatch cropped.png "$name - idx $idx" "$file" "$icons" $moveSourceFiles
}


extractAndMatch() {
	extractAndMatchCommon "$1" "$2" "$3" "$4" 0
}


extractAndMatchAndMove() {
	extractAndMatchCommon "$1" "$2" "$3" "$4" 1
}

extractIcons() {
	idx=$1
	crop="$2"
	file="$3"

	filename=$(basename "$file")
	name="${filename%.*}"

	extract "$crop" "$file" cropped.png
	mv cropped.png "$DEST_DIR/$name - idx $idx.png"
}

searchAndExtract() {
	count=$1
	shift

	# When matching cards 
	# offsetCornerX,offsetCornerY is coordinate of top left of first card
	# distanceCornerToCropStartX,distanceCornerToCropStartY is distance from top left of first card to left side of vertical center of the icon of the card
	# yIsCenter=1 indicates above distance is to vertical (y) center
	#
	# When matching banner
	# offsetCornerX,offsetCornerY top left corner of cutout of banner

 

	# Image size (screensize) is 2560x1440.
	if [ "$count" == "1" ] ; then
		# Tests that we see banner indicating its not a chest-proof
		dim=110
		offsetCornerX=447
		offsetCornerY=83
		distanceCornerToCropStartX=0
		distanceCornerToCropStartY=0
		yIsCenter=0
		icons="iconsBanner"
	elif [ "$count" == "5" ] ; then
		# Chest with 5+1 cards
		dim=92
		distanceBetweenCardsX=367
		distanceCornerToCropStartX=231
		distanceCornerToCropStartY=55
		offsetCornerX=182
		offsetCornerY=501
		yIsCenter=1
		icons="iconsRare"
	else
		dim=110
		distanceBetweenCardsX=428
		# distance from corner to icon left side, vertical center
		distanceCornerToCropStartX=239
		distanceCornerToCropStartY=24
		yIsCenter=1
		offsetCornerY=501
		icons="icons"
		if [ "$count" = "3" ] ; then
			# Left/Top 1st card corner: 457x501
			offsetCornerX=457
		elif [ "$count" = "4" ] ; then
			# Left/Top 1st card corner: 244x501, 1st icon left side, vertical center 412x556
			offsetCornerX=244
		else 
			echo "Unexpected count $count. Stopping"
			exit 1
		fi
	fi
	offsetX=$((offsetCornerX + distanceCornerToCropStartX))
	y=$((offsetCornerY + distanceCornerToCropStartY - dim/2*yIsCenter))
	
	# Patterns expand to themselves if not matched, unless somehow using (shopt -s nullglob)
	for file in "$@"
	do
		if [ -f "$file" ] ; then
			# echo $file
			x=$offsetX
			for i in $(seq $count) ; do
				#echo "$i - $x"
				# $COMMAND is extractIcons or extractAndMatch
				$COMMAND $i "${dim}x${dim}+${x}+${y}" "${file}" "$icons"
				x=$((x+distanceBetweenCardsX))
			done
		else
			echo "None $count: $file"
		fi
	done

}

if [ "$DO_SORT_MATCH_MOVE_ALL" = "1" ] ; then
	searchAndExtract 1 $inputDir/*.png
else
	searchAndExtract 3 $inputDir/*Gift*.png $inputDir/*Opponent_100*.png
	searchAndExtract 4 $inputDir/*Opponent_300*.png $inputDir/*Opponent_600*.png $inputDir/*Special
	searchAndExtract 5 $inputDir/*Rare*.png

	echo
	./count.sh "$DEST_DIR"
fi