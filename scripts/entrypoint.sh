#!/bin/bash

set -e
[[ -e  $XNAT_HOME/logs/init.byte ]] && INIT=1
for f in /startup/*; do
    if [ -f "$f" -a -x "$f" ]; then
	    #if it is an 80 level script we only run it on a fresh container
        [[ $(basename $f) =~ 8[0-9]-[a-zA-Z\-]+\.[a-zA-Z]+ ]] && \
		[[ $INIT == 1 ]] && continue
	    echo "Running $f $@"
        "$f" "$@"
    fi
done
