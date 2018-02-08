#!/bin/sh
#
#       /etc/rc.d/init.d/promvps
#
#       promvps daemon
#
# chkconfig:   2345 95 05
# description: a promvps script

### BEGIN INIT INFO
# Provides:       promvps
# Required-Start:
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start: 2 3 4 5
# Default-Stop:  0 1 6
# Short-Description: promvps
# Description: promvps
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:${PATH}
DIRECTORY=/home/phuslu/promvps
SUDO=$(test $(id -u) = 0 || echo sudo)

if [ -n "${SUDO}" ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

start() {
    test $(ulimit -n) -lt 65535 && ulimit -n 65535
    cd ${DIRECTORY}
    nohup ${DIRECTORY}/promvps -log_dir . >>promvps.log 2>&1 &
    local pid=$!
    echo -n "Starting promvps(${pid}): "
    sleep 1
    if (ps ax 2>/dev/null || ps) | grep "${pid} " >/dev/null 2>&1; then
        echo "OK"
    else
        echo "Failed"
    fi
}

stop() {
    local pid="$(pidof promvps)"
    echo -n "Stopping promvps(${pid}): "
    if pkill -x promvps; then
        echo "OK"
    else
        echo "Failed"
    fi
}

restart() {
    stop
    start
}

reload() {
    pkill -HUP -x promvps
}

usage() {
    echo "Usage: [sudo] $(basename "$0") {start|stop|reload|restart}" >&2
    exit 1
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    reload)
        reload
        ;;
    *)
        usage
        ;;
esac

exit $?

