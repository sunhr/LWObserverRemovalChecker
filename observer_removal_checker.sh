#!/bin/sh

SKIP_LIST=( "Pods" )

function process_file() {

	observed=false
	removed=false
	
	if cat $1 | grep "\[\[NSNotificationCenter defaultCenter\] addObserver:self" &>/dev/null ; then
		observed=true
	fi
	
	if cat $1 | grep "\[\[NSNotificationCenter defaultCenter\] removeObserver:self" &>/dev/null ; then
		removed=true
	fi

	if [ $observed == true ] && [ $removed == false ] ; then
		echo "error: Missing removeObserver in $1"
		exit 2
	fi
}

function scan_dir() {
	
	for file in `ls $1`
	do
		path=$1"/"$file
		
    	if test -d $path ; then
			
			if echo "${SKIP_LIST[@]}" | grep -w $file &>/dev/null ; then
				echo "Skipping Directory $file"
				continue
			fi
			
            scan_dir $path
        else
			
			if [[ $file == *.m ]] || [[ $file == *.mm ]] ; then
				process_file $path
			fi

        fi
    done
}

scan_dir $PWD
