#!/bin/bash
# if nginx configs, move to volume
mkdir -p /etc/nginx/conf.d/xnat
if [[ "$(ls -A /nginx)" ]]; then
    cp /nginx/* /etc/nginx/conf.d/xnat
else
    echo "ERROR: No nginx conf provided! Using default http config."
    cp /tmp/nginx-http.conf /etc/nginx/conf.d/xnat/nginx-http.conf
fi