# (C) Johan Kleuskens, aug-nov 2021
#


OP=" --keep-display-aspect"
OP="$OP --loose-anamorphic"
OP="$OP --encoder-preset slow"
OP="$OP -b 2000"
OP="$OP --stop-at duration:30"

OUTPUT_DIR_NAME="SGM_mp4"
OUTPUT_DIR="/mnt/hgfs/$OUTPUT_DIR_NAME"

SAVEIFS=$IFS		# Store seperator
IFS=$'\n'			# Make CR seperator

pushd /mnt/hgfs
for d in *;
do
    if [[ -d "$d" && ! "$d" == "$OUTPUT_DIR_NAME" ]];
    then
		echo Checking directory "$d/"
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
				echo "Found VIDEO_TS directory"
				echo "Converting from VIDEO_TS to mp4 in directory $d"	
				HandBrakeCLI -i "$d/VIDEO_TS" --main-feature -o "$OUTPUT_DIR/$d/$d.mp4"  -e x264 -q 20 $OP
				
			# Check if directory is empty
			elif [[ "$files" == "" ]];
			then
				echo "Skipping $d because this directory is empty"
				
			# Check if directory contains mpg files
			elif [[ "$files" == *".mpg"* ]];
			then
				mpgfiles=`find "$d" -maxdepth 1 -type f -name "*.mpg"`
				for f in $mpgfiles;
				do
					echo "Converting $f from mpg to mp4"
					HandBrakeCLI -i "$f" -o "$OUTPUT_DIR/$f.mp4" -e x264 -q 20 $OP					
				done
				
			# Check if directory contains avi files
			elif [[ "$files" == *".avi"* ]];
			then
				avifiles=`find "$d" -maxdepth 1 -type f -name "*.avi"`
				for f in $avifiles;
				do
					echo "Converting $f from avi to mp4"
					HandBrakeCLI -i "$f" -o "$OUTPUT_DIR/$f.mp4" -e x264 -q 20 $OP				
				done
				
			# Check if directory contains mp4 files
			elif [[ "$files" == *".mp4"* ]];
			then
				mp4files=`find "$d" -maxdepth 1 -type f -name "*.mp4"`
				for f in $mp4files;
				do
					echo "Copying  $f to $OUTPUT_DIR/$f"
					cp "$f" "$OUTPUT_DIR/$f"
				done
				
			# Check if directory contains VOB files
			elif [[ "$files" == *".VOB"* ]];
			then
				echo "Converting from DVD to mp4 in directory $d"
				HandBrakeCLI -i "$d" -o "$OUTPUT_DIR/$d/$d.mp4" --main-feature -e x264 -q 20 $OP
			else
				echo "Unknown content in directory $d"
			fi
		fi
	fi
done
popd

IFS=$SAVEIFS		# Put back seperator
