#!/bin/bash
# Starts Tomcat (maybe add monitors here)
[[ ! -e $XNAT_HOME/logs/init.byte ]] && touch $XNAT_HOME/logs/init.byte
/usr/local/tomcat/bin/catalina.sh run