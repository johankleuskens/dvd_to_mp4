pushd /mnt/hgfs
find * -prune -type d | while IFS= read -r d; 
do
	echo Stepping into "$d/"
	pushd "$d/"
	# Check if directory contains VIDEO_TS directory
	subdirs=`find * -prune -type d`
	echo $subdirs
	if [[ "$subdirs" == *"VIDEO_TS"* ]]
	then
		echo "Found VIDEO_TS directory"
		pushd VIDEO_TS
		popd
	fi
	popd
done
popd
