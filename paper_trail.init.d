#!/bin/bash

### BEGIN INIT INFO
# Provides: remote_syslog
# Required-Start: $network $remote_fs $syslog
# Required-Stop: $network $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start and Stop
# Description: Runs remote_syslog
### END INIT INFO

#       /etc/init.d/remote_syslog
#
# Starts the remote_syslog daemon
#
# chkconfig: 345 90 5
# description: Runs remote_syslog
#
# processname: remote_syslog

prog="remote_syslog"
config="$HOME/bin/remote_syslog_conf.yml"

dates=$(date)

EXTRAOPTIONS=""

RETVAL=0

start(){
    echo "$dates : paper_trail daemon starting" >> $HOME/logs/self.log

    $prog -c $config $EXTRAOPTIONS

    return 0
}

stop(){
    echo "Stopping $prog: "
    tmp=$(ps -A | grep remote_syslog | wc -l)
    if [[ $tmp > 0 ]]; then
      echo "found - killed"
      kill $(ps -A | grep remote_syslog | awk '{print $1}')
    else
      echo "not found"
    fi


      return 0
}

status(){
    echo -n $"Checking for process "
    tmp=$(ps -A | grep remote_syslog | wc -l)
    if [[ $tmp > 0 ]]; then
      echo -e '\033[1;32m[ FOUND ]\033[0m'
    else
      echo "[ not found ]"
    fi
    return 0
}


# See how we were called.
case "$1" in
    start)
	start
	;;
    stop)
	stop
	;;
    status)
	status
	;;
    *)
	echo $"Usage: $0 {start|stop|status}"
	RETVAL=1
esac

exit $RETVAL