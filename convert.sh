# (C) Johan Kleuskens, aug 2021
pushd /mnt/hgfs
find * -prune -type d | while IFS= read -r d; 
do
	echo Stepping into "$d/"
	pushd "$d/"
	# Check if directory contains VIDEO_TS directory
	subdirs=`find * -prune -type d`
	files=`find . -name "*"`
	echo $files
	if [[ "$subdirs" == *"VIDEO_TS"* ]]
	then
		echo "Found VIDEO_TS directory"
		pushd VIDEO_TS
		echo "Converting from DVD to mp4 in directory $d"		
		popd
	elif [[ "$files" == "" ]]
	then
		echo "Skipping $d because this directory is empty"
	elif [[ "$files" == *".mp4"* ]]
	then
		echo "Skipping $d because this directory already contains an mp4 file"
	elif [[ "$files" == *".VOB"* ]]
	then
		echo "Converting from DVD to mp4 in directory $d"
	fi
	popd
done
popd
