#!/bin/bash
# Takes a file of tsv (title,description,url) values and adds (war) files to plugin folder
TSV=${1:-"/tmp/plugins.tsv"}
if [[ ! -f $TSV ]]; then
    echo "$TSV does not exist"
    exit 1
fi
# awk out curl commands based on tsv
# execute compiled commands
awk -v XNAT_HOME=$XNAT_HOME -F '\t' '{if ($1 != "TITLE") {
    print "curl -qLo" XNAT_HOME "/plugins/"$1 ".jar " $3
}}' $TSV | tac | while read line; do
    $line
done 