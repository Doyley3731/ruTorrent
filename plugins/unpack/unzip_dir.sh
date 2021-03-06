#!/bin/sh
#
# $1 - unzip
# $2 - input directory with tail slash
# $3 - output directory with tail slash
# $5 - archive files to delete
# $6 - unpack temp dir

ret=0

process_directory()
{
        for fn in "$2"*.zip ; do
        	if [ -f "${fn}" ] && [ -r "${fn}" ] ; then
	        	mkdir -p "$3"
			"$1" -o "${fn}" -d "$3"
			last=$?
			[ $last -ge 1 ] && ret=$last
		fi
	done
	for fn in "$2"* ; do
		if [ -d "${fn}" ] && [ ! -L "${fn}" ] ; then
			name=$(basename "${fn}")
			process_directory "$1" "${fn}/" "$3${name}/"
			last=$?
			[ $last -ge 1 ] && ret=$last
		fi
	done
	return $ret
}

if [ "$6" != '' ] ; then
	process_directory "$1" "$2" "$6"
	ret=$?
else
	process_directory "$1" "$2" "$3"
	ret=$?
fi

[ $ret -eq 0 ] && echo 'All OK'
if [ $ret -eq 0 ] && [ "$5" != '' ] ; then
	OIFS=$IFS
	IFS=';'
	for file in "$5"
	do
		rm $file
	done
	IFS=$OIFS
fi

if [ "$6" != '' ] ; then
	cd "$6"
	find . -type d -exec mkdir -p "${3}"/\{} \;
	find . -type f -exec mv -f \{} "${3}"/\{} \;
	[ $? -eq 0 ] && rm -r "$6"
fi

exit $ret
