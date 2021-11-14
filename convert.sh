# (C) Johan Kleuskens, aug-nov 2021
#


OP=" --keep-display-aspect"
OP="$OP --loose-anamorphic"
OP="$OP --encoder-preset slow"
OP="$OP -b 2000"
OP="$OP --stop-at duration:30"
#OP="$OP --title 0"				# Scan all titles only

OUTPUT_DIR_NAME="SGM_mp4"
OUTPUT_DIR="/mnt/hgfs/$OUTPUT_DIR_NAME"

#SAVEIFS=$IFS		# Store seperator
#IFS=$'\n'			# Make CR seperator

pushd /mnt/hgfs
for d in *;
do
    if [[ -d "$d" && ! "$d" == "$OUTPUT_DIR_NAME" ]];
    then
		echo Checking directory "$d"
		# check for files in the directory
		files=`find "$d" -maxdepth 1 -type f -name "*"`
		echo $files
		# Create the destination directory
		mkdir -p "$OUTPUT_DIR/$d"

		# If destination directory already contains an mp4, skip this conversion
		mp4files=`find "$OUTPUT_DIR/$d" -name "*.mp4"`
		if [[ -z "$mp4files" ]];
		then	
			# Check if directory contains VIDEO_TS directory
			subdirs=`find "$d" -maxdepth 1 -type d `
			if [[ "$subdirs" == *"VIDEO_TS"* ]];
			then
				#Read handbrake's stderr into variable
				rawout=$(HandBrakeCLI -i "$d/VIDEO_TS" -t 0 2>&1 >/dev/null)
				#Parse the variable using grep to get the count
				count=$(echo $rawout | grep -Eao "\\+ title [0-9]+:" | wc -l)
				# Loop through all titles
				for t in $(seq $count)
				do
					echo "Converting title $t from VIDEO_TS to mp4 in directory $d"	
					HandBrakeCLI -i "$d/VIDEO_TS" -o "$OUTPUT_DIR/$d/$d-$t.mp4"  --title $t -e x264 -q 20 $OP
				done
			# Check if directory is empty
			elif [[ "$files" == "" ]];
			then
				echo "Skipping $d because this directory is empty"
				
			# Check if directory contains valid video files
			elif [[ "$files" == *".avi"* || "$files" == *".MOV"* || "$files" == *".mpg"* || "$files" == *".MOD"* ]];
			then
				pushd "$d"
				for f in *;
				do
					if [[ "$f" == *".avi"* || "$f" == *".MOV"* || "$f" == *".mpg"* || "$f" == *".MOD"* ]];
					then
						echo "Converting $f to mp4"
						HandBrakeCLI -i "$f" -o "$OUTPUT_DIR/$d/$f.mp4" -e x264 -q 20 $OP
					fi				
				done
				popd
				
			# Check if directory contains mp4 files
			elif [[ "$files" == *".mp4"* ]];
			then
				pushd "$d"
				for f in *;
				do
					if [[ "$f" == *".mp4"* ]];
					then
						echo "Copying  $f to $OUTPUT_DIR/$f"
						cp "$f" "$OUTPUT_DIR/$d/$f"
					fi
				done
				popd
				
			# Check if directory contains VOB files
			elif [[ "$files" == *".VOB"* ]];
			then
				#Read handbrake's stderr into variable
				rawout=$(HandBrakeCLI -i "$d" -t 0 2>&1 >/dev/null)
				#Parse the variable using grep to get the count
				count=$(echo $rawout | grep -Eao "\\+ title [0-9]+:" | wc -l)
				# Loop through all titles
				for t in $(seq $count)
				do
					echo "Converting from title $t from DVD to mp4 in directory $d"
					HandBrakeCLI -i "$d" -o "$OUTPUT_DIR/$d/$d-$t.mp4" --title $t -e x264 -q 20 $OP 
				done
			else
				echo "Unknown content in directory $d"
			fi
		fi
	fi
done
popd

#IFS=$SAVEIFS		# Put back seperator
