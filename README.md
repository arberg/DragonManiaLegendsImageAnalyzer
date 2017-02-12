# DragonManiaLegendsImageAnalyzer
Bash scripts for analysing images from Dragon Mania Legends of for collection statistics about enchanment elements

It is implemented with bash scripts and uses to do the image work. The bash-scripts have been used on cygwin, but should work on unix bash.

### ImageMagick
Download version 7 (or newer) from https://www.imagemagick.org/. It has been tested with ImageMagick-7.0.4-Q16, but will probably work with all 7x versions, it is incompatible with ImageMagick 6 or earlier, due to scripting changes in ImageMagick (as far as I know).

### Screenshots

To use this take screenshots of enchanment elements, and possibly the chest if you wish to 'document' which chest type the cards were from. 

The bash scripts assume the images have size 2560x1440. If different sizes are used then the script 'imageSearch.sh' (method searchAndExtract) needs to be updated with either new coordinates or with a scaling of the coordinates.

### Howto

Move all screenshots to folder newToSort\new

In: `newToSort`
```
doSort.sh
```
Manuelly check sort 
- Note chests where user gained +15 points means the opponent were at same level as player or higher (verified) or maybe slightly lower (unverified, probably false), +14 means lower level. Note that when inspecting battlelog, the points from the fight has been awarded to me as the winner (when I attack), so to get my points before attacking subtract victory points
Rename and postfix ' - Chestproof' in TotalCommander with '[N1-26] - Chestproof[N27-]'

Manuel task: Add data of Rare to excel (skip entering specials, they don't really matter)

In: `newToSort`
```
cd todo
. rename.sh
. rsyncToAll.sh
cd ../..
. doMatchNew.sh
```
Manuelly (if you so desire) Possibly verify matches by checking images - though I have never seen a mismatch

In: `/`
```
rsync --remove-source-files -av matches/ matchesAll
./doCountAll.sh
```

Below will delete files in new_noChestproofs (even if we rerun some images, it will not skew counting, because the files placed in match has unique names based on source file and index).

In: `/`
```
. moveTodoToDone.sh
rm -f newToMatch_noChestproofs/*.png
```