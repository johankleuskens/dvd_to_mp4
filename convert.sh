pushd /mnt/hgfs
find * -prune -type d | while IFS= read -r d; 
do
	echo "$d"
done
popd
