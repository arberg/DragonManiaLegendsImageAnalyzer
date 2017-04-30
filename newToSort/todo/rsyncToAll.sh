#!/bin/bash

TARGET_DIR_ALL=../../all_league_battles
for d in Normal* Special* Rare* Battle*; do
	if [ -d "$d" ]
	then
		rsync -a --exclude ".*" "$d"/ ${TARGET_DIR_ALL}
	fi
done

TARGET_DIR_ALL=../../newToMatch_noChestproofs
for d in Normal* Special* Rare* Gift* Battle*; do
	if [ -d "$d" ]
	then
		rsync -a --exclude "*Chestproof*.png" --exclude ".*" "$d"/ ${TARGET_DIR_ALL}
	fi
done
