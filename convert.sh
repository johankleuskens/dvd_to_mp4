# (C) Johan Kleuskens, aug 2021
#
# https://gist.github.com/atais/552ee207a673901eddfc199fe79a4a40
# HandBrakeCLI -i '0002_DVD 02_8mm'/ -o test.mp4   --main-feature -e x264 -q 20 --keep-display-aspect --loose-anamorphic --encoder-preset slow -b 2000
#

OP=" --keep-display-aspect"
OP="$OP --loose-anamorphic"
OP="$OP --encoder-preset slow"
OP="$OP -b 2000"

OUTPUT_DIR="/mnt/hgfs/SGM_mp4"

pushd /mnt/hgfs
for d in *;
do
    if [ -d "$d" ];
    then
		echo Stepping into "$d/"
		pushd "$d/"
		# Check if directory contains VIDEO_TS directory
		subdirs=`find * -prune -type d`
		files=`find . -name "*"`
		echo $files
		# Create the destination directory
		mkdir "$OUTPUT_DIR/$d"
		
		if [[ "$subdirs" == *"VIDEO_TS"* ]];
		then
			echo "Found VIDEO_TS directory"
			echo "Converting from DVD to mp4 in directory $d"	
			# If the directoty already contains an mp4, skip this conversion
			mp4files=`find "$OUTPUT_DIR/$d" -name "*.mp4"`
			if [[ -z "$mp4files" ]];
			then
				HandBrakeCLI -i "VIDEO_TS" --main-feature -o "$OUTPUT_DIR/$d/$d.mp4" "$OP" -e x264 -q 20 --stop-at duration:30
			fi
			popd
		elif [[ "$files" == "" ]];
		then
			echo "Skipping $d because this directory is empty"
			popd
		elif [[ "$files" == *".mp4"* ]];
		then
			echo "Skipping $d because this directory already contains an mp4 file"
			popd
		elif [[ "$files" == *".VOB"* ]];
		then
			echo "Converting from DVD to mp4 in directory $d"
			popd
			# If the directoty already contains an mp4, skip this conversion
			mp4files=`find "$OUTPUT_DIR/$d" -name "*.mp4"`
			if [[ -z "$mp4files" ]];
			then
				HandBrakeCLI -i "$d" -o "$OUTPUT_DIR/$d/$d.mp4" --main-feature -e x264 -q 20 "$OP" --stop-at duration:30
			fi
		else
			popd
		fi
	fi
done
popd
