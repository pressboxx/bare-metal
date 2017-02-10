#!/usr/bin/env bash

cd /pressboxx
source includes/constants.sh 
source includes/functions.sh 

if [ "$1" == "reset" ]; then
	rm -f $STEPFILE
	exit
fi

if [ ! -f $STEPFILE ]; then
	step=1
else	
	step=$(cat $STEPFILE)
fi

case $step in 
	1)
		nextstep 2
		clean_macos_files
		setup_version_control
		apt_get_update_upgrade		
		setup_hostname
		setup_autologin
		setup_boxx_user
		;;
	2)
		nextstep 3
		setup_zero_config_networking		
		;;
	3)
		nextstep 4
		setup_default_directories
		setup_nginx
		setup_mysql
		;;
esac

cd /pressboxx
/bin/sh install.sh
exit

