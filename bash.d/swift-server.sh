#!/bin/bash

# swift-server	This is the init script for starting up the Swift Poetry Project server.
#
# chkconfig: - 64 36
# description: The Ruby/Sinatra server for the Lafayette College Swift Poetry Project Virtual Research Environment (VRE).
# processname: swift-poetry-project
# pidfile: /var/run/spp.pid

# Source function library.
. /etc/rc.d/init.d/functions

# Get network config.
. /etc/sysconfig/network

# Find the name of the script
NAME=`basename $0`
if [ ${NAME:0:1} = "S" -o ${NAME:0:1} = "K" ]
then
	NAME=${NAME:3}
fi

# For SELinux we need to use 'runuser' not 'su'
if [ -x /sbin/runuser ]
then
    SU=runuser
else
    SU=su
fi

# Set defaults for configuration variables
SPP_HOME=/usr/share/spp/ruby-tools/spp
SPPLOG=/var/log/spp.log
SPP_WRAPPER="$SPP_HOME/swift-poetry-project.sh"

# Value to set as postmaster process's oom_adj
#PG_OOM_ADJ=-17
SPP_OOM_ADJ=-17

lockfile="/var/lock/subsys/${NAME}"
#pidfile="/var/run/postmaster.${PGPORT}.pid"
pidfile="/var/run/spp.pid"

script_result=0

start(){
        # [ -x "$PGENGINE/postmaster" ] || exit 5
	[ -x $SPP_WRAPPER ] || exit 5

	#PSQL_START=$"Starting ${NAME} service: "
	SPP_START=$"Starting ${NAME} service: "

	# Make sure startup-time log file is valid
	#if [ ! -e "$PGLOG" -a ! -h "$PGLOG" ]
	#then
	if [ ! -e "$SPPLOG" -a ! -h "$SPPLOG" ] ; then

	    #touch "$PGLOG" || exit 4
	    touch "$SPPLOG" || exit 4
	    #chown postgres:postgres "$PGLOG"
	    #chmod go-rwx "$PGLOG"
	    chmod go-rwx "$SPPLOG"
	    #[ -x /sbin/restorecon ] && /sbin/restorecon "$PGLOG"
	    [ -x /sbin/restorecon ] && /sbin/restorecon "$SPPLOG"
	fi

	#echo -n "$PSQL_START"
	echo -n "$SPP_START"
	#test x"$PG_OOM_ADJ" != x && echo "$PG_OOM_ADJ" > /proc/self/oom_adj
	test x"$SPP_OOM_ADJ" != x && echo "$SPP_OOM_ADJ" > /proc/self/oom_adj
	#$SU -l postgres -c "$PGENGINE/postmaster -p '$PGPORT' -D '$PGDATA' ${PGOPTS} &" >> "$PGLOG" 2>&1 < /dev/null
	$SU -lc "/usr/bin/nohup $SPP_WRAPPER" >> "$SPPLOG" 2>&1 &
	sleep 2
	#pid=`head -n 1 "$PGDATA/postmaster.pid" 2>/dev/null`
	pid=$!
	if [ "x$pid" != x ] ; then

	    # success "$PSQL_START"
	    success "$SPP_START"
	    touch "$lockfile"
	    echo $pid > "$pidfile"
	    echo
	else
	    # failure "$PSQL_START"
	    failure "$SPP_START"
	    echo
	    script_result=1
	fi
}

stop(){
	echo -n $"Stopping ${NAME} service: "
	if [ -e "$lockfile" ]
	then
	    # $SU -l postgres -c "$PGENGINE/pg_ctl stop -D '$PGDATA' -s -m fast" > /dev/null 2>&1 < /dev/null
	    pid=`cat $pidfile`
	    $SU -lc "/bin/kill -9 $pid"
	    ret=$? 
	    if [ $ret -eq 0 ]
	    then
		echo_success
		rm -f "$pidfile"
		rm -f "$lockfile"
	    else
		echo_failure
		script_result=1
	    fi
	else
	    # not running; per LSB standards this is "ok"
	    echo_success
	fi
	echo
}

restart(){
    stop
    start
}

condrestart(){
    [ -e "$lockfile" ] && restart || :
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
	status -p "$pidfile" swift-poetry-project
	script_result=$?
	;;
    restart)
	restart
	;;
    condrestart|try-restart)
	condrestart
	;;
    force-reload)
	restart
	;;
    *)
	echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|force-reload}"
	exit 2
esac

exit $script_result
