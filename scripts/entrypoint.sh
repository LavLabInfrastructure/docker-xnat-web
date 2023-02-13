#!/bin/bash
PGPASSWORD=${POSTGRES_PASSWORD:-password} psql -w -h "${POSTGRES_HOST:-postgres}" \
        -p "${POSTGRES_PORT:-5432}" \
        -U "${POSTGRES_USER:-root}" \
        "${XNAT_POSTGRES_DB:-xnat}" 2> /dev/null || \
    PGPASSWORD=${POSTGRES_PASSWORD:-password} psql -h "${POSTGRES_HOST:-postgres}" \
        -p "${POSTGRES_PORT:-5432}" \
        -U "${POSTGRES_USER:-root}" \
        -d "${POSTGRES_DB:-root}" \
        -c "create database ${XNAT_POSTGRES_DB:-xnat};"
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
